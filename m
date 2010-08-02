From: kaber@trash.net
Subject: [PATCH 08/28] netfilter: nf_ct_tcp: fix flow recovery with TCP window	tracking enabled
Date: Mon,  2 Aug 2010 21:57:25 +0200
Message-ID: <1280779065-9333-9-git-send-email-kaber@trash.net>
References: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1280779065-9333-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch adds the missing bits to support the recovery of TCP flows
without disabling window tracking (aka be_liberal). To ensure a
successful recovery, we have to inject the window scale factor via
ctnetlink.

This patch has been tested with a development snapshot of conntrackd
and the new clause `TCPWindowTracking' that allows to perform strict
TCP window tracking recovery across fail-overs.

With this patch, we don't update the receiver's window until it's not
initiated. We require this to perform a successful recovery. Jozsef
confirmed in a private email that this spotted a real issue since that
should not happen.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_proto_tcp.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 802dbff..c4c885d 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -585,8 +585,16 @@ static bool tcp_in_window(const struct nf_conn *ct,
 			 * Let's try to use the data from the packet.
 			 */
 			sender->td_end = end;
+			win <<= sender->td_scale;
 			sender->td_maxwin = (win == 0 ? 1 : win);
 			sender->td_maxend = end + sender->td_maxwin;
+			/*
+			 * We haven't seen traffic in the other direction yet
+			 * but we have to tweak window tracking to pass III
+			 * and IV until that happens.
+			 */
+			if (receiver->td_maxwin == 0)
+				receiver->td_end = receiver->td_maxend = sack;
 		}
 	} else if (((state->state == TCP_CONNTRACK_SYN_SENT
 		     && dir == IP_CT_DIR_ORIGINAL)
@@ -680,7 +688,7 @@ static bool tcp_in_window(const struct nf_conn *ct,
 		/*
 		 * Update receiver data.
 		 */
-		if (after(end, sender->td_maxend))
+		if (receiver->td_maxwin != 0 && after(end, sender->td_maxend))
 			receiver->td_maxwin += end - sender->td_maxend;
 		if (after(sack + win, receiver->td_maxend - 1)) {
 			receiver->td_maxend = sack + win;
-- 
1.7.1

