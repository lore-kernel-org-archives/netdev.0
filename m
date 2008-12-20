From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next 4/5] sctp: Avoid memory overflow while FWD-TSN chunk is received with bad stream ID
Date: Fri, 19 Dec 2008 20:47:51 -0500
Message-ID: <1229737672-28328-6-git-send-email-vladislav.yasevich@hp.com>
References: <1229737672-28328-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:42278 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250AbYLTBr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 20:47:58 -0500
In-Reply-To: <1229737672-28328-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

If FWD-TSN chunk is received with bad stream ID, the sctp will not do the
validity check, this may cause memory overflow when overwrite the TSN of
the stream ID.

The FORWARD-TSN chunk is like this:

FORWARD-TSN chunk
  Type                       = 192
  Flags                      = 0
  Length                     = 172
  NewTSN                     = 99
  Stream                     = 10000
  StreamSequence             = 0xFFFF

This patch fix this problem by discard the chunk if stream ID is not
less than MIS.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/sm_statefuns.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 9f2a3eb..1c4e5d6 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3689,6 +3689,7 @@ sctp_disposition_t sctp_sf_eat_fwd_tsn(const struct sctp_endpoint *ep,
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_fwdtsn_hdr *fwdtsn_hdr;
+	struct sctp_fwdtsn_skip *skip;
 	__u16 len;
 	__u32 tsn;
 
@@ -3718,6 +3719,12 @@ sctp_disposition_t sctp_sf_eat_fwd_tsn(const struct sctp_endpoint *ep,
 	if (sctp_tsnmap_check(&asoc->peer.tsn_map, tsn) < 0)
 		goto discard_noforce;
 
+	/* Silently discard the chunk if stream-id is not valid */
+	sctp_walk_fwdtsn(skip, chunk) {
+		if (ntohs(skip->stream) >= asoc->c.sinit_max_instreams)
+			goto discard_noforce;
+	}
+
 	sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_FWDTSN, SCTP_U32(tsn));
 	if (len > sizeof(struct sctp_fwdtsn_hdr))
 		sctp_add_cmd_sf(commands, SCTP_CMD_PROCESS_FWDTSN,
@@ -3749,6 +3756,7 @@ sctp_disposition_t sctp_sf_eat_fwd_tsn_fast(
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_fwdtsn_hdr *fwdtsn_hdr;
+	struct sctp_fwdtsn_skip *skip;
 	__u16 len;
 	__u32 tsn;
 
@@ -3778,6 +3786,12 @@ sctp_disposition_t sctp_sf_eat_fwd_tsn_fast(
 	if (sctp_tsnmap_check(&asoc->peer.tsn_map, tsn) < 0)
 		goto gen_shutdown;
 
+	/* Silently discard the chunk if stream-id is not valid */
+	sctp_walk_fwdtsn(skip, chunk) {
+		if (ntohs(skip->stream) >= asoc->c.sinit_max_instreams)
+			goto gen_shutdown;
+	}
+
 	sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_FWDTSN, SCTP_U32(tsn));
 	if (len > sizeof(struct sctp_fwdtsn_hdr))
 		sctp_add_cmd_sf(commands, SCTP_CMD_PROCESS_FWDTSN,
-- 
1.5.3.5

