From: "Ravinandan Arakali" <ravinandan.arakali@s2io.com>
Subject: RE: [PATCH 2.6.9-rc2 1/1] S2io: fixes in free_shared_mem function
Date: Thu, 2 Dec 2004 16:39:28 -0800
Message-ID: <003901c4d8d0$8cb11830$3a10100a@S2IOtech.com>
References: <20041118213506.1081C32887@linux.site>
Reply-To: <ravinandan.arakali@s2io.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <rapuru.sriram@s2io.com>, <leonid.grossman@s2io.com>,
        <alicia.pena@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Koushik'" <raghavendra.koushik@s2io.com>, <jgarzik@pobox.com>,
        <netdev@oss.sgi.com>, <kumarkr@us.ibm.com>
In-Reply-To: <20041118213506.1081C32887@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi KK,
Does this patch look okay ? Does it address your earlier comments ?

Thanks,
Ravi

-----Original Message-----
From: Koushik [mailto:raghavendra.koushik@s2io.com]
Sent: Thursday, November 18, 2004 1:35 PM
To: jgarzik@pobox.com; netdev@oss.sgi.com; kumarkr@us.ibm.com
Cc: rapuru.sriram@s2io.com; leonid.grossman@s2io.com;
alicia.pena@s2io.com; ravinandan.arakali@s2io.com;
raghavendra.koushik@s2io.com
Subject: [PATCH 2.6.9-rc2 1/1] S2io: fixes in free_shared_mem function


Hello All,
	As per KK's review comment received on Nov 8 about the free_shared_mem function, Iam sending the following patch.

The change log includes:

1. Break from the main 'for loop' if ba[i] is NULL.

2. In the second level 'for loop', if ba[i][j] is NULL, instead of 
continuing as was done previously, we now free the ba[i] pointer and 
break from the main 'for loop'.

3. In the 'while loop' inside the second tier 'for loop', if any of the 
three pointers (ba or ba->ba_0_org or ba->ba_1_org) is found to be NULL, 
then ba[i], ba[i][j] and the non NULL buffer pointer if any 
(ba_0_org or ba_1_org) is freed and break from the main 'for loop'.

Signed-off-by: Koushik <raghavendra.koushik@s2io.com>
Signed-off-by: Ravi <ravinandan.arakali@s2io.com>
---
diff -urN vanilla_linux/drivers/net/s2io.c linux-2.6.8.1/drivers/net/s2io.c
--- vanilla_linux/drivers/net/s2io.c	2004-11-16 16:42:16.429560736 -0800
+++ linux-2.6.8.1/drivers/net/s2io.c	2004-11-18 10:07:47.553183896 -0800
@@ -560,21 +560,35 @@
 	for (i = 0; i < config->rx_ring_num; i++) {
 		blk_cnt =
 		    config->rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK + 1);
+		if (!nic->ba[i])
+			goto end_free;
 		for (j = 0; j < blk_cnt; j++) {
 			int k = 0;
-			if (!nic->ba[i][j])
-				continue;
+			if (!nic->ba[i][j]) {
+				kfree(nic->ba[i]);
+				goto end_free;
+			}
 			while (k != MAX_RXDS_PER_BLOCK) {
 				buffAdd_t *ba = &nic->ba[i][j][k];
+				if (!ba || !ba->ba_0_org || !ba->ba_1_org)
+				{
+					kfree(nic->ba[i]);
+					kfree(nic->ba[i][j]);
+					if(ba->ba_0_org)
+						kfree(ba->ba_0_org);
+					if(ba->ba_1_org)
+						kfree(ba->ba_1_org);
+					goto end_free;
+				}
 				kfree(ba->ba_0_org);
 				kfree(ba->ba_1_org);
 				k++;
 			}
 			kfree(nic->ba[i][j]);
 		}
-		if (nic->ba[i])
-			kfree(nic->ba[i]);
+		kfree(nic->ba[i]);
 	}
+end_free:
 #endif
 
 	if (mac_control->stats_mem) {
