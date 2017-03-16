From: Numan Siddique <nusiddiq-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [RFC] [net]openvswitch: Clear the ct flow key for the
 recirculated packet
Date: Thu, 16 Mar 2017 17:55:06 +0530
Message-ID: <af0d1942-726b-b637-e8e3-2f4857bb00a2@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
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

It is possible that the ct flow key information would have
gone stale for the packets received from the userspace due to
clone or ct_clear actions.

In the case of OVN, it adds ping responder flows, which modifies
the original icmp4 request packet to a reply packet. It uses the
OVS actions - clone and ct_clear. When the reply packet hits the
"ovs_ct_execute" function, and since the ct flow key info is not
cleared, the connection tracker doesn't set the state to
ESTABLISHED state.

Note: This patch is marked as RFC, as I am not sure if this is the correct
place to address this issue or it should be addressed in ovs-vswitchd
to set the OVS_KEY_ATTR_CT_STATE and other related attributes
properly for ct_clear action.

Signed-off-by: Numan Siddique <nusiddiq-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/flow.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 9d4bb8e..72b73db 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -836,6 +836,11 @@ int ovs_flow_key_extract_userspace(struct net *net, const struct nlattr *attr,
 	if (err)
 		return err;
 
+	/* Clear the ct flow key after key_extract to avoid using
+	 * stale ct key information.
+	*/
+	ovs_ct_fill_key(skb, key);
+
 	/* Check that we have conntrack original direction tuple metadata only
 	 * for packets for which it makes sense.  Otherwise the key may be
 	 * corrupted due to overlapping key fields.
-- 
2.9.3
