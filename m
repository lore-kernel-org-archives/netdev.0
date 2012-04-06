From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next V2] tcp: Fix bug when gap in rcv sequence is filled
Date: Fri, 6 Apr 2012 15:17:12 -0700
Message-ID: <CADVnQy==-AbEfge3ZgmzSzMEjMXsGdRWVvw=Tb2dosP9StifJg@mail.gmail.com>
References: <1333733810-2381-1-git-send-email-subramanian.vijay@gmail.com>
	<CAAsGZS4w=2_e9O=cRK6r+gxirohhSPHpgkNpWw_ZvC-+Q-pHkA@mail.gmail.com>
	<CAGK4HS-FZ038=Yik4DEQ26y4-9Zx9Gp80CU5_JS0U-anxjh9Wg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: chetan loke <loke.chetan@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, ilpo.jarvinen@helsinki.fi
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:52341 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758233Ab2DFWRM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 18:17:12 -0400
Received: by iagz16 with SMTP id z16so3620858iag.19
        for <netdev@vger.kernel.org>; Fri, 06 Apr 2012 15:17:12 -0700 (PDT)
In-Reply-To: <CAGK4HS-FZ038=Yik4DEQ26y4-9Zx9Gp80CU5_JS0U-anxjh9Wg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 6, 2012 at 10:36 AM, Vijay Subramanian
<subramanian.vijay@gmail.com> wrote:
> As per RFC2581 and the newer RFC5681, "the receiver SHOULD send an im=
mediate ACK
> when it receives a data segment that fills in all or part of a gap in=
 the
> sequence space." When TCP receiver gets the next in-sequence packet, =
we move
> data from ofo queue to receive queue. At this point, we should send a=
n immediate
> ack by entering quickack mode. =A0In the current code, instead of ent=
ering
> quickack mode upon requeing packets from ofo queue to receive_queue, =
we enter
> quickack mode only when ofo queue becomes empty after requeuing. =A0T=
his ignores
> the possibility that there may be further packets left in ofo queue. =
This patch
> fixes this behavior and enters quickack mode whenever packets are mov=
ed from ofo
> queue to receive queue.

If you have some packet traces documenting that there is actually a
bug here, can you please share them?

AFAICT the code correctly generates immediate ACKs in these cases by:

(a) having __tcp_ack_snd_check() call tcp_send_ack() to send an
immediate ack if out_of_order_queue is non-empty.

(b) having tcp_data_queue set icsk_ack.pingpong to 0 when
out_of_order_queue transitions from non-empty to empty

My testing also shows that Linux TCP correctly generates an immediate
ACK when we move data from the out_of_order_queue to the
sk_receive_queue but the out_of_order_queue is still non-empty. Here
is a condensed packet trace showing the behavior I see in tests (with
a trace taken on machine A):

=2E798 B>A . 50001:60001(10000) ack 1001 win 20000
=2E838 A>B . ack 60001 win 10000
=2E848 B>A . 61001:62001(1000) ack 1001 win 20000
=2E848 A>B . ack 60001 win 10000 <nop,nop,sack 1 {61001:62001}>
=2E858 B>A . 63001:64001(1000) ack 1001 win 20000
=2E858 A>B . ack 60001 win 10000 <nop,nop,sack 2 {63001:64001}{61001:62=
001}>
=2E868 B>A . 60001:61001(1000) ack 1001 win 20000
=2E868 A>B . ack 62001 win 10000 <nop,nop,sack 1 {63001:64001}>

neal
