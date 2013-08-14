From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net 3/3] openvswitch: Reset tunnel key between
	input and output.
Date: Wed, 14 Aug 2013 16:19:07 -0700
Message-ID: <1376522347-39531-4-git-send-email-jesse@nicira.com>
References: <1376522347-39531-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1376522347-39531-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

It doesn't make sense to output a tunnel packet using the same
parameters that it was received with since that will generally
just result in the packet going back to us. As a result, userspace
assumes that the tunnel key is cleared when transitioning through
the switch. In the majority of cases this doesn't matter since a
packet is either going to a tunnel port (in which the key is
overwritten with new values) or to a non-tunnel port (in which
case the key is ignored). However, it's theoreticaly possible that
userspace could rely on the documented behavior, so this corrects
it.

Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/actions.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 22c5f39..ab101f7 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -535,6 +535,7 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb)
 {
 	struct sw_flow_actions *acts = rcu_dereference(OVS_CB(skb)->flow->sf_acts);
 
+	OVS_CB(skb)->tun_key = NULL;
 	return do_execute_actions(dp, skb, acts->actions,
 					 acts->actions_len, false);
 }
-- 
1.8.1.2
