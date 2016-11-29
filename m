From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tun: Use netif_receive_skb instead of netif_rx
Date: Tue, 29 Nov 2016 07:35:27 -0800
Message-ID: <1480433727.18162.138.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480433136-7922-1-git-send-email-andreyknvl@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S . Miller" <davem@davemloft.net>,
        Jason Wang <jasowang@redhat.com>,
        Eric Dumazet <edumazet@google.com>,
        Paolo Abeni <pabeni@redhat.com>,
        "Michael S . Tsirkin" <mst@redhat.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Markus Elfring <elfring@users.sourceforge.net>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>, syzkaller@googlegroups.com
To: Andrey Konovalov <andreyknvl@google.com>,
        Peter Klausler <pmk@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33829 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933987AbcK2Pfa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 10:35:30 -0500
In-Reply-To: <1480433136-7922-1-git-send-email-andreyknvl@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-11-29 at 16:25 +0100, Andrey Konovalov wrote:
> This patch changes tun.c to call netif_receive_skb instead of netif_rx
> when a packet is received. The difference between the two is that netif_rx
> queues the packet into the backlog, and netif_receive_skb proccesses the
> packet in the current context.
> 
> This patch is required for syzkaller [1] to collect coverage from packet
> receive paths, when a packet being received through tun (syzkaller collects
> coverage per process in the process context).
> 
> A similar patch was introduced back in 2010 [2, 3], but the author found
> out that the patch doesn't help with the task he had in mind (for cgroups
> to shape network traffic based on the original process) and decided not to
> go further with it. The main concern back then was about possible stack
> exhaustion with 4K stacks, but CONFIG_4KSTACKS was removed and stacks are
> 8K now.

Acked-by: Eric Dumazet <edumazet@google.com>

We're using a similar patch written by Peter , let me copy here part of
his changelog, since main motivation was speed improvement at that
time :

commit 29aa09f47d43e93327a706cd835a37012ccc5b9e
Author: Peter Klausler <pmk@google.com>
Date:   Fri Mar 29 17:08:02 2013 -0400

    net-tun: Add netif_rx_ni_immediate() variant to speed up tun/tap.
    
    Speed up packet reception from (i.e., writes to) a tun/tap
    device by adding an alternative netif_rx_ni_immediate()
    interface that invokes netif_receive_skb() immediately rather
    than enqueueing the packet in the backlog queue and then driving
    its processing with do_softirq().  Forced queueing as a consequence
    of an RPS CPU mask will still work as expected.
    
    This change speeds up my closed-loop single-stream tap/OVS benchmark
    by about 23%, from 700k packets/second to 867k packets/second.
    
