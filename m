From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 06/11] isdn/gigaset: handle Supplementary Service Listen
Date: Tue,  6 Jul 2010 02:19:04 +0200 (CEST)
Message-ID: <20100705-patch-gigaset-06.tilman@imap.cc>
References: <20100705-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100705-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add minimal handling for the non-optional CAPI FACILITY_REQ
Supplementary Service function Listen.

Impact: bugfix
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/capi.c |   27 ++++++++++++++++++++++++++-
 1 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index ff074e9..3714aef 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -45,6 +45,7 @@
 #define CAPI_FACILITY_LI	0x0005
 
 #define CAPI_SUPPSVC_GETSUPPORTED	0x0000
+#define CAPI_SUPPSVC_LISTEN		0x0001
 
 /* missing from capiutil.h */
 #define CAPIMSG_PLCI_PART(m)	CAPIMSG_U8(m, 9)
@@ -1151,7 +1152,7 @@ static void do_facility_req(struct gigaset_capi_ctr *iif,
 	case CAPI_FACILITY_SUPPSVC:
 		/* decode Function parameter */
 		pparam = cmsg->FacilityRequestParameter;
-		if (pparam == NULL || *pparam < 2) {
+		if (pparam == NULL || pparam[0] < 2) {
 			dev_notice(cs->dev, "%s: %s missing\n", "FACILITY_REQ",
 				   "Facility Request Parameter");
 			send_conf(iif, ap, skb, CapiIllMessageParmCoding);
@@ -1168,8 +1169,32 @@ static void do_facility_req(struct gigaset_capi_ctr *iif,
 			/* Supported Services: none */
 			capimsg_setu32(confparam, 6, 0);
 			break;
+		case CAPI_SUPPSVC_LISTEN:
+			if (pparam[0] < 7 || pparam[3] < 4) {
+				dev_notice(cs->dev, "%s: %s missing\n",
+					   "FACILITY_REQ", "Notification Mask");
+				send_conf(iif, ap, skb,
+					  CapiIllMessageParmCoding);
+				return;
+			}
+			if (CAPIMSG_U32(pparam, 4) != 0) {
+				dev_notice(cs->dev,
+	"%s: unsupported supplementary service notification mask 0x%x\n",
+				   "FACILITY_REQ", CAPIMSG_U32(pparam, 4));
+				info = CapiFacilitySpecificFunctionNotSupported;
+				confparam[3] = 2;	/* length */
+				capimsg_setu16(confparam, 4,
+					CapiSupplementaryServiceNotSupported);
+			}
+			info = CapiSuccess;
+			confparam[3] = 2;	/* length */
+			capimsg_setu16(confparam, 4, CapiSuccess);
+			break;
 		/* ToDo: add supported services */
 		default:
+			dev_notice(cs->dev,
+		"%s: unsupported supplementary service function 0x%04x\n",
+				   "FACILITY_REQ", function);
 			info = CapiFacilitySpecificFunctionNotSupported;
 			/* Supplementary Service specific parameter */
 			confparam[3] = 2;	/* length */
-- 
1.6.5.3.298.g39add
