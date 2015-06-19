From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next RFC v2 2/3] ipv4: add support for light weight
 tunnel encap attributes
Date: Fri, 19 Jun 2015 09:59:01 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1506190857520.1731@ja.home.ssi.bg>
References: <1434689355-4088-3-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ebiederm@xmission.com, rshearma@brocade.com, tgraf@suug.ch,
	davem@davemloft.net, netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:41837 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752686AbbFSG7Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jun 2015 02:59:25 -0400
In-Reply-To: <1434689355-4088-3-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 18 Jun 2015, Roopa Prabhu wrote:

> @@ -366,6 +371,7 @@ static inline size_t fib_nlmsg_size(struct fib_info *fi)
>  	payload += nla_total_size((RTAX_MAX * nla_total_size(4)));
>  
>  	if (fi->fib_nhs) {
> +		size_t nh_encapsize = 0;

	Var not in #ifdef. Any warnings with CONFIG_LWTUNNEL=n?

>  		/* Also handles the special case fib_nhs == 1 */
>  
>  		/* each nexthop is packed in an attribute */
> @@ -374,8 +380,23 @@ static inline size_t fib_nlmsg_size(struct fib_info *fi)
>  		/* may contain flow and gateway attribute */
>  		nhsize += 2 * nla_total_size(4);
>  
> +#ifdef CONFIG_LWTUNNEL
> +		/* grab encap info */
> +		for_nexthops(fi) {
> +			if (nh->nh_lwtstate) {
> +				/* RTA_ENCAP_TYPE */
> +				nh_encapsize += lwtunnel_get_encap_size(
> +						nh->nh_lwtstate);

	New labels not in #ifdef:

> +
> +err_inval:
> +	ret = -EINVAL;
> +
> +errout:
> +	return ret;
>  }

	Some other places may need changes:

- nh_comp: there is logic that decides if same fib_info
is reused from many fib nodes. There should be check
if NH matches by nh_lwtstate.

- xfrm4_fill_dst: not sure about this but some fields
are copied.

Regards

--
Julian Anastasov <ja@ssi.bg>
