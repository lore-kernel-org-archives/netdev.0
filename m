From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 1/3] lwtunnel: autoload of lwt modules
Date: Mon, 15 Feb 2016 17:02:32 +0100
Message-ID: <20160215170232.5f73b111@griffin>
References: <1455550923-23673-1-git-send-email-rshearma@brocade.com>
	<1455550923-23673-2-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Tom Herbert" <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Robert Shearman <rshearma@Brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36835 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751177AbcBOQCh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2016 11:02:37 -0500
In-Reply-To: <1455550923-23673-2-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Feb 2016 15:42:01 +0000, Robert Shearman wrote:
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

Why the repeating of "lwt"/"LWTUNNEL" and the unnecessary "ENCAP"?
Wouldn't be lwtunnel_encap_str returning just "MPLS" or "ILA" enough?
I don't have any strong preference here, it just looks weird to me.
Maybe there's a reason.

Also, this doesn't affect IP lwtunnels, i.e. LWTUNNEL_ENCAP_IP and
LWTUNNEL_ENCAP_IP6. Should we just return NULL from lwtunnel_encap_str
in such cases (plus unknown encap_type) and WARN on the NULL here?

 Jiri

-- 
Jiri Benc
