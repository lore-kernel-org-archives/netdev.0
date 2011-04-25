From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v4 11/27] HFI: Check window number/assign window number
Date: Mon, 25 Apr 2011 17:23:51 -0400
Message-ID: <1303766647-30156-12-git-send-email-dykmanj@linux.vnet.ibm.com>
References: <1303766647-30156-1-git-send-email-dykmanj@linux.vnet.ibm.com>
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
Received: from e33.co.us.ibm.com ([32.97.110.151]:41787 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755104Ab1DYVY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 17:24:26 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3PLHRn5005237
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 15:17:27 -0600
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p3PLOMrQ149776
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 15:24:22 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3PLOLW1032456
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 15:24:21 -0600
In-Reply-To: <1303766647-30156-1-git-send-email-dykmanj@linux.vnet.ibm.com>
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
index c2b4591..69fc7fa 100644
--- a/include/linux/hfi/hfidd_internal.h
+++ b/include/linux/hfi/hfidd_internal.h
@@ -141,6 +141,22 @@ struct hfidd_global {
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

