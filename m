From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next 1/2] team: use rcu_access_pointer to access
 RCU pointer by writer
Date: Wed, 20 Jun 2012 18:01:44 +0200
Message-ID: <1340208104.4604.1247.camel@edumazet-glaptop>
References: <1340206321-5986-1-git-send-email-jpirko@redhat.com>
	 <1340206321-5986-2-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jbrouer@redhat.com,
	paulmck@linux.vnet.ibm.com, wfg@linux.intel.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:49207 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756961Ab2FTQBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 12:01:49 -0400
Received: by bkcji2 with SMTP id ji2so6336282bkc.19
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2012 09:01:48 -0700 (PDT)
In-Reply-To: <1340206321-5986-2-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-20 at 17:32 +0200, Jiri Pirko wrote:
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> ---
>  drivers/net/team/team_mode_activebackup.c |    7 +++++--
>  drivers/net/team/team_mode_loadbalance.c  |    8 +++++---
>  2 files changed, 10 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/team/team_mode_activebackup.c b/drivers/net/team/team_mode_activebackup.c
> index 2fe02a8..c9e7621 100644
> --- a/drivers/net/team/team_mode_activebackup.c
> +++ b/drivers/net/team/team_mode_activebackup.c
> @@ -61,8 +61,11 @@ static void ab_port_leave(struct team *team, struct team_port *port)
>  
>  static int ab_active_port_get(struct team *team, struct team_gsetter_ctx *ctx)
>  {
> -	if (ab_priv(team)->active_port)
> -		ctx->data.u32_val = ab_priv(team)->active_port->dev->ifindex;
> +	struct team_port *active_port;
> +
> +	active_port = rcu_access_pointer(ab_priv(team)->active_port);

This is not the correct fix.

You cant safely dereference active_port if you got it from
rcu_access_pointer()

You should use rcu_dereference() of rcu_dereference_protected() or
rcu_dereference_bh() or similar variant, depending on the context.

> +	if (active_port)
> +		ctx->data.u32_val = active_port->dev->ifindex;
>  	else
>  		ctx->data.u32_val = 0;
>  	return 0;
> diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
> index 45cc095..b4475a5 100644
> --- a/drivers/net/team/team_mode_loadbalance.c
> +++ b/drivers/net/team/team_mode_loadbalance.c
> @@ -96,7 +96,7 @@ static void lb_tx_hash_to_port_mapping_null_port(struct team *team,
>  		struct lb_port_mapping *pm;
>  
>  		pm = &lb_priv->ex->tx_hash_to_port_mapping[i];
> -		if (pm->port == port) {
> +		if (rcu_access_pointer(pm->port) == port) {

This one is OK

>  			rcu_assign_pointer(pm->port, NULL);

I dont understand why you submit two patches...

>  			team_option_inst_set_change(pm->opt_inst_info);
>  			changed = true;
> @@ -292,7 +292,7 @@ static int lb_bpf_func_set(struct team *team, struct team_gsetter_ctx *ctx)
>  	if (lb_priv->ex->orig_fprog) {
>  		/* Clear old filter data */
>  		__fprog_destroy(lb_priv->ex->orig_fprog);
> -		sk_unattached_filter_destroy(lb_priv->fp);
> +		sk_unattached_filter_destroy(rcu_access_pointer(lb_priv->fp));
>  	}
