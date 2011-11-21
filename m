From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2 1/5] genetlink: Add genl_notify()
Date: Mon, 21 Nov 2011 13:30:25 -0800
Message-ID: <1321911029-20707-2-git-send-email-jesse@nicira.com>
References: <1321911029-20707-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1321911029-20707-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

Open vSwitch uses Generic Netlink interface for communication
between userspace and kernel module. genl_notify() is used
for sending notification back to userspace.

genl_notify() is analogous to rtnl_notify() but uses genl_sock
instead of rtnl.

Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
v2: Unchanged.
---
 include/net/genetlink.h |    2 ++
 net/netlink/genetlink.c |   13 +++++++++++++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 82d8d09..7db3299 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -128,6 +128,8 @@ extern int genl_register_mc_group(struct genl_family *family,
 				  struct genl_multicast_group *grp);
 extern void genl_unregister_mc_group(struct genl_family *family,
 				     struct genl_multicast_group *grp);
+extern void genl_notify(struct sk_buff *skb, struct net *net, u32 pid,
+			u32 group, struct nlmsghdr *nlh, gfp_t flags);
 
 /**
  * genlmsg_put - Add generic netlink header to netlink message
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 482fa57..8a36599 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -946,3 +946,16 @@ int genlmsg_multicast_allns(struct sk_buff *skb, u32 pid, unsigned int group,
 	return genlmsg_mcast(skb, pid, group, flags);
 }
 EXPORT_SYMBOL(genlmsg_multicast_allns);
+
+void genl_notify(struct sk_buff *skb, struct net *net, u32 pid, u32 group,
+		 struct nlmsghdr *nlh, gfp_t flags)
+{
+	struct sock *sk = net->genl_sock;
+	int report = 0;
+
+	if (nlh)
+		report = nlmsg_report(nlh);
+
+	nlmsg_notify(sk, skb, pid, group, report, flags);
+}
+EXPORT_SYMBOL(genl_notify);
-- 
1.7.5.4
