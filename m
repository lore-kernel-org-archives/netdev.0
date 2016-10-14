From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: bug in ixgbe_atr
Date: Thu, 13 Oct 2016 20:48:31 -0700
Message-ID: <20161014034831.GC14253@oracle.com>
References: <20161014014422.GA14253@oracle.com>
 <B1C1DF2ACD01FD4881736AA51731BAB2A0DDE3@ORSMSX107.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:45548 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753497AbcJNDsm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 23:48:42 -0400
Content-Disposition: inline
In-Reply-To: <B1C1DF2ACD01FD4881736AA51731BAB2A0DDE3@ORSMSX107.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (10/14/16 02:06), Duyck, Alexander H wrote:
> > +	case ETH_P_IP:
> > +		skb_header_pointer(skb, ETH_HLEN, sizeof (struct iphdr),
> > +				   &ip_hdr);
> >  		/* access ihl as u8 to avoid unaligned access on ia64 */
> > -		hlen = (hdr.network[0] & 0x0F) << 2;
> > -		l4_proto = hdr.ipv4->protocol;
> > +		hlen = ip_hdr.ipv4.ihl << 2;
> > +		l4_proto = ip_hdr.ipv4.protocol;
> >  		break;
  :
> The problem is this will break other stuff, for example I have seen
> the ihl access actually cause problems with unaligned accesses as some
> architectures decide to pull it as a u32 and then mask it.

Yes, I noticed that u8 comment for ia64.. if that's the only issue
here, we could just reset hdr.network to &ip_hdr..

However, I suspect the above patch is probably not going to work for
the vlan case (it was just a first-pass hack)

> My advice would be to keep this simple.  Add a check to make sure we
> have room for at least skb_headlen(skb) - 40  >= hrd.raw - skb->data.

I don't parse that- the hdr union in ixgbe_atr doesnt have a ->raw
field. Can you explain?

> Messing with the protocol bits will break stuff since there is support
> for tunneling also floating around in here now.
> 
> I believe we are planning on dropping this code in favor of
> ndo_rx_flow_steer in the future.  If we do that then the whole problem
> becomes moot.

Dropping it is fine with me I guess - maybe just return, if the
skb_headlen() doesnt have enough bytes for a network header, 
i.e., skb_headlen is at least ETH_HLEN + sizeof (struct iphdr) for
ETH_P_IP, or  ETH_HLEN + sizeof (struct ipv6hdr) for ETH_P_IPV6?

--Sowmini
