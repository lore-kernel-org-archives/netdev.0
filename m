From: frank.blaschka@de.ibm.com
Subject: [patch 2/3] s390/qdio: bridgeport support - CHSC part
Date: Tue, 14 Jan 2014 15:54:12 +0100
Message-ID: <20140114145509.412117449@de.ibm.com>
References: <20140114145410.453840919@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Eugene Crosser <eugene.crosser@ru.ibm.com>,
	Sebastian Ott <sebott@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:37984 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462AbaANOzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 09:55:14 -0500
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 14 Jan 2014 14:55:13 -0000
Content-Disposition: inline; filename=603-qeth-bridgeport-chsc.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>

Introduce function for the "Perform network-subchannel operation"
CHSC command with operation code "bridgeport information",
and bit definitions for "characteristics" pertaning to this command.

Signed-off-by: Eugene Crosser <eugene.crosser@ru.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Reviewed-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
---
 arch/s390/include/asm/css_chars.h |    2 
 arch/s390/include/asm/qdio.h      |   33 +++++++++++++
 drivers/s390/cio/chsc.c           |   33 +++++++++++++
 drivers/s390/cio/chsc.h           |   51 ++++++++++++++++++++-
 drivers/s390/cio/qdio_main.c      |   91 ++++++++++++++++++++++++++++++++++++++
 5 files changed, 209 insertions(+), 1 deletion(-)

--- a/arch/s390/include/asm/css_chars.h
+++ b/arch/s390/include/asm/css_chars.h
@@ -29,6 +29,8 @@ struct css_general_char {
 	u32 fcx : 1;	 /* bit 88 */
 	u32 : 19;
 	u32 alt_ssi : 1; /* bit 108 */
+	u32:1;
+	u32 narf:1;	 /* bit 110 */
 } __packed;
 
 extern struct css_general_char css_general_characteristics;
--- a/arch/s390/include/asm/qdio.h
+++ b/arch/s390/include/asm/qdio.h
@@ -378,6 +378,34 @@ struct qdio_initialize {
 	struct qdio_outbuf_state *output_sbal_state_array;
 };
 
+/**
+ * enum qdio_brinfo_entry_type - type of address entry for qdio_brinfo_desc()
+ * @l3_ipv6_addr: entry contains IPv6 address
+ * @l3_ipv4_addr: entry contains IPv4 address
+ * @l2_addr_lnid: entry contains MAC address and VLAN ID
+ */
+enum qdio_brinfo_entry_type {l3_ipv6_addr, l3_ipv4_addr, l2_addr_lnid};
+
+/**
+ * struct qdio_brinfo_entry_XXX - Address entry for qdio_brinfo_desc()
+ * @nit:  Network interface token
+ * @addr: Address of one of the three types
+ *
+ * The struct is passed to the callback function by qdio_brinfo_desc()
+ */
+struct qdio_brinfo_entry_l3_ipv6 {
+	u64 nit;
+	struct { unsigned char _s6_addr[16]; } addr;
+} __packed;
+struct qdio_brinfo_entry_l3_ipv4 {
+	u64 nit;
+	struct { uint32_t _s_addr; } addr;
+} __packed;
+struct qdio_brinfo_entry_l2 {
+	u64 nit;
+	struct { u8 mac[6]; u16 lnid; } addr_lnid;
+} __packed;
+
 #define QDIO_STATE_INACTIVE		0x00000002 /* after qdio_cleanup */
 #define QDIO_STATE_ESTABLISHED		0x00000004 /* after qdio_establish */
 #define QDIO_STATE_ACTIVE		0x00000008 /* after qdio_activate */
@@ -399,5 +427,10 @@ extern int qdio_get_next_buffers(struct
 extern int qdio_shutdown(struct ccw_device *, int);
 extern int qdio_free(struct ccw_device *);
 extern int qdio_get_ssqd_desc(struct ccw_device *, struct qdio_ssqd_desc *);
+extern int qdio_pnso_brinfo(struct subchannel_id schid,
+		int cnc, u16 *response,
+		void (*cb)(void *priv, enum qdio_brinfo_entry_type type,
+				void *entry),
+		void *priv);
 
 #endif /* __QDIO_H__ */
--- a/drivers/s390/cio/chsc.c
+++ b/drivers/s390/cio/chsc.c
@@ -55,6 +55,7 @@ int chsc_error_from_response(int respons
 	case 0x0004:
 		return -EOPNOTSUPP;
 	case 0x000b:
+	case 0x0107:		/* "Channel busy" for the op 0x003d */
 		return -EBUSY;
 	case 0x0100:
 	case 0x0102:
@@ -1234,3 +1235,35 @@ out:
 	return ret;
 }
 EXPORT_SYMBOL_GPL(chsc_scm_info);
+
+/**
+ * chsc_pnso_brinfo() - Perform Network-Subchannel Operation, Bridge Info.
+ * @schid:		id of the subchannel on which PNSO is performed
+ * @brinfo_area:	request and response block for the operation
+ * @resume_token:	resume token for multiblock response
+ * @cnc:		Boolean change-notification control
+ *
+ * brinfo_area must be allocated by the caller with get_zeroed_page(GFP_KERNEL)
+ *
+ * Returns 0 on success.
+ */
+int chsc_pnso_brinfo(struct subchannel_id schid,
+		struct chsc_pnso_area *brinfo_area,
+		struct chsc_brinfo_resume_token resume_token,
+		int cnc)
+{
+	memset(brinfo_area, 0, sizeof(*brinfo_area));
+	brinfo_area->request.length = 0x0030;
+	brinfo_area->request.code = 0x003d; /* network-subchannel operation */
+	brinfo_area->m	   = schid.m;
+	brinfo_area->ssid  = schid.ssid;
+	brinfo_area->sch   = schid.sch_no;
+	brinfo_area->cssid = schid.cssid;
+	brinfo_area->oc    = 0; /* Store-network-bridging-information list */
+	brinfo_area->resume_token = resume_token;
+	brinfo_area->n	   = (cnc != 0);
+	if (chsc(brinfo_area))
+		return -EIO;
+	return chsc_error_from_response(brinfo_area->response.code);
+}
+EXPORT_SYMBOL_GPL(chsc_pnso_brinfo);
--- a/drivers/s390/cio/chsc.h
+++ b/drivers/s390/cio/chsc.h
@@ -61,7 +61,9 @@ struct css_chsc_char {
 	u32 : 20;
 	u32 scssc : 1;  /* bit 107 */
 	u32 scsscf : 1; /* bit 108 */
-	u32 : 19;
+	u32:7;
+	u32 pnso:1; /* bit 116 */
+	u32:11;
 }__attribute__((packed));
 
 extern struct css_chsc_char css_chsc_characteristics;
@@ -188,6 +190,53 @@ struct chsc_scm_info {
 
 int chsc_scm_info(struct chsc_scm_info *scm_area, u64 token);
 
+struct chsc_brinfo_resume_token {
+	u64 t1;
+	u64 t2;
+} __packed;
+
+struct chsc_brinfo_naihdr {
+	struct chsc_brinfo_resume_token resume_token;
+	u32:32;
+	u32 instance;
+	u32:24;
+	u8 naids;
+	u32 reserved[3];
+} __packed;
+
+struct chsc_pnso_area {
+	struct chsc_header request;
+	u8:2;
+	u8 m:1;
+	u8:5;
+	u8:2;
+	u8 ssid:2;
+	u8 fmt:4;
+	u16 sch;
+	u8:8;
+	u8 cssid;
+	u16:16;
+	u8 oc;
+	u32:24;
+	struct chsc_brinfo_resume_token resume_token;
+	u32 n:1;
+	u32:31;
+	u32 reserved[3];
+	struct chsc_header response;
+	u32:32;
+	struct chsc_brinfo_naihdr naihdr;
+	union {
+		struct qdio_brinfo_entry_l3_ipv6 l3_ipv6[0];
+		struct qdio_brinfo_entry_l3_ipv4 l3_ipv4[0];
+		struct qdio_brinfo_entry_l2	 l2[0];
+	} entries;
+} __packed;
+
+int chsc_pnso_brinfo(struct subchannel_id schid,
+		struct chsc_pnso_area *brinfo_area,
+		struct chsc_brinfo_resume_token resume_token,
+		int cnc);
+
 #ifdef CONFIG_SCM_BUS
 int scm_update_information(void);
 int scm_process_availability_information(void);
--- a/drivers/s390/cio/qdio_main.c
+++ b/drivers/s390/cio/qdio_main.c
@@ -1752,6 +1752,97 @@ int qdio_stop_irq(struct ccw_device *cde
 }
 EXPORT_SYMBOL(qdio_stop_irq);
 
+/**
+ * qdio_pnso_brinfo() - perform network subchannel op #0 - bridge info.
+ * @schid:		Subchannel ID.
+ * @cnc:		Boolean Change-Notification Control
+ * @response:		Response code will be stored at this address
+ * @cb:			Callback function will be executed for each element
+ *			of the address list
+ * @priv:		Pointer passed from the caller to qdio_pnso_brinfo()
+ * @type:		Type of the address entry passed to the callback
+ * @entry:		Entry containg the address of the specified type
+ * @priv:		Pointer to pass to the callback function.
+ *
+ * Performs "Store-network-bridging-information list" operation and calls
+ * the callback function for every entry in the list. If "change-
+ * notification-control" is set, further changes in the address list
+ * will be reported via the IPA command.
+ */
+int qdio_pnso_brinfo(struct subchannel_id schid,
+		int cnc, u16 *response,
+		void (*cb)(void *priv, enum qdio_brinfo_entry_type type,
+				void *entry),
+		void *priv)
+{
+	struct chsc_pnso_area *rr;
+	int rc;
+	u32 prev_instance = 0;
+	int isfirstblock = 1;
+	int i, size, elems;
+
+	rr = (struct chsc_pnso_area *)get_zeroed_page(GFP_KERNEL);
+	if (rr == NULL)
+		return -ENOMEM;
+	do {
+		/* on the first iteration, naihdr.resume_token will be zero */
+		rc = chsc_pnso_brinfo(schid, rr, rr->naihdr.resume_token, cnc);
+		if (rc != 0 && rc != -EBUSY)
+			goto out;
+		if (rr->response.code != 1) {
+			rc = -EIO;
+			continue;
+		} else
+			rc = 0;
+
+		if (cb == NULL)
+			continue;
+
+		size = rr->naihdr.naids;
+		elems = (rr->response.length -
+				sizeof(struct chsc_header) -
+				sizeof(struct chsc_brinfo_naihdr)) /
+				size;
+
+		if (!isfirstblock && (rr->naihdr.instance != prev_instance)) {
+			/* Inform the caller that they need to scrap */
+			/* the data that was already reported via cb */
+				rc = -EAGAIN;
+				break;
+		}
+		isfirstblock = 0;
+		prev_instance = rr->naihdr.instance;
+		for (i = 0; i < elems; i++)
+			switch (size) {
+			case sizeof(struct qdio_brinfo_entry_l3_ipv6):
+				(*cb)(priv, l3_ipv6_addr,
+						&rr->entries.l3_ipv6[i]);
+				break;
+			case sizeof(struct qdio_brinfo_entry_l3_ipv4):
+				(*cb)(priv, l3_ipv4_addr,
+						&rr->entries.l3_ipv4[i]);
+				break;
+			case sizeof(struct qdio_brinfo_entry_l2):
+				(*cb)(priv, l2_addr_lnid,
+						&rr->entries.l2[i]);
+				break;
+			default:
+				WARN_ON_ONCE(1);
+				rc = -EIO;
+				goto out;
+			}
+	} while (rr->response.code == 0x0107 ||  /* channel busy */
+		  (rr->response.code == 1 && /* list stored */
+		   /* resume token is non-zero => list incomplete */
+		   (rr->naihdr.resume_token.t1 || rr->naihdr.resume_token.t2)));
+	(*response) = rr->response.code;
+
+out:
+	free_page((unsigned long)rr);
+	return rc;
+}
+EXPORT_SYMBOL_GPL(qdio_pnso_brinfo);
+
 static int __init init_QDIO(void)
 {
 	int rc;
