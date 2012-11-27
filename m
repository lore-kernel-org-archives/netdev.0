From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net 2/2] openvswitch: Store flow key len if ARP
	opcode is not request or reply.
Date: Tue, 27 Nov 2012 10:37:03 -0800
Message-ID: <1354041423-3050-3-git-send-email-jesse@nicira.com>
References: <1354041423-3050-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mehak Mahajan <mmahajan-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1354041423-3050-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

From: Mehak Mahajan <mmahajan-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

We currently only extract the ARP payload if the opcode indicates
that it is a request or reply.  However, we also only set the
key length in these situations even though it should still be
possible to match on the opcode.  There's no real reason to
restrict the ARP opcode since all have the same format so this
simply removes the check.

Signed-off-by: Mehak Mahajan <mmahajan-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/flow.c |   14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 98c7063..733cbf4 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -702,15 +702,11 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key,
 			/* We only match on the lower 8 bits of the opcode. */
 			if (ntohs(arp->ar_op) <= 0xff)
 				key->ip.proto = ntohs(arp->ar_op);
-
-			if (key->ip.proto == ARPOP_REQUEST
-					|| key->ip.proto == ARPOP_REPLY) {
-				memcpy(&key->ipv4.addr.src, arp->ar_sip, sizeof(key->ipv4.addr.src));
-				memcpy(&key->ipv4.addr.dst, arp->ar_tip, sizeof(key->ipv4.addr.dst));
-				memcpy(key->ipv4.arp.sha, arp->ar_sha, ETH_ALEN);
-				memcpy(key->ipv4.arp.tha, arp->ar_tha, ETH_ALEN);
-				key_len = SW_FLOW_KEY_OFFSET(ipv4.arp);
-			}
+			memcpy(&key->ipv4.addr.src, arp->ar_sip, sizeof(key->ipv4.addr.src));
+			memcpy(&key->ipv4.addr.dst, arp->ar_tip, sizeof(key->ipv4.addr.dst));
+			memcpy(key->ipv4.arp.sha, arp->ar_sha, ETH_ALEN);
+			memcpy(key->ipv4.arp.tha, arp->ar_tha, ETH_ALEN);
+			key_len = SW_FLOW_KEY_OFFSET(ipv4.arp);
 		}
 	} else if (key->eth.type == htons(ETH_P_IPV6)) {
 		int nh_len;             /* IPv6 Header + Extensions */
-- 
1.7.9.5
