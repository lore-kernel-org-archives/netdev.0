From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/2] tcp: miscounts due to tcp_fragment pcount reset
Date: Thu, 2 Apr 2009 12:18:20 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0904021216170.30150@wrl-59.cs.helsinki.fi>
References: <20090327211202.GA10014@gentoox2.trippelsdorf.de>
 <Pine.LNX.4.64.0903280031080.5904@wrl-59.cs.helsinki.fi>
 <20090328045056.GA2394@gentoox2.trippelsdorf.de>
 <Pine.LNX.4.64.0903280930440.6696@wrl-59.cs.helsinki.fi>
 <20090328095514.GA2599@gentoox2.trippelsdorf.de>
 <Pine.LNX.4.64.0903301155150.30150@wrl-59.cs.helsinki.fi>
 <20090330164035.GA2652@gentoox2.trippelsdorf.de>
 <Pine.LNX.4.64.0903302137100.29272@wrl-59.cs.helsinki.fi>
 <20090331071018.GA2641@gentoox2.trippelsdorf.de>
 <Pine.LNX.4.64.0903311205070.30150@wrl-59.cs.helsinki.fi>
 <20090331184959.GA2725@gentoox2.trippelsdorf.de>
 <Pine.LNX.4.64.0904011352470.30150@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0904021212310.30150@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-588721039-1238663900=:30150"
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, Uwe Bugla <uwe.bugla@gmx.de>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S935604AbZDBJSr@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0904021212310.30150@wrl-59.cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-588721039-1238663900=:30150
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


It seems that trivial reset of pcount to one was not sufficient
in tcp_retransmit_skb. Multiple counters experience a positive
miscount when skb's pcount gets lowered without the necessary
adjustments (depending on skb's sacked bits which exactly), at
worst a packets_out miscount can crash at RTO if the write queue
is empty!

Triggering this requires mss change, so bidir tcp or mtu probe or
like.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Reported-by: Markus Trippelsdorf <markus@trippelsdorf.de>
Tested-by: Uwe Bugla <uwe.bugla@gmx.de>
---

Markus probably tested this as well though I didn't hear any reports back 
yet.

 net/ipv4/tcp_output.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f1db89b..53300fa 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1893,7 +1893,12 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 		if (tcp_fragment(sk, skb, cur_mss, cur_mss))
 			return -ENOMEM; /* We'll try again later. */
 	} else {
-		tcp_init_tso_segs(sk, skb, cur_mss);
+		int oldpcount = tcp_skb_pcount(skb);
+
+		if (unlikely(oldpcount > 1)) {
+			tcp_init_tso_segs(sk, skb, cur_mss);
+			tcp_adjust_pcount(sk, skb, oldpcount - tcp_skb_pcount(skb));
+		}
 	}
 
 	tcp_retrans_try_collapse(sk, skb, cur_mss);
-- 
1.5.2.2

---696208474-588721039-1238663900=:30150--
