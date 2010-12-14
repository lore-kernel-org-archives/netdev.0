From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net-2.6] be2net: use mutex instead of spin lock for mbox_lock
Date: Tue, 14 Dec 2010 16:43:19 +0100
Message-ID: <1292341399-14353-1-git-send-email-ivecera@redhat.com>
References: <1292336483.20458.1.camel@bwh-desktop>
Cc: sathyap@serverengines.com, subbus@serverengines.com,
	sarveshwarb@serverengines.com, ajitk@serverengines.com,
	davem@davemloft.net, bhutchings@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33090 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753708Ab0LNPn1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Dec 2010 10:43:27 -0500
In-Reply-To: <1292336483.20458.1.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-12-14 at 14:21 +0000, Ben Hutchings wrote:
> On Tue, 2010-12-14 at 14:46 +0100, Ivan Vecera wrote:
> > Since the mbox polling uses the schedule_timeout, the mbox_lock should be
> > a semaphore and not a spin lock.
> > The commit f25b03a replaced udelay() with schedule_timeout() but didn't
> > change the mbox_lock to a semaphore or a mutex.
> [...]
> 
> I see no reason for this to be a semaphore; use a mutex instead.
> 
> Ben
Ok, Ben... the new version

Since the mbox polling uses the schedule_timeout, the mbox_lock should be
a mutex and not a spin lock.
The commit f25b03a replaced udelay() with schedule_timeout() but didn't
change mbox_lock to semaphore or mutex.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/benet/be.h      |    2 +-
 drivers/net/benet/be_cmds.c |   75 +++++++++++++++++++++++++-----------------
 drivers/net/benet/be_main.c |    2 +-
 3 files changed, 47 insertions(+), 32 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 4594a28..d64313b 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -234,7 +234,7 @@ struct be_adapter {
 	u8 __iomem *db;		/* Door Bell */
 	u8 __iomem *pcicfg;	/* PCI config space */
 
-	spinlock_t mbox_lock;	/* For serializing mbox cmds to BE card */
+	struct mutex mbox_lock; /* For serializing mbox cmds to BE card */
 	struct be_dma_mem mbox_mem;
 	/* Mbox mem is adjusted to align to 16 bytes. The allocated addr
 	 * is stored for freeing purpose */
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index e4465d2..1c8c79c 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -462,7 +462,8 @@ int be_cmd_fw_init(struct be_adapter *adapter)
 	u8 *wrb;
 	int status;
 
-	spin_lock(&adapter->mbox_lock);
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
 
 	wrb = (u8 *)wrb_from_mbox(adapter);
 	*wrb++ = 0xFF;
@@ -476,7 +477,7 @@ int be_cmd_fw_init(struct be_adapter *adapter)
 
 	status = be_mbox_notify_wait(adapter);
 
-	spin_unlock(&adapter->mbox_lock);
+	mutex_unlock(&adapter->mbox_lock);
 	return status;
 }
 
@@ -491,7 +492,8 @@ int be_cmd_fw_clean(struct be_adapter *adapter)
 	if (adapter->eeh_err)
 		return -EIO;
 
-	spin_lock(&adapter->mbox_lock);
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
 
 	wrb = (u8 *)wrb_from_mbox(adapter);
 	*wrb++ = 0xFF;
@@ -505,7 +507,7 @@ int be_cmd_fw_clean(struct be_adapter *adapter)
 
 	status = be_mbox_notify_wait(adapter);
 
-	spin_unlock(&adapter->mbox_lock);
+	mutex_unlock(&adapter->mbox_lock);
 	return status;
 }
 int be_cmd_eq_create(struct be_adapter *adapter,
@@ -516,7 +518,8 @@ int be_cmd_eq_create(struct be_adapter *adapter,
 	struct be_dma_mem *q_mem = &eq->dma_mem;
 	int status;
 
-	spin_lock(&adapter->mbox_lock);
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
 
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
@@ -546,7 +549,7 @@ int be_cmd_eq_create(struct be_adapter *adapter,
 		eq->created = true;
 	}
 
-	spin_unlock(&adapter->mbox_lock);
+	mutex_unlock(&adapter->mbox_lock);
 	return status;
 }
 
@@ -558,7 +561,8 @@ int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
 	struct be_cmd_req_mac_query *req;
 	int status;
 
-	spin_lock(&adapter->mbox_lock);
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
 
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
@@ -583,7 +587,7 @@ int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
 		memcpy(mac_addr, resp->mac.addr, ETH_ALEN);
 	}
 
-	spin_unlock(&adapter->mbox_lock);
+	mutex_unlock(&adapter->mbox_lock);
 	return status;
 }
 
@@ -667,7 +671,8 @@ int be_cmd_cq_create(struct be_adapter *adapter,
 	void *ctxt;
 	int status;
 
-	spin_lock(&adapter->mbox_lock);
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
 
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
@@ -701,7 +706,7 @@ int be_cmd_cq_create(struct be_adapter *adapter,
 		cq->created = true;
 	}
 
-	spin_unlock(&adapter->mbox_lock);
+	mutex_unlock(&adapter->mbox_lock);
 
 	return status;
 }
@@ -724,7 +729,8 @@ int be_cmd_mccq_create(struct be_adapter *adapter,
 	void *ctxt;
 	int status;
 
-	spin_lock(&adapter->mbox_lock);
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
 
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
@@ -754,7 +760,7 @@ int be_cmd_mccq_create(struct be_adapter *adapter,
 		mccq->id = le16_to_cpu(resp->id);
 		mccq->created = true;
 	}
-	spin_unlock(&adapter->mbox_lock);
+	mutex_unlock(&adapter->mbox_lock);
 
 	return status;
 }
@@ -769,7 +775,8 @@ int be_cmd_txq_create(struct be_adapter *adapter,
 	void *ctxt;
 	int status;
 
-	spin_lock(&adapter->mbox_lock);
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
 
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
@@ -801,7 +808,7 @@ int be_cmd_txq_create(struct be_adapter *adapter,
 		txq->created = true;
 	}
 
-	spin_unlock(&adapter->mbox_lock);
+	mutex_unlock(&adapter->mbox_lock);
 
 	return status;
 }
@@ -816,7 +823,8 @@ int be_cmd_rxq_create(struct be_adapter *adapter,
 	struct be_dma_mem *q_mem = &rxq->dma_mem;
 	int status;
 
-	spin_lock(&adapter->mbox_lock);
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
 
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
@@ -843,7 +851,7 @@ int be_cmd_rxq_create(struct be_adapter *adapter,
 		*rss_id = resp->rss_id;
 	}
 
-	spin_unlock(&adapter->mbox_lock);
+	mutex_unlock(&adapter->mbox_lock);
 
 	return status;
 }
@@ -862,7 +870,8 @@ int be_cmd_q_destroy(struct be_adapter *adapter, struct be_queue_info *q,
 	if (adapter->eeh_err)
 		return -EIO;
 
-	spin_lock(&adapter->mbox_lock);
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
 
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
@@ -899,7 +908,7 @@ int be_cmd_q_destroy(struct be_adapter *adapter, struct be_queue_info *q,
 
 	status = be_mbox_notify_wait(adapter);
 
-	spin_unlock(&adapter->mbox_lock);
+	mutex_unlock(&adapter->mbox_lock);
 
 	return status;
 }
@@ -915,7 +924,8 @@ int be_cmd_if_create(struct be_adapter *adapter, u32 cap_flags, u32 en_flags,
 	struct be_cmd_req_if_create *req;
 	int status;
 
-	spin_lock(&adapter->mbox_lock);
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
 
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
@@ -941,7 +951,7 @@ int be_cmd_if_create(struct be_adapter *adapter, u32 cap_flags, u32 en_flags,
 			*pmac_id = le32_to_cpu(resp->pmac_id);
 	}
 
-	spin_unlock(&adapter->mbox_lock);
+	mutex_unlock(&adapter->mbox_lock);
 	return status;
 }
 
@@ -955,7 +965,8 @@ int be_cmd_if_destroy(struct be_adapter *adapter, u32 interface_id)
 	if (adapter->eeh_err)
 		return -EIO;
 
-	spin_lock(&adapter->mbox_lock);
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
 
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
@@ -970,7 +981,7 @@ int be_cmd_if_destroy(struct be_adapter *adapter, u32 interface_id)
 
 	status = be_mbox_notify_wait(adapter);
 
-	spin_unlock(&adapter->mbox_lock);
+	mutex_unlock(&adapter->mbox_lock);
 
 	return status;
 }
@@ -1060,7 +1071,8 @@ int be_cmd_get_fw_ver(struct be_adapter *adapter, char *fw_ver)
 	struct be_cmd_req_get_fw_version *req;
 	int status;
 
-	spin_lock(&adapter->mbox_lock);
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
 
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
@@ -1077,7 +1089,7 @@ int be_cmd_get_fw_ver(struct be_adapter *adapter, char *fw_ver)
 		strncpy(fw_ver, resp->firmware_version_string, FW_VER_LEN);
 	}
 
-	spin_unlock(&adapter->mbox_lock);
+	mutex_unlock(&adapter->mbox_lock);
 	return status;
 }
 
@@ -1322,7 +1334,8 @@ int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num,
 	struct be_cmd_req_query_fw_cfg *req;
 	int status;
 
-	spin_lock(&adapter->mbox_lock);
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
 
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
@@ -1341,7 +1354,7 @@ int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num,
 		*caps = le32_to_cpu(resp->function_caps);
 	}
 
-	spin_unlock(&adapter->mbox_lock);
+	mutex_unlock(&adapter->mbox_lock);
 	return status;
 }
 
@@ -1352,7 +1365,8 @@ int be_cmd_reset_function(struct be_adapter *adapter)
 	struct be_cmd_req_hdr *req;
 	int status;
 
-	spin_lock(&adapter->mbox_lock);
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
 
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
@@ -1365,7 +1379,7 @@ int be_cmd_reset_function(struct be_adapter *adapter)
 
 	status = be_mbox_notify_wait(adapter);
 
-	spin_unlock(&adapter->mbox_lock);
+	mutex_unlock(&adapter->mbox_lock);
 	return status;
 }
 
@@ -1376,7 +1390,8 @@ int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable, u16 table_size)
 	u32 myhash[10];
 	int status;
 
-	spin_lock(&adapter->mbox_lock);
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
 
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
@@ -1396,7 +1411,7 @@ int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable, u16 table_size)
 
 	status = be_mbox_notify_wait(adapter);
 
-	spin_unlock(&adapter->mbox_lock);
+	mutex_unlock(&adapter->mbox_lock);
 	return status;
 }
 
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 93354ee..fd251b5 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2677,7 +2677,7 @@ static int be_ctrl_init(struct be_adapter *adapter)
 	}
 	memset(mc_cmd_mem->va, 0, mc_cmd_mem->size);
 
-	spin_lock_init(&adapter->mbox_lock);
+	mutex_init(&adapter->mbox_lock);
 	spin_lock_init(&adapter->mcc_lock);
 	spin_lock_init(&adapter->mcc_cq_lock);
 
-- 
1.7.2.2

