From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: bug in ixgbe_atr
Date: Fri, 14 Oct 2016 16:09:54 +0000
Message-ID: <B1C1DF2ACD01FD4881736AA51731BAB2A0E025@ORSMSX107.amr.corp.intel.com>
References: <20161014014422.GA14253@oracle.com>
 <B1C1DF2ACD01FD4881736AA51731BAB2A0DDE3@ORSMSX107.amr.corp.intel.com>
 <20161014034831.GC14253@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:3216 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754536AbcJNQKv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Oct 2016 12:10:51 -0400
In-Reply-To: <20161014034831.GC14253@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Sowmini Varadhan [mailto:sowmini.varadhan@oracle.com]
> Sent: Thursday, October 13, 2016 8:49 PM
> To: Duyck, Alexander H <alexander.h.duyck@intel.com>
> Cc: netdev@vger.kernel.org
> Subject: Re: bug in ixgbe_atr
> 
> On (10/14/16 02:06), Duyck, Alexander H wrote:
> > > +	case ETH_P_IP:
> > > +		skb_header_pointer(skb, ETH_HLEN, sizeof (struct iphdr),
> > > +				   &ip_hdr);
> > >  		/* access ihl as u8 to avoid unaligned access on ia64 */
> > > -		hlen = (hdr.network[0] & 0x0F) << 2;
> > > -		l4_proto = hdr.ipv4->protocol;
> > > +		hlen = ip_hdr.ipv4.ihl << 2;
> > > +		l4_proto = ip_hdr.ipv4.protocol;
> > >  		break;
>   :
> > The problem is this will break other stuff, for example I have seen
> > the ihl access actually cause problems with unaligned accesses as some
> > architectures decide to pull it as a u32 and then mask it.
> 
> Yes, I noticed that u8 comment for ia64.. if that's the only issue here, we could
> just reset hdr.network to &ip_hdr..
> 
> However, I suspect the above patch is probably not going to work for the vlan
> case (it was just a first-pass hack)

I kind of figured that.  Ideally we only wat to pick out the pieces we need.  I would prefer to avoid skb_header_pointer if possible since we only need a few parts of the header and don't really need to copy the whole thing.

> > My advice would be to keep this simple.  Add a check to make sure we
> > have room for at least skb_headlen(skb) - 40  >= hrd.raw - skb->data.
> 
> I don't parse that- the hdr union in ixgbe_atr doesnt have a ->raw field. Can you
> explain?

Sorry I was thinking of a different piece of code.  In the case of the atr code it would be hdr.network, not hdr.raw.  Basically the thought was to validate that there is enough data in skb_headlen() that we can verify that from where the network header should be we have at least 40 bytes of data as that would be the minimum needed for a TCP header and an IPv4 header, or just an IPv6 header.  We would probably need a separate follow-up for the TCP header after we validate network header.

> > Messing with the protocol bits will break stuff since there is support
> > for tunneling also floating around in here now.
> >
> > I believe we are planning on dropping this code in favor of
> > ndo_rx_flow_steer in the future.  If we do that then the whole problem
> > becomes moot.
> 
> Dropping it is fine with me I guess - maybe just return, if the
> skb_headlen() doesnt have enough bytes for a network header, i.e., skb_headlen
> is at least ETH_HLEN + sizeof (struct iphdr) for ETH_P_IP, or  ETH_HLEN + sizeof
> (struct ipv6hdr) for ETH_P_IPV6?
> 
> --Sowmini

Right that is kind of what I was thinking.  If we validate that we have at least 40 before inspecting the network header, and at least 20 before we validate the TCP header that would work for me.

- Alex
