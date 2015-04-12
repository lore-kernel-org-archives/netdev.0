From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 4/4] bgmac: fix DMA rx corruption
Date: Sun, 12 Apr 2015 12:04:26 -0700
Message-ID: <1428865466.25985.366.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1428848565-94187-1-git-send-email-nbd@openwrt.org>
	 <1428848565-94187-4-git-send-email-nbd@openwrt.org>
	 <1428862182.25985.354.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552ABD6E.10000@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zajec5@gmail.com, hauke@hauke-m.de
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:33546 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbbDLTE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 15:04:28 -0400
Received: by igbpi8 with SMTP id pi8so14945193igb.0
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 12:04:27 -0700 (PDT)
In-Reply-To: <552ABD6E.10000@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-04-12 at 20:46 +0200, Felix Fietkau wrote:
> On 2015-04-12 20:09, Eric Dumazet wrote:

> > 
> > Given the fact that previous driver kind of worked, have you tried not
> > doing the modulo at all here ?
> The previous driver was causing reproducible DMA corruption issues under
> load. My patch fixes this, and I've verified this with hours of stress
> testing (previously I could reproduce the issue in minutes).
> 
> > ring->end = desc_idx + 1;
> > 
> > It looks like the hardware accepted setting BGMAC_DMA_RX_INDEX to
> > ring->index_base + ring->num_slots * sizeof(struct bgmac_dma_desc)
> The hardware accepts it, but with that value, it considers all rx slot
> entries filled, there's no CPU ownership bit in the descriptor.
> According to documentation, that register indicates the first *invalid*
> rx descriptor (i.e. one where the CPU hasn't posted a valid buffer yet).
> 
> > So apparently the presence of BGMAC_DESC_CTL0_EOT in last rx desc was
> > enough to avoid any problem with this.
> EOT serves a completely different purpose. It simply indicates the end
> of the ring, telling the hardware to go back to the beginning for the
> next descriptor.

Right, but after your patch, we program the hardware with end == start
== 0

So I do not really understand how the hardware can still deliver first
frame.

If it was really taking care of 'end' value, then it should not even
deliver one frame.

The dma corruption happened because hardware was simply reusing frames,
that driver already took to upper stack, since as you said, there is no
ownership bit.

You might try your patch with BGMAC_RX_RING_SLOTS = 3 and check if it is
still working properly.

I find BGMAC_RX_RING_SLOTS==511 very suspect, and a comment of why this
magic value is not 512 would be nice.
