From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 2/2] net: mv643xx_eth: Fix highmem support in non-TSO
 egress path
Date: Thu, 22 Jan 2015 00:11:03 +0000
Message-ID: <20150122001103.GY26493@n2100.arm.linux.org.uk>
References: <1421844850-30886-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <1421844850-30886-3-git-send-email-ezequiel.garcia@free-electrons.com>
 <20150121174049.GW26493@n2100.arm.linux.org.uk>
 <54C03786.2060101@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	B38611@freescale.com, fabio.estevam@freescale.com
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:44820 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362AbbAVALQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 19:11:16 -0500
Content-Disposition: inline
In-Reply-To: <54C03786.2060101@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 21, 2015 at 08:34:30PM -0300, Ezequiel Garcia wrote:
> I have just realised that the non-TSO and the TSO paths must work
> simultaneously (we don't know which path an egress skb will take).
> 
> So, with these patches, the unmapping is done using dma_unmap_page() which
> is only correct if the skb took the non-TSO paths. In other words,
> these fixes are wrong (although I have no idea the effect of
> using dma_unmap_page on a mapping done with dma_map_single).
> 
> And the problem is that in the TSO path, the linear and the non-linear
> fragments use the same kind of descriptors, so we can't distinguish
> them in the cleanup, and can't decide if _single or _page should be used.
> 
> Any ideas?

Or, maybe, if davem would reply, we might come to the conclusion (as
I previously pointed out) that it's not a driver issue, but a netdev
core issue:

static netdev_features_t harmonize_features(struct sk_buff *skb,
        netdev_features_t features)
{
...
        if (skb->ip_summed != CHECKSUM_NONE &&
            !can_checksum_protocol(features, type)) {
                features &= ~NETIF_F_ALL_CSUM;
        } else if (illegal_highdma(skb->dev, skb)) {
                features &= ~NETIF_F_SG;
        }

The problem is when the first "if" is true (as is the case with IPv6 on
mv643xx_eth.c), we clear NETIF_F_ALL_CSUM, but leave NETIF_F_SG set.

Had that first if been false, we would've called illegal_highdma(), and
found that the skb contains some highmem fragments, but the device does
*not* have NETIF_F_HIGHDMA set, and so that second "if" would be true.
The result of that is NETIF_F_SG is cleared.

In this case, in validate_xmit_skb(), skb_needs_linearize() would be
false for a skb with fragments, causing the skb to be linearised.  I've
not completely traced the GSO path, but I'd assume that does something
similar (which I think skb_segment() handles.)

So, I'm wondering whether the above should be:

static netdev_features_t harmonize_features(struct sk_buff *skb,
        netdev_features_t features)
{
...
        if (skb->ip_summed != CHECKSUM_NONE &&
            !can_checksum_protocol(features, type)) {
                features &= ~NETIF_F_ALL_CSUM;
        }

        if (illegal_highdma(skb->dev, skb)) {
                features &= ~NETIF_F_SG;
        }

So that we get NETIF_F_SG turned off for all cases (irrespective of the
NETIF_F_ALL_CSUM test) if we see a skb with highmem and we the device
does not support highdma.

Yes, the code above hasn't changed in functionality for a long time, but
that doesn't mean it isn't buggy, and isn't the cause of our current bug.

However, it would be far better to have the drivers fixed for the sake
of performance - it's only this dma_map_page() thing that is the real
cause of the problem in these drivers.

Looking at TSO, it seems madness that it doesn't support highmem:

void tso_start(struct sk_buff *skb, struct tso_t *tso)
{
...
        tso->data = skb->data + hdr_len;
...
                tso->data = page_address(frag->page.p) + frag->page_offset;

Of course, this would all be a lot easier for drivers if all drivers had
to worry about was a struct page, offset and size, rather than having to
track whether each individual mapping of a transmit packet was mapped
with dma_map_single() or dma_map_page().

That all said, what I really care about is the regression which basically
makes 3.18 unusable on this hardware and seeing _some_ kind of resolution
to that regression - I don't care if it doesn't quite perform, what I care
about is that the network driver doesn't oops the kernel.

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.
