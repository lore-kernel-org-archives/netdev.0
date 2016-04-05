From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 1/7] sctp: add sctp_info dump api for sctp_diag
Date: Tue,  5 Apr 2016 12:06:26 +0800
Message-ID: <c507274a984bd1b0a7e7a59d1e825352536efd25.1459829123.git.lucien.xin@gmail.com>
References: <cover.1459829123.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34730 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752334AbcDEEGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 00:06:43 -0400
In-Reply-To: <cover.1459829123.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1459829123.git.lucien.xin@gmail.com>
References: <cover.1459829123.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_diag will dump some important details of sctp's assoc or ep, we use
sctp_info to describe them,  sctp_get_sctp_info to get them, and export
it to sctp_diag.ko.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h    | 65 +++++++++++++++++++++++++++++++++++++
 include/net/sctp/sctp.h |  3 ++
 net/sctp/socket.c       | 86 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 154 insertions(+)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index a9414fd..a448ebc 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -705,4 +705,69 @@ typedef struct sctp_auth_chunk {
 	sctp_authhdr_t auth_hdr;
 } __packed sctp_auth_chunk_t;
 
+struct sctp_info {
+	__u32	sctpi_tag;
+	__u32	sctpi_state;
+	__u32	sctpi_rwnd;
+	__u16	sctpi_unackdata;
+	__u16	sctpi_penddata;
+	__u16	sctpi_instrms;
+	__u16	sctpi_outstrms;
+	__u32	sctpi_fragmentation_point;
+	__u32	sctpi_inqueue;
+	__u32	sctpi_outqueue;
+	__u32	sctpi_overall_error;
+	__u32	sctpi_max_burst;
+	__u32	sctpi_maxseg;
+	__u32	sctpi_peer_rwnd;
+	__u32	sctpi_peer_tag;
+	__u8	sctpi_peer_capable;
+	__u8	sctpi_peer_sack;
+
+	/* assoc status info */
+	__u64	sctpi_isacks;
+	__u64	sctpi_osacks;
+	__u64	sctpi_opackets;
+	__u64	sctpi_ipackets;
+	__u64	sctpi_rtxchunks;
+	__u64	sctpi_outofseqtsns;
+	__u64	sctpi_idupchunks;
+	__u64	sctpi_gapcnt;
+	__u64	sctpi_ouodchunks;
+	__u64	sctpi_iuodchunks;
+	__u64	sctpi_oodchunks;
+	__u64	sctpi_iodchunks;
+	__u64	sctpi_octrlchunks;
+	__u64	sctpi_ictrlchunks;
+
+	/* primary transport info */
+	struct sockaddr_storage	sctpi_p_address;
+	__s32	sctpi_p_state;
+	__u32	sctpi_p_cwnd;
+	__u32	sctpi_p_srtt;
+	__u32	sctpi_p_rto;
+	__u32	sctpi_p_hbinterval;
+	__u32	sctpi_p_pathmaxrxt;
+	__u32	sctpi_p_sackdelay;
+	__u32	sctpi_p_sackfreq;
+	__u32	sctpi_p_ssthresh;
+	__u32	sctpi_p_partial_bytes_acked;
+	__u32	sctpi_p_flight_size;
+	__u16	sctpi_p_error;
+
+	/* sctp sock info */
+	__u32	sctpi_s_autoclose;
+	__u32	sctpi_s_adaptation_ind;
+	__u32	sctpi_s_pd_point;
+	__u8	sctpi_s_nodelay;
+	__u8	sctpi_s_disable_fragments;
+	__u8	sctpi_s_v4mapped;
+	__u8	sctpi_s_frag_interleave;
+};
+
+struct sctp_infox {
+	struct sctp_info *sctpinfo;
+	struct sctp_association *asoc;
+};
+
 #endif /* __LINUX_SCTP_H__ */
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 65521cf..36e1eae 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -116,6 +116,9 @@ extern struct percpu_counter sctp_sockets_allocated;
 int sctp_asconf_mgmt(struct sctp_sock *, struct sctp_sockaddr_entry *);
 struct sk_buff *sctp_skb_recv_datagram(struct sock *, int, int, int *);
 
+int sctp_get_sctp_info(struct sock *sk, struct sctp_association *asoc,
+		       struct sctp_info *info);
+
 /*
  * sctp/primitive.c
  */
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 878d28e..8f79f23 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4202,6 +4202,92 @@ static void sctp_shutdown(struct sock *sk, int how)
 	}
 }
 
+int sctp_get_sctp_info(struct sock *sk, struct sctp_association *asoc,
+		       struct sctp_info *info)
+{
+	struct sctp_transport *prim;
+	struct list_head *pos, *temp;
+	int mask;
+
+	memset(info, 0, sizeof(*info));
+	if (!asoc) {
+		struct sctp_sock *sp = sctp_sk(sk);
+
+		info->sctpi_s_autoclose = sp->autoclose;
+		info->sctpi_s_adaptation_ind = sp->adaptation_ind;
+		info->sctpi_s_pd_point = sp->pd_point;
+		info->sctpi_s_nodelay = sp->nodelay;
+		info->sctpi_s_disable_fragments = sp->disable_fragments;
+		info->sctpi_s_v4mapped = sp->v4mapped;
+		info->sctpi_s_frag_interleave = sp->frag_interleave;
+
+		return 0;
+	}
+
+	info->sctpi_tag = asoc->c.my_vtag;
+	info->sctpi_state = asoc->state;
+	info->sctpi_rwnd = asoc->a_rwnd;
+	info->sctpi_unackdata = asoc->unack_data;
+	info->sctpi_penddata = sctp_tsnmap_pending(&asoc->peer.tsn_map);
+	info->sctpi_instrms = asoc->c.sinit_max_instreams;
+	info->sctpi_outstrms = asoc->c.sinit_num_ostreams;
+	list_for_each_safe(pos, temp, &asoc->base.inqueue.in_chunk_list)
+		info->sctpi_inqueue++;
+	list_for_each_safe(pos, temp, &asoc->outqueue.out_chunk_list)
+		info->sctpi_outqueue++;
+	info->sctpi_overall_error = asoc->overall_error_count;
+	info->sctpi_max_burst = asoc->max_burst;
+	info->sctpi_maxseg = asoc->frag_point;
+	info->sctpi_peer_rwnd = asoc->peer.rwnd;
+	info->sctpi_peer_tag = asoc->c.peer_vtag;
+
+	mask = asoc->peer.ecn_capable << 1;
+	mask = (mask | asoc->peer.ipv4_address) << 1;
+	mask = (mask | asoc->peer.ipv6_address) << 1;
+	mask = (mask | asoc->peer.hostname_address) << 1;
+	mask = (mask | asoc->peer.asconf_capable) << 1;
+	mask = (mask | asoc->peer.prsctp_capable) << 1;
+	mask = (mask | asoc->peer.auth_capable);
+	info->sctpi_peer_capable = mask;
+	mask = asoc->peer.sack_needed << 1;
+	mask = (mask | asoc->peer.sack_generation) << 1;
+	mask = (mask | asoc->peer.zero_window_announced);
+	info->sctpi_peer_sack = mask;
+
+	info->sctpi_isacks = asoc->stats.isacks;
+	info->sctpi_osacks = asoc->stats.osacks;
+	info->sctpi_opackets = asoc->stats.opackets;
+	info->sctpi_ipackets = asoc->stats.ipackets;
+	info->sctpi_rtxchunks = asoc->stats.rtxchunks;
+	info->sctpi_outofseqtsns = asoc->stats.outofseqtsns;
+	info->sctpi_idupchunks = asoc->stats.idupchunks;
+	info->sctpi_gapcnt = asoc->stats.gapcnt;
+	info->sctpi_ouodchunks = asoc->stats.ouodchunks;
+	info->sctpi_iuodchunks = asoc->stats.iuodchunks;
+	info->sctpi_oodchunks = asoc->stats.oodchunks;
+	info->sctpi_iodchunks = asoc->stats.iodchunks;
+	info->sctpi_octrlchunks = asoc->stats.octrlchunks;
+	info->sctpi_ictrlchunks = asoc->stats.ictrlchunks;
+
+	prim = asoc->peer.primary_path;
+	memcpy(&info->sctpi_p_address, &prim->ipaddr,
+	       sizeof(struct sockaddr_storage));
+	info->sctpi_p_state = prim->state;
+	info->sctpi_p_cwnd = prim->cwnd;
+	info->sctpi_p_srtt = prim->srtt;
+	info->sctpi_p_rto = jiffies_to_msecs(prim->rto);
+	info->sctpi_p_hbinterval = prim->hbinterval;
+	info->sctpi_p_pathmaxrxt = prim->pathmaxrxt;
+	info->sctpi_p_sackdelay = jiffies_to_msecs(prim->sackdelay);
+	info->sctpi_p_ssthresh = prim->ssthresh;
+	info->sctpi_p_partial_bytes_acked = prim->partial_bytes_acked;
+	info->sctpi_p_flight_size = prim->flight_size;
+	info->sctpi_p_error = prim->error_count;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(sctp_get_sctp_info);
+
 /* 7.2.1 Association Status (SCTP_STATUS)
 
  * Applications can retrieve current status information about an
-- 
2.1.0
