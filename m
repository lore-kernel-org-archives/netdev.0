From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: [PATCH net-next] openvswitch: Don't insert empty
	OVS_VPORT_ATTR_OPTIONS attribute
Date: Wed,  3 Apr 2013 00:30:43 +0200
Message-ID: <8f6704668f7f795658b48a7b0219c88d0ca088a3.1364941760.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
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

The port specific options are currently unused resulting in an
empty OVS_VPORT_ATTR_OPTIONS nested attribute being inserted
into every OVS_VPORT_CMD_GET message.

Don't insert OVS_VPORT_ATTR_OPTIONS if no options are present.

Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
---
 net/openvswitch/vport.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index f6b8132..71a2de8 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -301,17 +301,19 @@ void ovs_vport_get_stats(struct vport *vport, struct ovs_vport_stats *stats)
 int ovs_vport_get_options(const struct vport *vport, struct sk_buff *skb)
 {
 	struct nlattr *nla;
+	int err;
+
+	if (!vport->ops->get_options)
+		return 0;
 
 	nla = nla_nest_start(skb, OVS_VPORT_ATTR_OPTIONS);
 	if (!nla)
 		return -EMSGSIZE;
 
-	if (vport->ops->get_options) {
-		int err = vport->ops->get_options(vport, skb);
-		if (err) {
-			nla_nest_cancel(skb, nla);
-			return err;
-		}
+	err = vport->ops->get_options(vport, skb);
+	if (err) {
+		nla_nest_cancel(skb, nla);
+		return err;
 	}
 
 	nla_nest_end(skb, nla);
-- 
1.7.11.7
