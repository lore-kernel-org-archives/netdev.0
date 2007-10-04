From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2.6.23-rc9] [TCP]: Fix fastpath_cnt_hint when GSO skb is
 partially ACKed
Date: Thu, 4 Oct 2007 23:38:24 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710042330140.17406@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-328386165-1191530304=:17406"
Cc: Netdev <netdev@vger.kernel.org>, Cedric Le Goater <clg@fr.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60801 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756017AbXJDUiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 16:38:25 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-328386165-1191530304=:17406
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


When only GSO skb was partially ACKed, no hints are reset,
therefore fastpath_cnt_hint must be tweaked too or else it can
corrupt fackets_out. The corruption to occur, one must have
non-trivial ACK/SACK sequence, so this bug is not very often
that harmful. There's a fackets_out state reset in TCP because
fackets_out is known to be inaccurate and that fixes the issue
eventually anyway.

In case there was also at least one skb that got fully ACKed,
the fastpath_skb_hint is set to NULL which causes a recount for
fastpath_cnt_hint (the old value won't be accessed anymore),
thus it can safely be decremented without additional checking.

Reported by Cedric Le Goater <clg@fr.ibm.com>

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---

Dave, here's the same fix to upcoming 2.6.23, hopefully it can
make it in time. Probably minor enough to skip stable-2.6.22,
especially since 2.6.23 is soooo close :-), but I leave that
up to you.

 net/ipv4/tcp_input.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bbad2cd..f893e90 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2420,6 +2420,9 @@ static int tcp_tso_acked(struct sock *sk, struct sk_buff *skb,
 			__u32 dval = min(tp->fackets_out, packets_acked);
 			tp->fackets_out -= dval;
 		}
+		/* hint's skb might be NULL but we don't need to care */
+		tp->fastpath_cnt_hint -= min_t(u32, packets_acked,
+					       tp->fastpath_cnt_hint);
 		tp->packets_out -= packets_acked;
 
 		BUG_ON(tcp_skb_pcount(skb) == 0);
-- 
1.5.0.6

---696243703-328386165-1191530304=:17406--
