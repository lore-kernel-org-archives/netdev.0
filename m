From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [REGRESSION, bisect]cxgb4 port failure with TSO traffic after
 commit 10d3be569243def8("tcp-tso: do not split TSO packets at retransmit
 time")
Date: Mon, 27 Jun 2016 14:46:56 +0200
Message-ID: <1467031616.6850.150.camel@edumazet-glaptop3.roam.corp.google.com>
References: <6DE8042992C3D3488ACEF3F2607097E3C4A81CA5@nice.asicdesigners.com>
	 <CANn89iLpBC5tUqpdSE4jCMKFgUi=mg=2kPZtMaRh-cnBhvauNg@mail.gmail.com>
	 <6DE8042992C3D3488ACEF3F2607097E3C4A82805@nice.asicdesigners.com>
	 <CANn89i+ePpSDYPtQeZa=fdN84=4WKdDb88P-dOVyPyY_DMK02g@mail.gmail.com>
	 <1466785507.6850.105.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160627071750.GA13304@v4.asicdesigners.com>
	 <1467014782.6850.144.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160627085957.GB13319@v4.asicdesigners.com>
	 <1467019279.6850.145.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160627095445.GC13319@v4.asicdesigners.com>
	 <1467024617.6850.148.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hariprasad S <hariprasad@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	Kumar A S <kumaras@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	Nirranjan Kirubaharan <nirranjan@chelsio.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"ycheng@google.com" <ycheng@google.com>
To: Arjun V <arjun@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34361 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbcF0MrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 08:47:05 -0400
Received: by mail-wm0-f65.google.com with SMTP id 187so24281446wmz.1
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 05:47:03 -0700 (PDT)
In-Reply-To: <1467024617.6850.148.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-06-27 at 12:50 +0200, Eric Dumazet wrote:
> On Mon, 2016-06-27 at 15:24 +0530, Arjun V wrote:
> 
> > Applied your patch.
> > The above debug print is not getting invoked, when skb->len is greater than 65536.
> 
> Interesting.
> 
> It looks like we might have a bug in tcp_shift_skb_data() not respecting
> sk->sk_gso_max_size at all ...

Note that this also means TCP receiver misbehaves and force us to SACK
reneging.

Patch would be :

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8bd9911fdd16..3587efe22864 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2784,6 +2784,10 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 		segs = tp->snd_cwnd - tcp_packets_in_flight(tp);
 		if (segs <= 0)
 			return;
+		/* In case tcp_shift_skb_data() have aggregated large skbs,
+		 * we need to make sure not sending too big TSO packets.
+		 */
+		segs = min_t(int, segs, tp->gso_segs);
 
 		if (fwd_rexmitting) {
 begin_fwd:
