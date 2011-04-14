From: Daniel Walter <sahne@0x90.at>
Subject: [PATCH 1/1] ipv6: ignore looped-back NA while dad is running
Date: Thu, 14 Apr 2011 09:09:25 +0200
Message-ID: <20110414070925.GA78446@0x90.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ipv6] Ignore looped-back NAs while in Duplicate Address Detection

If we send an unsolicited NA shortly after bringing up an
IPv6 address, the duplicate address detection algorithm
fails and the ip stays in tentative mode forever. 
This is due a missing check if the NA is looped-back to us.

Signed-off-by: Daniel Walter <dwalter@barracuda.com>
---
apply against linux-2.6 HEAD

 net/ipv6/ndisc.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)
---
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 92f952d..f057ff3 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -945,9 +945,10 @@ static void ndisc_recv_na(struct sk_buff *skb)
 	}
 	ifp = ipv6_get_ifaddr(dev_net(dev), &msg->target, dev, 1);
 	if (ifp) {
-		if (ifp->flags & IFA_F_TENTATIVE) {
-			addrconf_dad_failure(ifp);
-			return;
+		if (skb->pkt_type != PACKET_LOOPBACK
+		    && (ifp->flags & IFA_F_TENTATIVE)) {
+				addrconf_dad_failure(ifp);
+				return;
 		}
 		/* What should we make now? The advertisement
 		   is invalid, but ndisc specs say nothing
