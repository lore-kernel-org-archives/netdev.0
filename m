From: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
Subject: [RFC v2 1/3] iwlwifi: mvm: add real TSO implementation
Date: Wed, 19 Aug 2015 15:59:39 +0300
Message-ID: <1439989181-4444-2-git-send-email-emmanuel.grumbach@intel.com>
References: <1439989181-4444-1-git-send-email-emmanuel.grumbach@intel.com>
Cc: ido@wizery.com, netdev@vger.kernel.org,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:11337 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753093AbbHSM76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 08:59:58 -0400
In-Reply-To: <1439989181-4444-1-git-send-email-emmanuel.grumbach@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The segmentation is done completely in software. The
driver creates several MPDUs out of a single large send.
Each MPDU is a newly allocated SKB.
A page is allocated to create the headers that need to be
duplicated (SNAP / IP / TCP). The WiFi header is in the
header of the newly created SKBs.

type=feature

Change-Id: I238ffa79cacc5bbdacdfbf3e9673c8d4f02b462a
Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
---
 drivers/net/wireless/iwlwifi/mvm/tx.c | 513 +++++++++++++++++++++++++++++++---
 1 file changed, 481 insertions(+), 32 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/mvm/tx.c b/drivers/net/wireless/iwlwifi/mvm/tx.c
index 90f0ea1..a63686c 100644
--- a/drivers/net/wireless/iwlwifi/mvm/tx.c
+++ b/drivers/net/wireless/iwlwifi/mvm/tx.c
@@ -65,6 +65,7 @@
 #include <linux/ieee80211.h>
 #include <linux/etherdevice.h>
 #include <net/tcp.h>
+#include <net/ip.h>
 
 #include "iwl-trans.h"
 #include "iwl-eeprom-parse.h"
@@ -435,32 +436,471 @@ int iwl_mvm_tx_skb_non_sta(struct iwl_mvm *mvm, struct sk_buff *skb)
 	return 0;
 }
 
+/*
+ * Update the IP / TCP headers and recompute the IP header CSUM +
+ * pseudo header CSUM.
+ */
+static void iwl_update_ip_tcph(void *iph, struct tcphdr *tcph, bool ipv6,
+			       unsigned int len, unsigned int tcp_seq_offset,
+			       u16 num_segment)
+{
+	be32_add_cpu(&tcph->seq, tcp_seq_offset);
+
+	if (ipv6) {
+		struct ipv6hdr *iphv6 = iph;
+
+		iphv6->payload_len = cpu_to_be16(len + tcph->doff * 4);
+
+		/* Compute CSUM on the the pseudo-header */
+		tcph->check = ~csum_ipv6_magic(&iphv6->saddr, &iphv6->daddr,
+					       len + tcph->doff * 4,
+					       IPPROTO_TCP, 0);
+	} else {
+		struct iphdr *iphv4 = iph;
+
+		iphv4->tot_len =
+			cpu_to_be16(len + tcph->doff * 4 + iphv4->ihl * 4);
+		be16_add_cpu(&iphv4->id, num_segment);
+		ip_send_check(iphv4);
+
+		/* Compute CSUM on the the pseudo-header */
+		tcph->check = ~csum_tcpudp_magic(iphv4->saddr, iphv4->daddr,
+						 len + tcph->doff * 4,
+						 IPPROTO_TCP, 0);
+	}
+}
+
+/**
+ * struct iwl_lso_splitter - state of the split.
+ * @linear_payload_len: The length of the payload inside the header of the
+ *	original GSO skb.
+ * @gso_frag_num: The fragment number from which to take the data in the
+ *	original GSO skb.
+ * @gso_payload_len: The length of the payload in the original GSO skb.
+ * @gso_payload_pos: The incrementing position in the payload of the original
+ *	GSO skb.
+ * @gso_offset_in_page: The offset in the page of &gso_frag_num.
+ * @gso_current_frag_size: The size of &gso_frag_num.
+ * @gso_offset_in_frag: The offset in the &gso_frag_num.
+ * @frag_in_mpdu: The index of the frag inside the new (split) MPDU.
+ * @mss: The maximal segment size.
+ * @si: Points to the the shared info of the original GSO skb.
+ * @ieee80211_hdr *hdr: Points to the WiFi header.
+ * @gso_nr_frags: The number of frags in the original GSO skb.
+ * @wifi_hdr_iv_len: The length of the WiFi header including IV.
+ * @tcp_fin: True if TCP_FIN is set in the original GSO skb.
+ * @tcp_push: True if TCP_PSH is set in the original GSO skb.
+ */
+struct iwl_lso_splitter {
+	unsigned int linear_payload_len;
+	unsigned int gso_frag_num;
+	unsigned int gso_payload_len;
+	unsigned int gso_payload_pos;
+	unsigned int gso_offset_in_page;
+	unsigned int gso_current_frag_size;
+	unsigned int gso_offset_in_frag;
+	unsigned int frag_in_mpdu;
+	unsigned int mss;
+	struct skb_shared_info *si;
+	struct ieee80211_hdr *hdr;
+	u8 gso_nr_frags;
+	u8 wifi_hdr_iv_len;
+	bool tcp_fin;
+	bool tcp_push;
+};
+
+/*
+ * Adds a TCP segment from skb_gso to skb. All the state is taken from
+ * and fed back to p. This function takes care about the payload only.
+ * This MSDU might already have msdu_sz bytes of payload that come from
+ * the original GSO skb's header.
+ */
+static unsigned int
+iwl_add_tcp_segment(struct iwl_mvm *mvm, struct sk_buff *skb_gso,
+		    struct sk_buff *skb, struct iwl_lso_splitter *p,
+		    unsigned int msdu_sz)
+{
+	while (msdu_sz < p->mss) {
+		unsigned int frag_sz =
+			min_t(unsigned int, p->gso_current_frag_size,
+			      p->mss - msdu_sz);
+
+		if (p->frag_in_mpdu >= mvm->trans->max_skb_frags)
+			return msdu_sz;
+
+		skb_add_rx_frag(skb, p->frag_in_mpdu,
+				skb_frag_page(&p->si->frags[p->gso_frag_num]),
+				p->gso_offset_in_page, frag_sz, 0);
+
+		/* We just added one frag to the mpdu ... */
+		p->frag_in_mpdu++;
+
+		/* ... which is frag_sz byte long ... */
+		msdu_sz += frag_sz;
+
+		/* ... we progress inside the gso frag ... */
+		p->gso_offset_in_page += frag_sz;
+
+		/* ... which is now getting smaller ... */
+		p->gso_current_frag_size -= frag_sz;
+
+		/* ... and we also progress in the global pos counting. */
+		p->gso_payload_pos += frag_sz;
+
+		/*
+		 * This frag has some more bytes that can't fit into this MSDU,
+		 * get a new one, and take a ref since this frag will be
+		 * attached to two different skbs.
+		 */
+		if (p->gso_current_frag_size) {
+			skb_frag_ref(skb_gso, p->gso_frag_num);
+			break;
+		}
+
+		/* We exhausted this frag go the next one ... */
+		p->gso_frag_num++;
+
+		/* ... if it exists ... */
+		if (p->gso_frag_num == p->gso_nr_frags)
+			break;
+
+		/* ... consider its full size ... */
+		p->gso_current_frag_size =
+			skb_frag_size(&p->si->frags[p->gso_frag_num]);
+		/* ... and start from its beginning. */
+		p->gso_offset_in_page =
+			p->si->frags[p->gso_frag_num].page_offset;
+	}
+	return msdu_sz;
+}
+
+/* Hack to compute the CSUM in software. For early testing */
+static __sum16
+iwl_sw_tcp_csum_offload(struct sk_buff *skb,
+			int tcph_offset, int len, int tcp_hdrlen)
+{
+	struct sk_buff *skb1;
+	__wsum csum;
+
+	len += tcp_hdrlen;
+	skb1 = alloc_skb(len, GFP_ATOMIC);
+	BUG_ON(!skb1);
+
+	skb_copy_bits(skb, tcph_offset, skb_put(skb1, len), len);
+
+	skb_set_transport_header(skb1, 0);
+	skb1->csum_start = (unsigned char *)tcp_hdr(skb1) - skb1->head;
+	csum = skb_checksum(skb1, skb_checksum_start_offset(skb1),
+			    skb1->len - skb_checksum_start_offset(skb1),
+			    0);
+	dev_kfree_skb(skb1);
+
+	return csum_fold(csum);
+}
+
+static u8 *get_page_pos(struct page **page, u8 *page_pos, size_t len)
+{
+	if (!*page)
+		goto alloc;
+
+	if (page_pos + len < (u8 *)page_address(*page) + PAGE_SIZE)
+		return page_pos;
+
+	__free_pages(*page, 0);
+
+alloc:
+	*page = alloc_pages(GFP_ATOMIC, 0);
+	if (!*page)
+		return NULL;
+
+	return page_address(*page);
+}
+
+static int iwl_add_msdu(struct iwl_mvm *mvm, struct sk_buff *skb_gso,
+			struct sk_buff *skb, struct page **hdr_page,
+			u8 **hdr_page_pos, int ip_id,
+			struct iwl_lso_splitter *p)
+{
+	unsigned int tcp_seg_sz, snap_ip_tcp_len, copy_sz = 0;
+	bool ipv6 = p->si->gso_type & SKB_GSO_TCPV6;
+	u8 *start_hdr;
+	struct tcphdr *tcph;
+	struct iphdr *iph;
+
+	snap_ip_tcp_len =
+		8 + skb_network_header_len(skb_gso) + tcp_hdrlen(skb_gso);
+	copy_sz = min_t(unsigned int, p->linear_payload_len, p->mss);
+
+	*hdr_page_pos =
+		get_page_pos(hdr_page, *hdr_page_pos,
+			     snap_ip_tcp_len + copy_sz +
+			     sizeof(struct ethhdr) + 4);
+	if (!*hdr_page_pos)
+		return -ENOMEM;
+
+	start_hdr = *hdr_page_pos;
+
+	/*
+	 * Copy SNAP / IP / TCP headers from the original GSO skb to the
+	 * header page.
+	 */
+	skb_copy_bits(skb_gso, p->wifi_hdr_iv_len,
+		      *hdr_page_pos, snap_ip_tcp_len);
+
+	*hdr_page_pos += 8;
+
+	iph = (void *)*hdr_page_pos;
+	*hdr_page_pos += skb_network_header_len(skb_gso);
+
+	tcph = (void *)*hdr_page_pos;
+	*hdr_page_pos += tcp_hdrlen(skb_gso);
+
+	/*
+	 * If the original GSO skb had more than MSS bytes of payload in its
+	 * header, consume it now.
+	 */
+	if (copy_sz) {
+		/*
+		 * Since we copy from the tail pointer and don't update it,
+		 * we can't have more than 1 mss in the linear_payload_len
+		 * at this stage. Hence the limitation of 2 MSS in
+		 * iwl_mvm_tx_tso.
+		 */
+		memcpy(*hdr_page_pos, skb_tail_pointer(skb_gso), copy_sz);
+		*hdr_page_pos += copy_sz;
+		p->gso_payload_pos += copy_sz;
+		p->linear_payload_len -= copy_sz;
+	}
+
+	/* Add frag for SNAP / IP / TCP headers and possibly some payload .. */
+	get_page(*hdr_page);
+	skb_add_rx_frag(skb, p->frag_in_mpdu, *hdr_page,
+			(u8 *)start_hdr - (u8 *)page_address(*hdr_page),
+			*hdr_page_pos - start_hdr, 0);
+	p->frag_in_mpdu++;
+
+	/* .. and now add the payload coming from the frags. */
+	tcp_seg_sz = iwl_add_tcp_segment(mvm, skb_gso, skb, p, copy_sz);
+
+	iwl_update_ip_tcph(iph, tcph, ipv6, tcp_seg_sz,
+			   p->gso_payload_pos - tcp_seg_sz, ip_id);
+
+	/* Last segment, apply the TCP flags that may have been delayed */
+	if (p->gso_payload_pos == p->gso_payload_len) {
+		if (p->tcp_push)
+			tcph->psh = 1;
+		if (p->tcp_fin)
+			tcph->fin = 1;
+	}
+
+	if (IWL_MVM_SW_TX_CSUM_OFFLOAD)
+		tcph->check =
+			iwl_sw_tcp_csum_offload(skb, skb->len -
+						     tcp_seg_sz -
+						     tcp_hdrlen(skb_gso),
+						tcp_seg_sz,
+						tcp_hdrlen(skb_gso));
+
+	return 0;
+}
+
 static int iwl_mvm_tx_tso(struct iwl_mvm *mvm, struct sk_buff *skb_gso,
 			  struct ieee80211_sta *sta,
 			  struct sk_buff_head *mpdus_skb)
 {
-	struct sk_buff *tmp, *next;
-	char cb[sizeof(skb_gso->cb)];
+	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb_gso);
+	struct ieee80211_key_conf *keyconf = info->control.hw_key;
+	struct ieee80211_hdr *wifi_hdr = (void *)skb_gso->data;
+	bool ipv6 = skb_shinfo(skb_gso)->gso_type & SKB_GSO_TCPV6;
+	struct iwl_lso_splitter s = {};
+	struct page *hdr_page;
+	unsigned int mpdu_sz;
+	u8 *hdr_page_pos;
+	int i, ret;
+
+	s.si = skb_shinfo(skb_gso);
+	s.mss = skb_shinfo(skb_gso)->gso_size;
+	s.gso_nr_frags = skb_shinfo(skb_gso)->nr_frags;
+	s.linear_payload_len = skb_tail_pointer(skb_gso) -
+			  skb_transport_header(skb_gso) - tcp_hdrlen(skb_gso);
+	s.gso_payload_len = s.linear_payload_len + skb_gso->data_len;
+
+	/* more than 2 * mss in the header or no frags ? segment w/o GSO */
+	if (s.linear_payload_len >= 2 * s.mss || !skb_gso->data_len) {
+		struct sk_buff *tmp, *next;
+		char cb[sizeof(skb_gso->cb)];
+
+		memcpy(cb, skb_gso->cb, sizeof(cb));
+		next = skb_gso_segment(skb_gso, 0);
+		if (IS_ERR(next))
+			return -EINVAL;
+		else if (next)
+			consume_skb(skb_gso);
+
+		while (next) {
+			tmp = next;
+			next = tmp->next;
+			memcpy(tmp->cb, cb, sizeof(tmp->cb));
+
+			tmp->prev = NULL;
+			tmp->next = NULL;
+
+			__skb_queue_tail(mpdus_skb, tmp);
+		}
+		return 0;
+	}
+
+	/*
+	 * We got an GSO skb that may or may not have payload in its header.
+	 * Re-use the same skb and chop the payload that can't fit into 1 MSS.
+	 * First take the payload from the header...
+	 */
+	mpdu_sz = min_t(unsigned int, s.linear_payload_len, s.mss);
+	s.linear_payload_len -= mpdu_sz;
+	skb_gso->data_len = 0;
+
+	/*
+	 * ... and add now payload from the frags to get up to 1 MSS.
+	 * If we have one mss already, mpdu_sz will be s.mss and
+	 * this loop won't do much.
+	 * Make sure we don't go beyond the limit of the origin GSO
+	 * skb.
+	 */
+	s.gso_offset_in_frag = 0;
+	while (s.gso_frag_num < s.gso_nr_frags &&
+	       s.gso_frag_num <= mvm->trans->max_skb_frags) {
+		unsigned int frag_sz =
+			skb_frag_size(&s.si->frags[s.gso_frag_num]);
+
+		if ((s.mss - mpdu_sz) >= frag_sz) {
+			/* there is enough room for this entire frag */
+			mpdu_sz += frag_sz;
+			skb_gso->data_len += frag_sz;
+			s.gso_frag_num++;
+			continue;
+		}
 
-	memcpy(cb, skb_gso->cb, sizeof(cb));
-	next = skb_gso_segment(skb_gso, 0);
-	if (IS_ERR(next))
+		/*
+		 * Only part of this frag will fit and
+		 * we now have a complete mss
+		 */
+		s.gso_offset_in_frag = s.mss - mpdu_sz;
+		skb_gso->data_len += (s.mss - mpdu_sz);
+		mpdu_sz = s.mss;
+		break;
+	}
+
+	/* We have only one mss or even less? */
+	if (WARN(s.gso_frag_num == s.gso_nr_frags,
+		 "frag: %d payload: %d\n", s.gso_frag_num, s.gso_payload_len))
 		return -EINVAL;
-	else if (next)
-		consume_skb(skb_gso);
 
-	while (next) {
-		tmp = next;
-		next = tmp->next;
-		memcpy(tmp->cb, cb, sizeof(tmp->cb));
+	/* remember the size of the remainder of the frag */
+	s.gso_current_frag_size = skb_frag_size(&s.si->frags[s.gso_frag_num]) -
+		s.gso_offset_in_frag;
+
+	/* shorten the skb_gso's frag to fit the mss */
+	skb_frag_size_set(&s.si->frags[s.gso_frag_num], s.gso_offset_in_frag);
+
+	/* translate to offset from the start of the page */
+	s.gso_offset_in_page =
+		s.gso_offset_in_frag + s.si->frags[s.gso_frag_num].page_offset;
+
+	/* remove all the other frags from skb_gso */
+	skb_shinfo(skb_gso)->nr_frags = s.gso_frag_num + 1;
+
+	/* FIXME: do we need to ref the last frag if no bytes of it were added
+	 * to skb_gso: e.g. when the previous segment was completely consumed
+	 * closed the first MSS?
+	 */
+
+	/* take a temp ref to the last frag */
+	skb_frag_ref(skb_gso, s.gso_frag_num);
+
+	/* update the skb_gso's length fields */
+	skb_gso->len -= (s.gso_payload_len - mpdu_sz);
+
+	/*
+	 * If there is still some payload in the header, update the tail to the
+	 * end of MSS.
+	 */
+	if (s.linear_payload_len)
+		skb_gso->tail -= s.linear_payload_len;
+
+	/*
+	 * Clear the bits in the TCP header that we delay for
+	 * the last segment.
+	 */
+	s.tcp_push = tcp_hdr(skb_gso)->psh;
+	s.tcp_fin = tcp_hdr(skb_gso)->fin;
+	tcp_hdr(skb_gso)->psh = 0;
+	tcp_hdr(skb_gso)->fin = 0;
+
+	/* update the IP / TCP header with the new length */
+	iwl_update_ip_tcph(ip_hdr(skb_gso), tcp_hdr(skb_gso),
+			   ipv6, mpdu_sz, 0, 0);
+
+	if (IWL_MVM_SW_TX_CSUM_OFFLOAD)
+		tcp_hdr(skb_gso)->check =
+			iwl_sw_tcp_csum_offload(skb_gso,
+						(u8 *)tcp_hdr(skb_gso) -
+						(u8 *)skb_gso->data,
+						mpdu_sz, tcp_hdrlen(skb_gso));
+
+	__skb_queue_tail(mpdus_skb, skb_gso);
+
+	/* mss bytes have been consumed from the data */
+	s.gso_payload_pos = s.mss;
+	i = 0;
+
+	hdr_page = NULL;
+	hdr_page_pos = get_page_pos(&hdr_page, NULL, 1);
+	if (!hdr_page_pos)
+		return -ENOMEM;
+
+	s.hdr = wifi_hdr;
+	s.wifi_hdr_iv_len = ieee80211_hdrlen(wifi_hdr->frame_control);
+	if (keyconf && (keyconf->cipher == WLAN_CIPHER_SUITE_CCMP ||
+			keyconf->cipher == WLAN_CIPHER_SUITE_CCMP_256))
+		s.wifi_hdr_iv_len += IEEE80211_CCMP_HDR_LEN;
+
+	while (s.gso_payload_pos < s.gso_payload_len) {
+		struct sk_buff *skb = dev_alloc_skb(s.wifi_hdr_iv_len);
+		int l;
+
+		s.frag_in_mpdu = 0;
 
-		tmp->prev = NULL;
-		tmp->next = NULL;
+		if (WARN_ON(s.gso_frag_num >= s.gso_nr_frags))
+			break;
+
+		if (!skb) {
+			ret = -ENOMEM;
+			goto out;
+		}
 
-		__skb_queue_tail(mpdus_skb, tmp);
+		memcpy(skb->cb, skb_gso->cb, sizeof(skb->cb));
+
+		/* new MPDU - add WiFi header + IV */
+		memcpy(skb_put(skb, s.wifi_hdr_iv_len),
+		       wifi_hdr, s.wifi_hdr_iv_len);
+
+		l = iwl_add_msdu(mvm, skb_gso, skb, &hdr_page,
+				 &hdr_page_pos, i++, &s);
+		if (l < 0) {
+			skb_queue_purge(mpdus_skb);
+			ret = l;
+			goto out;
+		}
+
+		__skb_queue_tail(mpdus_skb, skb);
 	}
 
-	return 0;
+	ret = 0;
+
+out:
+	if (hdr_page)
+		__free_pages(hdr_page, 0);
+	return ret;
 }
 
 static int iwl_skb_ensure_writable(struct sk_buff *skb, int write_len)
@@ -564,6 +1004,26 @@ drop:
 	return -1;
 }
 
+static int iwl_mvm_tx_csum_and_send(struct iwl_mvm *mvm, struct sk_buff *skb,
+				    struct ieee80211_sta *sta)
+{
+	if (skb->ip_summed == CHECKSUM_PARTIAL &&
+	    IWL_MVM_SW_TX_CSUM_OFFLOAD) {
+		int offs = skb_checksum_start_offset(skb);
+		int csum_offs = offs + skb->csum_offset;
+		__wsum csum;
+
+		if (iwl_skb_ensure_writable(skb, csum_offs + sizeof(__sum16)))
+			return -1;
+
+		csum = skb_checksum(skb, offs, skb->len - offs, 0);
+
+		*(__sum16 *)(skb->data + csum_offs) = csum_fold(csum);
+	}
+
+	return iwl_mvm_tx_mpdu(mvm, skb, sta);
+}
+
 /*
  * Sets the fields in the Tx cmd that are crypto related
  */
@@ -581,26 +1041,15 @@ int iwl_mvm_tx_skb(struct iwl_mvm *mvm, struct sk_buff *skb,
 	if (WARN_ON_ONCE(mvmsta->sta_id == IWL_MVM_STATION_COUNT))
 		return -1;
 
+	if (!skb_is_gso(skb))
+		return iwl_mvm_tx_csum_and_send(mvm, skb, sta);
+
 	payload_len = skb_tail_pointer(skb) - skb_transport_header(skb) -
 		tcp_hdrlen(skb) + skb->data_len;
 
-	if (!skb_is_gso(skb) || payload_len <= skb_shinfo(skb)->gso_size) {
-		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			int offs = skb_checksum_start_offset(skb);
-			int csum_offs = offs + skb->csum_offset;
-			__wsum csum;
-
-			if (iwl_skb_ensure_writable(skb, csum_offs +
-							 sizeof(__sum16)))
-				return -1;
-
-			csum = skb_checksum(skb, offs, skb->len - offs, 0);
-
-			*(__sum16 *)(skb->data + csum_offs) = csum_fold(csum);
-		}
-
-		return iwl_mvm_tx_mpdu(mvm, skb, sta);
-	}
+	/* This packet is smaller than MSS, one MPDU is enough */
+	if (payload_len <= skb_shinfo(skb)->gso_size)
+		return iwl_mvm_tx_csum_and_send(mvm, skb, sta);
 
 	__skb_queue_head_init(&mpdus_skbs);
 
-- 
2.1.4
