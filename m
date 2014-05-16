From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next 05/11] mac802154: add llsec
	decryption method
Date: Fri, 16 May 2014 17:46:39 +0200
Message-ID: <1400255205-9031-6-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1400255205-9031-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1400255205-9031-1-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
---
 net/mac802154/llsec.c |  247 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/mac802154/llsec.h |    1 +
 2 files changed, 248 insertions(+)

diff --git a/net/mac802154/llsec.c b/net/mac802154/llsec.c
index 2a4b68e..392653b 100644
--- a/net/mac802154/llsec.c
+++ b/net/mac802154/llsec.c
@@ -18,6 +18,7 @@
 #include <linux/bug.h>
 #include <linux/completion.h>
 #include <net/ieee802154.h>
+#include <crypto/algapi.h>
 
 #include "mac802154.h"
 #include "llsec.h"
@@ -780,3 +781,249 @@ fail:
 	rcu_read_unlock();
 	return rc;
 }
+
+
+
+static struct mac802154_llsec_device*
+llsec_lookup_dev(struct mac802154_llsec *sec,
+		 const struct ieee802154_addr *addr)
+{
+	struct ieee802154_addr devaddr = *addr;
+	struct mac802154_llsec_device *dev = NULL;
+
+	if (devaddr.mode == IEEE802154_ADDR_NONE &&
+	    llsec_recover_addr(sec, &devaddr) < 0)
+		return NULL;
+
+	if (devaddr.mode == IEEE802154_ADDR_SHORT) {
+		u32 key = llsec_dev_hash_short(devaddr.short_addr,
+					       devaddr.pan_id);
+
+		hash_for_each_possible_rcu(sec->devices_short, dev,
+					   bucket_s, key) {
+			if (dev->dev.pan_id == devaddr.pan_id &&
+			    dev->dev.short_addr == devaddr.short_addr)
+				return dev;
+		}
+	} else {
+		u64 key = llsec_dev_hash_long(devaddr.extended_addr);
+
+		hash_for_each_possible_rcu(sec->devices_hw, dev,
+					   bucket_hw, key) {
+			if (dev->dev.hwaddr == devaddr.extended_addr)
+				return dev;
+		}
+	}
+
+	return NULL;
+}
+
+static int
+llsec_lookup_seclevel(const struct mac802154_llsec *sec,
+		      u8 frame_type, u8 cmd_frame_id,
+		      struct ieee802154_llsec_seclevel *rlevel)
+{
+	struct ieee802154_llsec_seclevel *level;
+
+	list_for_each_entry_rcu(level, &sec->table.security_levels, list) {
+		if (level->frame_type == frame_type &&
+		    (frame_type != IEEE802154_FC_TYPE_MAC_CMD ||
+		     level->cmd_frame_id == cmd_frame_id)) {
+			*rlevel = *level;
+			return 0;
+		}
+	}
+
+	return -EINVAL;
+}
+
+static int
+llsec_do_decrypt_unauth(struct sk_buff *skb, const struct mac802154_llsec *sec,
+			const struct ieee802154_hdr *hdr,
+			struct mac802154_llsec_key *key, __le64 dev_addr)
+{
+	u8 iv[16];
+	unsigned char *data;
+	int datalen;
+	struct scatterlist src;
+	struct blkcipher_desc req = {
+		.tfm = key->tfm0,
+		.info = iv,
+		.flags = 0,
+	};
+
+	llsec_geniv(iv, dev_addr, &hdr->sec);
+	data = skb_mac_header(skb) + skb->mac_len;
+	datalen = skb_tail_pointer(skb) - data;
+
+	sg_init_one(&src, data, datalen);
+
+	return crypto_blkcipher_decrypt_iv(&req, &src, &src, datalen);
+}
+
+static int
+llsec_do_decrypt_auth(struct sk_buff *skb, const struct mac802154_llsec *sec,
+		      const struct ieee802154_hdr *hdr,
+		      struct mac802154_llsec_key *key, __le64 dev_addr)
+{
+	u8 iv[16];
+	unsigned char *data;
+	int authlen, datalen, assoclen, rc;
+	struct scatterlist src, assoc[2];
+	struct aead_request *req;
+
+	authlen = ieee802154_sechdr_authtag_len(&hdr->sec);
+	llsec_geniv(iv, dev_addr, &hdr->sec);
+
+	req = aead_request_alloc(llsec_tfm_by_len(key, authlen), GFP_ATOMIC);
+	if (!req)
+		return -ENOMEM;
+
+	sg_init_table(assoc, 2);
+	sg_set_buf(&assoc[0], skb_mac_header(skb), skb->mac_len);
+	assoclen = skb->mac_len;
+
+	data = skb_mac_header(skb) + skb->mac_len;
+	datalen = skb_tail_pointer(skb) - data;
+
+	if (hdr->sec.level & IEEE802154_SCF_SECLEVEL_ENC) {
+		sg_set_buf(&assoc[1], data, 0);
+	} else {
+		sg_set_buf(&assoc[1], data, datalen - authlen);
+		assoclen += datalen - authlen;
+		data += datalen - authlen;
+		datalen = authlen;
+	}
+
+	sg_init_one(&src, data, datalen);
+
+	aead_request_set_callback(req, 0, NULL, NULL);
+	aead_request_set_assoc(req, assoc, assoclen);
+	aead_request_set_crypt(req, &src, &src, datalen, iv);
+
+	rc = crypto_aead_decrypt(req);
+
+	kfree(req);
+	skb_trim(skb, skb->len - authlen);
+
+	return rc;
+}
+
+static int
+llsec_do_decrypt(struct sk_buff *skb, const struct mac802154_llsec *sec,
+		 const struct ieee802154_hdr *hdr,
+		 struct mac802154_llsec_key *key, __le64 dev_addr)
+{
+	if (hdr->sec.level == IEEE802154_SCF_SECLEVEL_ENC)
+		return llsec_do_decrypt_unauth(skb, sec, hdr, key, dev_addr);
+	else
+		return llsec_do_decrypt_auth(skb, sec, hdr, key, dev_addr);
+}
+
+static int
+llsec_update_devkey_info(struct mac802154_llsec_device *dev,
+			 const struct ieee802154_llsec_key_id *in_key,
+			 u32 frame_counter)
+{
+	struct mac802154_llsec_device_key *devkey = NULL;
+
+	if (dev->dev.key_mode == IEEE802154_LLSEC_DEVKEY_RESTRICT) {
+		devkey = llsec_devkey_find(dev, in_key);
+		if (!devkey)
+			return -ENOENT;
+	}
+
+	spin_lock_bh(&dev->lock);
+
+	if ((!devkey && frame_counter < dev->dev.frame_counter) ||
+	    (devkey && frame_counter < devkey->devkey.frame_counter)) {
+		spin_unlock_bh(&dev->lock);
+		return -EINVAL;
+	}
+
+	if (devkey)
+		devkey->devkey.frame_counter = frame_counter + 1;
+	else
+		dev->dev.frame_counter = frame_counter + 1;
+
+	spin_unlock_bh(&dev->lock);
+
+	return 0;
+}
+
+int mac802154_llsec_decrypt(struct mac802154_llsec *sec, struct sk_buff *skb)
+{
+	struct ieee802154_hdr hdr;
+	struct mac802154_llsec_key *key;
+	struct ieee802154_llsec_key_id key_id;
+	struct mac802154_llsec_device *dev;
+	struct ieee802154_llsec_seclevel seclevel;
+	int err;
+	__le64 dev_addr;
+	u32 frame_ctr;
+
+	if (ieee802154_hdr_peek(skb, &hdr) < 0)
+		return -EINVAL;
+	if (!hdr.fc.security_enabled)
+		return 0;
+	if (hdr.fc.version == 0)
+		return -EINVAL;
+
+	read_lock_bh(&sec->lock);
+	if (!sec->params.enabled) {
+		read_unlock_bh(&sec->lock);
+		return -EINVAL;
+	}
+	read_unlock_bh(&sec->lock);
+
+	rcu_read_lock();
+
+	key = llsec_lookup_key(sec, &hdr, &hdr.source, &key_id);
+	if (!key) {
+		err = -ENOKEY;
+		goto fail;
+	}
+
+	dev = llsec_lookup_dev(sec, &hdr.source);
+	if (!dev) {
+		err = -EINVAL;
+		goto fail_dev;
+	}
+
+	if (llsec_lookup_seclevel(sec, hdr.fc.type, 0, &seclevel) < 0) {
+		err = -EINVAL;
+		goto fail_dev;
+	}
+
+	if (!(seclevel.sec_levels & BIT(hdr.sec.level)) &&
+	    (hdr.sec.level == 0 && seclevel.device_override &&
+	     !dev->dev.seclevel_exempt)) {
+		err = -EINVAL;
+		goto fail_dev;
+	}
+
+	frame_ctr = le32_to_cpu(hdr.sec.frame_counter);
+
+	if (frame_ctr == 0xffffffff) {
+		err = -EOVERFLOW;
+		goto fail_dev;
+	}
+
+	err = llsec_update_devkey_info(dev, &key_id, frame_ctr);
+	if (err)
+		goto fail_dev;
+
+	dev_addr = dev->dev.hwaddr;
+
+	rcu_read_unlock();
+
+	err = llsec_do_decrypt(skb, sec, &hdr, key, dev_addr);
+	llsec_key_put(key);
+	return err;
+
+fail_dev:
+	llsec_key_put(key);
+fail:
+	rcu_read_unlock();
+	return err;
+}
diff --git a/net/mac802154/llsec.h b/net/mac802154/llsec.h
index 083055b..950578e 100644
--- a/net/mac802154/llsec.h
+++ b/net/mac802154/llsec.h
@@ -103,5 +103,6 @@ int mac802154_llsec_seclevel_del(struct mac802154_llsec *sec,
 				 const struct ieee802154_llsec_seclevel *sl);
 
 int mac802154_llsec_encrypt(struct mac802154_llsec *sec, struct sk_buff *skb);
+int mac802154_llsec_decrypt(struct mac802154_llsec *sec, struct sk_buff *skb);
 
 #endif /* MAC802154_LLSEC_H */
-- 
1.7.9.5


------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.
Get unparalleled scalability from the best Selenium testing platform available
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
