From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH] xfrm_user: return error pointer instead of NULL
Date: Thu, 13 Sep 2012 23:41:26 +0200
Message-ID: <1347572486-1628-1-git-send-email-minipli@googlemail.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mathias Krause <minipli@googlemail.com>, stable@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When dump_one_state() returns an error, e.g. because of a too small
buffer to dump the whole xfrm state, xfrm_state_netlink() returns NULL
instead of an error pointer. But its callers expect an error pointer
and therefore continue to operate on a NULL skbuff.

This could lead to a privilege escalation (execution of user code in
kernel context) if the attacker has CAP_NET_ADMIN and is able to map
address 0.

Cc: stable@vger.kernel.org
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---

A test case can be provided on request.

 net/xfrm/xfrm_user.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index e75d8e4..dac08e2 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -878,6 +878,7 @@ static struct sk_buff *xfrm_state_netlink(struct sk_buff *in_skb,
 {
 	struct xfrm_dump_info info;
 	struct sk_buff *skb;
+	int err;
 
 	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
 	if (!skb)
@@ -888,9 +889,10 @@ static struct sk_buff *xfrm_state_netlink(struct sk_buff *in_skb,
 	info.nlmsg_seq = seq;
 	info.nlmsg_flags = 0;
 
-	if (dump_one_state(x, 0, &info)) {
+	err = dump_one_state(x, 0, &info);
+	if (err) {
 		kfree_skb(skb);
-		return NULL;
+		return ERR_PTR(err);
 	}
 
 	return skb;
-- 
1.7.10.4
