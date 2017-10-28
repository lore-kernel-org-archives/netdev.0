From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 4/4] sctp: fix some type cast warnings introduced since very beginning
Date: Sat, 28 Oct 2017 19:43:57 +0800
Message-ID: <40b05aa84d107b434bae3794692ac2da61da65ca.1509190967.git.lucien.xin@gmail.com>
References: <cover.1509190967.git.lucien.xin@gmail.com>
 <d85747d7d1af0972a00b8d4594a84f2afe97aac8.1509190967.git.lucien.xin@gmail.com>
 <ddda2f5b5825a379793ac6f2ffff4c7ab9aa64e5.1509190967.git.lucien.xin@gmail.com>
 <3d8cee6216e261609ec6307fc17fd6f5d6d28e5f.1509190967.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Eric Dumazet <edumazet@google.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:47660 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751029AbdJ1Loj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 07:44:39 -0400
In-Reply-To: <3d8cee6216e261609ec6307fc17fd6f5d6d28e5f.1509190967.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1509190967.git.lucien.xin@gmail.com>
References: <cover.1509190967.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These warnings were found by running 'make C=2 M=net/sctp/'.
They are there since very beginning.

Note after this patch, there still one warning left in
sctp_outq_flush():
  sctp_chunk_fail(chunk, SCTP_ERROR_INV_STRM)

Since it has been moved to sctp_stream_outq_migrate on net-next,
to avoid the extra job when merging net-next to net, I will post
the fix for it after the merging is done.

Reported-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h      | 2 +-
 include/uapi/linux/sctp.h | 2 +-
 net/sctp/ipv6.c           | 2 +-
 net/sctp/sm_make_chunk.c  | 4 ++--
 net/sctp/sm_sideeffect.c  | 4 ++--
 5 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 09d7412..da803df 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -231,7 +231,7 @@ struct sctp_datahdr {
 	__be32 tsn;
 	__be16 stream;
 	__be16 ssn;
-	__be32 ppid;
+	__u32 ppid;
 	__u8  payload[0];
 };
 
diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index 6217ff8..84fc291 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -376,7 +376,7 @@ struct sctp_remote_error {
 	__u16 sre_type;
 	__u16 sre_flags;
 	__u32 sre_length;
-	__u16 sre_error;
+	__be16 sre_error;
 	sctp_assoc_t sre_assoc_id;
 	__u8 sre_data[0];
 };
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 7fe9e1d1..a6dfa86 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -738,7 +738,7 @@ static int sctp_v6_skb_iif(const struct sk_buff *skb)
 /* Was this packet marked by Explicit Congestion Notification? */
 static int sctp_v6_is_ce(const struct sk_buff *skb)
 {
-	return *((__u32 *)(ipv6_hdr(skb))) & htonl(1 << 20);
+	return *((__u32 *)(ipv6_hdr(skb))) & (__force __u32)htonl(1 << 20);
 }
 
 /* Dump the v6 addr to the seq file. */
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 57c5504..514465b 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2854,7 +2854,7 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
 		addr_param_len = af->to_addr_param(addr, &addr_param);
 		param.param_hdr.type = flags;
 		param.param_hdr.length = htons(paramlen + addr_param_len);
-		param.crr_id = i;
+		param.crr_id = htonl(i);
 
 		sctp_addto_chunk(retval, paramlen, &param);
 		sctp_addto_chunk(retval, addr_param_len, &addr_param);
@@ -2867,7 +2867,7 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
 		addr_param_len = af->to_addr_param(addr, &addr_param);
 		param.param_hdr.type = SCTP_PARAM_DEL_IP;
 		param.param_hdr.length = htons(paramlen + addr_param_len);
-		param.crr_id = i;
+		param.crr_id = htonl(i);
 
 		sctp_addto_chunk(retval, paramlen, &param);
 		sctp_addto_chunk(retval, addr_param_len, &addr_param);
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 8f2762b..e2d9a4b 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1607,12 +1607,12 @@ static int sctp_cmd_interpreter(enum sctp_event event_type,
 			break;
 
 		case SCTP_CMD_INIT_FAILED:
-			sctp_cmd_init_failed(commands, asoc, cmd->obj.err);
+			sctp_cmd_init_failed(commands, asoc, cmd->obj.u32);
 			break;
 
 		case SCTP_CMD_ASSOC_FAILED:
 			sctp_cmd_assoc_failed(commands, asoc, event_type,
-					      subtype, chunk, cmd->obj.err);
+					      subtype, chunk, cmd->obj.u32);
 			break;
 
 		case SCTP_CMD_INIT_COUNTER_INC:
-- 
2.1.0
