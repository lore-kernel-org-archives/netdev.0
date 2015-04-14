From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v6 1/9] bgmac: simplify tx ring index handling
Date: Tue, 14 Apr 2015 07:38:47 +0200
Message-ID: <CACna6ryBVXS0-bC_L7KnSr_BBRLMekYJ9-p+zF_a5-hHKewbKQ@mail.gmail.com>
References: <1428968537-6181-1-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:34250 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751596AbbDNFis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 01:38:48 -0400
Received: by iedfl3 with SMTP id fl3so7732990ied.1
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 22:38:48 -0700 (PDT)
In-Reply-To: <1428968537-6181-1-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 April 2015 at 01:42, Felix Fietkau <nbd@openwrt.org> wrote:
> @@ -158,13 +157,7 @@ static netdev_tx_t bgmac_dma_tx_add(struct bgmac *bgmac,
>                 skb_checksum_help(skb);
>
>         nr_frags = skb_shinfo(skb)->nr_frags;
> -
> -       if (ring->start <= ring->end)
> -               free_slots = ring->start - ring->end + BGMAC_TX_RING_SLOTS;
> -       else
> -               free_slots = ring->start - ring->end;
> -
> -       if (free_slots <= nr_frags + 1) {
> +       if (ring->end - ring->start + nr_frags + 1 >= BGMAC_TX_RING_SLOTS) {
>                 bgmac_err(bgmac, "TX ring is full, queue should be stopped!\n");
>                 netif_stop_queue(net_dev);
>                 return NETDEV_TX_BUSY;

Regarding my previous report if following problem:
ring->end:0x00 ring->start:0xfd (ring->end - ring->start + nr_frags + 1):-252
ring->end:0x00 ring->start:0xff (ring->end - ring->start + nr_frags + 1):-254
ring->end:0x00 ring->start:0xff (ring->end - ring->start + nr_frags + 1):-254
ring->end:0x00 ring->start:0xff (ring->end - ring->start + nr_frags + 1):-254
ring->end:0x00 ring->start:0xfe (ring->end - ring->start + nr_frags + 1):-253
ring->end:0x00 ring->start:0xff (ring->end - ring->start + nr_frags + 1):-254
ring->end:0x00 ring->start:0xfe (ring->end - ring->start + nr_frags + 1):-253
ring->end:0x00 ring->start:0xfd (ring->end - ring->start + nr_frags + 1):-252
ring->end:0x00 ring->start:0xfd (ring->end - ring->start + nr_frags + 1):-252
(with hacked *_RING_SLOTS and u8 start, end;)

My hacked code didn't work, because using u8 killed your trick with
using the way of treating numbers (32b limit) in condition.

When using u32 your trick seems to work:
bgmac: [bgmac_dma_tx_add] ring->end:0x00000000 ring->start:0xfffffff9
bgmac: [bgmac_dma_tx_add] (ring->end - ring->start + nr_frags + 1):8

bgmac: [bgmac_dma_tx_add] ring->end:0x00000001 ring->start:0xfffffff9
bgmac: [bgmac_dma_tx_add] (ring->end - ring->start + nr_frags + 1):9

bgmac: [bgmac_dma_tx_add] ring->end:0x00000002 ring->start:0xfffffff9
bgmac: [bgmac_dma_tx_add] (ring->end - ring->start + nr_frags + 1):10

If you'll be sending V7, what about adding something like
/* Ring start and end are u32, subtraction gives number of free slots */
Would that be OK? To point this way the code is OK and help understand why?
