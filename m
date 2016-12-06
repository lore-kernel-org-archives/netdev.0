From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH] net/udp: do not touch skb->peeked unless really needed
Date: Tue, 06 Dec 2016 11:34:11 +0100
Message-ID: <1481020451.6225.38.camel@redhat.com>
References: <1480905784.18162.509.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480944138.4694.37.camel@redhat.com>
         <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480960639.18162.556.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57348 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751581AbcLFKek (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 05:34:40 -0500
In-Reply-To: <1480960639.18162.556.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Mon, 2016-12-05 at 09:57 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> In UDP recvmsg() path we currently access 3 cache lines from an skb
> while holding receive queue lock, plus another one if packet is
> dequeued, since we need to change skb->next->prev
> 
> 1st cache line (contains ->next/prev pointers, offsets 0x00 and 0x08)
> 2nd cache line (skb->len & skb->peeked, offsets 0x80 and 0x8e)
> 3rd cache line (skb->truesize/users, offsets 0xe0 and 0xe4)
> 
> skb->peeked is only needed to make sure 0-length packets are properly
> handled while MSG_PEEK is operated.
> 
> I had first the intent to remove skb->peeked but the "MSG_PEEK at
> non-zero offset" support added by Sam Kumar makes this not possible.
> 
> This patch avoids one cache line miss during the locked section, when
> skb->len and skb->peeked do not have to be read.
> 
> It also avoids the skb_set_peeked() cost for non empty UDP datagrams.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Thank you for all the good work.

After all your improvement, I see the cacheline miss in inet_recvmsg()
as a major perf offender for the user space process in the udp flood
scenario due to skc_rxhash sharing the same sk_drops cacheline.

Using an udp-specific drop counter (and an sk_drops accessor to wrap
sk_drops access where needed), we could avoid such cache miss. With that
- patch for udp.h only below - I get 3% improvement on top of all the
pending udp patches, and the gain should be more relevant after the 2
queues rework. What do you think ?

Cheers,

Paolo.
---
diff --git a/include/linux/udp.h b/include/linux/udp.h
index d1fd8cd..2bbf5db 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -49,7 +49,11 @@ struct udp_sock {
        unsigned int     corkflag;      /* Cork is required */
        __u8             encap_type;    /* Is this an Encapsulation socket? */
        unsigned char    no_check6_tx:1,/* Send zero UDP6 checksums on TX? */
-                        no_check6_rx:1;/* Allow zero UDP6 checksums on RX? */
+                        no_check6_rx:1,/* Allow zero UDP6 checksums on RX? */
+                        pcflag:6;      /* UDP-Lite specific, moved here to */
+                                       /* fill an hole, marks socket as */
+                                       /* UDP-Lite if > 0    */
+
        /*
         * Following member retains the information to create a UDP header
         * when the socket is uncorked.
@@ -64,8 +68,7 @@ struct udp_sock {
 #define UDPLITE_BIT      0x1           /* set by udplite proto init function */
 #define UDPLITE_SEND_CC  0x2           /* set via udplite setsockopt         */
 #define UDPLITE_RECV_CC  0x4           /* set via udplite setsocktopt        */
-       __u8             pcflag;        /* marks socket as UDP-Lite if > 0    */
-       __u8             unused[3];
+
        /*
         * For encapsulation sockets.
         */
@@ -79,6 +82,9 @@ struct udp_sock {
        int                     (*gro_complete)(struct sock *sk,
                                                struct sk_buff *skb,
                                                int nhoff);
+
+       /* since we are prone to drops, avoid dirtying any sk cacheline */
+       atomic_t                drops ____cacheline_aligned_in_smp;
 };
 
 static inline struct udp_sock *udp_sk(const struct sock *sk)
