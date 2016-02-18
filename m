From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] i40e: drop unused debugfs file "dump"
Date: Thu, 18 Feb 2016 01:03:59 -0800
Message-ID: <1455786252-71881-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455786252-71881-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:36842 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1425595AbcBRJES (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 04:04:18 -0500
In-Reply-To: <1455786252-71881-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

There was a completely unused file "dump" in debugfs that
never panned out to be useful.

Change-ID: I12bb9e37b5a83299725dda815a8746157baf6562
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 250 -------------------------
 1 file changed, 250 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 34da53b..631c2d6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -72,248 +72,6 @@ static struct i40e_veb *i40e_dbg_find_veb(struct i40e_pf *pf, int seid)
 }
 
 /**************************************************************
- * dump
- * The dump entry in debugfs is for getting a data snapshow of
- * the driver's current configuration and runtime details.
- * When the filesystem entry is written, a snapshot is taken.
- * When the entry is read, the most recent snapshot data is dumped.
- **************************************************************/
-static char *i40e_dbg_dump_buf;
-static ssize_t i40e_dbg_dump_data_len;
-static ssize_t i40e_dbg_dump_buffer_len;
-
-/**
- * i40e_dbg_dump_read - read the dump data
- * @filp: the opened file
- * @buffer: where to write the data for the user to read
- * @count: the size of the user's buffer
- * @ppos: file position offset
- **/
-static ssize_t i40e_dbg_dump_read(struct file *filp, char __user *buffer,
-				  size_t count, loff_t *ppos)
-{
-	int bytes_not_copied;
-	int len;
-
-	/* is *ppos bigger than the available data? */
-	if (*ppos >= i40e_dbg_dump_data_len || !i40e_dbg_dump_buf)
-		return 0;
-
-	/* be sure to not read beyond the end of available data */
-	len = min_t(int, count, (i40e_dbg_dump_data_len - *ppos));
-
-	bytes_not_copied = copy_to_user(buffer, &i40e_dbg_dump_buf[*ppos], len);
-	if (bytes_not_copied)
-		return -EFAULT;
-
-	*ppos += len;
-	return len;
-}
-
-/**
- * i40e_dbg_prep_dump_buf
- * @pf: the PF we're working with
- * @buflen: the desired buffer length
- *
- * Return positive if success, 0 if failed
- **/
-static int i40e_dbg_prep_dump_buf(struct i40e_pf *pf, int buflen)
-{
-	/* if not already big enough, prep for re alloc */
-	if (i40e_dbg_dump_buffer_len && i40e_dbg_dump_buffer_len < buflen) {
-		kfree(i40e_dbg_dump_buf);
-		i40e_dbg_dump_buffer_len = 0;
-		i40e_dbg_dump_buf = NULL;
-	}
-
-	/* get a new buffer if needed */
-	if (!i40e_dbg_dump_buf) {
-		i40e_dbg_dump_buf = kzalloc(buflen, GFP_KERNEL);
-		if (i40e_dbg_dump_buf != NULL)
-			i40e_dbg_dump_buffer_len = buflen;
-	}
-
-	return i40e_dbg_dump_buffer_len;
-}
-
-/**
- * i40e_dbg_dump_write - trigger a datadump snapshot
- * @filp: the opened file
- * @buffer: where to find the user's data
- * @count: the length of the user's data
- * @ppos: file position offset
- *
- * Any write clears the stats
- **/
-static ssize_t i40e_dbg_dump_write(struct file *filp,
-				   const char __user *buffer,
-				   size_t count, loff_t *ppos)
-{
-	struct i40e_pf *pf = filp->private_data;
-	bool seid_found = false;
-	long seid = -1;
-	int buflen = 0;
-	int i, ret;
-	int len;
-	u8 *p;
-
-	/* don't allow partial writes */
-	if (*ppos != 0)
-		return 0;
-
-	/* decode the SEID given to be dumped */
-	ret = kstrtol_from_user(buffer, count, 0, &seid);
-
-	if (ret) {
-		dev_info(&pf->pdev->dev, "bad seid value\n");
-	} else if (seid == 0) {
-		seid_found = true;
-
-		kfree(i40e_dbg_dump_buf);
-		i40e_dbg_dump_buffer_len = 0;
-		i40e_dbg_dump_data_len = 0;
-		i40e_dbg_dump_buf = NULL;
-		dev_info(&pf->pdev->dev, "debug buffer freed\n");
-
-	} else if (seid == pf->pf_seid || seid == 1) {
-		seid_found = true;
-
-		buflen = sizeof(struct i40e_pf);
-		buflen += (sizeof(struct i40e_aq_desc)
-		     * (pf->hw.aq.num_arq_entries + pf->hw.aq.num_asq_entries));
-
-		if (i40e_dbg_prep_dump_buf(pf, buflen)) {
-			p = i40e_dbg_dump_buf;
-
-			/* avoid use of memcpy here due to sparse warning
-			 * about copy size.
-			 */
-			*((struct i40e_pf *)p) = *pf;
-			p += sizeof(struct i40e_pf);
-
-			len = (sizeof(struct i40e_aq_desc)
-					* pf->hw.aq.num_asq_entries);
-			memcpy(p, pf->hw.aq.asq.desc_buf.va, len);
-			p += len;
-
-			len = (sizeof(struct i40e_aq_desc)
-					* pf->hw.aq.num_arq_entries);
-			memcpy(p, pf->hw.aq.arq.desc_buf.va, len);
-			p += len;
-
-			i40e_dbg_dump_data_len = buflen;
-			dev_info(&pf->pdev->dev,
-				 "PF seid %ld dumped %d bytes\n",
-				 seid, (int)i40e_dbg_dump_data_len);
-		}
-	} else if (seid >= I40E_BASE_VSI_SEID) {
-		struct i40e_vsi *vsi = NULL;
-		struct i40e_mac_filter *f;
-		int filter_count = 0;
-
-		mutex_lock(&pf->switch_mutex);
-		vsi = i40e_dbg_find_vsi(pf, seid);
-		if (!vsi) {
-			mutex_unlock(&pf->switch_mutex);
-			goto write_exit;
-		}
-
-		buflen = sizeof(struct i40e_vsi);
-		buflen += sizeof(struct i40e_q_vector) * vsi->num_q_vectors;
-		buflen += sizeof(struct i40e_ring) * 2 * vsi->num_queue_pairs;
-		buflen += sizeof(struct i40e_tx_buffer) * vsi->num_queue_pairs;
-		buflen += sizeof(struct i40e_rx_buffer) * vsi->num_queue_pairs;
-		list_for_each_entry(f, &vsi->mac_filter_list, list)
-			filter_count++;
-		buflen += sizeof(struct i40e_mac_filter) * filter_count;
-
-		if (i40e_dbg_prep_dump_buf(pf, buflen)) {
-			p = i40e_dbg_dump_buf;
-			seid_found = true;
-
-			len = sizeof(struct i40e_vsi);
-			memcpy(p, vsi, len);
-			p += len;
-
-			if (vsi->num_q_vectors) {
-				len = (sizeof(struct i40e_q_vector)
-					* vsi->num_q_vectors);
-				memcpy(p, vsi->q_vectors, len);
-				p += len;
-			}
-
-			if (vsi->num_queue_pairs) {
-				len = (sizeof(struct i40e_ring) *
-				      vsi->num_queue_pairs);
-				memcpy(p, vsi->tx_rings, len);
-				p += len;
-				memcpy(p, vsi->rx_rings, len);
-				p += len;
-			}
-
-			if (vsi->tx_rings[0]) {
-				len = sizeof(struct i40e_tx_buffer);
-				for (i = 0; i < vsi->num_queue_pairs; i++) {
-					memcpy(p, vsi->tx_rings[i]->tx_bi, len);
-					p += len;
-				}
-				len = sizeof(struct i40e_rx_buffer);
-				for (i = 0; i < vsi->num_queue_pairs; i++) {
-					memcpy(p, vsi->rx_rings[i]->rx_bi, len);
-					p += len;
-				}
-			}
-
-			/* macvlan filter list */
-			len = sizeof(struct i40e_mac_filter);
-			list_for_each_entry(f, &vsi->mac_filter_list, list) {
-				memcpy(p, f, len);
-				p += len;
-			}
-
-			i40e_dbg_dump_data_len = buflen;
-			dev_info(&pf->pdev->dev,
-				 "VSI seid %ld dumped %d bytes\n",
-				 seid, (int)i40e_dbg_dump_data_len);
-		}
-		mutex_unlock(&pf->switch_mutex);
-	} else if (seid >= I40E_BASE_VEB_SEID) {
-		struct i40e_veb *veb = NULL;
-
-		mutex_lock(&pf->switch_mutex);
-		veb = i40e_dbg_find_veb(pf, seid);
-		if (!veb) {
-			mutex_unlock(&pf->switch_mutex);
-			goto write_exit;
-		}
-
-		buflen = sizeof(struct i40e_veb);
-		if (i40e_dbg_prep_dump_buf(pf, buflen)) {
-			seid_found = true;
-			memcpy(i40e_dbg_dump_buf, veb, buflen);
-			i40e_dbg_dump_data_len = buflen;
-			dev_info(&pf->pdev->dev,
-				 "VEB seid %ld dumped %d bytes\n",
-				 seid, (int)i40e_dbg_dump_data_len);
-		}
-		mutex_unlock(&pf->switch_mutex);
-	}
-
-write_exit:
-	if (!seid_found)
-		dev_info(&pf->pdev->dev, "unknown seid %ld\n", seid);
-
-	return count;
-}
-
-static const struct file_operations i40e_dbg_dump_fops = {
-	.owner = THIS_MODULE,
-	.open =  simple_open,
-	.read =  i40e_dbg_dump_read,
-	.write = i40e_dbg_dump_write,
-};
-
-/**************************************************************
  * command
  * The command entry in debugfs is for giving the driver commands
  * to be executed - these may be for changing the internal switch
@@ -2217,11 +1975,6 @@ void i40e_dbg_pf_init(struct i40e_pf *pf)
 	if (!pfile)
 		goto create_failed;
 
-	pfile = debugfs_create_file("dump", 0600, pf->i40e_dbg_pf, pf,
-				    &i40e_dbg_dump_fops);
-	if (!pfile)
-		goto create_failed;
-
 	pfile = debugfs_create_file("netdev_ops", 0600, pf->i40e_dbg_pf, pf,
 				    &i40e_dbg_netdev_ops_fops);
 	if (!pfile)
@@ -2242,9 +1995,6 @@ void i40e_dbg_pf_exit(struct i40e_pf *pf)
 {
 	debugfs_remove_recursive(pf->i40e_dbg_pf);
 	pf->i40e_dbg_pf = NULL;
-
-	kfree(i40e_dbg_dump_buf);
-	i40e_dbg_dump_buf = NULL;
 }
 
 /**
-- 
2.5.0
