From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: refine tcp_prune_ofo_queue() to not drop
 all packets
Date: Thu, 18 Aug 2016 11:05:45 -0700
Message-ID: <1471543545.29842.83.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1471468629.29842.39.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAK6E8=cVpvGLLzXBGsTm1E692bi1jvQ70Dp0QsaB94smvhzrGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        "C. Stephen Gun" <csg@google.com>, Van Jacobson <vanj@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35968 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751442AbcHSHF0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 03:05:26 -0400
Received: by mail-pf0-f194.google.com with SMTP id y134so1016104pfg.3
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 00:05:26 -0700 (PDT)
In-Reply-To: <CAK6E8=cVpvGLLzXBGsTm1E692bi1jvQ70Dp0QsaB94smvhzrGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-08-18 at 10:55 -0700, Yuchung Cheng wrote:

> > +       /* Reset SACK state.  A conforming SACK implementation will
> > +        * do the same at a timeout based retransmit.  When a connection
> > +        * is in a sad state like this, we care only about integrity
> > +        * of the connection not performance.
> > +        */
> > +       if (tp->rx_opt.sack_ok)
> > +               tcp_sack_reset(&tp->rx_opt);
> I am curious what if we don't reset. It seems SACK will continue to
> function properly (at least for Linux sender). But this of course
> belongs  to a different patch / discussion.
> 

Agreed, we might try to be smarter here and update sack block if
possible.

BTW, here is the packetdrill test I used to test this patch :

# cat sack-prune.pkt

0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
+0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
+0 setsockopt(3, SOL_SOCKET, SO_RCVBUF, [2048], 4) = 0
+0 bind(3, ..., ...) = 0
+0 listen(3, 1) = 0

+0 < S 0:0(0) win 32792 <mss 1000,sackOK,nop,nop,nop,wscale 7>
+0 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 0>
+0.100 < . 1:1(0) ack 1 win 1024
+0 accept(3, ..., ...) = 4

+0.01 < . 2:3(1) ack 1 win 1024
+0    > . 1:1(0) ack 1 <nop,nop, sack 2:3>

+0.01 < . 4:5(1) ack 1 win 1024
+0    > . 1:1(0) ack 1 <nop,nop, sack 4:5 2:3>

+0.01 < . 6:7(1) ack 1 win 1024
+0    > . 1:1(0) ack 1 <nop,nop, sack 6:7 4:5 2:3>

+0.01 < . 8:9(1) ack 1 win 1024
+0    > . 1:1(0) ack 1 <nop,nop, sack 8:9 6:7 4:5 2:3>

+0.01 < . 10:11(1) ack 1 win 1024
// Alas, we had to clean OFO queue, last skb (sequence 8:9) was dropped.
+0    > . 1:1(0) ack 1 <nop,nop, sack 10:11>

+0.01 < . 1:2(1) ack 1 win 1024
// Make sure kernel did not drop 2:3 sequence
+0    > . 1:1(0) ack 3 <nop,nop, sack 10:11>

+0 read(4, ..., 2) = 2

+0.01 < . 3:4(1) ack 1 win 1024
+0    > . 1:1(0) ack 5 <nop,nop, sack 10:11>

+0.01 < . 5:6(1) ack 1 win 1024
+0    > . 1:1(0) ack 7 <nop,nop, sack 10:11>

+0 read(4, ..., 4) = 4

+0.01 < . 7:8(1) ack 1 win 1024
+0    > . 1:1(0) ack 8 <nop,nop, sack 10:11>

+0.01 < . 8:9(1) ack 1 win 1024
+0    > . 1:1(0) ack 9 <nop,nop, sack 10:11>

+0.01 < . 9:10(1) ack 1 win 1024
+0    > . 1:1(0) ack 11
