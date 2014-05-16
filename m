From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next 04/11] mac802154: add llsec encryption method
Date: Fri, 16 May 2014 17:46:38 +0200
Message-ID: <1400255205-9031-5-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1400255205-9031-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:39842 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169AbaEPPrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 11:47:04 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s4GFl0ga031634
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 16 May 2014 17:47:00 +0200
In-Reply-To: <1400255205-9031-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 net/mac802154/llsec.c |  253 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/mac802154/llsec.h |    2 +
 2 files changed, 255 insertions(+)

diff --git a/net/mac802154/llsec.c b/net/mac802154/llsec.c
index a210d1e..2a4b68e 100644
--- a/net/mac802154/llsec.c
+++ b/net/mac802154/llsec.c
@@ -527,3 +527,256 @@ int mac802154_llsec_seclevel_del(struct mac802154_llsec *sec,
 
 	return 0;
 }
+
+
+
+static int llsec_recover_addr(struct mac802154_llsec *sec,
+			      struct ieee802154_addr *addr)
+{
+	__le16 caddr = sec->params.coord_shortaddr;
+	addr->pan_id = sec->params.pan_id;
+
+	if (caddr == cpu_to_le16(IEEE802154_ADDR_BROADCAST)) {
+		return -EINVAL;
+	} else if (caddr == cpu_to_le16(IEEE802154_ADDR_UNDEF)) {
+		addr->extended_addr = sec->params.coord_hwaddr;
+		addr->mode = IEEE802154_ADDR_LONG;
+	} else {
+		addr->short_addr = sec->params.coord_shortaddr;
+		addr->mode = IEEE802154_ADDR_SHORT;
+	}
+
+	return 0;
+}
+
+static struct mac802154_llsec_key*
+llsec_lookup_key(struct mac802154_llsec *sec,
+		 const struct ieee802154_hdr *hdr,
+		 const struct ieee802154_addr *addr,
+		 struct ieee802154_llsec_key_id *key_id)
+{
+	struct ieee802154_addr devaddr = *addr;
+	u8 key_id_mode = hdr->sec.key_id_mode;
+	struct ieee802154_llsec_key_entry *key_entry;
+	struct mac802154_llsec_key *key;
+
+	if (key_id_mode == IEEE802154_SCF_KEY_IMPLICIT &&
+	    devaddr.mode == IEEE802154_ADDR_NONE) {
+		if (hdr->fc.type == IEEE802154_FC_TYPE_BEACON) {
+			devaddr.extended_addr = sec->params.coord_hwaddr;
+			devaddr.mode = IEEE802154_ADDR_LONG;
+		} else if (llsec_recover_addr(sec, &devaddr) < 0) {
+			return NULL;
+		}
+	}
+
+	list_for_each_entry_rcu(key_entry, &sec->table.keys, list) {
+		const struct ieee802154_llsec_key_id *id = &key_entry->id;
+
+		if (!(key_entry->key->frame_types & BIT(hdr->fc.type)))
+			continue;
+
+		if (id->mode != key_id_mode)
+			continue;
+
+		if (key_id_mode == IEEE802154_SCF_KEY_IMPLICIT) {
+			if (ieee802154_addr_equal(&devaddr, &id->device_addr))
+				goto found;
+		} else {
+			if (id->id != hdr->sec.key_id)
+				continue;
+
+			if ((key_id_mode == IEEE802154_SCF_KEY_INDEX) ||
+			    (key_id_mode == IEEE802154_SCF_KEY_SHORT_INDEX &&
+			     id->short_source == hdr->sec.short_src) ||
+			    (key_id_mode == IEEE802154_SCF_KEY_HW_INDEX &&
+			     id->extended_source == hdr->sec.extended_src))
+				goto found;
+		}
+	}
+
+	return NULL;
+
+found:
+	key = container_of(key_entry->key, struct mac802154_llsec_key, key);
+	if (key_id)
+		*key_id = key_entry->id;
+	return llsec_key_get(key);
+}
+
+
+static void llsec_geniv(u8 iv[16], __le64 addr,
+			const struct ieee802154_sechdr *sec)
+{
+	__be64 addr_bytes = (__force __be64) swab64((__force u64) addr);
+	__be32 frame_counter = (__force __be32) swab32((__force u32) sec->frame_counter);
+
+	iv[0] = 1; /* L' = L - 1 = 1 */
+	memcpy(iv + 1, &addr_bytes, sizeof(addr_bytes));
+	memcpy(iv + 9, &frame_counter, sizeof(frame_counter));
+	iv[13] = sec->level;
+	iv[14] = 0;
+	iv[15] = 1;
+}
+
+static int
+llsec_do_encrypt_unauth(struct sk_buff *skb, const struct mac802154_llsec *sec,
+			const struct ieee802154_hdr *hdr,
+			struct mac802154_llsec_key *key)
+{
+	u8 iv[16];
+	struct scatterlist src;
+	struct blkcipher_desc req = {
+		.tfm = key->tfm0,
+		.info = iv,
+		.flags = 0,
+	};
+
+	llsec_geniv(iv, sec->params.hwaddr, &hdr->sec);
+	sg_init_one(&src, skb->data, skb->len);
+	return crypto_blkcipher_encrypt_iv(&req, &src, &src, skb->len);
+}
+
+static struct crypto_aead*
+llsec_tfm_by_len(struct mac802154_llsec_key *key, int authlen)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(key->tfm); i++)
+		if (crypto_aead_authsize(key->tfm[i]) == authlen)
+			return key->tfm[i];
+
+	BUG();
+}
+
+static int
+llsec_do_encrypt_auth(struct sk_buff *skb, const struct mac802154_llsec *sec,
+		      const struct ieee802154_hdr *hdr,
+		      struct mac802154_llsec_key *key)
+{
+	u8 iv[16];
+	unsigned char *data;
+	int authlen, assoclen, datalen, rc;
+	struct scatterlist src, assoc[2], dst[2];
+	struct aead_request *req;
+
+	authlen = ieee802154_sechdr_authtag_len(&hdr->sec);
+	llsec_geniv(iv, sec->params.hwaddr, &hdr->sec);
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
+		sg_set_buf(&assoc[1], data, datalen);
+		assoclen += datalen;
+		datalen = 0;
+	}
+
+	sg_init_one(&src, data, datalen);
+
+	sg_init_table(dst, 2);
+	sg_set_buf(&dst[0], data, datalen);
+	sg_set_buf(&dst[1], skb_put(skb, authlen), authlen);
+
+	aead_request_set_callback(req, 0, NULL, NULL);
+	aead_request_set_assoc(req, assoc, assoclen);
+	aead_request_set_crypt(req, &src, dst, datalen, iv);
+
+	rc = crypto_aead_encrypt(req);
+
+	kfree(req);
+
+	return rc;
+}
+
+static int llsec_do_encrypt(struct sk_buff *skb,
+			    const struct mac802154_llsec *sec,
+			    const struct ieee802154_hdr *hdr,
+			    struct mac802154_llsec_key *key)
+{
+	if (hdr->sec.level == IEEE802154_SCF_SECLEVEL_ENC)
+		return llsec_do_encrypt_unauth(skb, sec, hdr, key);
+	else
+		return llsec_do_encrypt_auth(skb, sec, hdr, key);
+}
+
+int mac802154_llsec_encrypt(struct mac802154_llsec *sec, struct sk_buff *skb)
+{
+	struct ieee802154_hdr hdr;
+	int rc, authlen, hlen;
+	struct mac802154_llsec_key *key;
+	u32 frame_ctr;
+
+	hlen = ieee802154_hdr_pull(skb, &hdr);
+
+	if (hlen < 0 || hdr.fc.type != IEEE802154_FC_TYPE_DATA)
+		return -EINVAL;
+
+	if (!hdr.fc.security_enabled || hdr.sec.level == 0) {
+		skb_push(skb, hlen);
+		return 0;
+	}
+
+	authlen = ieee802154_sechdr_authtag_len(&hdr.sec);
+
+	if (skb->len + hlen + authlen + IEEE802154_MFR_SIZE > IEEE802154_MTU)
+		return -EMSGSIZE;
+
+	rcu_read_lock();
+
+	read_lock_bh(&sec->lock);
+
+	if (!sec->params.enabled) {
+		rc = -EINVAL;
+		goto fail_read;
+	}
+
+	key = llsec_lookup_key(sec, &hdr, &hdr.dest, NULL);
+	if (!key) {
+		rc = -ENOKEY;
+		goto fail_read;
+	}
+
+	read_unlock_bh(&sec->lock);
+
+	write_lock_bh(&sec->lock);
+
+	frame_ctr = be32_to_cpu(sec->params.frame_counter);
+	hdr.sec.frame_counter = cpu_to_le32(frame_ctr);
+	if (frame_ctr == 0xFFFFFFFF) {
+		write_unlock_bh(&sec->lock);
+		llsec_key_put(key);
+		rc = -EOVERFLOW;
+		goto fail;
+	}
+
+	sec->params.frame_counter = cpu_to_be32(frame_ctr + 1);
+
+	write_unlock_bh(&sec->lock);
+
+	rcu_read_unlock();
+
+	skb->mac_len = ieee802154_hdr_push(skb, &hdr);
+	skb_reset_mac_header(skb);
+
+	rc = llsec_do_encrypt(skb, sec, &hdr, key);
+	llsec_key_put(key);
+
+	return rc < 0 ? rc : 0;
+
+fail_read:
+	read_unlock(&sec->lock);
+fail:
+	rcu_read_unlock();
+	return rc;
+}
diff --git a/net/mac802154/llsec.h b/net/mac802154/llsec.h
index 65c1dd4..083055b 100644
--- a/net/mac802154/llsec.h
+++ b/net/mac802154/llsec.h
@@ -102,4 +102,6 @@ int mac802154_llsec_seclevel_add(struct mac802154_llsec *sec,
 int mac802154_llsec_seclevel_del(struct mac802154_llsec *sec,
 				 const struct ieee802154_llsec_seclevel *sl);
 
+int mac802154_llsec_encrypt(struct mac802154_llsec *sec, struct sk_buff *skb);
+
 #endif /* MAC802154_LLSEC_H */
-- 
1.7.9.5
