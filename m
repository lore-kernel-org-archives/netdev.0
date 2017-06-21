From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next V2] ibmvnic: Correct return code checking for
 ibmvnic_init during probe
Date: Wed, 21 Jun 2017 15:41:02 -0500
Message-ID: <149807766247.32243.8342302161340985903.stgit@mudbug>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:47956 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751108AbdFUUlJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 16:41:09 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5LKcbmf065917
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 16:41:07 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2b7ycw9kny-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 16:41:06 -0400
Received: from localhost
        by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Wed, 21 Jun 2017 16:41:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The update to ibmvnic_init to allow an EAGAIN return code broke
the calling of ibmvnic_init from ibmvnic_probe. The code now
will return from this point in the probe routine if anything
other than EAGAIN is returned. The check should be to see if rc
is non-zero and not equal to EAGAIN.

Without this fix, the vNIC driver can return 0 (success) from
its probe routine due to ibmvnic_init returning zero, but before
completing the probe process and registering with the netdev layer.

Fixes: 6a2fb0e99f9c (ibmvnic: driver initialization for kdump/kexec)
Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 0135095..05edf19 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -3737,7 +3737,7 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 
 	do {
 		rc = ibmvnic_init(adapter);
-		if (rc != EAGAIN) {
+		if (rc && rc != EAGAIN) {
 			free_netdev(netdev);
 			return rc;
 		}
