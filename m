From: Geir Ola Vaagland <geirola@gmail.com>
Subject: [PATCH net-next 3/6] Support for SCTP_SNDINFO ancillary data
Date: Tue, 17 Jun 2014 13:57:50 +0200
Message-ID: <1403006273-27859-4-git-send-email-geirola@gmail.com>
References: <1403006273-27859-1-git-send-email-geirola@gmail.com>
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:49446 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754281AbaFQL6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 07:58:03 -0400
In-Reply-To: <1403006273-27859-1-git-send-email-geirola@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: Vlad Yasevich <vyasevich@gmail.com>
Signed-off-by: Geir Ola Vaagland <geirola@gmail.com>
---
 include/net/sctp/structs.h |  9 +++++++-
 include/uapi/linux/sctp.h  | 19 +++++++++++++++++
 net/sctp/socket.c          | 53 +++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 75 insertions(+), 6 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 75c598a..5ed8a3c 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1921,9 +1921,16 @@ struct sctp_chunk *sctp_get_ecne_prepend(struct sctp_association *asoc);
 /* A convenience structure to parse out SCTP specific CMSGs. */
 typedef struct sctp_cmsgs {
 	struct sctp_initmsg *init;
-	struct sctp_sndrcvinfo *info;
+	union {
+		struct sctp_sndrcvinfo *srinfo;
+		struct sctp_sndinfo *sinfo;
+	} info;
+	sctp_cmsg_t cmsg_type;
 } sctp_cmsgs_t;
 
+#define sr_info info.srinfo
+#define s_info info.sinfo
+
 /* Structure for tracking memory objects */
 typedef struct {
 	char *label;
diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index 7e8736b..d725e30 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -156,6 +156,23 @@ struct sctp_sndrcvinfo {
 	__u32 sinfo_cumtsn;
 	sctp_assoc_t sinfo_assoc_id;
 };
+/*
+ * 5.3.4 SCTP Send Information Structure (SCTP_SNDINFO)
+ *
+ *   This cmsghdr structure specifies SCTP options for sendmsg().
+ *
+ *   cmsg_level    cmsg_type      cmsg_data[]
+ *   ------------  ------------   -------------------
+ *   IPPROTO_SCTP  SCTP_SNDINFO   struct sctp_sndinfo
+ *
+ */
+struct sctp_sndinfo {
+	__u16 snd_sid;
+	__u16 snd_flags;
+	__u32 snd_ppid;
+	__u32 snd_context;
+	sctp_assoc_t snd_assoc_id;
+};
 
 /*
  *  5.3.5 SCTP Receive Information Structure (SCTP_RCVINFO)
@@ -207,6 +224,8 @@ typedef enum sctp_cmsg_type {
 #define SCTP_SNDRCV	SCTP_SNDRCV
 	SCTP_RCVINFO,
 #define SCTP_RCVINFO SCTP_RCVINFO
+	SCTP_SNDINFO,
+#define SCTP_SNDINFO SCTP_SNDINFO
 } sctp_cmsg_t;
 
 /*
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index aee161b..57657b6 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1648,10 +1648,21 @@ static int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 		msg_name = msg->msg_name;
 	}
 
-	sinfo = cmsgs.info;
+	if(cmsgs.cmsg_type == SCTP_SNDINFO){
+		memset(&default_sinfo, 0, sizeof(default_sinfo));
+		default_sinfo.sinfo_flags = cmsgs.s_info->snd_flags;
+		default_sinfo.sinfo_stream = cmsgs.s_info->snd_sid;
+		default_sinfo.sinfo_assoc_id = cmsgs.s_info->snd_assoc_id;
+		default_sinfo.sinfo_ppid = cmsgs.s_info->snd_ppid;
+		default_sinfo.sinfo_context = cmsgs.s_info->snd_context;
+		sinfo = &default_sinfo;
+	}else{
+		sinfo = cmsgs.sr_info;
+	}
+
 	sinit = cmsgs.init;
 
-	/* Did the user specify SNDRCVINFO?  */
+	/* Did the user specify SNDINFO/SNDRCVINFO?  */
 	if (sinfo) {
 		sinfo_flags = sinfo->sinfo_flags;
 		associd = sinfo->sinfo_assoc_id;
@@ -1858,7 +1869,7 @@ static int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 	pr_debug("%s: we have a valid association\n", __func__);
 
 	if (!sinfo) {
-		/* If the user didn't specify SNDRCVINFO, make up one with
+		/* If the user didn't specify SNDINFO/SNDRCVINFO, make up one with
 		 * some defaults.
 		 */
 		memset(&default_sinfo, 0, sizeof(default_sinfo));
@@ -1869,6 +1880,8 @@ static int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 		default_sinfo.sinfo_timetolive = asoc->default_timetolive;
 		default_sinfo.sinfo_assoc_id = sctp_assoc2id(asoc);
 		sinfo = &default_sinfo;
+	}else{
+		sinfo->sinfo_timetolive = asoc->default_timetolive;
 	}
 
 	/* API 7.1.7, the sndbuf size per association bounds the
@@ -6473,16 +6486,46 @@ static int sctp_msghdr_parse(const struct msghdr *msg, sctp_cmsgs_t *cmsgs)
 			    CMSG_LEN(sizeof(struct sctp_sndrcvinfo)))
 				return -EINVAL;
 
-			cmsgs->info =
+			cmsgs->info.srinfo =
 				(struct sctp_sndrcvinfo *)CMSG_DATA(cmsg);
 
 			/* Minimally, validate the sinfo_flags. */
-			if (cmsgs->info->sinfo_flags &
+			if (cmsgs->sr_info->sinfo_flags &
 			    ~(SCTP_UNORDERED | SCTP_ADDR_OVER |
 			      SCTP_ABORT | SCTP_EOF))
 				return -EINVAL;
 			break;
 
+		case SCTP_SNDINFO:
+			/* SCTP Socket API Extension
+			 * 5.3.4 SCTP Send Information Structure (SCTP_SNDINFO)
+			 *
+			 * This cmsghdr structure specifies SCTP options for
+			 * sendmsg(). This structure and SCTP_RCVINFO replaces
+			 * SCTP_SNDRCV which has been depleted.
+			 *
+			 * cmsg_level    cmsg_type      cmsg_data[]
+			 * ------------  ------------   ---------------------
+			 * IPPROTO_SCTP  SCTP_SNDINFO    struct sctp_sndinfo
+			 * */
+			if(cmsg->cmsg_len !=
+					CMSG_LEN(sizeof(struct sctp_sndinfo))){
+
+				return -EINVAL;
+			}
+
+			/* SCTP_SENDALL should also be added here when
+			 * it is implemented */
+			cmsgs->info.sinfo = (struct sctp_sndinfo *)CMSG_DATA(cmsg);
+			cmsgs->cmsg_type = SCTP_SNDINFO;
+
+			if (cmsgs->s_info->snd_flags &
+					~(SCTP_UNORDERED | SCTP_ADDR_OVER |
+						SCTP_ABORT | SCTP_EOF)){
+				return -EINVAL;
+			}
+			break;
+
 		default:
 			return -EINVAL;
 		}
