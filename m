From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] drop_monitor: Make updating data->skb smp safe
Date: Thu, 26 Apr 2012 21:00:09 +0200
Message-ID: <1335466809.2775.59.camel@edumazet-glaptop>
References: <1335466022-32661-1-git-send-email-nhorman@tuxdriver.com>
	 <1335466022-32661-3-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:40990 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716Ab2DZTAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 15:00:14 -0400
Received: by eaaq12 with SMTP id q12so434369eaa.19
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2012 12:00:13 -0700 (PDT)
In-Reply-To: <1335466022-32661-3-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-26 at 14:47 -0400, Neil Horman wrote:
> Eric Dumazet pointed out to me that the drop_monitor protocol has some holes in
> its smp protections.  Specifically, its possible to replace data->skb while its
> being written.  This patch corrects that by making data->skb and rcu protected
> variable.  That will prevent it from being overwritten while a tracepoint is
> modifying it.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: David Miller <davem@davemloft.net>
> ---
>  net/core/drop_monitor.c |   43 ++++++++++++++++++++++++++++++++-----------
>  1 files changed, 32 insertions(+), 11 deletions(-)
> 

Hi Neil

I believe more work is needed on this patch

> diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
> index 04ce1dd..852e36b 100644
> --- a/net/core/drop_monitor.c
> +++ b/net/core/drop_monitor.c
> @@ -46,7 +46,7 @@ static DEFINE_MUTEX(trace_state_lock);
>  
>  struct per_cpu_dm_data {
>  	struct work_struct dm_alert_work;
> -	struct sk_buff *skb;
> +	struct sk_buff __rcu *skb;
>  	atomic_t dm_hit_count;
>  	struct timer_list send_timer;
>  };
> @@ -79,29 +79,41 @@ static void reset_per_cpu_data(struct per_cpu_dm_data *data)
>  	size_t al;
>  	struct net_dm_alert_msg *msg;
>  	struct nlattr *nla;
> +	struct sk_buff *skb;
>  
>  	al = sizeof(struct net_dm_alert_msg);
>  	al += dm_hit_limit * sizeof(struct net_dm_drop_point);
>  	al += sizeof(struct nlattr);
>  
> -	data->skb = genlmsg_new(al, GFP_KERNEL);
> -	genlmsg_put(data->skb, 0, 0, &net_drop_monitor_family,
> +	skb = genlmsg_new(al, GFP_KERNEL);

skb can be NULL here...

> +	genlmsg_put(skb, 0, 0, &net_drop_monitor_family,
>  			0, NET_DM_CMD_ALERT);
> -	nla = nla_reserve(data->skb, NLA_UNSPEC, sizeof(struct net_dm_alert_msg));
> +	nla = nla_reserve(skb, NLA_UNSPEC, sizeof(struct net_dm_alert_msg));
>  	msg = nla_data(nla);
>  	memset(msg, 0, al);
> +
> +	/*
> +	 * Don't need to lock this, since we are guaranteed to only
> +	 * run this on a single cpu at a time
> +	 */
> +	rcu_assign_pointer(data->skb, skb);
> +
> +	synchronize_rcu();
> +
>  	atomic_set(&data->dm_hit_count, dm_hit_limit);
>  }
>  
>  static void send_dm_alert(struct work_struct *unused)
>  {
>  	struct sk_buff *skb;
> -	struct per_cpu_dm_data *data = &__get_cpu_var(dm_cpu_data);
> +	struct per_cpu_dm_data *data = &get_cpu_var(dm_cpu_data);
>  
>  	/*
>  	 * Grab the skb we're about to send
>  	 */
> -	skb = data->skb;
> +	rcu_read_lock();
> +	skb = rcu_dereference(data->skb);

This protects nothing ...

> +	rcu_read_unlock();
>  



>  	/*
>  	 * Replace it with a new one
> @@ -113,6 +125,7 @@ static void send_dm_alert(struct work_struct *unused)
>  	 */
>  	genlmsg_multicast(skb, 0, NET_DM_GRP_ALERT, GFP_KERNEL);
>  
> +	put_cpu_var(dm_cpu_data);
>  }
>  
>  /*
> @@ -123,9 +136,11 @@ static void send_dm_alert(struct work_struct *unused)
>   */
>  static void sched_send_work(unsigned long unused)
>  {
> -	struct per_cpu_dm_data *data =  &__get_cpu_var(dm_cpu_data);
> +	struct per_cpu_dm_data *data =  &get_cpu_var(dm_cpu_data);
> +
> +	schedule_work_on(smp_processor_id(), &data->dm_alert_work);
>  
> -	schedule_work(&data->dm_alert_work);
> +	put_cpu_var(dm_cpu_data);
>  }
>  
>  static void trace_drop_common(struct sk_buff *skb, void *location)
> @@ -134,9 +149,13 @@ static void trace_drop_common(struct sk_buff *skb, void *location)
>  	struct nlmsghdr *nlh;
>  	struct nlattr *nla;
>  	int i;
> -	struct per_cpu_dm_data *data = &__get_cpu_var(dm_cpu_data);
> +	struct sk_buff *dskb;
> +	struct per_cpu_dm_data *data = &get_cpu_var(dm_cpu_data);
>  
> 
> +	rcu_read_lock();
> +	dskb = rcu_dereference(data->skb);
> +

	dskb can be NULL here

>  	if (!atomic_add_unless(&data->dm_hit_count, -1, 0)) {
>  		/*
>  		 * we're already at zero, discard this hit
> @@ -144,7 +163,7 @@ static void trace_drop_common(struct sk_buff *skb, void *location)
>  		goto out;
>  	}
>  
> -	nlh = (struct nlmsghdr *)data->skb->data;
> +	nlh = (struct nlmsghdr *)dskb->data;
>  	nla = genlmsg_data(nlmsg_data(nlh));
>  	msg = nla_data(nla);
>  	for (i = 0; i < msg->entries; i++) {
> @@ -158,7 +177,7 @@ static void trace_drop_common(struct sk_buff *skb, void *location)
>  	/*
>  	 * We need to create a new entry
>  	 */
> -	__nla_reserve_nohdr(data->skb, sizeof(struct net_dm_drop_point));
> +	__nla_reserve_nohdr(dskb, sizeof(struct net_dm_drop_point));
>  	nla->nla_len += NLA_ALIGN(sizeof(struct net_dm_drop_point));
>  	memcpy(msg->points[msg->entries].pc, &location, sizeof(void *));
>  	msg->points[msg->entries].count = 1;
> @@ -170,6 +189,8 @@ static void trace_drop_common(struct sk_buff *skb, void *location)
>  	}
>  
>  out:
> +	rcu_read_unlock();
> +	put_cpu_var(dm_cpu_data);
>  	return;
>  }
>  

Thanks
