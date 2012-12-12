From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCHv2 iproute2] add DOVE extensions for iproute2
Date: Wed, 12 Dec 2012 09:14:12 -0800
Message-ID: <20121212091412.12f3b028@nehalam.linuxnetplumber.net>
References: <201212121612.qBCGAimS017147@lab1.dls>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39960 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754169Ab2LLRP2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 12:15:28 -0500
In-Reply-To: <201212121612.qBCGAimS017147@lab1.dls>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2012 11:10:44 -0500
David L Stevens <dlstevens@us.ibm.com> wrote:

> 
> 	This patch adds a new flag to iproute2 for vxlan devices to enable
> DOVE features. It also adds support for L2 and L3 switch lookup miss
> netlink messages to "ip monitor".
> 
> Changes since v1:
> 	- split "dove" flag into separate feature flags:
> 		- "proxy" for ARP reduction
> 		- "rsc" for route short circuiting
> 		- "l2miss" for L2 switch miss notifications
> 		- "l3miss" for L3 switch miss notifications
> 
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
> 
> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> index 012d95a..a163702 100644
> - --- a/include/linux/if_link.h
> +++ b/include/linux/if_link.h
> @@ -283,6 +283,10 @@ enum {
>  	IFLA_VXLAN_AGEING,
>  	IFLA_VXLAN_LIMIT,
>  	IFLA_VXLAN_PORT_RANGE,
> +	IFLA_VXLAN_PROXY,
> +	IFLA_VXLAN_RSC,
> +	IFLA_VXLAN_L2MISS,
> +	IFLA_VXLAN_L3MISS,
>  	__IFLA_VXLAN_MAX
>  };
>  #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
> diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
> index ba5c4ab..f2e6bef 100644
> - --- a/ip/iplink_vxlan.c
> +++ b/ip/iplink_vxlan.c
> @@ -26,6 +26,8 @@ static void explain(void)
>  	fprintf(stderr, "Usage: ... vxlan id VNI [ group ADDR ] [ local ADDR ]\n");
>  	fprintf(stderr, "                 [ ttl TTL ] [ tos TOS ] [ dev PHYS_DEV ]\n");
>  	fprintf(stderr, "                 [ port MIN MAX ] [ [no]learning ]\n");
> +	fprintf(stderr, "                 [ [no]proxy ] [ [no]rsc ]\n");
> +	fprintf(stderr, "                 [ [no]l2miss ] [ [no]l3miss ]\n");
>  	fprintf(stderr, "\n");
>  	fprintf(stderr, "Where: VNI := 0-16777215\n");
>  	fprintf(stderr, "       ADDR := { IP_ADDRESS | any }\n");
> @@ -44,6 +46,10 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
>  	__u8 tos = 0;
>  	__u8 ttl = 0;
>  	__u8 learning = 1;
> +	__u8 proxy = 0;
> +	__u8 rsc = 0;
> +	__u8 l2miss = 0;
> +	__u8 l3miss = 0;
>  	__u8 noage = 0;
>  	__u32 age = 0;
>  	__u32 maxaddr = 0;
> @@ -123,6 +129,22 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
>  			learning = 0;
>  		} else if (!matches(*argv, "learning")) {
>  			learning = 1;
> +		} else if (!matches(*argv, "noproxy")) {
> +			proxy = 0;
> +		} else if (!matches(*argv, "proxy")) {
> +			proxy = 1;
> +		} else if (!matches(*argv, "norsc")) {
> +			rsc = 0;
> +		} else if (!matches(*argv, "rsc")) {
> +			rsc = 1;
> +		} else if (!matches(*argv, "nol2miss")) {
> +			l2miss = 0;
> +		} else if (!matches(*argv, "l2miss")) {
> +			l2miss = 1;
> +		} else if (!matches(*argv, "nol3miss")) {
> +			l3miss = 0;
> +		} else if (!matches(*argv, "l3miss")) {
> +			l3miss = 1;
>  		} else if (matches(*argv, "help") == 0) {
>  			explain();
>  			return -1;
> @@ -148,6 +170,10 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
>  	addattr8(n, 1024, IFLA_VXLAN_TTL, ttl);
>  	addattr8(n, 1024, IFLA_VXLAN_TOS, tos);
>  	addattr8(n, 1024, IFLA_VXLAN_LEARNING, learning);
> +	addattr8(n, 1024, IFLA_VXLAN_PROXY, proxy);
> +	addattr8(n, 1024, IFLA_VXLAN_RSC, rsc);
> +	addattr8(n, 1024, IFLA_VXLAN_L2MISS, l2miss);
> +	addattr8(n, 1024, IFLA_VXLAN_L3MISS, l3miss);
>  	if (noage)
>  		addattr32(n, 1024, IFLA_VXLAN_AGEING, 0);
>  	else if (age)
> @@ -213,6 +239,18 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
>  	if (tb[IFLA_VXLAN_LEARNING] &&
>  	    !rta_getattr_u8(tb[IFLA_VXLAN_LEARNING]))
>  		fputs("nolearning ", f);
> + 
> +	if (tb[IFLA_VXLAN_PROXY] && rta_getattr_u8(tb[IFLA_VXLAN_PROXY]))
> +		fputs("proxy ", f);
> + 
> +	if (tb[IFLA_VXLAN_RSC] && rta_getattr_u8(tb[IFLA_VXLAN_RSC]))
> +		fputs("rsc ", f);
> +
> +	if (tb[IFLA_VXLAN_L2MISS] && rta_getattr_u8(tb[IFLA_VXLAN_L2MISS]))
> +		fputs("l2miss ", f);
> +
> +	if (tb[IFLA_VXLAN_L3MISS] && rta_getattr_u8(tb[IFLA_VXLAN_L3MISS]))
> +		fputs("l3miss ", f);
>  	
>  	if (tb[IFLA_VXLAN_TOS] &&
>  	    (tos = rta_getattr_u8(tb[IFLA_VXLAN_TOS]))) {
> diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
> index 4b1d469..7a7cc88 100644
> - --- a/ip/ipmonitor.c
> +++ b/ip/ipmonitor.c
> @@ -67,7 +67,8 @@ int accept_msg(const struct sockaddr_nl *who,
>  		print_addrlabel(who, n, arg);
>  		return 0;
>  	}
> - -	if (n->nlmsg_type == RTM_NEWNEIGH || n->nlmsg_type == RTM_DELNEIGH) {
> +	if (n->nlmsg_type == RTM_NEWNEIGH || n->nlmsg_type == RTM_DELNEIGH ||
> +	    n->nlmsg_type == RTM_GETNEIGH) {
>  		if (prefix_banner)
>  			fprintf(fp, "[NEIGH]");
>  		print_neigh(who, n, arg);
> diff --git a/ip/ipneigh.c b/ip/ipneigh.c
> index 56e56b2..1b7600b 100644
> - --- a/ip/ipneigh.c
> +++ b/ip/ipneigh.c
> @@ -189,7 +189,8 @@ int print_neigh(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
>  	struct rtattr * tb[NDA_MAX+1];
>  	char abuf[256];
>  
> - -	if (n->nlmsg_type != RTM_NEWNEIGH && n->nlmsg_type != RTM_DELNEIGH) {
> +	if (n->nlmsg_type != RTM_NEWNEIGH && n->nlmsg_type != RTM_DELNEIGH &&
> +	    n->nlmsg_type != RTM_GETNEIGH) {
>  		fprintf(stderr, "Not RTM_NEWNEIGH: %08x %08x %08x\n",
>  			n->nlmsg_len, n->nlmsg_type, n->nlmsg_flags);
>  
> @@ -251,6 +252,8 @@ int print_neigh(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
>  
>  	if (n->nlmsg_type == RTM_DELNEIGH)
>  		fprintf(fp, "delete ");
> +	else if (n->nlmsg_type == RTM_GETNEIGH)
> +		fprintf(fp, "miss ");
>  	if (tb[NDA_DST]) {
>  		fprintf(fp, "%s ",
>  			format_host(r->ndm_family,
> 

This patch doesn't apply cleanly against the current version in iproute2 git.
Not your fault, conflicts arose from earlier patches applied. Could you fix
the conflicts and resubmit please.
