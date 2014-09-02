From: roy.qing.li-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Subject: [PATCH] openvswitch: fix a memory leak
Date: Tue,  2 Sep 2014 20:52:28 +0800
Message-ID: <1409662348-2475-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Li RongQing <roy.qing.li-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

The user_skb maybe be leaked if the operation on it failed and codes
skipped into the label "out:" without calling genlmsg_unicast.

Cc: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> 
Signed-off-by: Li RongQing <roy.qing.li-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/openvswitch/datapath.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 7228ec3..35d866f 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -404,7 +404,7 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 {
 	struct ovs_header *upcall;
 	struct sk_buff *nskb = NULL;
-	struct sk_buff *user_skb; /* to be queued to userspace */
+	struct sk_buff *user_skb = NULL; /* to be queued to userspace */
 	struct nlattr *nla;
 	struct genl_info info = {
 		.dst_sk = ovs_dp_get_net(dp)->genl_sock,
@@ -494,9 +494,11 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 	((struct nlmsghdr *) user_skb->data)->nlmsg_len = user_skb->len;
 
 	err = genlmsg_unicast(ovs_dp_get_net(dp), user_skb, upcall_info->portid);
+	user_skb = NULL;
 out:
 	if (err)
 		skb_tx_error(skb);
+	kfree_skb(user_skb);
 	kfree_skb(nskb);
 	return err;
 }
-- 
1.7.10.4
