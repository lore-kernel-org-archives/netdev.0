From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v2 11/27] HFI: Check window number/assign window number
Date: Sun, 17 Apr 2011 23:21:43 -0400
Message-ID: <1303096919-7367-12-git-send-email-dykmanj@linux.vnet.ibm.com>
References: <1303096919-7367-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Cc: Jim Dykman <dykmanj@linux.vnet.ibm.com>,
	Piyush Chaudhary <piyushc@linux.vnet.ibm.com>,
	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>,
	" William S. Cadden" <wscadden@linux.vnet.ibm.com>,
	" Wen C. Chen" <winstonc@linux.vnet.ibm.com>,
	Scot Sakolish <sakolish@linux.vnet.ibm.com>,
	Jian Xiao <jian@linux.vnet.ibm.com>,
	" Carol L. Soto" <clsoto@linux.vnet.ibm.com>,
	" Sarah J. Sheppard" <sjsheppa@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:48485 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752105Ab1DRDWd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 23:22:33 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3I3Bu4c023579
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 23:11:56 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3I3MWH7324892
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 23:22:32 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3I3MVr7001250
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 23:22:32 -0400
In-Reply-To: <1303096919-7367-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Dykman <dykmanj@linux.vnet.ibm.com>

RESERVED windows are reserved by a job scheduler before the application starts.
the application is given a list of windows to use, the DD has to check that
they are opening one of the windows assigned to that jobid.
DYNAMIC windows are used without a job scheduler; the application calls into
the DD and asks for any free window.

Signed-off-by:  Piyush Chaudhary <piyushc@linux.vnet.ibm.com>
Signed-off-by:  Jim Dykman <dykmanj@linux.vnet.ibm.com>
Signed-off-by:  Fu-Chung Chang <fcchang@linux.vnet.ibm.com>
Signed-off-by:  William S. Cadden <wscadden@linux.vnet.ibm.com>
Signed-off-by:  Wen C. Chen <winstonc@linux.vnet.ibm.com>
Signed-off-by:  Scot Sakolish <sakolish@linux.vnet.ibm.com>
Signed-off-by:  Jian Xiao <jian@linux.vnet.ibm.com>
Signed-off-by:  Carol L. Soto <clsoto@linux.vnet.ibm.com>
Signed-off-by:  Sarah J. Sheppard <sjsheppa@linux.vnet.ibm.com>
---
 drivers/net/hfi/core/hfidd_window.c |  161 +++++++++++++++++++++++++++++++++++
 include/linux/hfi/hfidd_internal.h  |   16 ++++
 2 files changed, 177 insertions(+), 0 deletions(-)

diff --git a/drivers/net/hfi/core/hfidd_window.c b/drivers/net/hfi/core/hfidd_window.c
index f16caf7..cc775e3 100644
--- a/drivers/net/hfi/core/hfidd_window.c
+++ b/drivers/net/hfi/core/hfidd_window.c
@@ -35,6 +35,153 @@
 #include "hfidd_proto.h"
 #include <linux/hfi/hfidd_requests.h>
 
+/* Validate the type, state and job id for RESERVED window */
+static int hfi_validate_reserve_window_id(struct hfidd_acs *p_acs,
+		struct hfi_client_info *client_p)
+{
+	struct hfidd_window	*win_p;
+
+	/* Check if win is between min_hfi_windows and max_hfi_windows */
+	if ((client_p->window < min_hfi_windows(p_acs)) ||
+	    (client_p->window >= max_hfi_windows(p_acs))) {
+
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_validate_reserve_window_id: window = 0x%x too big\n",
+			client_p->window);
+		return -EINVAL;
+	}
+
+	/* Check if win_p indexed by window is not NULL */
+	win_p = hfi_window(p_acs, client_p->window);
+	if (win_p == NULL) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_validate_reserve_window_id: win 0x%x win_p is NULL\n",
+			client_p->window);
+		return -EINVAL;
+	}
+
+	spin_lock(&(win_p->win_lock));
+	/*
+	 * Check if win_p->type is HFIDD_RESERVE_WIN
+	 * win_p->state is WIN_RESERVED,
+	 * job id is matched
+	 */
+	if ((win_p->type != HFIDD_RESERVE_WIN) ||
+	    (win_p->state != WIN_RESERVED) ||
+	    (win_p->job_id != client_p->job_id)) {
+		spin_unlock(&(win_p->win_lock));
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_validate_reserve_window_id: win 0x%x type0x%x/"
+			"state0x%x/jid invalid\n",
+			client_p->window, win_p->type, win_p->state);
+		return -EINVAL;
+	}
+	spin_unlock(&(win_p->win_lock));
+	return 0;
+}
+
+/* Find an available dynamic window for open window request */
+static int hfi_validate_dynamic_window_id(struct hfidd_acs *p_acs,
+		struct hfi_client_info *client_p)
+{
+	int			i;
+	struct hfidd_window	*win_p;
+
+	/* Find out next available dynamic window */
+	for (i = min_hfi_windows(p_acs);
+	     i < max_hfi_windows(p_acs); i++) {
+
+		win_p = hfi_window(p_acs, i);
+		if (win_p == NULL)
+			continue;
+
+		/* if the spinlock is busy, the window is in use */
+		if (!spin_trylock(&(win_p->win_lock)))
+			continue;
+
+		if ((win_p->type == HFIDD_DYNAMIC_WIN) &&
+		    (win_p->state == WIN_AVAILABLE)) {
+			/*
+			 * Fill in the window number into
+			 * client info and update state
+			 */
+			client_p->window = win_p->index;
+			win_p->job_id = client_p->job_id;
+			win_p->state = WIN_RESERVED;
+			win_p->type  = client_p->win_type;
+
+			/* Set isIP flag if came from IP */
+			if (win_p->type == HFIDD_IP_WIN)
+				win_p->is_ip = 1;
+			else
+				win_p->is_ip = 0;
+			spin_unlock(&(win_p->win_lock));
+			return 0;
+		}
+		spin_unlock(&(win_p->win_lock));
+	}
+
+	/* We are out of dynamic windows */
+	if  (i == max_hfi_windows(p_acs)) {
+		client_p->window = 0;
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_validate_dynamic_window_id: out of dynamic window\n");
+		return -ENOBUFS;
+	}
+
+	return 0;
+}
+
+/* Validate the window request for RESERVED or DYNAMIC window */
+static inline int hfi_validate_window_id(struct hfidd_acs *p_acs,
+		struct hfi_client_info *client_p, unsigned int is_userspace)
+{
+	int	rc = 0;
+
+	/* Check the type of window request */
+	switch (client_p->win_type) {
+	case HFIDD_RESERVE_WIN:
+		rc = hfi_validate_reserve_window_id(p_acs, client_p);
+		break;
+	case HFIDD_IP_WIN:
+	case HFIDD_KERNEL_WIN:
+		if (is_userspace) {
+			rc = -EINVAL;
+			break;
+		}
+		/* fall thru here....*/
+	case HFIDD_DYNAMIC_WIN:
+		rc = hfi_validate_dynamic_window_id(p_acs, client_p);
+		break;
+	default:
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_validate_window_id: invalid win type 0x%x\n",
+			client_p->win_type);
+		rc = -EINVAL;
+		break;
+	}
+
+	return rc;
+}
+
+/* Validate window number and type for open window request */
+static int hfi_validate_window_parm(struct hfidd_acs *p_acs,
+		unsigned int is_userspace,
+		struct hfi_client_info *client_p)
+{
+	int			rc = 0;
+
+	/* Validate the window number */
+	rc = hfi_validate_window_id(p_acs, client_p, is_userspace);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_validate_window_parm: hfi_validate_window_id "
+			"failed, rc = 0x%x\n", rc);
+		return rc;
+	}
+	return 0;
+}
+
 /*
  * Allows an user/kernel window to send/receive network traffic thru HFI
  * adapter. This function will allocate the system resources needed to open
@@ -62,9 +209,23 @@ int hfidd_open_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
 	if (rc) {
 		dev_printk(KERN_ERR, p_acs->hfidd_dev,
 			"open_window_func: hfi_copy_from_user failed\n");
+		goto hfidd_open_window_func_err1;
+	}
+
+	/* Validate the window parms */
+	rc = hfi_validate_window_parm(p_acs, is_userspace, local_p);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"open_window_func: hfi_validate_window_parm failed, "
+			"rc = 0x%x\n", rc);
+		goto hfidd_open_window_func_err1;
 	}
 
 	kfree(local_p);
 	return rc;
+
+hfidd_open_window_func_err1:
+	kfree(local_p);
+	return rc;
 }
 EXPORT_SYMBOL_GPL(hfidd_open_window_func);
diff --git a/include/linux/hfi/hfidd_internal.h b/include/linux/hfi/hfidd_internal.h
index dd1ce4c..1781d52 100644
--- a/include/linux/hfi/hfidd_internal.h
+++ b/include/linux/hfi/hfidd_internal.h
@@ -142,6 +142,22 @@ struct hfidd_global {
 	struct hfidd_acs	*p_acs[MAX_HFIS];
 };
 
+static inline struct hfidd_window *hfi_window(struct hfidd_acs *p,
+		unsigned int idx)
+{
+	return p->win[idx - p->dds.window_start];
+}
+
+static inline unsigned int min_hfi_windows(struct hfidd_acs *p)
+{
+	return p->dds.window_start;
+}
+
+static inline unsigned int max_hfi_windows(struct hfidd_acs *p)
+{
+	return p->dds.window_start + p->dds.window_num;
+}
+
 static inline int hfi_copy_to_user(void *user_p, void *local_p,
 		unsigned int is_userspace, unsigned int size)
 {
-- 
1.7.3.5

