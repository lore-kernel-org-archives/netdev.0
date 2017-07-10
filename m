From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH 1/2 net] ptp: fix error codes in ptp_clock_register()
Date: Mon, 10 Jul 2017 10:11:37 +0300
Message-ID: <20170710071137.ui2fhjkqzjqhkopz@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>,
        Atul Gupta <atul.gupta@chelsio.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ptp_clock_register() function returns NULL when it's #ifdefed out
because CONFIG_PTP_1588_CLOCK is disabled.  Otherwise, it's intended to
return error pointers.  Unfortunately, there are a couple paths where we
forget to set the error code.  It means that we could result in NULL
pointer dereferences in the callers.

Fixes: d94ba80ebbea ("ptp: Added a brand new class driver for ptp clocks.")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index b77435783ef3..a50e96143a25 100644
--- a/drivers/ptp/ptp_clock.c
+++ b/drivers/ptp/ptp_clock.c
@@ -190,7 +190,7 @@ struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
 				     struct device *parent)
 {
 	struct ptp_clock *ptp;
-	int err = 0, index, major = MAJOR(ptp_devt);
+	int err, index, major = MAJOR(ptp_devt);
 
 	if (info->n_alarm > PTP_MAX_ALARMS)
 		return ERR_PTR(-EINVAL);
@@ -225,8 +225,10 @@ struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
 	ptp->dev = device_create_with_groups(ptp_class, parent, ptp->devid,
 					     ptp, ptp->pin_attr_groups,
 					     "ptp%d", ptp->index);
-	if (IS_ERR(ptp->dev))
+	if (IS_ERR(ptp->dev)) {
+		err = PTR_ERR(ptp->dev);
 		goto no_device;
+	}
 
 	/* Register a new PPS source. */
 	if (info->pps) {
@@ -238,6 +240,7 @@ struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
 		ptp->pps_source = pps_register_source(&pps, PTP_PPS_DEFAULTS);
 		if (!ptp->pps_source) {
 			pr_err("failed to register pps source\n");
+			err = -ENOMEM;
 			goto no_pps;
 		}
 	}
