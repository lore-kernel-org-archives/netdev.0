From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [v12 PATCH 1/3] NETFILTER added flags to ipv6_find_hdr()
Date: Wed, 9 May 2012 13:01:08 +0200
Message-ID: <20120509110108.GA22776@1984>
References: <1335188128-23645-1-git-send-email-hans.schillstrom@ericsson.com>
 <1335188128-23645-2-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hans@schillstrom.com
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51603 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751076Ab2EILBM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 07:01:12 -0400
Content-Disposition: inline
In-Reply-To: <1335188128-23645-2-git-send-email-hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have applied this with minor changes.

BTW, please use the following patch tagging next time, I'll save time:

netfilter: ip6_tables: add flags parameter to ipv6_find_hdr()

note the initial netfilter, then ip6_tables, then the description.

This is useful for grepping.

More minor glitches:

On Mon, Apr 23, 2012 at 03:35:26PM +0200, Hans Schillstrom wrote:
> Two new flags to ipv6_find_hdr,
> One that tells us that this is a fragment.
> One that stops at AH if any i.e. treat it like a transport header.
> i.e. make handling of ESP and AH the same.
> Param offset can now point to an inner icmp ipv5 header.
> 
> Version 3:
>     offset param into ipv6_find_hdr set to zero.
> 
> Version 2:
>     wrapper removed and changes made at every call.
> 
> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> ---
>  include/linux/netfilter_ipv6/ip6_tables.h |   12 +++++++++-
>  net/ipv6/netfilter/ip6_tables.c           |   35 ++++++++++++++++++++++++----
>  net/ipv6/netfilter/ip6t_ah.c              |    4 +-
>  net/ipv6/netfilter/ip6t_frag.c            |    4 +-
>  net/ipv6/netfilter/ip6t_hbh.c             |    4 +-
>  net/ipv6/netfilter/ip6t_rt.c              |    4 +-
>  net/netfilter/xt_TPROXY.c                 |    4 +-
>  net/netfilter/xt_socket.c                 |    4 +-
>  8 files changed, 53 insertions(+), 18 deletions(-)
> 
> diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
> index 1bc898b..d96a39d 100644
> --- a/include/linux/netfilter_ipv6/ip6_tables.h
> +++ b/include/linux/netfilter_ipv6/ip6_tables.h
> @@ -287,6 +287,7 @@ extern unsigned int ip6t_do_table(struct sk_buff *skb,
>  				  struct xt_table *table);
>  
>  /* Check for an extension */
> +

removed this extra line.

>  static inline int
>  ip6t_ext_hdr(u8 nexthdr)
>  {	return (nexthdr == IPPROTO_HOPOPTS) ||
> @@ -298,9 +299,18 @@ ip6t_ext_hdr(u8 nexthdr)
>  	       (nexthdr == IPPROTO_DSTOPTS);
>  }
>  
> +

removed double extra line.

> +extern int ip6t_ext_hdr(u8 nexthdr);
> +enum {
> +	IP6T_FH_FRAG,
> +	IP6T_FH_AUTH,

removed these two above, the are not used anywhere in the code.

> +	IP6T_FH_F_FRAG = 1 << IP6T_FH_FRAG,
> +	IP6T_FH_F_AUTH = 1 << IP6T_FH_AUTH,
> +};
> +
>  /* find specified header and get offset to it */
>  extern int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
> -			 int target, unsigned short *fragoff);
> +			 int target, unsigned short *fragoff, int *fragflg);
>  
>  #ifdef CONFIG_COMPAT
>  #include <net/compat.h>
> diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
> index d4e350f..1f18662 100644
> --- a/net/ipv6/netfilter/ip6_tables.c
> +++ b/net/ipv6/netfilter/ip6_tables.c
> @@ -133,7 +133,7 @@ ip6_packet_match(const struct sk_buff *skb,
>  		int protohdr;
>  		unsigned short _frag_off;
>  
> -		protohdr = ipv6_find_hdr(skb, protoff, -1, &_frag_off);
> +		protohdr = ipv6_find_hdr(skb, protoff, -1, &_frag_off, NULL);
>  		if (protohdr < 0) {
>  			if (_frag_off == 0)
>  				*hotdrop = true;
> @@ -362,6 +362,7 @@ ip6t_do_table(struct sk_buff *skb,
>  		const struct xt_entry_match *ematch;
>  
>  		IP_NF_ASSERT(e);
> +		acpar.thoff = 0;
>  		if (!ip6_packet_match(skb, indev, outdev, &e->ipv6,
>  		    &acpar.thoff, &acpar.fragoff, &acpar.hotdrop)) {
>   no_match:
> @@ -2277,6 +2278,8 @@ static void __exit ip6_tables_fini(void)
>   * find the offset to specified header or the protocol number of last header
>   * if target < 0. "last header" is transport protocol header, ESP, or
>   * "No next header".
> + * Note, *offset is used as input param. an if != 0
> + * it must be an offset to an inner ipv6 header ex. icmp error
>   *
>   * If target header is found, its offset is set in *offset and return protocol
>   * number. Otherwise, return -1.
> @@ -2289,17 +2292,34 @@ static void __exit ip6_tables_fini(void)
>   * *offset is meaningless and fragment offset is stored in *fragoff if fragoff
>   * isn't NULL.
>   *
> + * if flags != NULL AND
> + *    it's a fragment the frag flag "IP6T_FH_F_FRAG" will be set
> + *    it's an AH header and IP6T_FH_F_AUTH is set and target < 0
> + *      stop at AH (i.e. treat is as a transport header)

I've cleaned up these comments. The format does not look very orthodox
(I'm not blaming your English, but the way the text is organized).
