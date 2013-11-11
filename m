From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP performance regression
Date: Sun, 10 Nov 2013 21:55:26 -0800
Message-ID: <1384149326.16391.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <21120.27501.32323.332316@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Sujith Manoharan <sujith@msujith.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:52176 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222Ab3KKFz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 00:55:28 -0500
Received: by mail-pd0-f172.google.com with SMTP id w10so4748968pde.3
        for <netdev@vger.kernel.org>; Sun, 10 Nov 2013 21:55:27 -0800 (PST)
In-Reply-To: <21120.27501.32323.332316@gargle.gargle.HOWL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-11 at 11:00 +0530, Sujith Manoharan wrote:
> Hi,
> 
> The commit, "tcp: TSQ can use a dynamic limit" causes a large
> performance drop in TCP transmission with the wireless driver ath9k.
> 
> With a 2-stream card (AR9462), the usual throughput is around 195 Mbps.
> But, with this commit, it drops to ~125 Mbps, occasionally reaching 130.
> 
> If the commit is reverted, performance is normal again and I can get
> 190+ Mbps. Apparently, ath10k is also affected and a 250 Mbps drop
> is seen (from an original 740 Mbps).

I am afraid this commit shows bugs in various network drivers.

All drivers doing TX completion using a timer are buggy.

Random example : drivers/net/ethernet/marvell/mvneta.c

#define MVNETA_TX_DONE_TIMER_PERIOD 10

/* Trigger tx done timer in MVNETA_TX_DONE_TIMER_PERIOD msecs */
static void mvneta_add_tx_done_timer(struct mvneta_port *pp)
{
        if (test_and_set_bit(MVNETA_F_TX_DONE_TIMER_BIT, &pp->flags) == 0) {
                pp->tx_done_timer.expires = jiffies +
                        msecs_to_jiffies(MVNETA_TX_DONE_TIMER_PERIOD);
                add_timer(&pp->tx_done_timer);
        }
}

Holding skb 10 ms before TX completion is totally wrong and must be fixed.

If really NIC is not able to trigger an interrupt after TX completion, then
driver should call skb_orphan() in its ndo_start_xmit()
