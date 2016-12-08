From: Yi Yang <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next] openvswitch: fix VxLAN-gpe port can't be
	created in ovs compat mode
Date: Thu,  8 Dec 2016 16:20:10 +0800
Message-ID: <1481185210-13056-1-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

In ovs compat mode, ovs won't use LWT in current kernel, this is to
make sure ovs can work on the old kernels, Linux kernel v4.7 includes
VxLAN-gpe support but many Linux distributions' kernels are odler than
v4.7, this fix will ensure that ovs can create VxLAN-gpe port correctly
on old kernels, it has been verified on Ubuntu 16.04 x86_64 with Linux
kernel 4.4.0-53-generic.

This does touch compat code, but it is necessary as Pravin commented.

Without this fix, ovs can't create VxLAN-gpe port, it is still a VxLAN
port.

vxlan_sys_4790 Link encap:Ethernet  HWaddr 72:23:60:c2:8b:8d
          inet6 addr: fe80::7023:60ff:fec2:8b8d/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:65485  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:8 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

But with this fix applied, a real L3 port is created

vxlan_sys_4790 Link encap:UNSPEC  HWaddr
00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
          UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:65485  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

Signed-off-by: Yi Yang <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 include/uapi/linux/openvswitch.h |  1 +
 net/openvswitch/vport-vxlan.c    | 15 +++++++++++++++
 2 files changed, 16 insertions(+)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 375d812..b0e27b3 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -265,6 +265,7 @@ enum ovs_vport_attr {
 enum {
 	OVS_VXLAN_EXT_UNSPEC,
 	OVS_VXLAN_EXT_GBP,	/* Flag or __u32 */
+	OVS_VXLAN_EXT_GPE,	/* Flag or __u32 */
 	__OVS_VXLAN_EXT_MAX,
 };
 
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 7eb955e..42e46af 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -52,6 +52,18 @@ static int vxlan_get_options(const struct vport *vport, struct sk_buff *skb)
 			return -EMSGSIZE;
 
 		nla_nest_end(skb, exts);
+	} else if (vxlan->flags & VXLAN_F_GPE) {
+		struct nlattr *exts;
+
+		exts = nla_nest_start(skb, OVS_TUNNEL_ATTR_EXTENSION);
+		if (!exts)
+			return -EMSGSIZE;
+
+		if (vxlan->flags & VXLAN_F_GPE &&
+		    nla_put_flag(skb, OVS_VXLAN_EXT_GPE))
+			return -EMSGSIZE;
+
+		nla_nest_end(skb, exts);
 	}
 
 	return 0;
@@ -59,6 +71,7 @@ static int vxlan_get_options(const struct vport *vport, struct sk_buff *skb)
 
 static const struct nla_policy exts_policy[OVS_VXLAN_EXT_MAX + 1] = {
 	[OVS_VXLAN_EXT_GBP]	= { .type = NLA_FLAG, },
+	[OVS_VXLAN_EXT_GPE]	= { .type = NLA_FLAG, },
 };
 
 static int vxlan_configure_exts(struct vport *vport, struct nlattr *attr,
@@ -76,6 +89,8 @@ static int vxlan_configure_exts(struct vport *vport, struct nlattr *attr,
 
 	if (exts[OVS_VXLAN_EXT_GBP])
 		conf->flags |= VXLAN_F_GBP;
+	else if (exts[OVS_VXLAN_EXT_GPE])
+		conf->flags |= VXLAN_F_GPE;
 
 	return 0;
 }
-- 
1.9.3
