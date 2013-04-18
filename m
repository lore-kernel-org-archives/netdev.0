From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v3 1/1] net: fec: Enable imx6 enet checksum
 acceleration.
Date: Thu, 18 Apr 2013 17:16:36 +0100
Message-ID: <1366301796.2735.18.camel@bwh-desktop.uk.solarflarecom.com>
References: <Jim Baxter <jim_baxter@mentor.com>
	  <1366229278-7528-1-git-send-email-jim_baxter@mentor.com>
	 <1366234670.3205.38.camel@edumazet-glaptop> <516FEBD3.8000803@mentor.com>
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
Received: from webmail.solarflare.com ([12.187.104.25]:42309 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935712Ab3DRQQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 12:16:41 -0400
In-Reply-To: <516FEBD3.8000803@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-18 at 13:49 +0100, Jim Baxter wrote:
> On 17/04/13 22:37, Eric Dumazet wrote:
> > On Wed, 2013-04-17 at 21:07 +0100, Jim Baxter wrote:
> >> Enables hardware generation of IP header and
> >> protocol specific checksums for transmitted
> >> packets.
> >>
> >> Enabled hardware discarding of received packets with
> >> invalid IP header or protocol specific checksums.
> >>
> >> The feature is enabled by default but can be
> >> enabled/disabled by ethtool.
> >>
> >> Signed-off-by: Fugang Duan <B38611@freescale.com>
> >> Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
> >> ---
> >>  
> >> +static void
> >> +fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
> >> +{
> >> +	int hdr_len = 0;
> >> +
> >> +	/* Only run for packets requiring a checksum. */
> >> +	if (skb->ip_summed != CHECKSUM_PARTIAL)
> >> +		return;
> >> +	if (skb->len < (ETH_HLEN + sizeof(struct iphdr)))
> >> +		return;
> >> +
> > 
> > You could do the skb_cow_head() here.
> 
> I do not know the full length of the header at this point, so I think
> that would be tricky.
> 
> > 
> >> +	if (skb->protocol == htons(ETH_P_IP)) {
> >> +		ip_hdr(skb)->check = 0;

But you're already changing it here.

> >> +		switch (ip_hdr(skb)->protocol) {
> >> +		case IPPROTO_UDP:
> >> +			hdr_len = (ETH_HLEN +
> >> +					(ip_hdr(skb)->ihl << 2) +
> >> +					sizeof(struct udphdr));
> >> +			if (skb->len < hdr_len)
> >> +				return;
> >> +			skb_cow_head(skb, hdr_len);
> > 
> > You should not ignore the return value...
> I agree.
> > 
> >> +			skb_set_transport_header(skb,
> >> +					ETH_HLEN + ip_hdrlen(skb));
> >> +			udp_hdr(skb)->check = 0;
> >> +			break;
> >> +		case IPPROTO_TCP:
> >> +			hdr_len = (ETH_HLEN +
> >> +					(ip_hdr(skb)->ihl << 2) +
> >> +					sizeof(struct tcphdr));
> >> +			if (skb->len < hdr_len)
> >> +				return;
> >> +			skb_cow_head(skb, hdr_len);
> > 
> > same here
> Do I need to call skb_cow_head here, I am not changing the size of the
> header?
[...]

The length passed to skb_cow_head() may be significant when the skb has
paged fragments.  Since you aren't (yet) implementing scatter-gather,
that won't happen.  And the headers shouldn't be in paged fragments
anyway.  I think you can safely use skb_cow_head(skb, 0).

But you don't actually need to check protocol numbers at all, as the
kernel already specifies where the checksum should be.

So I think this function should look like:
{
	if (skb->ip_summed != CHECKSUM_PARTIAL)
		return 0;

	if (unlikely(skb_cow_head(skb, 0)))
		return -1;

	*(__sum16 *)(skb->head + skb->csum_start + skb->csum_offset) = 0;
	return 0;
}

The caller needs to check for the failure, and free the skb
(kfree_skb()) rather than transmitting it.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
