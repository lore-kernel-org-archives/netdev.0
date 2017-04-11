From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: af_packet: use after free in prb_retire_rx_blk_timer_expired
Date: Tue, 11 Apr 2017 19:22:37 -0400
Message-ID: <CAF=yD-+MiyTvC=F=ApyF=+bCUgWWDT_4dTxPXsGRziuVTqQSiw@mail.gmail.com>
References: <20170410190350.ngfw435zzr7gpw7e@sasha-lappy> <20170410192309.35x7ddya2cyyv4y6@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Dave Jones <davej@codemonkey.org.uk>, alexander.levin@verizon.com,
        "davem@davemloft.net" <davem@davemloft.net>,
        "edumazet@google.com" <edumazet@google.com>,
        "willemb@google.com" <willemb@google.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35551 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752010AbdDKXXS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 19:23:18 -0400
In-Reply-To: <20170410192309.35x7ddya2cyyv4y6@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 10, 2017 at 3:23 PM, Dave Jones <davej@codemonkey.org.uk> wrote:
> On Mon, Apr 10, 2017 at 07:03:30PM +0000, alexander.levin@verizon.com wrote:
>  > Hi all,
>  >
>  > I seem to be hitting this use-after-free on a -next kernel using trinity:
>  >
>  > [  531.036054] BUG: KASAN: use-after-free in prb_retire_rx_blk_timer_expired (net/packet/af_packet.c:688)

The retire_blk_timer is called after the pg_vec struct for this ring
was freed. This should not happen. packet_set_ring stops the timer
with del_timer_sync when tearing down the ring before freeing that
struct:

        if (closing && (po->tp_version > TPACKET_V2)) {
                /* Because we don't support block-based V3 on tx-ring */
                if (!tx_ring)
                        prb_shutdown_retire_blk_timer(po, rb_queue);
        }

        if (pg_vec)
                free_pg_vec(pg_vec, order, req->tp_block_nr);

This is a similar race to the use-after-free fixed by 84ac7260236a
("packet: fix race condition in packet_set_ring"). The previous race
was triggered by a call to setsockopt PACKET_VERSION changing
tp_version while the ring is active. It is not immediately obvious
what is the cause now. I suppose trinity does not give a trace of such
system calls on this file descriptor? That would be helpful.

The bug report shows both a timer firing after the packet_set_ring
call that freed the pg_vec, and later a CONFIG_DEBUG_OBJECTS_FREE
warning that the timer is still active when the socket is closed on
release of the last file descriptor.
