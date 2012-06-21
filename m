From: <Sathya.Perla@Emulex.Com>
Subject: RE: [RFC net-next 11/14] Fix emulex/benet
Date: Wed, 20 Jun 2012 23:42:22 -0700
Message-ID: <3367B80B08154D42A3B2BC708B5D41F647C69FA2E4@EXMAIL.ad.emulex.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>,<1340118848-30978-12-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <eilong@broadcom.com>
To: <yuvalmin@broadcom.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:6754 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755299Ab2FUGrS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 02:47:18 -0400
In-Reply-To: <1340118848-30978-12-git-send-email-yuvalmin@broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yuval, for be2net, the best place to cap the number of queues to a global default 
value would be_num_rss_want(). The change would look like:

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/
index fa2a01e..5265b42 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2186,12 +2186,15 @@ static void be_msix_disable(struct be_adapter *adapter)
 
 static uint be_num_rss_want(struct be_adapter *adapter)
 {
+       u32 num = 0;
+
        if ((adapter->function_caps & BE_FUNCTION_CAPS_RSS) &&
             !sriov_want(adapter) && be_physfn(adapter) &&
-            !be_is_mc(adapter))
-               return (adapter->be3_native) ? BE3_MAX_RSS_QS : BE2_MAX_RSS_QS;
-       else
-               return 0;
+            !be_is_mc(adapter)) {
+               num = (adapter->be3_native) ? BE3_MAX_RSS_QS : BE2_MAX_RSS_QS;
+               num = min_t(u32, num, DEFAULT_MAX_NUM_RSS_QUEUES);
+       }
+       return num;
 }
 
 static void be_msix_enable(struct be_adapter *adapter)

thanks,
-Sathya

________________________________________
From: Yuval Mintz [yuvalmin@broadcom.com]

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Sathya Perla <sathya.perla@emulex.com>
Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 5a34503..e42597d 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2153,13 +2153,15 @@ static uint be_num_rss_want(struct be_adapter *adapter)
 static void be_msix_enable(struct be_adapter *adapter)
 {
 #define BE_MIN_MSIX_VECTORS            1
-       int i, status, num_vec, num_roce_vec = 0;
+       int i, status, num_vec, num_roce_vec = 0, ncpu;
+
+       ncpu = min_t(int, num_online_cpus(), DEFAULT_MAX_NUM_RSS_QUEUES);

        /* If RSS queues are not used, need a vec for default RX Q */
-       num_vec = min(be_num_rss_want(adapter), num_online_cpus());
+       num_vec = min(be_num_rss_want(adapter), ncpu);
        if (be_roce_supported(adapter)) {
                num_roce_vec = min_t(u32, MAX_ROCE_MSIX_VECTORS,
-                                       (num_online_cpus() + 1));
+                                    (u32)(ncpu + 1));
                num_roce_vec = min(num_roce_vec, MAX_ROCE_EQS);
                num_vec += num_roce_vec;
                num_vec = min(num_vec, MAX_MSIX_VECTORS);
--
1.7.9.rc2
