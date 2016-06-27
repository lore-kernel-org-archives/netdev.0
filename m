From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: do not send too big packets at retransmit time
Date: Mon, 27 Jun 2016 17:38:50 +0200
Message-ID: <1467041930.6850.166.camel@edumazet-glaptop3.roam.corp.google.com>
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
	 <1467031616.6850.150.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CADVnQynZxphzi37PD6GRV6k=tgjHfH2HuL7GiGVjOSMOCLSOcA@mail.gmail.com>
	 <1467034072.6850.152.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arjun V <arjun@chelsio.com>, Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hariprasad S <hariprasad@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	Kumar A S <kumaras@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	Nirranjan Kirubaharan <nirranjan@chelsio.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"ycheng@google.com" <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34103 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbcF0PjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 11:39:10 -0400
Received: by mail-wm0-f68.google.com with SMTP id 187so25654630wmz.1
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 08:38:57 -0700 (PDT)
In-Reply-To: <1467034072.6850.152.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Arjun reported a bug in TCP stack and bisected it to a recent commit.

In case where we process SACK, we can coalesce multiple skbs
into fat ones (tcp_shift_skb_data()), to lower write queue
overhead, because we do not expect to retransmit these packets.

However, SACK reneging can happen, forcing the sender to retransmit
all these packets. If skb->len is above 64KB, we then send buggy
IP packets that could hang TSO engine on cxgb4.

Neal suggested to use tcp_tso_autosize() instead of tp->gso_segs
so that we cook packets of optimal size vs TCP/pacing.

Thanks to Arjun for reporting the bug and running the tests !

Fixes: 10d3be569243 ("tcp-tso: do not split TSO packets at retransmit time")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Arjun V <arjun@chelsio.com>
Tested-by: Arjun V <arjun@chelsio.com>
---
 net/ipv4/tcp_output.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8bd9911fdd16..e00e972c4e6a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2751,7 +2751,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 	struct sk_buff *hole = NULL;
-	u32 last_lost;
+	u32 max_segs, last_lost;
 	int mib_idx;
 	int fwd_rexmitting = 0;
 
@@ -2771,6 +2771,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 		last_lost = tp->snd_una;
 	}
 
+	max_segs = tcp_tso_autosize(sk, tcp_current_mss(sk));
 	tcp_for_write_queue_from(skb, sk) {
 		__u8 sacked = TCP_SKB_CB(skb)->sacked;
 		int segs;
@@ -2784,6 +2785,10 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 		segs = tp->snd_cwnd - tcp_packets_in_flight(tp);
 		if (segs <= 0)
 			return;
+		/* In case tcp_shift_skb_data() have aggregated large skbs,
+		 * we need to make sure not sending too bigs TSO packets
+		 */
+		segs = min_t(int, segs, max_segs);
 
 		if (fwd_rexmitting) {
 begin_fwd:
