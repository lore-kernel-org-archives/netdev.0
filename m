From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: [PATCH 1/2] [NIU] Determine the # of ports from the card's VPD
 data.
Date: Thu, 24 Apr 2008 12:44:21 -0700
Message-ID: <4810E315.8080303@sun.com>
References: <200804231811.m3NIBhQl043628@sr1-umpk-33.sfbay.sun.com>
 <20080423.182848.74720455.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_eeRRzndVraYRrEfa7XtLgA)"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:52006 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759055AbYDXTpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 15:45:50 -0400
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m3OJjnHC009983
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 12:45:49 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0JZU00801HCXQD00@fe-sfbay-10.sun.com>
 (original mail from Matheos.Worku@Sun.COM) for netdev@vger.kernel.org; Thu,
 24 Apr 2008 12:45:49 -0700 (PDT)
In-reply-to: <20080423.182848.74720455.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

--Boundary_(ID_eeRRzndVraYRrEfa7XtLgA)
Content-type: text/plain; format=flowed; charset=ISO-8859-1
Content-transfer-encoding: 7BIT

David Miller wrote:
> From: Matheos Worku <matheos.worku@sun.com>
> Date: Wed, 23 Apr 2008 10:10:52 -0700
>
>   
>> +#define NIU_BMD_MATCHES(np, md_str) \
>> +  (!strncmp(np->vpd.board_model, md_str, strlen(md_str)))
>>     
>
> Why is this special construct necessary?  How can anyone tell the
> reason this is needed by reading this code?
>
> Plain ole' strcmp() should suffice.  If the string length is
> different, we should get a comparison failure.  We've also made sure
> that the board_model[] field is a properly null terminated string.
>
> Is the issue that there could be some spurious trailing characters in
> the board_model[] string that we'd like to ignore?
>
> If that's the case this comparison deserves it's own small function,
> with some descriptive text, rather than an ugly and undescriptive
> macro.
>   
Dave,
Thanks a lot for the feedback.
The board model contains a HW dash version number which changes with HW 
change. Need to ignore  the - version number.
A new patch, using a small function as you suggested is attached.

Matheos

> Something like:
>
> /* Board model strings can have trailing characters we wish
>  * to ignore during comparison, for example:
>  *
>  *	XXXX (add example(s) here) XXX
>  */
> static int niu_board_model_compare(struct niu *np, const char *model)
> {
> 	return strncmp(np->vpd.board_model, model, strlen(model));
> }
>
> Thanks.
>   


--Boundary_(ID_eeRRzndVraYRrEfa7XtLgA)
Content-type: text/x-patch; name=ncr.patch
Content-transfer-encoding: 7BIT
Content-disposition: inline; filename=ncr.patch

From: Matheos Worku <matheos.worku@sun.com>
Date: Thu, 24 Apr 2008 10:23:22 -0700
Subject: [PATCH 1/1] [NIU] Determine the # of ports from the card's VPD data


Signed-off-by: Matheos Worku <matheos.worku@sun.com>
---
 drivers/net/niu.c |   70 ++++++++++++++++++++++++++++++++++++++++++++--------
 drivers/net/niu.h |    9 +++++++
 2 files changed, 68 insertions(+), 11 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 7565c2d..431d490 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6773,6 +6773,41 @@ static int __devinit niu_phy_type_prop_decode(struct niu *np,
 	return 0;
 }
 
+/*
+ * niu board models have a trailing dash version incremented
+ * with HW rev change. Need to ingnore the  dash version while
+ * checking for match
+ * 
+ * for example, for the 10G card the current vpd.board_model
+ * is 501-5283-04, of which -04 is the  dash version and have
+ * to be ignored
+ *
+ */
+
+static int niu_board_model_match(struct niu *np, const char *model)
+{
+	return !strncmp(np->vpd.board_model, model, strlen(model));
+}
+
+static int niu_pci_vpd_get_nports(struct niu *np)
+{
+	int ports = 0;
+
+	if ((niu_board_model_match(np, NIU_QGC_LP_BM_STR)) ||
+		(niu_board_model_match(np, NIU_QGC_PEM_BM_STR)) ||
+		(niu_board_model_match(np, NIU_ALONSO_BM_STR))) {
+		ports = 4;
+	} else if ((niu_board_model_match(np, NIU_2XGF_LP_BM_STR)) ||
+			   (niu_board_model_match(np, NIU_2XGF_PEM_BM_STR)) ||
+			   (niu_board_model_match(np, NIU_FOXXY_BM_STR)) ||
+			   (niu_board_model_match(np, NIU_2XGF_MRVL_BM_STR))) {
+		ports = 2;
+	}
+
+	return (ports);
+}
+
+
 static void __devinit niu_pci_vpd_validate(struct niu *np)
 {
 	struct net_device *dev = np->dev;
@@ -6976,6 +7011,7 @@ static int __devinit niu_pci_probe_sprom(struct niu *np)
 	return 0;
 }
 
+
 static int __devinit niu_get_and_validate_port(struct niu *np)
 {
 	struct niu_parent *parent = np->parent;
@@ -6987,11 +7023,15 @@ static int __devinit niu_get_and_validate_port(struct niu *np)
 		if (parent->plat_type == PLAT_TYPE_NIU) {
 			parent->num_ports = 2;
 		} else {
-			parent->num_ports = nr64(ESPC_NUM_PORTS_MACS) &
-				ESPC_NUM_PORTS_MACS_VAL;
-
-			if (!parent->num_ports)
-				parent->num_ports = 4;
+			parent->num_ports = niu_pci_vpd_get_nports(np);
+			if (!parent->num_ports) {
+				/* fall back to SPROM as last resort. will fail on most cards*/
+				parent->num_ports = nr64(ESPC_NUM_PORTS_MACS) &
+					ESPC_NUM_PORTS_MACS_VAL;
+
+				if (!parent->num_ports)
+					return -ENODEV;
+			}
 		}
 	}
 
@@ -7733,15 +7773,16 @@ static int __devinit niu_get_invariants(struct niu *np)
 
 	have_props = !err;
 
-	err = niu_get_and_validate_port(np);
-	if (err)
-		return err;
-
 	err = niu_init_mac_ipp_pcs_base(np);
 	if (err)
 		return err;
 
-	if (!have_props) {
+	if (have_props) {
+		err = niu_get_and_validate_port(np);
+		if (err)
+			return err;
+
+	} else  {
 		if (np->parent->plat_type == PLAT_TYPE_NIU)
 			return -EINVAL;
 
@@ -7753,10 +7794,17 @@ static int __devinit niu_get_invariants(struct niu *np)
 			niu_pci_vpd_fetch(np, offset);
 		nw64(ESPC_PIO_EN, 0);
 
-		if (np->flags & NIU_FLAGS_VPD_VALID)
+		if (np->flags & NIU_FLAGS_VPD_VALID) {
 			niu_pci_vpd_validate(np);
+			err = niu_get_and_validate_port(np);
+			if (err)
+				return err;
+		}
 
 		if (!(np->flags & NIU_FLAGS_VPD_VALID)) {
+			err = niu_get_and_validate_port(np);
+			if (err)
+				return err;
 			err = niu_pci_probe_sprom(np);
 			if (err)
 				return err;
diff --git a/drivers/net/niu.h b/drivers/net/niu.h
index 336aed0..257dd16 100644
--- a/drivers/net/niu.h
+++ b/drivers/net/niu.h
@@ -2936,6 +2936,15 @@ struct rx_ring_info {
 #define MAC_NUM_HASH		16
 
 #define NIU_MAX_MTU		9216
+/* vpd strings */
+
+#define	NIU_QGC_LP_BM_STR	"501-7606"
+#define	NIU_2XGF_LP_BM_STR	"501-7283"
+#define	NIU_QGC_PEM_BM_STR	"501-7765"
+#define	NIU_2XGF_PEM_BM_STR	"501-7626"
+#define	NIU_ALONSO_BM_STR	"373-0202"
+#define	NIU_FOXXY_BM_STR	"501-7961"
+#define	NIU_2XGF_MRVL_BM_STR	"SK-6E82"
 
 #define NIU_VPD_MIN_MAJOR	3
 #define NIU_VPD_MIN_MINOR	4
-- 
1.5.2


--Boundary_(ID_eeRRzndVraYRrEfa7XtLgA)--
