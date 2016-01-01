From: Nicholas Krause <xerofoify@gmail.com>
Subject: [PATCH RESEND] bridge:Fix concurrent access issue in the
	function brnf_get_logical_dev
Date: Fri,  1 Jan 2016 01:17:25 -0500
Message-ID: <1451629045-9017-1-git-send-email-xerofoify@gmail.com>
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kaber@trash.net,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	kadlec@blackhole.kfki.hu, davem@davemloft.net
To: pablo@netfilter.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
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

This fixes a concurrent access issue in the function brnf_get_logical_dev
by properly locking with the function rcu_read_lock before calling the
function vlan_find_dev_deep_rcu and unlocking after this function call
as all callers of this function are required to do this in order to
improve issues with concurrent access by other threads executing
on this data structures simultaneously.

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
---
 net/bridge/br_netfilter_hooks.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index c8b9bcf..73c84a8 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -428,9 +428,10 @@ static struct net_device *brnf_get_logical_dev(struct sk_buff *skb, const struct
 	if (brnf_pass_vlan_indev == 0 || !skb_vlan_tag_present(skb))
 		return br;
 
+	rcu_read_lock();
 	vlan = __vlan_find_dev_deep_rcu(br, skb->vlan_proto,
 				    skb_vlan_tag_get(skb) & VLAN_VID_MASK);
-
+	rcu_read_unlock();
 	return vlan ? vlan : br;
 }
 
-- 
2.1.4
