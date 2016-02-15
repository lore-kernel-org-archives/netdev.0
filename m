From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 1/3] lwtunnel: autoload of lwt modules
Date: Mon, 15 Feb 2016 15:33:18 -0600
Message-ID: <878u2l7j6p.fsf@x220.int.ebiederm.org>
References: <1455550923-23673-1-git-send-email-rshearma@brocade.com>
	<1455550923-23673-2-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Tom Herbert" <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
	Jiri Benc <jbenc@redhat.com>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:57471 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752444AbcBOVms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 16:42:48 -0500
In-Reply-To: <1455550923-23673-2-git-send-email-rshearma@brocade.com> (Robert
	Shearman's message of "Mon, 15 Feb 2016 15:42:01 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> The lwt implementations using net devices can autoload using the
> existing mechanism using IFLA_INFO_KIND. However, there's no mechanism
> that lwt modules not using net devices can use.
>
> Therefore, add the ability to autoload modules registering lwt
> operations for lwt implementations not using a net device so that
> users don't have to manually load the modules.
>
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
>  include/net/lwtunnel.h |  4 +++-
>  net/core/lwtunnel.c    | 32 ++++++++++++++++++++++++++++++++
>  2 files changed, 35 insertions(+), 1 deletion(-)
>
> diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
> index 66350ce3e955..e9f116e29c22 100644
> --- a/include/net/lwtunnel.h
> +++ b/include/net/lwtunnel.h
> @@ -170,6 +170,8 @@ static inline int lwtunnel_input(struct sk_buff *skb)
>  	return -EOPNOTSUPP;
>  }
>  
> -#endif
> +#endif /* CONFIG_LWTUNNEL */
> +
> +#define MODULE_ALIAS_RTNL_LWT(encap_type) MODULE_ALIAS("rtnl-lwt-" __stringify(encap_type))
>  
>  #endif /* __NET_LWTUNNEL_H */
> diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
> index 299cfc24d888..8ef5e5cec03e 100644
> --- a/net/core/lwtunnel.c
> +++ b/net/core/lwtunnel.c
> @@ -27,6 +27,30 @@
>  #include <net/rtnetlink.h>
>  #include <net/ip6_fib.h>
>  
> +#ifdef CONFIG_MODULES
> +
> +static const char *lwtunnel_encap_str(enum lwtunnel_encap_types encap_type)
> +{
> +	switch (encap_type) {
> +	case LWTUNNEL_ENCAP_MPLS:
> +		return "LWTUNNEL_ENCAP_MPLS";
> +	case LWTUNNEL_ENCAP_IP:
> +		return "LWTUNNEL_ENCAP_IP";
> +	case LWTUNNEL_ENCAP_ILA:
> +		return "LWTUNNEL_ENCAP_ILA";
> +	case LWTUNNEL_ENCAP_IP6:
> +		return "LWTUNNEL_ENCAP_IP6";
> +	case LWTUNNEL_ENCAP_NONE:
> +	case __LWTUNNEL_ENCAP_MAX:
> +		/* should not have got here */
> +		break;
> +	}
> +	WARN_ON(1);
> +	return "LWTUNNEL_ENCAP_NONE";
> +}
> +
> +#endif /* CONFIG_MODULES */
> +
>  struct lwtunnel_state *lwtunnel_state_alloc(int encap_len)
>  {
>  	struct lwtunnel_state *lws;
> @@ -85,6 +109,14 @@ int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
>  	ret = -EOPNOTSUPP;
>  	rcu_read_lock();
>  	ops = rcu_dereference(lwtun_encaps[encap_type]);
> +#ifdef CONFIG_MODULES
> +	if (!ops) {
> +		rcu_read_unlock();
> +		request_module("rtnl-lwt-%s", lwtunnel_encap_str(encap_type));
> +		rcu_read_lock();
> +		ops = rcu_dereference(lwtun_encaps[encap_type]);
> +	}
> +#endif
>  	if (likely(ops && ops->build_state))
>  		ret = ops->build_state(dev, encap, family, cfg, lws);
>  	rcu_read_unlock();

My memory is fuzzy on how this is done elsewhere but this looks like it
needs a capability check to ensure that non-root user's can't trigger
this.

It tends to be problematic if a non-root user can trigger an autoload of
a known-buggy module.  With a combination of user namespaces and network
namespaces unprivileged users can cause just about every corner of the
network stack to be exercised.

Eric
