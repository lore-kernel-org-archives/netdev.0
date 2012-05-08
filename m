From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/3] openvswitch: Release rtnl_lock if
	ovs_vport_cmd_build_info() failed.
Date: Mon,  7 May 2012 18:51:24 -0700
Message-ID: <1336441885-11085-3-git-send-email-jesse@nicira.com>
References: <1336441885-11085-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1336441885-11085-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

From: Ansis Atteka <aatteka-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

This patch fixes a possible lock-up bug where rtnl_lock might not
get released.

Signed-off-by: Ansis Atteka <aatteka-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index e44e631..4cb615d 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1641,10 +1641,9 @@ static int ovs_vport_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	reply = ovs_vport_cmd_build_info(vport, info->snd_pid, info->snd_seq,
 					 OVS_VPORT_CMD_NEW);
 	if (IS_ERR(reply)) {
-		err = PTR_ERR(reply);
 		netlink_set_err(init_net.genl_sock, 0,
-				ovs_dp_vport_multicast_group.id, err);
-		return 0;
+				ovs_dp_vport_multicast_group.id, PTR_ERR(reply));
+		goto exit_unlock;
 	}
 
 	genl_notify(reply, genl_info_net(info), info->snd_pid,
-- 
1.7.9.5
