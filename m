From: Huw Davies <huw@codeweavers.com>
Subject: [PATCH v4 10/19] calipso: Set the calipso socket label to match the secattr.
Date: Mon, 20 Jun 2016 14:36:50 +0100
Message-ID: <1466429819-12707-11-git-send-email-huw@codeweavers.com>
Cc: Paul Moore <pmoore@redhat.com>
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

CALIPSO is a hop-by-hop IPv6 option.  A lot of this patch is based on
the equivalent CISPO code.  The main difference is due to manipulating
the options in the hop-by-hop header.

Signed-off-by: Huw Davies <huw@codeweavers.com>
---
 include/net/ipv6.h              |   2 +
 include/net/netlabel.h          |   9 +
 include/uapi/linux/in6.h        |   1 +
 net/ipv6/calipso.c              | 595 ++++++++++++++++++++++++++++++++++++++++
 net/ipv6/ipv6_sockglue.c        |   1 -
 net/netlabel/Kconfig            |   1 +
 net/netlabel/netlabel_calipso.c |  64 +++++
 net/netlabel/netlabel_calipso.h |   5 +
 net/netlabel/netlabel_kapi.c    |  64 ++++-
 security/selinux/netlabel.c     |   2 +-
 10 files changed, 733 insertions(+), 11 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 917036f..22c7a37 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -319,6 +319,8 @@ struct ipv6_txoptions *ipv6_fixup_options(struct ipv6_txoptions *opt_space,
 
 bool ipv6_opt_accepted(const struct sock *sk, const struct sk_buff *skb,
 		       const struct inet6_skb_parm *opt);
+struct ipv6_txoptions *ipv6_update_options(struct sock *sk,
+					   struct ipv6_txoptions *opt);
 
 static inline bool ipv6_accept_ra(struct inet6_dev *idev)
 {
diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index 9fc2cab..918a604 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -226,6 +226,9 @@ struct netlbl_lsm_secattr {
  * @doi_getdef: returns a reference to a DOI
  * @doi_putdef: releases a reference of a DOI
  * @doi_walk: enumerate the DOI list
+ * @sock_getattr: retrieve the socket's attr
+ * @sock_setattr: set the socket's attr
+ * @sock_delattr: remove the socket's attr
  *
  * Description:
  * This structure is filled out by the CALIPSO engine and passed
@@ -243,6 +246,12 @@ struct netlbl_calipso_ops {
 	int (*doi_walk)(u32 *skip_cnt,
 			int (*callback)(struct calipso_doi *doi_def, void *arg),
 			void *cb_arg);
+	int (*sock_getattr)(struct sock *sk,
+			    struct netlbl_lsm_secattr *secattr);
+	int (*sock_setattr)(struct sock *sk,
+			    const struct calipso_doi *doi_def,
+			    const struct netlbl_lsm_secattr *secattr);
+	void (*sock_delattr)(struct sock *sk);
 };
 
 /*
diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
index 318a482..b39ea4f 100644
--- a/include/uapi/linux/in6.h
+++ b/include/uapi/linux/in6.h
@@ -143,6 +143,7 @@ struct in6_flowlabel_req {
 #define IPV6_TLV_PAD1		0
 #define IPV6_TLV_PADN		1
 #define IPV6_TLV_ROUTERALERT	5
+#define IPV6_TLV_CALIPSO	7	/* RFC 5570 */
 #define IPV6_TLV_JUMBO		194
 #define IPV6_TLV_HAO		201	/* home address option */
 
diff --git a/net/ipv6/calipso.c b/net/ipv6/calipso.c
index d7df7a4..959db52 100644
--- a/net/ipv6/calipso.c
+++ b/net/ipv6/calipso.c
@@ -44,6 +44,24 @@
 #include <linux/atomic.h>
 #include <linux/bug.h>
 #include <asm/unaligned.h>
+#include <linux/crc-ccitt.h>
+
+/* Maximium size of the calipso option including
+ * the two-byte TLV header.
+ */
+#define CALIPSO_OPT_LEN_MAX (2 + 252)
+
+/* Size of the minimum calipso option including
+ * the two-byte TLV header.
+ */
+#define CALIPSO_HDR_LEN (2 + 8)
+
+/* Maximium size of the calipso option including
+ * the two-byte TLV header and upto 3 bytes of
+ * leading pad and 7 bytes of trailing pad.
+ */
+#define CALIPSO_OPT_LEN_MAX_WITH_PAD (3 + CALIPSO_OPT_LEN_MAX + 7)
+
 
 /* List of available DOI definitions */
 static DEFINE_SPINLOCK(calipso_doi_list_lock);
@@ -297,6 +315,580 @@ doi_walk_return:
 	return ret_val;
 }
 
+/**
+ * calipso_map_cat_hton - Perform a category mapping from host to network
+ * @doi_def: the DOI definition
+ * @secattr: the security attributes
+ * @net_cat: the zero'd out category bitmap in network/CALIPSO format
+ * @net_cat_len: the length of the CALIPSO bitmap in bytes
+ *
+ * Description:
+ * Perform a label mapping to translate a local MLS category bitmap to the
+ * correct CALIPSO bitmap using the given DOI definition.  Returns the minimum
+ * size in bytes of the network bitmap on success, negative values otherwise.
+ *
+ */
+static int calipso_map_cat_hton(const struct calipso_doi *doi_def,
+				const struct netlbl_lsm_secattr *secattr,
+				unsigned char *net_cat,
+				u32 net_cat_len)
+{
+	int spot = -1;
+	u32 net_spot_max = 0;
+	u32 net_clen_bits = net_cat_len * 8;
+
+	for (;;) {
+		spot = netlbl_catmap_walk(secattr->attr.mls.cat,
+					  spot + 1);
+		if (spot < 0)
+			break;
+		if (spot >= net_clen_bits)
+			return -ENOSPC;
+		netlbl_bitmap_setbit(net_cat, spot, 1);
+
+		if (spot > net_spot_max)
+			net_spot_max = spot;
+	}
+
+	return (net_spot_max / 32 + 1) * 4;
+}
+
+/**
+ * calipso_map_cat_ntoh - Perform a category mapping from network to host
+ * @doi_def: the DOI definition
+ * @net_cat: the category bitmap in network/CALIPSO format
+ * @net_cat_len: the length of the CALIPSO bitmap in bytes
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Perform a label mapping to translate a CALIPSO bitmap to the correct local
+ * MLS category bitmap using the given DOI definition.  Returns zero on
+ * success, negative values on failure.
+ *
+ */
+static int calipso_map_cat_ntoh(const struct calipso_doi *doi_def,
+				const unsigned char *net_cat,
+				u32 net_cat_len,
+				struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val;
+	int spot = -1;
+	u32 net_clen_bits = net_cat_len * 8;
+
+	for (;;) {
+		spot = netlbl_bitmap_walk(net_cat,
+					  net_clen_bits,
+					  spot + 1,
+					  1);
+		if (spot < 0) {
+			if (spot == -2)
+				return -EFAULT;
+			return 0;
+		}
+
+		ret_val = netlbl_catmap_setbit(&secattr->attr.mls.cat,
+					       spot,
+					       GFP_ATOMIC);
+		if (ret_val != 0)
+			return ret_val;
+	}
+
+	return -EINVAL;
+}
+
+/**
+ * calipso_pad_write - Writes pad bytes in TLV format
+ * @buf: the buffer
+ * @offset: offset from start of buffer to write padding
+ * @count: number of pad bytes to write
+ *
+ * Description:
+ * Write @count bytes of TLV padding into @buffer starting at offset @offset.
+ * @count should be less than 8 - see RFC 4942.
+ *
+ */
+static int calipso_pad_write(unsigned char *buf, unsigned int offset,
+			     unsigned int count)
+{
+	if (WARN_ON_ONCE(count >= 8))
+		return -EINVAL;
+
+	switch (count) {
+	case 0:
+		break;
+	case 1:
+		buf[offset] = IPV6_TLV_PAD1;
+		break;
+	default:
+		buf[offset] = IPV6_TLV_PADN;
+		buf[offset + 1] = count - 2;
+		if (count > 2)
+			memset(buf + offset + 2, 0, count - 2);
+		break;
+	}
+	return 0;
+}
+
+/**
+ * calipso_genopt - Generate a CALIPSO option
+ * @buf: the option buffer
+ * @start: offset from which to write
+ * @buf_len: the size of opt_buf
+ * @doi_def: the CALIPSO DOI to use
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Generate a CALIPSO option using the DOI definition and security attributes
+ * passed to the function. This also generates upto three bytes of leading
+ * padding that ensures that the option is 4n + 2 aligned.  It returns the
+ * number of bytes written (including any initial padding).
+ */
+static int calipso_genopt(unsigned char *buf, u32 start, u32 buf_len,
+			  const struct calipso_doi *doi_def,
+			  const struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val;
+	u32 len, pad;
+	u16 crc;
+	static const unsigned char padding[4] = {2, 1, 0, 3};
+	unsigned char *calipso;
+
+	/* CALIPSO has 4n + 2 alignment */
+	pad = padding[start & 3];
+	if (buf_len <= start + pad + CALIPSO_HDR_LEN)
+		return -ENOSPC;
+
+	if ((secattr->flags & NETLBL_SECATTR_MLS_LVL) == 0)
+		return -EPERM;
+
+	len = CALIPSO_HDR_LEN;
+
+	if (secattr->flags & NETLBL_SECATTR_MLS_CAT) {
+		ret_val = calipso_map_cat_hton(doi_def,
+					       secattr,
+					       buf + start + pad + len,
+					       buf_len - start - pad - len);
+		if (ret_val < 0)
+			return ret_val;
+		len += ret_val;
+	}
+
+	calipso_pad_write(buf, start, pad);
+	calipso = buf + start + pad;
+
+	calipso[0] = IPV6_TLV_CALIPSO;
+	calipso[1] = len - 2;
+	*(__be32 *)(calipso + 2) = htonl(doi_def->doi);
+	calipso[6] = (len - CALIPSO_HDR_LEN) / 4;
+	calipso[7] = secattr->attr.mls.lvl,
+	crc = ~crc_ccitt(0xffff, calipso, len);
+	calipso[8] = crc & 0xff;
+	calipso[9] = (crc >> 8) & 0xff;
+	return pad + len;
+}
+
+/* Hop-by-hop hdr helper functions
+ */
+
+/**
+ * calipso_opt_update - Replaces socket's hop options with a new set
+ * @sk: the socket
+ * @hop: new hop options
+ *
+ * Description:
+ * Replaces @sk's hop options with @hop.  @hop may be NULL to leave
+ * the socket with no hop options.
+ *
+ */
+static int calipso_opt_update(struct sock *sk, struct ipv6_opt_hdr *hop)
+{
+	struct ipv6_txoptions *old = txopt_get(inet6_sk(sk)), *txopts;
+
+	txopts = ipv6_renew_options_kern(sk, old, IPV6_HOPOPTS,
+					 hop, hop ? ipv6_optlen(hop) : 0);
+	txopt_put(old);
+	if (IS_ERR(txopts))
+		return PTR_ERR(txopts);
+
+	txopts = ipv6_update_options(sk, txopts);
+	if (txopts) {
+		atomic_sub(txopts->tot_len, &sk->sk_omem_alloc);
+		txopt_put(txopts);
+	}
+
+	return 0;
+}
+
+/**
+ * calipso_tlv_len - Returns the length of the TLV
+ * @opt: the option header
+ * @offset: offset of the TLV within the header
+ *
+ * Description:
+ * Returns the length of the TLV option at offset @offset within
+ * the option header @opt.  Checks that the entire TLV fits inside
+ * the option header, returns a negative value if this is not the case.
+ */
+static int calipso_tlv_len(struct ipv6_opt_hdr *opt, unsigned int offset)
+{
+	unsigned char *tlv = (unsigned char *)opt;
+	unsigned int opt_len = ipv6_optlen(opt), tlv_len;
+
+	if (offset < sizeof(*opt) || offset >= opt_len)
+		return -EINVAL;
+	if (tlv[offset] == IPV6_TLV_PAD1)
+		return 1;
+	if (offset + 1 >= opt_len)
+		return -EINVAL;
+	tlv_len = tlv[offset + 1] + 2;
+	if (offset + tlv_len > opt_len)
+		return -EINVAL;
+	return tlv_len;
+}
+
+/**
+ * calipso_opt_find - Finds the CALIPSO option in an IPv6 hop options header
+ * @hop: the hop options header
+ * @start: on return holds the offset of any leading padding
+ * @end: on return holds the offset of the first non-pad TLV after CALIPSO
+ *
+ * Description:
+ * Finds the space occupied by a CALIPSO option (including any leading and
+ * trailing padding).
+ *
+ * If a CALIPSO option exists set @start and @end to the
+ * offsets within @hop of the start of padding before the first
+ * CALIPSO option and the end of padding after the first CALIPSO
+ * option.  In this case the function returns 0.
+ *
+ * In the absence of a CALIPSO option, @start and @end will be
+ * set to the start and end of any trailing padding in the header.
+ * This is useful when appending a new option, as the caller may want
+ * to overwrite some of this padding.  In this case the function will
+ * return -ENOENT.
+ */
+static int calipso_opt_find(struct ipv6_opt_hdr *hop, unsigned int *start,
+			    unsigned int *end)
+{
+	int ret_val = -ENOENT, tlv_len;
+	unsigned int opt_len, offset, offset_s = 0, offset_e = 0;
+	unsigned char *opt = (unsigned char *)hop;
+
+	opt_len = ipv6_optlen(hop);
+	offset = sizeof(*hop);
+
+	while (offset < opt_len) {
+		tlv_len = calipso_tlv_len(hop, offset);
+		if (tlv_len < 0)
+			return tlv_len;
+
+		switch (opt[offset]) {
+		case IPV6_TLV_PAD1:
+		case IPV6_TLV_PADN:
+			if (offset_e)
+				offset_e = offset;
+			break;
+		case IPV6_TLV_CALIPSO:
+			ret_val = 0;
+			offset_e = offset;
+			break;
+		default:
+			if (offset_e == 0)
+				offset_s = offset;
+			else
+				goto out;
+		}
+		offset += tlv_len;
+	}
+
+out:
+	if (offset_s)
+		*start = offset_s + calipso_tlv_len(hop, offset_s);
+	else
+		*start = sizeof(*hop);
+	if (offset_e)
+		*end = offset_e + calipso_tlv_len(hop, offset_e);
+	else
+		*end = opt_len;
+
+	return ret_val;
+}
+
+/**
+ * calipso_opt_insert - Inserts a CALIPSO option into an IPv6 hop opt hdr
+ * @hop: the original hop options header
+ * @doi_def: the CALIPSO DOI to use
+ * @secattr: the specific security attributes of the socket
+ *
+ * Description:
+ * Creates a new hop options header based on @hop with a
+ * CALIPSO option added to it.  If @hop already contains a CALIPSO
+ * option this is overwritten, otherwise the new option is appended
+ * after any existing options.  If @hop is NULL then the new header
+ * will contain just the CALIPSO option and any needed padding.
+ *
+ */
+static struct ipv6_opt_hdr *
+calipso_opt_insert(struct ipv6_opt_hdr *hop,
+		   const struct calipso_doi *doi_def,
+		   const struct netlbl_lsm_secattr *secattr)
+{
+	unsigned int start, end, buf_len, pad, hop_len;
+	struct ipv6_opt_hdr *new;
+	int ret_val;
+
+	if (hop) {
+		hop_len = ipv6_optlen(hop);
+		ret_val = calipso_opt_find(hop, &start, &end);
+		if (ret_val && ret_val != -ENOENT)
+			return ERR_PTR(ret_val);
+	} else {
+		hop_len = 0;
+		start = sizeof(*hop);
+		end = 0;
+	}
+
+	buf_len = hop_len + start - end + CALIPSO_OPT_LEN_MAX_WITH_PAD;
+	new = kzalloc(buf_len, GFP_ATOMIC);
+	if (!new)
+		return ERR_PTR(-ENOMEM);
+
+	if (start > sizeof(*hop))
+		memcpy(new, hop, start);
+	ret_val = calipso_genopt((unsigned char *)new, start, buf_len, doi_def,
+				 secattr);
+	if (ret_val < 0)
+		return ERR_PTR(ret_val);
+
+	buf_len = start + ret_val;
+	/* At this point buf_len aligns to 4n, so (buf_len & 4) pads to 8n */
+	pad = ((buf_len & 4) + (end & 7)) & 7;
+	calipso_pad_write((unsigned char *)new, buf_len, pad);
+	buf_len += pad;
+
+	if (end != hop_len) {
+		memcpy((char *)new + buf_len, (char *)hop + end, hop_len - end);
+		buf_len += hop_len - end;
+	}
+	new->nexthdr = 0;
+	new->hdrlen = buf_len / 8 - 1;
+
+	return new;
+}
+
+/**
+ * calipso_opt_del - Removes the CALIPSO option from an option header
+ * @hop: the original header
+ * @new: the new header
+ *
+ * Description:
+ * Creates a new header based on @hop without any CALIPSO option.  If @hop
+ * doesn't contain a CALIPSO option it returns -ENOENT.  If @hop contains
+ * no other non-padding options, it returns zero with @new set to NULL.
+ * Otherwise it returns zero, creates a new header without the CALIPSO
+ * option (and removing as much padding as possible) and returns with
+ * @new set to that header.
+ *
+ */
+static int calipso_opt_del(struct ipv6_opt_hdr *hop,
+			   struct ipv6_opt_hdr **new)
+{
+	int ret_val;
+	unsigned int start, end, delta, pad, hop_len;
+
+	ret_val = calipso_opt_find(hop, &start, &end);
+	if (ret_val)
+		return ret_val;
+
+	hop_len = ipv6_optlen(hop);
+	if (start == sizeof(*hop) && end == hop_len) {
+		/* There's no other option in the header so return NULL */
+		*new = NULL;
+		return 0;
+	}
+
+	delta = (end - start) & ~7;
+	*new = kzalloc(hop_len - delta, GFP_ATOMIC);
+	if (!*new)
+		return -ENOMEM;
+
+	memcpy(*new, hop, start);
+	(*new)->hdrlen -= delta / 8;
+	pad = (end - start) & 7;
+	calipso_pad_write((unsigned char *)*new, start, pad);
+	if (end != hop_len)
+		memcpy((char *)*new + start + pad, (char *)hop + end,
+		       hop_len - end);
+
+	return 0;
+}
+
+/**
+ * calipso_opt_getattr - Get the security attributes from a memory block
+ * @calipso: the CALIPSO option
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Inspect @calipso and return the security attributes in @secattr.
+ * Returns zero on success and negative values on failure.
+ *
+ */
+static int calipso_opt_getattr(const unsigned char *calipso,
+			       struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val = -ENOMSG;
+	u32 doi, len = calipso[1], cat_len = calipso[6] * 4;
+	struct calipso_doi *doi_def;
+
+	if (cat_len + 8 > len)
+		return -EINVAL;
+
+	doi = get_unaligned_be32(calipso + 2);
+	rcu_read_lock();
+	doi_def = calipso_doi_search(doi);
+	if (!doi_def)
+		goto getattr_return;
+
+	secattr->attr.mls.lvl = calipso[7];
+	secattr->flags |= NETLBL_SECATTR_MLS_LVL;
+
+	if (cat_len) {
+		ret_val = calipso_map_cat_ntoh(doi_def,
+					       calipso + 10,
+					       cat_len,
+					       secattr);
+		if (ret_val != 0) {
+			netlbl_catmap_free(secattr->attr.mls.cat);
+			goto getattr_return;
+		}
+
+		secattr->flags |= NETLBL_SECATTR_MLS_CAT;
+	}
+
+	secattr->type = NETLBL_NLTYPE_CALIPSO;
+
+getattr_return:
+	rcu_read_unlock();
+	return ret_val;
+}
+
+/* sock functions.
+ */
+
+/**
+ * calipso_sock_getattr - Get the security attributes from a sock
+ * @sk: the sock
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Query @sk to see if there is a CALIPSO option attached to the sock and if
+ * there is return the CALIPSO security attributes in @secattr.  This function
+ * requires that @sk be locked, or privately held, but it does not do any
+ * locking itself.  Returns zero on success and negative values on failure.
+ *
+ */
+static int calipso_sock_getattr(struct sock *sk,
+				struct netlbl_lsm_secattr *secattr)
+{
+	struct ipv6_opt_hdr *hop;
+	int opt_len, len, ret_val = -ENOMSG, offset;
+	unsigned char *opt;
+	struct ipv6_txoptions *txopts = txopt_get(inet6_sk(sk));
+
+	if (!txopts || !txopts->hopopt)
+		goto done;
+
+	hop = txopts->hopopt;
+	opt = (unsigned char *)hop;
+	opt_len = ipv6_optlen(hop);
+	offset = sizeof(*hop);
+	while (offset < opt_len) {
+		len = calipso_tlv_len(hop, offset);
+		if (len < 0) {
+			ret_val = len;
+			goto done;
+		}
+		switch (opt[offset]) {
+		case IPV6_TLV_CALIPSO:
+			if (len < CALIPSO_HDR_LEN)
+				ret_val = -EINVAL;
+			else
+				ret_val = calipso_opt_getattr(&opt[offset],
+							      secattr);
+			goto done;
+		default:
+			offset += len;
+			break;
+		}
+	}
+done:
+	txopt_put(txopts);
+	return ret_val;
+}
+
+/**
+ * calipso_sock_setattr - Add a CALIPSO option to a socket
+ * @sk: the socket
+ * @doi_def: the CALIPSO DOI to use
+ * @secattr: the specific security attributes of the socket
+ *
+ * Description:
+ * Set the CALIPSO option on the given socket using the DOI definition and
+ * security attributes passed to the function.  This function requires
+ * exclusive access to @sk, which means it either needs to be in the
+ * process of being created or locked.  Returns zero on success and negative
+ * values on failure.
+ *
+ */
+static int calipso_sock_setattr(struct sock *sk,
+				const struct calipso_doi *doi_def,
+				const struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val;
+	struct ipv6_opt_hdr *old, *new;
+	struct ipv6_txoptions *txopts = txopt_get(inet6_sk(sk));
+
+	old = NULL;
+	if (txopts)
+		old = txopts->hopopt;
+
+	new = calipso_opt_insert(old, doi_def, secattr);
+	txopt_put(txopts);
+	if (IS_ERR(new))
+		return PTR_ERR(new);
+
+	ret_val = calipso_opt_update(sk, new);
+
+	kfree(new);
+	return ret_val;
+}
+
+/**
+ * calipso_sock_delattr - Delete the CALIPSO option from a socket
+ * @sk: the socket
+ *
+ * Description:
+ * Removes the CALIPSO option from a socket, if present.
+ *
+ */
+static void calipso_sock_delattr(struct sock *sk)
+{
+	struct ipv6_opt_hdr *new_hop;
+	struct ipv6_txoptions *txopts = txopt_get(inet6_sk(sk));
+
+	if (!txopts || !txopts->hopopt)
+		goto done;
+
+	if (calipso_opt_del(txopts->hopopt, &new_hop))
+		goto done;
+
+	calipso_opt_update(sk, new_hop);
+	kfree(new_hop);
+
+done:
+	txopt_put(txopts);
+}
+
 static const struct netlbl_calipso_ops ops = {
 	.doi_add          = calipso_doi_add,
 	.doi_free         = calipso_doi_free,
@@ -304,6 +896,9 @@ static const struct netlbl_calipso_ops ops = {
 	.doi_getdef       = calipso_doi_getdef,
 	.doi_putdef       = calipso_doi_putdef,
 	.doi_walk         = calipso_doi_walk,
+	.sock_getattr     = calipso_sock_getattr,
+	.sock_setattr     = calipso_sock_setattr,
+	.sock_delattr     = calipso_sock_delattr,
 };
 
 /**
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 4449ad1..8a80d59 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -98,7 +98,6 @@ int ip6_ra_control(struct sock *sk, int sel)
 	return 0;
 }
 
-static
 struct ipv6_txoptions *ipv6_update_options(struct sock *sk,
 					   struct ipv6_txoptions *opt)
 {
diff --git a/net/netlabel/Kconfig b/net/netlabel/Kconfig
index 56958c8..d9eaa30 100644
--- a/net/netlabel/Kconfig
+++ b/net/netlabel/Kconfig
@@ -5,6 +5,7 @@
 config NETLABEL
 	bool "NetLabel subsystem support"
 	depends on SECURITY
+	select CRC_CCITT if IPV6
 	default n
 	---help---
 	  NetLabel provides support for explicit network packet labeling
diff --git a/net/netlabel/netlabel_calipso.c b/net/netlabel/netlabel_calipso.c
index 2857673..6f9c658 100644
--- a/net/netlabel/netlabel_calipso.c
+++ b/net/netlabel/netlabel_calipso.c
@@ -514,3 +514,67 @@ int calipso_doi_walk(u32 *skip_cnt,
 		ret_val = ops->doi_walk(skip_cnt, callback, cb_arg);
 	return ret_val;
 }
+
+/**
+ * calipso_sock_getattr - Get the security attributes from a sock
+ * @sk: the sock
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Query @sk to see if there is a CALIPSO option attached to the sock and if
+ * there is return the CALIPSO security attributes in @secattr.  This function
+ * requires that @sk be locked, or privately held, but it does not do any
+ * locking itself.  Returns zero on success and negative values on failure.
+ *
+ */
+int calipso_sock_getattr(struct sock *sk, struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val = -ENOMSG;
+	const struct netlbl_calipso_ops *ops = netlbl_calipso_ops_get();
+
+	if (ops)
+		ret_val = ops->sock_getattr(sk, secattr);
+	return ret_val;
+}
+
+/**
+ * calipso_sock_setattr - Add a CALIPSO option to a socket
+ * @sk: the socket
+ * @doi_def: the CALIPSO DOI to use
+ * @secattr: the specific security attributes of the socket
+ *
+ * Description:
+ * Set the CALIPSO option on the given socket using the DOI definition and
+ * security attributes passed to the function.  This function requires
+ * exclusive access to @sk, which means it either needs to be in the
+ * process of being created or locked.  Returns zero on success and negative
+ * values on failure.
+ *
+ */
+int calipso_sock_setattr(struct sock *sk,
+			 const struct calipso_doi *doi_def,
+			 const struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val = -ENOMSG;
+	const struct netlbl_calipso_ops *ops = netlbl_calipso_ops_get();
+
+	if (ops)
+		ret_val = ops->sock_setattr(sk, doi_def, secattr);
+	return ret_val;
+}
+
+/**
+ * calipso_sock_delattr - Delete the CALIPSO option from a socket
+ * @sk: the socket
+ *
+ * Description:
+ * Removes the CALIPSO option from a socket, if present.
+ *
+ */
+void calipso_sock_delattr(struct sock *sk)
+{
+	const struct netlbl_calipso_ops *ops = netlbl_calipso_ops_get();
+
+	if (ops)
+		ops->sock_delattr(sk);
+}
diff --git a/net/netlabel/netlabel_calipso.h b/net/netlabel/netlabel_calipso.h
index ed78554..49bc116 100644
--- a/net/netlabel/netlabel_calipso.h
+++ b/net/netlabel/netlabel_calipso.h
@@ -128,5 +128,10 @@ void calipso_doi_putdef(struct calipso_doi *doi_def);
 int calipso_doi_walk(u32 *skip_cnt,
 		     int (*callback)(struct calipso_doi *doi_def, void *arg),
 		     void *cb_arg);
+int calipso_sock_getattr(struct sock *sk, struct netlbl_lsm_secattr *secattr);
+int calipso_sock_setattr(struct sock *sk,
+			 const struct calipso_doi *doi_def,
+			 const struct netlbl_lsm_secattr *secattr);
+void calipso_sock_delattr(struct sock *sk);
 
 #endif
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 609c853..ed35ad9 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -37,12 +37,14 @@
 #include <net/ipv6.h>
 #include <net/netlabel.h>
 #include <net/cipso_ipv4.h>
+#include <net/calipso.h>
 #include <asm/bug.h>
 #include <linux/atomic.h>
 
 #include "netlabel_domainhash.h"
 #include "netlabel_unlabeled.h"
 #include "netlabel_cipso_v4.h"
+#include "netlabel_calipso.h"
 #include "netlabel_user.h"
 #include "netlabel_mgmt.h"
 #include "netlabel_addrlist.h"
@@ -521,6 +523,7 @@ int netlbl_catmap_walk(struct netlbl_lsm_catmap *catmap, u32 offset)
 
 	return -ENOENT;
 }
+EXPORT_SYMBOL(netlbl_catmap_walk);
 
 /**
  * netlbl_catmap_walkrng - Find the end of a string of set bits
@@ -657,6 +660,7 @@ int netlbl_catmap_setbit(struct netlbl_lsm_catmap **catmap,
 
 	return 0;
 }
+EXPORT_SYMBOL(netlbl_catmap_setbit);
 
 /**
  * netlbl_catmap_setrng - Set a range of bits in a LSM secattr catmap
@@ -871,9 +875,21 @@ int netlbl_sock_setattr(struct sock *sk,
 		break;
 #if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
-		/* since we don't support any IPv6 labeling protocols right
-		 * now we can optimize everything away until we do */
-		ret_val = 0;
+		switch (dom_entry->def.type) {
+		case NETLBL_NLTYPE_ADDRSELECT:
+			ret_val = -EDESTADDRREQ;
+			break;
+		case NETLBL_NLTYPE_CALIPSO:
+			ret_val = calipso_sock_setattr(sk,
+						       dom_entry->def.calipso,
+						       secattr);
+			break;
+		case NETLBL_NLTYPE_UNLABELED:
+			ret_val = 0;
+			break;
+		default:
+			ret_val = -ENOENT;
+		}
 		break;
 #endif /* IPv6 */
 	default:
@@ -896,7 +912,16 @@ socket_setattr_return:
  */
 void netlbl_sock_delattr(struct sock *sk)
 {
-	cipso_v4_sock_delattr(sk);
+	switch (sk->sk_family) {
+	case AF_INET:
+		cipso_v4_sock_delattr(sk);
+		break;
+#if IS_ENABLED(CONFIG_IPV6)
+	case AF_INET6:
+		calipso_sock_delattr(sk);
+		break;
+#endif /* IPv6 */
+	}
 }
 
 /**
@@ -922,7 +947,7 @@ int netlbl_sock_getattr(struct sock *sk,
 		break;
 #if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
-		ret_val = -ENOMSG;
+		ret_val = calipso_sock_getattr(sk, secattr);
 		break;
 #endif /* IPv6 */
 	default:
@@ -950,6 +975,9 @@ int netlbl_conn_setattr(struct sock *sk,
 {
 	int ret_val;
 	struct sockaddr_in *addr4;
+#if IS_ENABLED(CONFIG_IPV6)
+	struct sockaddr_in6 *addr6;
+#endif
 	struct netlbl_dommap_def *entry;
 
 	rcu_read_lock();
@@ -970,7 +998,7 @@ int netlbl_conn_setattr(struct sock *sk,
 		case NETLBL_NLTYPE_UNLABELED:
 			/* just delete the protocols we support for right now
 			 * but we could remove other protocols if needed */
-			cipso_v4_sock_delattr(sk);
+			netlbl_sock_delattr(sk);
 			ret_val = 0;
 			break;
 		default:
@@ -979,9 +1007,27 @@ int netlbl_conn_setattr(struct sock *sk,
 		break;
 #if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
-		/* since we don't support any IPv6 labeling protocols right
-		 * now we can optimize everything away until we do */
-		ret_val = 0;
+		addr6 = (struct sockaddr_in6 *)addr;
+		entry = netlbl_domhsh_getentry_af6(secattr->domain,
+						   &addr6->sin6_addr);
+		if (entry == NULL) {
+			ret_val = -ENOENT;
+			goto conn_setattr_return;
+		}
+		switch (entry->type) {
+		case NETLBL_NLTYPE_CALIPSO:
+			ret_val = calipso_sock_setattr(sk,
+						       entry->calipso, secattr);
+			break;
+		case NETLBL_NLTYPE_UNLABELED:
+			/* just delete the protocols we support for right now
+			 * but we could remove other protocols if needed */
+			netlbl_sock_delattr(sk);
+			ret_val = 0;
+			break;
+		default:
+			ret_val = -ENOENT;
+		}
 		break;
 #endif /* IPv6 */
 	default:
diff --git a/security/selinux/netlabel.c b/security/selinux/netlabel.c
index 1f989a5..5470f32 100644
--- a/security/selinux/netlabel.c
+++ b/security/selinux/netlabel.c
@@ -333,7 +333,7 @@ int selinux_netlbl_socket_post_create(struct sock *sk, u16 family)
 	struct sk_security_struct *sksec = sk->sk_security;
 	struct netlbl_lsm_secattr *secattr;
 
-	if (family != PF_INET)
+	if (family != PF_INET && family != PF_INET6)
 		return 0;
 
 	secattr = selinux_netlbl_sock_genattr(sk);
-- 
2.7.4

