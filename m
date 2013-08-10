From: Vlad Yasevich <vyasevich@gmail.com>
Subject: [PATCH net-next] net: sctp: Add rudimentary infrastructure to account for control chunks
Date: Fri,  9 Aug 2013 22:05:36 -0400
Message-ID: <1376100336-21481-1-git-send-email-vyasevich@gmail.com>
References: <52058BB2.4010606@gmail.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	dborkman@redhat.com, eric.dumazet@gmail.com,
	Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f173.google.com ([209.85.220.173]:47540 "EHLO
	mail-vc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031731Ab3HJCGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 22:06:07 -0400
In-Reply-To: <52058BB2.4010606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a base infrastructure that allows SCTP to do
memory accounting for control chunks.  Real accounting code will
follow.

This patch alos fixes the following triggered bug ...

[  553.109742] kernel BUG at include/linux/skbuff.h:1813!
[  553.109766] invalid opcode: 0000 [#1] SMP
[  553.109789] Modules linked in: sctp libcrc32c rfcomm [...]
[  553.110259]  uinput i915 i2c_algo_bit drm_kms_helper e1000e drm ptp
pps_core i2c_core wmi video sunrpc
[  553.110320] CPU: 0 PID: 1636 Comm: lt-test_1_to_1_ Not tainted
3.11.0-rc3+ #2
[  553.110350] Hardware name: LENOVO 74597D6/74597D6, BIOS 6DET60WW
(3.10 ) 09/17/2009
[  553.110381] task: ffff88020a01dd40 ti: ffff880204ed0000 task.ti:
ffff880204ed0000
[  553.110411] RIP: 0010:[<ffffffffa0698017>]  [<ffffffffa0698017>]
skb_orphan.part.9+0x4/0x6 [sctp]
[  553.110459] RSP: 0018:ffff880204ed1bb8  EFLAGS: 00010286
[  553.110483] RAX: ffff8802086f5a40 RBX: ffff880204303300 RCX:
0000000000000000
[  553.110487] RDX: ffff880204303c28 RSI: ffff8802086f5a40 RDI:
ffff880202158000
[  553.110487] RBP: ffff880204ed1bb8 R08: 0000000000000000 R09:
0000000000000000
[  553.110487] R10: ffff88022f2d9a04 R11: ffff880233001600 R12:
0000000000000000
[  553.110487] R13: ffff880204303c00 R14: ffff8802293d0000 R15:
ffff880202158000
[  553.110487] FS:  00007f31b31fe740(0000) GS:ffff88023bc00000(0000)
knlGS:0000000000000000
[  553.110487] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  553.110487] CR2: 000000379980e3e0 CR3: 000000020d225000 CR4:
00000000000407f0
[  553.110487] Stack:
[  553.110487]  ffff880204ed1ca8 ffffffffa068d7fc 0000000000000000
0000000000000000
[  553.110487]  0000000000000000 ffff8802293d0000 ffff880202158000
ffffffff81cb7900
[  553.110487]  0000000000000000 0000400000001c68 ffff8802086f5a40
000000000000000f
[  553.110487] Call Trace:
[  553.110487]  [<ffffffffa068d7fc>] sctp_sendmsg+0x6bc/0xc80 [sctp]
[  553.110487]  [<ffffffff8128f185>] ? sock_has_perm+0x75/0x90
[  553.110487]  [<ffffffff815a3593>] inet_sendmsg+0x63/0xb0
[  553.110487]  [<ffffffff8128f2b3>] ? selinux_socket_sendmsg+0x23/0x30
[  553.110487]  [<ffffffff8151c5d6>] sock_sendmsg+0xa6/0xd0
[  553.110487]  [<ffffffff81637b05>] ? _raw_spin_unlock_bh+0x15/0x20
[  553.110487]  [<ffffffff8151cd38>] SYSC_sendto+0x128/0x180
[  553.110487]  [<ffffffff8151ce6b>] ? SYSC_connect+0xdb/0x100
[  553.110487]  [<ffffffffa0690031>] ? sctp_inet_listen+0x71/0x1f0
[sctp]
[  553.110487]  [<ffffffff8151d35e>] SyS_sendto+0xe/0x10
[  553.110487]  [<ffffffff81640202>] system_call_fastpath+0x16/0x1b
[  553.110487] Code: e0 48 c7 c7 00 22 6a a0 e8 67 a3 f0 e0 48 c7 [...]
[  553.110487] RIP  [<ffffffffa0698017>] skb_orphan.part.9+0x4/0x6
[sctp]
[  553.110487]  RSP <ffff880204ed1bb8>
[  553.121578] ---[ end trace 46c20c5903ef5be2 ]---

The approach taken here is to split data and control chunks
creation a  bit.  Data chunks already have memory accounting
so noting needs to happen.  For control chunks, add stubs handlers.

Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
---
 net/sctp/sm_make_chunk.c | 99 +++++++++++++++++++++++++++++++++---------------
 1 file changed, 69 insertions(+), 30 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 780a2d4..04a82a6 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -68,8 +68,12 @@
 #include <net/sctp/sctp.h>
 #include <net/sctp/sm.h>
 
-static struct sctp_chunk *sctp_make_chunk(const struct sctp_association *asoc,
-					  __u8 type, __u8 flags, int paylen);
+static struct sctp_chunk *sctp_make_control(const struct sctp_association *asoc,
+					    __u8 type, __u8 flags, int paylen);
+static struct sctp_chunk *sctp_make_data(const struct sctp_association *asoc,
+					 __u8 flags, int paylen);
+static struct sctp_chunk *_sctp_make_chunk(const struct sctp_association *asoc,
+					   __u8 type, __u8 flags, int paylen);
 static sctp_cookie_param_t *sctp_pack_cookie(const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					const struct sctp_chunk *init_chunk,
@@ -82,6 +86,28 @@ static int sctp_process_param(struct sctp_association *asoc,
 static void *sctp_addto_param(struct sctp_chunk *chunk, int len,
 			      const void *data);
 
+/* Control chunk destructor */
+static void sctp_control_release_owner(struct sk_buff *skb)
+{
+	/*TODO: do memory release */
+}
+
+static void sctp_control_set_owner_w(struct sctp_chunk *chunk)
+{
+	struct sctp_association *asoc = chunk->asoc;
+	struct sk_buff *skb = chunk->skb;
+
+	/* TODO: properly account for control chunks. 
+	 * To do it right we'll need:
+	 *  1) endpoint if association isn't known.
+	 *  2) proper memory accounting.
+	 *
+	 *  For now don't do anything for now.
+	 */
+	skb->sk = asoc ? asoc->base.sk : NULL;
+	skb->destructor = sctp_control_release_owner;
+}
+
 /* What was the inbound interface for this chunk? */
 int sctp_chunk_iif(const struct sctp_chunk *chunk)
 {
@@ -296,7 +322,7 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 	 * PLEASE DO NOT FIXME [This version does not support Host Name.]
 	 */
 
-	retval = sctp_make_chunk(asoc, SCTP_CID_INIT, 0, chunksize);
+	retval = sctp_make_control(asoc, SCTP_CID_INIT, 0, chunksize);
 	if (!retval)
 		goto nodata;
 
@@ -443,7 +469,7 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 					num_ext);
 
 	/* Now allocate and fill out the chunk.  */
-	retval = sctp_make_chunk(asoc, SCTP_CID_INIT_ACK, 0, chunksize);
+	retval = sctp_make_control(asoc, SCTP_CID_INIT_ACK, 0, chunksize);
 	if (!retval)
 		goto nomem_chunk;
 
@@ -548,7 +574,7 @@ struct sctp_chunk *sctp_make_cookie_echo(const struct sctp_association *asoc,
 	cookie_len = asoc->peer.cookie_len;
 
 	/* Build a cookie echo chunk.  */
-	retval = sctp_make_chunk(asoc, SCTP_CID_COOKIE_ECHO, 0, cookie_len);
+	retval = sctp_make_control(asoc, SCTP_CID_COOKIE_ECHO, 0, cookie_len);
 	if (!retval)
 		goto nodata;
 	retval->subh.cookie_hdr =
@@ -593,7 +619,7 @@ struct sctp_chunk *sctp_make_cookie_ack(const struct sctp_association *asoc,
 {
 	struct sctp_chunk *retval;
 
-	retval = sctp_make_chunk(asoc, SCTP_CID_COOKIE_ACK, 0, 0);
+	retval = sctp_make_control(asoc, SCTP_CID_COOKIE_ACK, 0, 0);
 
 	/* RFC 2960 6.4 Multi-homed SCTP Endpoints
 	 *
@@ -641,8 +667,8 @@ struct sctp_chunk *sctp_make_cwr(const struct sctp_association *asoc,
 	sctp_cwrhdr_t cwr;
 
 	cwr.lowest_tsn = htonl(lowest_tsn);
-	retval = sctp_make_chunk(asoc, SCTP_CID_ECN_CWR, 0,
-				 sizeof(sctp_cwrhdr_t));
+	retval = sctp_make_control(asoc, SCTP_CID_ECN_CWR, 0,
+				   sizeof(sctp_cwrhdr_t));
 
 	if (!retval)
 		goto nodata;
@@ -675,8 +701,8 @@ struct sctp_chunk *sctp_make_ecne(const struct sctp_association *asoc,
 	sctp_ecnehdr_t ecne;
 
 	ecne.lowest_tsn = htonl(lowest_tsn);
-	retval = sctp_make_chunk(asoc, SCTP_CID_ECN_ECNE, 0,
-				 sizeof(sctp_ecnehdr_t));
+	retval = sctp_make_control(asoc, SCTP_CID_ECN_ECNE, 0,
+				   sizeof(sctp_ecnehdr_t));
 	if (!retval)
 		goto nodata;
 	retval->subh.ecne_hdr =
@@ -712,7 +738,7 @@ struct sctp_chunk *sctp_make_datafrag_empty(struct sctp_association *asoc,
 		dp.ssn = htons(ssn);
 
 	chunk_len = sizeof(dp) + data_len;
-	retval = sctp_make_chunk(asoc, SCTP_CID_DATA, flags, chunk_len);
+	retval = sctp_make_data(asoc, flags, chunk_len);
 	if (!retval)
 		goto nodata;
 
@@ -759,7 +785,7 @@ struct sctp_chunk *sctp_make_sack(const struct sctp_association *asoc)
 		+ sizeof(__u32) * num_dup_tsns;
 
 	/* Create the chunk.  */
-	retval = sctp_make_chunk(asoc, SCTP_CID_SACK, 0, len);
+	retval = sctp_make_control(asoc, SCTP_CID_SACK, 0, len);
 	if (!retval)
 		goto nodata;
 
@@ -838,8 +864,8 @@ struct sctp_chunk *sctp_make_shutdown(const struct sctp_association *asoc,
 	ctsn = sctp_tsnmap_get_ctsn(&asoc->peer.tsn_map);
 	shut.cum_tsn_ack = htonl(ctsn);
 
-	retval = sctp_make_chunk(asoc, SCTP_CID_SHUTDOWN, 0,
-				 sizeof(sctp_shutdownhdr_t));
+	retval = sctp_make_control(asoc, SCTP_CID_SHUTDOWN, 0,
+				   sizeof(sctp_shutdownhdr_t));
 	if (!retval)
 		goto nodata;
 
@@ -857,7 +883,7 @@ struct sctp_chunk *sctp_make_shutdown_ack(const struct sctp_association *asoc,
 {
 	struct sctp_chunk *retval;
 
-	retval = sctp_make_chunk(asoc, SCTP_CID_SHUTDOWN_ACK, 0, 0);
+	retval = sctp_make_control(asoc, SCTP_CID_SHUTDOWN_ACK, 0, 0);
 
 	/* RFC 2960 6.4 Multi-homed SCTP Endpoints
 	 *
@@ -886,7 +912,7 @@ struct sctp_chunk *sctp_make_shutdown_complete(
 	 */
 	flags |= asoc ? 0 : SCTP_CHUNK_FLAG_T;
 
-	retval = sctp_make_chunk(asoc, SCTP_CID_SHUTDOWN_COMPLETE, flags, 0);
+	retval = sctp_make_control(asoc, SCTP_CID_SHUTDOWN_COMPLETE, flags, 0);
 
 	/* RFC 2960 6.4 Multi-homed SCTP Endpoints
 	 *
@@ -925,7 +951,7 @@ struct sctp_chunk *sctp_make_abort(const struct sctp_association *asoc,
 			flags = SCTP_CHUNK_FLAG_T;
 	}
 
-	retval = sctp_make_chunk(asoc, SCTP_CID_ABORT, flags, hint);
+	retval = sctp_make_control(asoc, SCTP_CID_ABORT, flags, hint);
 
 	/* RFC 2960 6.4 Multi-homed SCTP Endpoints
 	 *
@@ -1117,7 +1143,7 @@ struct sctp_chunk *sctp_make_heartbeat(const struct sctp_association *asoc,
 	struct sctp_chunk *retval;
 	sctp_sender_hb_info_t hbinfo;
 
-	retval = sctp_make_chunk(asoc, SCTP_CID_HEARTBEAT, 0, sizeof(hbinfo));
+	retval = sctp_make_control(asoc, SCTP_CID_HEARTBEAT, 0, sizeof(hbinfo));
 
 	if (!retval)
 		goto nodata;
@@ -1145,7 +1171,7 @@ struct sctp_chunk *sctp_make_heartbeat_ack(const struct sctp_association *asoc,
 {
 	struct sctp_chunk *retval;
 
-	retval  = sctp_make_chunk(asoc, SCTP_CID_HEARTBEAT_ACK, 0, paylen);
+	retval  = sctp_make_control(asoc, SCTP_CID_HEARTBEAT_ACK, 0, paylen);
 	if (!retval)
 		goto nodata;
 
@@ -1177,8 +1203,8 @@ static struct sctp_chunk *sctp_make_op_error_space(
 {
 	struct sctp_chunk *retval;
 
-	retval = sctp_make_chunk(asoc, SCTP_CID_ERROR, 0,
-				 sizeof(sctp_errhdr_t) + size);
+	retval = sctp_make_control(asoc, SCTP_CID_ERROR, 0,
+				   sizeof(sctp_errhdr_t) + size);
 	if (!retval)
 		goto nodata;
 
@@ -1248,7 +1274,7 @@ struct sctp_chunk *sctp_make_auth(const struct sctp_association *asoc)
 	if (unlikely(!hmac_desc))
 		return NULL;
 
-	retval = sctp_make_chunk(asoc, SCTP_CID_AUTH, 0,
+	retval = sctp_make_control(asoc, SCTP_CID_AUTH, 0,
 			hmac_desc->hmac_len + sizeof(sctp_authhdr_t));
 	if (!retval)
 		return NULL;
@@ -1351,8 +1377,8 @@ const union sctp_addr *sctp_source(const struct sctp_chunk *chunk)
 /* Create a new chunk, setting the type and flags headers from the
  * arguments, reserving enough space for a 'paylen' byte payload.
  */
-static struct sctp_chunk *sctp_make_chunk(const struct sctp_association *asoc,
-					  __u8 type, __u8 flags, int paylen)
+static struct sctp_chunk *_sctp_make_chunk(const struct sctp_association *asoc,
+					    __u8 type, __u8 flags, int paylen)
 {
 	struct sctp_chunk *retval;
 	sctp_chunkhdr_t *chunk_hdr;
@@ -1385,14 +1411,27 @@ static struct sctp_chunk *sctp_make_chunk(const struct sctp_association *asoc,
 	if (sctp_auth_send_cid(type, asoc))
 		retval->auth = 1;
 
-	/* Set the skb to the belonging sock for accounting.  */
-	skb->sk = sk;
-
 	return retval;
 nodata:
 	return NULL;
 }
 
+static struct sctp_chunk *sctp_make_data(const struct sctp_association *asoc,
+					 __u8 flags, int paylen)
+{
+	return _sctp_make_chunk(asoc, SCTP_CID_DATA, flags, paylen);
+}
+
+static struct sctp_chunk *sctp_make_control(const struct sctp_association *asoc,
+					    __u8 type, __u8 flags, int paylen)
+{
+	struct sctp_chunk *chunk = _sctp_make_chunk(asoc, type, flags, paylen);
+
+	if (chunk)
+		sctp_control_set_owner_w(chunk);
+
+	return chunk;
+}
 
 /* Release the memory occupied by a chunk.  */
 static void sctp_chunk_destroy(struct sctp_chunk *chunk)
@@ -2733,7 +2772,7 @@ static struct sctp_chunk *sctp_make_asconf(struct sctp_association *asoc,
 	length += addrlen;
 
 	/* Create the chunk.  */
-	retval = sctp_make_chunk(asoc, SCTP_CID_ASCONF, 0, length);
+	retval = sctp_make_control(asoc, SCTP_CID_ASCONF, 0, length);
 	if (!retval)
 		return NULL;
 
@@ -2917,7 +2956,7 @@ static struct sctp_chunk *sctp_make_asconf_ack(const struct sctp_association *as
 	int			length = sizeof(asconf) + vparam_len;
 
 	/* Create the chunk.  */
-	retval = sctp_make_chunk(asoc, SCTP_CID_ASCONF_ACK, 0, length);
+	retval = sctp_make_control(asoc, SCTP_CID_ASCONF_ACK, 0, length);
 	if (!retval)
 		return NULL;
 
@@ -3448,7 +3487,7 @@ struct sctp_chunk *sctp_make_fwdtsn(const struct sctp_association *asoc,
 
 	hint = (nstreams + 1) * sizeof(__u32);
 
-	retval = sctp_make_chunk(asoc, SCTP_CID_FWD_TSN, 0, hint);
+	retval = sctp_make_control(asoc, SCTP_CID_FWD_TSN, 0, hint);
 
 	if (!retval)
 		return NULL;
-- 
1.8.1.4
