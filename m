From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v4] af_mpls: fix undefined reference to
 ip6_route_output
Date: Tue, 28 Jul 2015 15:04:36 +0200
Message-ID: <1438088676.25794.19.camel@stressinduktion.org>
References: <1438065624-38229-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net,
	tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:59887 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752113AbbG1NEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 09:04:40 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 1B68220796
	for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 09:04:40 -0400 (EDT)
In-Reply-To: <1438065624-38229-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-07-27 at 23:40 -0700, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> Undefined reference to ip6_route_output and ip_route_output
> was reported with CONFIG_INET=n and CONFIG_IPV6=n.
> 
> This patch adds new CONFIG_MPLS_NEXTHOP_DEVLOOKUP
> to lookup nexthop device if user has not specified it
> in RTA_OIF attribute. Make CONFIG_MPLS_NEXTHOP_DEVLOOKUP
> depend on INET and (IPV6 || IPV6=n) because it
> uses ip6_route_output and ip_route_output.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Reported-by: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
> 
> v1 - v2: use IS_BUILTIN
> 
> v2 - v3: Use new Kconfig option that depends on (IPV6 || IPV6=n) as
> 	 suggested by Dave. Also uses IS_ERR as suggested by Thomas.
> 
> v3 - v4: Include missed case of (MPLS_ROUTING=y && IPV6=m) reported by
>          Dave.
> 
>  net/mpls/Kconfig   |    8 ++++++++
>  net/mpls/af_mpls.c |   19 ++++++++++++++++++-
>  2 files changed, 26 insertions(+), 1 deletion(-)
> 
> diff --git a/net/mpls/Kconfig b/net/mpls/Kconfig
> index 5c467ef..134764e 100644
> --- a/net/mpls/Kconfig
> +++ b/net/mpls/Kconfig
> @@ -33,4 +33,12 @@ config MPLS_IPTUNNEL
>  	---help---
>  	 mpls ip tunnel support.
>  
> +config MPLS_NEXTHOP_DEVLOOKUP
> +	bool "MPLS: nexthop oif dev lookup"
> +	depends on MPLS_ROUTING && INET && \
> +		((IPV6 && !(MPLS_ROUTING=y && IPV6=m)) || IPV6=n)
> +	---help---
> +	 This enables mpls route nexthop dev lookup when oif is not
> +	 specified by user
> +

Urks.

Can't you simply use ipv6_stub_impl.ipv6_dst_lookup with sk=NULL to do
that and don't have a run-time dependency on IPv6 at all (for the cost
of a function pointer). Maybe same for IPv4?

If builtin you can inline those calls anyway.

Bye,
Hannes
