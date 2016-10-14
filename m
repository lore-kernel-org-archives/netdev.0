From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: bug in ixgbe_atr
Date: Fri, 14 Oct 2016 02:06:38 +0000
Message-ID: <B1C1DF2ACD01FD4881736AA51731BAB2A0DDE3@ORSMSX107.amr.corp.intel.com>
References: <20161014014422.GA14253@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:59944 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756369AbcJNCLt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Oct 2016 22:11:49 -0400
In-Reply-To: <20161014014422.GA14253@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Sowmini Varadhan [mailto:sowmini.varadhan@oracle.com]
> Sent: Thursday, October 13, 2016 6:44 PM
> To: Duyck, Alexander H <alexander.h.duyck@intel.com>;
> netdev@vger.kernel.org
> Subject: bug in ixgbe_atr
> 
> When I was playing around with TPACKET_V2, I think I ran into a bug in
> ixgbe_atr(): if I get here with an sk_buff that has, e.g., just 14 bytes in the
> header, then the skb_network_header is invalid. I found my kernel sometimes
> wandering off into  ipv6_find_hdr() in an attempt to get the l4_proto, and then
> complaining that "IPv6 header not found\n"
> (this was an ipv4 packet).
> 
> I think we want to use skb_header_pointer in ixgbe_atr to get the network
> header itself.. I tried the patch below, and it works for simple (non-vlan, basic)
> ethernet header, but probably needs more refinement to work for more
> complex encapsulations?
> 
> And other drivers may need a similar fix too, I've not checked yet.
> 
> --Sowmini
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index a244d9a..be453c6 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -7627,6 +7627,10 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
>  		struct iphdr *ipv4;
>  		struct ipv6hdr *ipv6;
>  	} hdr;
> +	union {
> +		struct iphdr ipv4;
> +		struct ipv6hdr ipv6;
> +	} ip_hdr;
>  	struct tcphdr *th;
>  	unsigned int hlen;
>  	struct sk_buff *skb;
> @@ -7667,13 +7671,15 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
>  	}
> 
>  	/* Currently only IPv4/IPv6 with TCP is supported */
> -	switch (hdr.ipv4->version) {
> -	case IPVERSION:
> +	switch (ntohs(first->protocol)) {
> +	case ETH_P_IP:
> +		skb_header_pointer(skb, ETH_HLEN, sizeof (struct iphdr),
> +				   &ip_hdr);
>  		/* access ihl as u8 to avoid unaligned access on ia64 */
> -		hlen = (hdr.network[0] & 0x0F) << 2;
> -		l4_proto = hdr.ipv4->protocol;
> +		hlen = ip_hdr.ipv4.ihl << 2;
> +		l4_proto = ip_hdr.ipv4.protocol;
>  		break;
> -	case 6:
> +	case ETH_P_IPV6:
>  		hlen = hdr.network - skb->data;
>  		l4_proto = ipv6_find_hdr(skb, &hlen, IPPROTO_TCP, NULL,
> NULL);
>  		hlen -= hdr.network - skb->data;

The problem is this will break other stuff, for example I have seen the ihl access actually cause problems with unaligned accesses as some architectures decide to pull it as a u32 and then mask it.

My advice would be to keep this simple.  Add a check to make sure we have room for at least skb_headlen(skb) - 40  >= hrd.raw - skb->data.  Messing with the protocol bits will break stuff since there is support for tunneling also floating around in here now.

I believe we are planning on dropping this code in favor of ndo_rx_flow_steer in the future.  If we do that then the whole problem becomes moot.

- Alex
