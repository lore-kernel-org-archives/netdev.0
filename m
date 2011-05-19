From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ip_vs_ftp causing ip_vs oops on module load.
Date: Thu, 19 May 2011 11:55:07 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1105191139360.2171@ja.ssi.bg>
References: <20110518201915.GB20475@redhat.com> <20110519011045.GF16688@verge.net.au> <20110519032611.GG16688@verge.net.au> <201105190952.49006.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Simon Horman <horms@verge.net.au>, Dave Jones <davej@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wensong Zhang <wensong@linuxvirtualserver.org>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:40578 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756848Ab1ESIxY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2011 04:53:24 -0400
In-Reply-To: <201105190952.49006.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 19 May 2011, Hans Schillstrom wrote:

> I can reproduce the source of the problem,
> use multiple netns and then unload the ftp module...
> i.e. same list head used in multiple netns
> 
> This brings up a question:
> - How should ftp be handled in a netns ? 
> You might want to have it in one netns but not in another,
> this requires changes to ipvsadm
> 
> A way of doing it could be a disable switch like --noftp [port,port]
> i.e. do not break old apps.
> 
> Any other ideas ?
> 
> This patch solves the root problem, I'm not sure if this is the way to go
> or if we should split the ip_vs_app struct ?

	This patch is a fast fix but may be it is too late for it,
after 2.6.39 is out. It seems we overlooked the apps when
migrating to netns. I think, the apps do not need to be pernet.
If one day application needs pernet context we can add such
fields in the ipvs structure.

	While the protocols have controls that manipulate pernet
timeouts, the apps do not have such controls about app->timeouts.
May be we can remove app->timeouts to avoid confusion because
it was never implemented in user space. May be instead of this
fix we should restore the global ip_vs_app_list and all things in
ip_vs_app.c and ip_vs_ftp.c as before the netns changes?

> If it's the way to go I can send it as a proper formated patch ...
> (after some testing)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 4fff432..481f856 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -797,7 +797,8 @@ struct netns_ipvs {
>  	struct list_head	rs_table[IP_VS_RTAB_SIZE];
>  	/* ip_vs_app */
>  	struct list_head	app_list;
> -
> +	/* ip_vs_ftp */
> +	struct ip_vs_app	*ftp_app;
>  	/* ip_vs_proto */
>  	#define IP_VS_PROTO_TAB_SIZE	32	/* must be power of 2 */
>  	struct ip_vs_proto_data *proto_data_table[IP_VS_PROTO_TAB_SIZE];
> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> index 6b5dd6d..17afb09 100644
> --- a/net/netfilter/ipvs/ip_vs_ftp.c
> +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> @@ -411,25 +411,36 @@ static struct ip_vs_app ip_vs_ftp = {
>  static int __net_init __ip_vs_ftp_init(struct net *net)
>  {
>  	int i, ret;
> -	struct ip_vs_app *app = &ip_vs_ftp;
> +	struct ip_vs_app *app;
> +	struct netns_ipvs *ipvs = net_ipvs(net);
> +
> +	app = kmemdup(&ip_vs_ftp, sizeof(struct ip_vs_app), GFP_KERNEL);
> +	if (!app)
> +		return -ENOMEM;
> +	INIT_LIST_HEAD(&app->a_list);
> +	INIT_LIST_HEAD(&app->incs_list);
> +	INIT_LIST_HEAD(&app->p_list);
> +	ipvs->ftp_app = app;
>  
>  	ret = register_ip_vs_app(net, app);
>  	if (ret)
> -		return ret;
> +		goto err_exit;
>  
>  	for (i=0; i<IP_VS_APP_MAX_PORTS; i++) {
>  		if (!ports[i])
>  			continue;
>  		ret = register_ip_vs_app_inc(net, app, app->protocol, ports[i]);
>  		if (ret)
> -			break;
> +			goto err_unreg;
>  		pr_info("%s: loaded support on port[%d] = %d\n",
>  			app->name, i, ports[i]);
>  	}
> +	return 0;
>  
> -	if (ret)
> -		unregister_ip_vs_app(net, app);
> -
> +err_unreg:
> +	unregister_ip_vs_app(net, app);
> +err_exit:
> +	kfree(ipvs->ftp_app);
>  	return ret;
>  }
>  /*
> @@ -437,9 +448,7 @@ static int __net_init __ip_vs_ftp_init(struct net *net)
>   */
>  static void __ip_vs_ftp_exit(struct net *net)
>  {
> -	struct ip_vs_app *app = &ip_vs_ftp;
> -
> -	unregister_ip_vs_app(net, app);
> +	unregister_ip_vs_app(net, net_ipvs(net)->ftp_app);
>  }
>  
>  static struct pernet_operations ip_vs_ftp_ops = {

Regards

--
Julian Anastasov <ja@ssi.bg>
