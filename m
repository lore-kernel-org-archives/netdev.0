From: Pan Bian <bianpan2016-9Onoh4P/yGk@public.gmane.org>
Subject: [PATCH 1/1] openvswitch: check return value of
	nla_nest_start
Date: Sun, 23 Apr 2017 14:43:02 +0800
Message-ID: <1492929782-1112-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Pan Bian <bianpan2016-9Onoh4P/yGk@public.gmane.org>
To: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Function nla_nest_start() will return a NULL pointer on error, and its
return value should be validated before it is used. However, in function
queue_userspace_packet(), its return value is ignored. This may result
in NULL dereference when calling nla_nest_end(). This patch fixes the
bug.

Signed-off-by: Pan Bian <bianpan2016-9Onoh4P/yGk@public.gmane.org>
---
 net/openvswitch/datapath.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 9c62b63..34c0fbd 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -489,7 +489,8 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 		err = ovs_nla_put_tunnel_info(user_skb,
 					      upcall_info->egress_tun_info);
 		BUG_ON(err);
-		nla_nest_end(user_skb, nla);
+		if (nla)
+			nla_nest_end(user_skb, nla);
 	}
 
 	if (upcall_info->actions_len) {
@@ -497,7 +498,7 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 		err = ovs_nla_put_actions(upcall_info->actions,
 					  upcall_info->actions_len,
 					  user_skb);
-		if (!err)
+		if (!err && nla)
 			nla_nest_end(user_skb, nla);
 		else
 			nla_nest_cancel(user_skb, nla);
-- 
1.9.1
