From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: Receive offloads, small RCVBUF and zero TCP window
Date: Mon, 28 Nov 2016 20:01:46 -0200
Message-ID: <20161128220146.GA13169@localhost.localdomain>
References: <2080597.A38JFJZ1AD@zbook>
 <20161128.155459.1527519991492144879.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexandre.sidorenko@hpe.com, netdev@vger.kernel.org,
        jmaxwell37@gmail.com, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60838 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752857AbcK1WBu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 17:01:50 -0500
Content-Disposition: inline
In-Reply-To: <20161128.155459.1527519991492144879.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 03:54:59PM -0500, David Miller wrote:
> From: Alex Sidorenko <alexandre.sidorenko@hpe.com>
> Date: Mon, 28 Nov 2016 15:49:26 -0500
> 
> > Now the question is whether is is OK to have icsk->icsk_ack.rcv_mss
> > larger than MTU.
> 
> It absolutely is not OK.
> 

Would it make sense to add a pr_warn_once() and perhaps even clamp it
down to known/saner MSS?

> If VMWare wants to receive large frames for batching purposes it must
> use GRO or similar to achieve that, not just send vanilla frames into
> the stack which are larger than the device MTU.
> 

It's not the first report I've seen on this type of issue. IBM also had
this issue recently while not being able to send the gso_size from tx
side to rx, and the warning probably could have saved quite some
debugging time.

Something like (but with a better msg, for sure):

--8<--

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a27b9c0e27c0..3a59cffae3fa 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -144,7 +144,9 @@ static void tcp_measure_rcv_mss(struct sock *sk, const struct sk_buff *skb)
 	 */
 	len = skb_shinfo(skb)->gso_size ? : skb->len;
 	if (len >= icsk->icsk_ack.rcv_mss) {
-		icsk->icsk_ack.rcv_mss = len;
+		icsk->icsk_ack.rcv_mss = max(len, tcp_sk(sk)->advmss);
+		if (icsk->icsk_ack.rcv_mss != len)
+			pr_warn_once("Your driver is likely doing bad rx acceleration.\n");
 	} else {
 		/* Otherwise, we make more careful check taking into account,
 		 * that SACKs block is variable.
