From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/14] i40e: don't store user requested mode until we've validated it
Date: Thu, 26 Jun 2014 05:13:48 -0700
Message-ID: <1403784834-23301-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403784834-23301-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:10421 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757670AbaFZMOb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2014 08:14:31 -0400
In-Reply-To: <1403784834-23301-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch prevents the SIOCGHWTSTAMP ioctl from possibly returning bad
data, by not permanently storing the setting into the private
structure until after we've finished validating that we can support it.

Change-ID: Ib59f9b4f73f451d5a2e76fb8efa5d4271b218433
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ptp.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index e5f558c..f7dded9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -549,17 +549,20 @@ static int i40e_ptp_set_timestamp_mode(struct i40e_pf *pf,
  **/
 int i40e_ptp_set_ts_config(struct i40e_pf *pf, struct ifreq *ifr)
 {
-	struct hwtstamp_config *config = &pf->tstamp_config;
+	struct hwtstamp_config config;
 	int err;
 
-	if (copy_from_user(config, ifr->ifr_data, sizeof(*config)))
+	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
 		return -EFAULT;
 
-	err = i40e_ptp_set_timestamp_mode(pf, config);
+	err = i40e_ptp_set_timestamp_mode(pf, &config);
 	if (err)
 		return err;
 
-	return copy_to_user(ifr->ifr_data, config, sizeof(*config)) ?
+	/* save these settings for future reference */
+	pf->tstamp_config = config;
+
+	return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?
 		-EFAULT : 0;
 }
 
-- 
1.9.3
