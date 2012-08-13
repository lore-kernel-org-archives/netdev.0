From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 1/4] packet: Introduce net/packet/internal.h header
Date: Mon, 13 Aug 2012 19:49:39 +0400
Message-ID: <50292213.7080108@parallels.com>
References: <5029219C.20305@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:33974 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751777Ab2HMPto (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2012 11:49:44 -0400
In-Reply-To: <5029219C.20305@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The diag module will need to access some private packet_sock data, so
move it to a header in advance. This file will be shared between the
af_packet.c and the diag.c

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/packet/af_packet.c |   99 +---------------------------------------------
 net/packet/internal.h  |  103 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 105 insertions(+), 97 deletions(-)
 create mode 100644 net/packet/internal.h

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index ceaca7c..8a1605a 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -93,6 +93,8 @@
 #include <net/inet_common.h>
 #endif
 
+#include "internal.h"
+
 /*
    Assumptions:
    - if device has no dev->hard_header routine, it adds and removes ll header
@@ -146,14 +148,6 @@ dev->hard_header == NULL (ll header is added by device, we cannot control it)
 
 /* Private packet socket structures. */
 
-struct packet_mclist {
-	struct packet_mclist	*next;
-	int			ifindex;
-	int			count;
-	unsigned short		type;
-	unsigned short		alen;
-	unsigned char		addr[MAX_ADDR_LEN];
-};
 /* identical to struct packet_mreq except it has
  * a longer address field.
  */
@@ -175,63 +169,7 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 #define BLK_PLUS_PRIV(sz_of_priv) \
 	(BLK_HDR_LEN + ALIGN((sz_of_priv), V3_ALIGNMENT))
 
-/* kbdq - kernel block descriptor queue */
-struct tpacket_kbdq_core {
-	struct pgv	*pkbdq;
-	unsigned int	feature_req_word;
-	unsigned int	hdrlen;
-	unsigned char	reset_pending_on_curr_blk;
-	unsigned char   delete_blk_timer;
-	unsigned short	kactive_blk_num;
-	unsigned short	blk_sizeof_priv;
-
-	/* last_kactive_blk_num:
-	 * trick to see if user-space has caught up
-	 * in order to avoid refreshing timer when every single pkt arrives.
-	 */
-	unsigned short	last_kactive_blk_num;
-
-	char		*pkblk_start;
-	char		*pkblk_end;
-	int		kblk_size;
-	unsigned int	knum_blocks;
-	uint64_t	knxt_seq_num;
-	char		*prev;
-	char		*nxt_offset;
-	struct sk_buff	*skb;
-
-	atomic_t	blk_fill_in_prog;
-
-	/* Default is set to 8ms */
-#define DEFAULT_PRB_RETIRE_TOV	(8)
-
-	unsigned short  retire_blk_tov;
-	unsigned short  version;
-	unsigned long	tov_in_jiffies;
-
-	/* timer to retire an outstanding block */
-	struct timer_list retire_blk_timer;
-};
-
 #define PGV_FROM_VMALLOC 1
-struct pgv {
-	char *buffer;
-};
-
-struct packet_ring_buffer {
-	struct pgv		*pg_vec;
-	unsigned int		head;
-	unsigned int		frames_per_block;
-	unsigned int		frame_size;
-	unsigned int		frame_max;
-
-	unsigned int		pg_vec_order;
-	unsigned int		pg_vec_pages;
-	unsigned int		pg_vec_len;
-
-	struct tpacket_kbdq_core	prb_bdqc;
-	atomic_t		pending;
-};
 
 #define BLOCK_STATUS(x)	((x)->hdr.bh1.block_status)
 #define BLOCK_NUM_PKTS(x)	((x)->hdr.bh1.num_pkts)
@@ -269,34 +207,6 @@ static void prb_fill_vlan_info(struct tpacket_kbdq_core *,
 		struct tpacket3_hdr *);
 static void packet_flush_mclist(struct sock *sk);
 
-struct packet_fanout;
-struct packet_sock {
-	/* struct sock has to be the first member of packet_sock */
-	struct sock		sk;
-	struct packet_fanout	*fanout;
-	struct tpacket_stats	stats;
-	union  tpacket_stats_u	stats_u;
-	struct packet_ring_buffer	rx_ring;
-	struct packet_ring_buffer	tx_ring;
-	int			copy_thresh;
-	spinlock_t		bind_lock;
-	struct mutex		pg_vec_lock;
-	unsigned int		running:1,	/* prot_hook is attached*/
-				auxdata:1,
-				origdev:1,
-				has_vnet_hdr:1;
-	int			ifindex;	/* bound device		*/
-	__be16			num;
-	struct packet_mclist	*mclist;
-	atomic_t		mapped;
-	enum tpacket_versions	tp_version;
-	unsigned int		tp_hdrlen;
-	unsigned int		tp_reserve;
-	unsigned int		tp_loss:1;
-	unsigned int		tp_tstamp;
-	struct packet_type	prot_hook ____cacheline_aligned_in_smp;
-};
-
 #define PACKET_FANOUT_MAX	256
 
 struct packet_fanout {
@@ -334,11 +244,6 @@ struct packet_skb_cb {
 	(((x)->kactive_blk_num < ((x)->knum_blocks-1)) ? \
 	((x)->kactive_blk_num+1) : 0)
 
-static struct packet_sock *pkt_sk(struct sock *sk)
-{
-	return (struct packet_sock *)sk;
-}
-
 static void __fanout_unlink(struct sock *sk, struct packet_sock *po);
 static void __fanout_link(struct sock *sk, struct packet_sock *po);
 
diff --git a/net/packet/internal.h b/net/packet/internal.h
new file mode 100644
index 0000000..2c5fca2
--- /dev/null
+++ b/net/packet/internal.h
@@ -0,0 +1,103 @@
+#ifndef __PACKET_INTERNAL_H__
+#define __PACKET_INTERNAL_H__
+
+struct packet_mclist {
+	struct packet_mclist	*next;
+	int			ifindex;
+	int			count;
+	unsigned short		type;
+	unsigned short		alen;
+	unsigned char		addr[MAX_ADDR_LEN];
+};
+
+/* kbdq - kernel block descriptor queue */
+struct tpacket_kbdq_core {
+	struct pgv	*pkbdq;
+	unsigned int	feature_req_word;
+	unsigned int	hdrlen;
+	unsigned char	reset_pending_on_curr_blk;
+	unsigned char   delete_blk_timer;
+	unsigned short	kactive_blk_num;
+	unsigned short	blk_sizeof_priv;
+
+	/* last_kactive_blk_num:
+	 * trick to see if user-space has caught up
+	 * in order to avoid refreshing timer when every single pkt arrives.
+	 */
+	unsigned short	last_kactive_blk_num;
+
+	char		*pkblk_start;
+	char		*pkblk_end;
+	int		kblk_size;
+	unsigned int	knum_blocks;
+	uint64_t	knxt_seq_num;
+	char		*prev;
+	char		*nxt_offset;
+	struct sk_buff	*skb;
+
+	atomic_t	blk_fill_in_prog;
+
+	/* Default is set to 8ms */
+#define DEFAULT_PRB_RETIRE_TOV	(8)
+
+	unsigned short  retire_blk_tov;
+	unsigned short  version;
+	unsigned long	tov_in_jiffies;
+
+	/* timer to retire an outstanding block */
+	struct timer_list retire_blk_timer;
+};
+
+struct pgv {
+	char *buffer;
+};
+
+struct packet_ring_buffer {
+	struct pgv		*pg_vec;
+	unsigned int		head;
+	unsigned int		frames_per_block;
+	unsigned int		frame_size;
+	unsigned int		frame_max;
+
+	unsigned int		pg_vec_order;
+	unsigned int		pg_vec_pages;
+	unsigned int		pg_vec_len;
+
+	struct tpacket_kbdq_core	prb_bdqc;
+	atomic_t		pending;
+};
+
+struct packet_fanout;
+struct packet_sock {
+	/* struct sock has to be the first member of packet_sock */
+	struct sock		sk;
+	struct packet_fanout	*fanout;
+	struct tpacket_stats	stats;
+	union  tpacket_stats_u	stats_u;
+	struct packet_ring_buffer	rx_ring;
+	struct packet_ring_buffer	tx_ring;
+	int			copy_thresh;
+	spinlock_t		bind_lock;
+	struct mutex		pg_vec_lock;
+	unsigned int		running:1,	/* prot_hook is attached*/
+				auxdata:1,
+				origdev:1,
+				has_vnet_hdr:1;
+	int			ifindex;	/* bound device		*/
+	__be16			num;
+	struct packet_mclist	*mclist;
+	atomic_t		mapped;
+	enum tpacket_versions	tp_version;
+	unsigned int		tp_hdrlen;
+	unsigned int		tp_reserve;
+	unsigned int		tp_loss:1;
+	unsigned int		tp_tstamp;
+	struct packet_type	prot_hook ____cacheline_aligned_in_smp;
+};
+
+static struct packet_sock *pkt_sk(struct sock *sk)
+{
+	return (struct packet_sock *)sk;
+}
+
+#endif
-- 
1.7.6.5
