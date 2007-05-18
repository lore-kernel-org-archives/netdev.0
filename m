From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6 2/2] [TCP] FRTO: Prevent state inconsistency in corner
 cases
Date: Fri, 18 May 2007 12:17:44 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0705181216570.28356@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0705181213360.28356@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1578970453-1179479864=:28356"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35436 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753957AbXERJRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2007 05:17:45 -0400
In-Reply-To: <Pine.LNX.4.64.0705181213360.28356@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1578970453-1179479864=:28356
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

State could become inconsistent in two cases:

1) Userspace disabled FRTO by tuning sysctl when one of the TCP
   flows was in the middle of FRTO algorithm (and then RTO is
   again triggered)

2) SACK reneging occurs during FRTO algorithm

A simple solution is just to abort the previous FRTO when such
obscure condition occurs...

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7ecdc89..38cb25b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1501,6 +1501,8 @@ void tcp_enter_loss(struct sock *sk, int how)
 	tcp_set_ca_state(sk, TCP_CA_Loss);
 	tp->high_seq = tp->snd_nxt;
 	TCP_ECN_queue_cwr(tp);
+	/* Abort FRTO algorithm if one is in progress */
+	tp->frto_counter = 0;
 
 	clear_all_retrans_hints(tp);
 }
-- 
1.5.0.6

---696243703-1578970453-1179479864=:28356--
