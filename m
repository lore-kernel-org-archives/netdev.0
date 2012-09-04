From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net 1/3] openvswitch: Relax set header validation.
Date: Tue,  4 Sep 2012 12:08:06 -0700
Message-ID: <1346785688-2910-2-git-send-email-jesse@nicira.com>
References: <1346785688-2910-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1346785688-2910-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

When installing a flow with an action to set a particular field we
need to validate that the packets that are part of the flow actually
contain that header.  With IP we use zeroed addresses and with TCP/UDP
the check is for zeroed ports.  This check is overly broad and can catch
packets like DHCP requests that have a zero source address in a
legitimate header.  This changes the check to look for a zeroed protocol
number for IP or for both ports be zero for TCP/UDP before considering
the header to not exist.

Reported-by: Ethan Jackson <ethan-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index d8277d2..cf58ced 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -425,10 +425,10 @@ static int validate_sample(const struct nlattr *attr,
 static int validate_tp_port(const struct sw_flow_key *flow_key)
 {
 	if (flow_key->eth.type == htons(ETH_P_IP)) {
-		if (flow_key->ipv4.tp.src && flow_key->ipv4.tp.dst)
+		if (flow_key->ipv4.tp.src || flow_key->ipv4.tp.dst)
 			return 0;
 	} else if (flow_key->eth.type == htons(ETH_P_IPV6)) {
-		if (flow_key->ipv6.tp.src && flow_key->ipv6.tp.dst)
+		if (flow_key->ipv6.tp.src || flow_key->ipv6.tp.dst)
 			return 0;
 	}
 
@@ -460,7 +460,7 @@ static int validate_set(const struct nlattr *a,
 		if (flow_key->eth.type != htons(ETH_P_IP))
 			return -EINVAL;
 
-		if (!flow_key->ipv4.addr.src || !flow_key->ipv4.addr.dst)
+		if (!flow_key->ip.proto)
 			return -EINVAL;
 
 		ipv4_key = nla_data(ovs_key);
-- 
1.7.9.5
