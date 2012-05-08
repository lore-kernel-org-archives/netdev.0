From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/3] openvswitch: Validation of IPv6 set port
	action uses IPv4 header
Date: Mon,  7 May 2012 18:51:25 -0700
Message-ID: <1336441885-11085-4-git-send-email-jesse@nicira.com>
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

From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

When the kernel validates set TCP/UDP port actions, it looks at
the ports in the existing flow to make sure that the L4 header exists.
However, these actions always use the IPv4 version of the struct.
Following patch fixes this by checking for flow ip protocol first.

Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c |   22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 4cb615d..777716b 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -421,6 +421,19 @@ static int validate_sample(const struct nlattr *attr,
 	return validate_actions(actions, key, depth + 1);
 }
 
+static int validate_tp_port(const struct sw_flow_key *flow_key)
+{
+	if (flow_key->eth.type == htons(ETH_P_IP)) {
+		if (flow_key->ipv4.tp.src && flow_key->ipv4.tp.dst)
+			return 0;
+	} else if (flow_key->eth.type == htons(ETH_P_IPV6)) {
+		if (flow_key->ipv6.tp.src && flow_key->ipv6.tp.dst)
+			return 0;
+	}
+
+	return -EINVAL;
+}
+
 static int validate_set(const struct nlattr *a,
 			const struct sw_flow_key *flow_key)
 {
@@ -462,18 +475,13 @@ static int validate_set(const struct nlattr *a,
 		if (flow_key->ip.proto != IPPROTO_TCP)
 			return -EINVAL;
 
-		if (!flow_key->ipv4.tp.src || !flow_key->ipv4.tp.dst)
-			return -EINVAL;
-
-		break;
+		return validate_tp_port(flow_key);
 
 	case OVS_KEY_ATTR_UDP:
 		if (flow_key->ip.proto != IPPROTO_UDP)
 			return -EINVAL;
 
-		if (!flow_key->ipv4.tp.src || !flow_key->ipv4.tp.dst)
-			return -EINVAL;
-		break;
+		return validate_tp_port(flow_key);
 
 	default:
 		return -EINVAL;
-- 
1.7.9.5
