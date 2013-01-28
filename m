From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Patch net-next] pktgen: use the net namespace of current process instead of init_net
Date: Sun, 27 Jan 2013 18:48:00 -0800
Message-ID: <87mwvu10rj.fsf@xmission.com>
References: <1359340387-18004-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:38155 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886Ab3A1CsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 21:48:09 -0500
In-Reply-To: <1359340387-18004-1-git-send-email-amwang@redhat.com> (Cong
	Wang's message of "Mon, 28 Jan 2013 10:33:07 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <amwang@redhat.com> writes:

> From: Cong Wang <amwang@redhat.com>
>
> Use the net namespace of the current process loading
> pktgen module.

Why not add proper support for multiple network namespaces?

It looks like the proc files could be created in each network namespace
and be controlled from there.

Your patch below looks like it could have some unintended effects
if pktgen was loaded automatically or compiled into the kernel.

Eric


> Cc: Eric W. Biederman <ebiederm@xmission.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
>
> ---
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index b29dacf..db1f444 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -440,6 +440,7 @@ static int pg_count_d __read_mostly = 1000;
>  static int pg_delay_d __read_mostly;
>  static int pg_clone_skb_d  __read_mostly;
>  static int debug  __read_mostly;
> +static struct net *pktgen_net __read_mostly;
>  
>  static DEFINE_MUTEX(pktgen_thread_lock);
>  static LIST_HEAD(pktgen_threads);
> @@ -1910,7 +1911,7 @@ static int pktgen_device_event(struct notifier_block *unused,
>  {
>  	struct net_device *dev = ptr;
>  
> -	if (!net_eq(dev_net(dev), &init_net) || pktgen_exiting)
> +	if (!net_eq(dev_net(dev), pktgen_net) || pktgen_exiting)
>  		return NOTIFY_DONE;
>  
>  	/* It is OK that we do not hold the group lock right now,
> @@ -1944,7 +1945,7 @@ static struct net_device *pktgen_dev_get_by_name(struct pktgen_dev *pkt_dev,
>  	}
>  	b[i] = 0;
>  
> -	return dev_get_by_name(&init_net, b);
> +	return dev_get_by_name(pktgen_net, b);
>  }
>  
>  
> @@ -2205,7 +2206,7 @@ static void get_ipsec_sa(struct pktgen_dev *pkt_dev, int flow)
>  	struct xfrm_state *x = pkt_dev->flows[flow].x;
>  	if (!x) {
>  		/*slow path: we dont already have xfrm_state*/
> -		x = xfrm_stateonly_find(&init_net, DUMMY_MARK,
> +		x = xfrm_stateonly_find(pktgen_net, DUMMY_MARK,
>  					(xfrm_address_t *)&pkt_dev->cur_daddr,
>  					(xfrm_address_t *)&pkt_dev->cur_saddr,
>  					AF_INET,
> @@ -3600,7 +3601,8 @@ static int __init pg_init(void)
>  
>  	pr_info("%s", version);
>  
> -	pg_proc_dir = proc_mkdir(PG_PROC_DIR, init_net.proc_net);
> +	pktgen_net = current->nsproxy->net_ns;
> +	pg_proc_dir = proc_mkdir(PG_PROC_DIR, pktgen_net->proc_net);
>  	if (!pg_proc_dir)
>  		return -ENODEV;
>  
> @@ -3634,7 +3636,7 @@ static int __init pg_init(void)
>  	unregister_netdevice_notifier(&pktgen_notifier_block);
>  	remove_proc_entry(PGCTRL, pg_proc_dir);
>   remove_dir:
> -	proc_net_remove(&init_net, PG_PROC_DIR);
> +	proc_net_remove(pktgen_net, PG_PROC_DIR);
>  	return ret;
>  }
>  
