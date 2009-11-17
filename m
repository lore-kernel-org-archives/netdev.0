From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC PATCH iproute2] ip: Add support for setting MAC and VLAN on
	hardware queues
Date: Tue, 17 Nov 2009 13:55:07 -0800
Message-ID: <20091117215432.15195.94504.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:36532 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752194AbZKQVzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 16:55:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Williams, Mitch A <mitch.a.williams@intel.com>

This patch adds support to the "ip" tool for setting the MAC address and
VLAN filter for hardware device queues. This is most immediately useful for
SR-IOV; for VF devices to be usable in the real world, the hypervisor or VM
manager must be able to set these parameters before the VF device is
assigned to any VM.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/if_link.h |   16 ++++++++++++++++
 ip/iplink.c             |   29 +++++++++++++++++++++++++++--
 2 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index b0b9e8a..a458d63 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -81,6 +81,8 @@ enum
 #define IFLA_LINKINFO IFLA_LINKINFO
 	IFLA_NET_NS_PID,
 	IFLA_IFALIAS,
+	IFLA_QUEUE_MAC,		/* Hardware queue specific attributes */
+	IFLA_QUEUE_VLAN,
 	__IFLA_MAX
 };
 
@@ -188,4 +190,18 @@ struct ifla_vlan_qos_mapping
 	__u32 to;
 };
 
+/* subqueue managment section */
+
+struct ifla_queue_mac
+{
+	__u32 queue;
+	__u8 mac[32]; /* MAX_ADDR_LEN */
+};
+
+struct ifla_queue_vlan
+{
+	__u32 queue;
+	__u32 vlan;
+};
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/ip/iplink.c b/ip/iplink.c
index 32cce24..9542d62 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -68,7 +68,9 @@ void iplink_usage(void)
 	fprintf(stderr, "	                  [ mtu MTU ]\n");
 	fprintf(stderr, "	                  [ netns PID ]\n");
 	fprintf(stderr, "			  [ alias NAME ]\n");
-	fprintf(stderr, "       ip link show [ DEVICE ]\n");
+	fprintf(stderr, "	                  [ queue NUM [ mac LLADDR ]\n");
+	fprintf(stderr, "				      [ vlan VLANID ] ] \n");
+	fprintf(stderr, "       ip link show [ DEVICE [ queue NUM] ]\n");
 
 	if (iplink_have_newlink()) {
 		fprintf(stderr, "\n");
@@ -176,7 +178,7 @@ struct iplink_req {
 int iplink_parse(int argc, char **argv, struct iplink_req *req,
 		char **name, char **type, char **link, char **dev)
 {
-	int ret, len;
+	int ret, len, qnum;
 	char abuf[32];
 	int qlen = -1;
 	int mtu = -1;
@@ -278,6 +280,29 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 				req->i.ifi_flags |= IFF_NOARP;
 			} else
 				return on_off("noarp");
+		} else if (strcmp(*argv, "queue") == 0) {
+			NEXT_ARG();
+			if (get_integer(&qnum,  *argv, 0)) {
+				invarg("Invalid \"queue\" value\n", *argv);
+			}
+			NEXT_ARG();
+			if (matches(*argv, "mac") == 0) {
+				struct ifla_queue_mac iqm;
+				NEXT_ARG();
+				iqm.queue = qnum;
+				len = ll_addr_a2n((char *)iqm.mac, 32, *argv);
+				if (len < 0)
+					return -1;
+				addattr_l(&req->n, sizeof(*req), IFLA_QUEUE_MAC, &iqm, sizeof(iqm));
+			} else if (matches(*argv, "vlan") == 0) {
+				struct ifla_queue_vlan iqv;
+				NEXT_ARG();
+				if (get_unsigned(&iqv.vlan, *argv, 0)) {
+					invarg("Invalid \"vlan\" value\n", *argv);
+				}
+				iqv.queue = qnum;
+				addattr_l(&req->n, sizeof(*req), IFLA_QUEUE_VLAN, &iqv, sizeof(iqv));
+			}
 #ifdef IFF_DYNAMIC
 		} else if (matches(*argv, "dynamic") == 0) {
 			NEXT_ARG();

