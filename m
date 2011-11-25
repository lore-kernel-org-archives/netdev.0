From: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Subject: [PATCH] bridge: master device stuck in no-carrier state
	forever when in user-stp mode
Date: Fri, 25 Nov 2011 12:16:37 +0200
Message-ID: <201111251216.37466.vitas@nppfactor.kiev.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	bridge@lists.linux-foundation.org,
	Michael Tremer <michael.tremer@ipfire.org>
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

When in user-stp mode, bridge master do not follow state of its slaves, so 
after the following sequence of events it can stuck forever in no-carrier 
state:
1) turn stp off
2) put all slaves down - master device will follow their state and also go in 
no-carrier state
3) turn stp on with bridge-stp script returning 0 (go to the user-stp mode)
Now bridge master won't follow slaves' state and will never reach running 
state.

This patch solves the problem by making user-stp and kernel-stp behavior 
similar regarding master following slaves' states.

Signed-off-by: Vitalii Demianets <vitas@nppfactor.kiev.ua>

---
 net/bridge/br_netlink.c |    6 ++++++
 net/bridge/br_stp.c     |   29 ++++++++++++++---------------
 2 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index e5f9ece3..a1daf82 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -18,6 +18,7 @@
 #include <net/sock.h>
 
 #include "br_private.h"
+#include "br_private_stp.h"
 
 static inline size_t br_nlmsg_size(void)
 {
@@ -188,6 +189,11 @@ static int br_rtm_setlink(struct sk_buff *skb,  struct 
nlmsghdr *nlh, void *arg)
 
 	p->state = new_state;
 	br_log_state(p);
+
+	spin_lock_bh(&p->br->lock);
+	br_port_state_selection(p->br);
+	spin_unlock_bh(&p->br->lock);
+
 	br_ifinfo_notify(RTM_NEWLINK, p);
 
 	return 0;
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index ad0a3f7..dd147d7 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -399,25 +399,24 @@ void br_port_state_selection(struct net_bridge *br)
 	struct net_bridge_port *p;
 	unsigned int liveports = 0;
 
-	/* Don't change port states if userspace is handling STP */
-	if (br->stp_enabled == BR_USER_STP)
-		return;
-
 	list_for_each_entry(p, &br->port_list, list) {
 		if (p->state == BR_STATE_DISABLED)
 			continue;
 
-		if (p->port_no == br->root_port) {
-			p->config_pending = 0;
-			p->topology_change_ack = 0;
-			br_make_forwarding(p);
-		} else if (br_is_designated_port(p)) {
-			del_timer(&p->message_age_timer);
-			br_make_forwarding(p);
-		} else {
-			p->config_pending = 0;
-			p->topology_change_ack = 0;
-			br_make_blocking(p);
+		/* Don't change port states if userspace is handling STP */
+		if (br->stp_enabled != BR_USER_STP) {
+			if (p->port_no == br->root_port) {
+				p->config_pending = 0;
+				p->topology_change_ack = 0;
+				br_make_forwarding(p);
+			} else if (br_is_designated_port(p)) {
+				del_timer(&p->message_age_timer);
+				br_make_forwarding(p);
+			} else {
+				p->config_pending = 0;
+				p->topology_change_ack = 0;
+				br_make_blocking(p);
+			}
 		}
 
 		if (p->state == BR_STATE_FORWARDING)
-- 
1.7.3.4
