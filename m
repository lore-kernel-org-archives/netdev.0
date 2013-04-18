From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v3 1/1] net: fec: Enable imx6 enet checksum
 acceleration.
Date: Thu, 18 Apr 2013 18:12:50 +0100
Message-ID: <1366305170.2735.40.camel@bwh-desktop.uk.solarflarecom.com>
References: <Jim Baxter <jim_baxter@mentor.com>
	   <1366229278-7528-1-git-send-email-jim_baxter@mentor.com>
	  <1366234670.3205.38.camel@edumazet-glaptop> <516FEBD3.8000803@mentor.com>
	 <1366301796.2735.18.camel@bwh-desktop.uk.solarflarecom.com>
	 <5170288B.4080008@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>, <netdev@vger.kernel.org>,
	Fabio Estevam <festevam@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:26038 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966669Ab3DRRMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 13:12:54 -0400
In-Reply-To: <5170288B.4080008@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-18 at 18:08 +0100, Jim Baxter wrote:
> On 18/04/13 17:16, Ben Hutchings wrote:
> > On Thu, 2013-04-18 at 13:49 +0100, Jim Baxter wrote:
> >> On 17/04/13 22:37, Eric Dumazet wrote:
> >>> On Wed, 2013-04-17 at 21:07 +0100, Jim Baxter wrote:
> >>>
> >>>> +			skb_set_transport_header(skb,
> >>>> +					ETH_HLEN + ip_hdrlen(skb));
> >>>> +			udp_hdr(skb)->check = 0;
> >>>> +			break;
> >>>> +		case IPPROTO_TCP:
> >>>> +			hdr_len = (ETH_HLEN +
> >>>> +					(ip_hdr(skb)->ihl << 2) +
> >>>> +					sizeof(struct tcphdr));
> >>>> +			if (skb->len < hdr_len)
> >>>> +				return;
> >>>> +			skb_cow_head(skb, hdr_len);
> >>>
> >>> same here
> >> Do I need to call skb_cow_head here, I am not changing the size of the
> >> header?
> > [...]
> > 
> > The length passed to skb_cow_head() may be significant when the skb has
> > paged fragments.  Since you aren't (yet) implementing scatter-gather,
> > that won't happen.  And the headers shouldn't be in paged fragments
> > anyway.  I think you can safely use skb_cow_head(skb, 0).
> > 
> > But you don't actually need to check protocol numbers at all, as the
> > kernel already specifies where the checksum should be.
> > 
> > So I think this function should look like:
> > {
> > 	if (skb->ip_summed != CHECKSUM_PARTIAL)
> > 		return 0;
> > 
> > 	if (unlikely(skb_cow_head(skb, 0)))
> > 		return -1;
> > 
> > 	*(__sum16 *)(skb->head + skb->csum_start + skb->csum_offset) = 0;
> > 	return 0;
> > }
> > 
> > The caller needs to check for the failure, and free the skb
> > (kfree_skb()) rather than transmitting it.
> > 
> > Ben.
> > 
> 
> Which checksum does skb->csum (skb->csum_start + skb->csum_offset)
> relate to?

TCP or UDP.

> The network card can generate IP header and protocol (UDP/TCP/ICMP)
> checksums as long as the checksums are zeroed?

You don't need to offload the IPv4 header checksum.  TX checksum offload
will not be requested for ICMP.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
