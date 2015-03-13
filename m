From: Alexey Kodanev <alexey.kodanev@oracle.com>
Subject: [PATCH] vxlan: fix wrong usage of VXLAN_VID_MASK
Date: Fri, 13 Mar 2015 19:13:53 +0300
Message-ID: <1426263233-27443-1-git-send-email-alexey.kodanev@oracle.com>
Cc: linux-kernel@vger.kernel.org, vasily.isaenko@oracle.com,
	Alexey Kodanev <alexey.kodanev@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit dfd8645ea1bd9127 wrongly assumes that VXLAN_VDI_MASK includes
eight lower order reserved bits of VNI field that are using for remote
checksum offload.

Right now, when VNI number greater then 0xffff, vxlan_udp_encap_recv()
will always return with 'bad_flag' error, reducing the usable vni range
from 0..16777215 to 0..65535. Also, it doesn't really check whether RCO
bits processed or not.

Fix it by adding new VNI mask which has all 32 bits of VNI field:
24 bits for id and 8 bits for other usage.

Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
---
 drivers/net/vxlan.c |    4 ++--
 include/net/vxlan.h |    1 +
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1e0a775..f8528a4 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1218,7 +1218,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 			goto drop;
 
 		flags &= ~VXLAN_HF_RCO;
-		vni &= VXLAN_VID_MASK;
+		vni &= VXLAN_VNI_MASK;
 	}
 
 	/* For backwards compatibility, only allow reserved fields to be
@@ -1239,7 +1239,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		flags &= ~VXLAN_GBP_USED_BITS;
 	}
 
-	if (flags || (vni & ~VXLAN_VID_MASK)) {
+	if (flags || vni & ~VXLAN_VNI_MASK) {
 		/* If there are any unprocessed flags remaining treat
 		 * this as a malformed packet. This behavior diverges from
 		 * VXLAN RFC (RFC7348) which stipulates that bits in reserved
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index eabd3a0..c73e7ab 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -91,6 +91,7 @@ struct vxlanhdr {
 
 #define VXLAN_N_VID     (1u << 24)
 #define VXLAN_VID_MASK  (VXLAN_N_VID - 1)
+#define VXLAN_VNI_MASK  (VXLAN_VID_MASK << 8)
 #define VXLAN_HLEN (sizeof(struct udphdr) + sizeof(struct vxlanhdr))
 
 struct vxlan_metadata {
-- 
1.7.1
