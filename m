From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 09/14] sctp: remove the typedef sctp_arg_t
Date: Fri, 11 Aug 2017 10:23:53 +0800
Message-ID: <8a912c943fa40c635ac0dba8726c7e744031a446.1502417340.git.lucien.xin@gmail.com>
References: <cover.1502417340.git.lucien.xin@gmail.com>
 <e15322cc52e110730f2bcb77973222b687717369.1502417340.git.lucien.xin@gmail.com>
 <67dec3f4936413e5bf596dc0ce9be0b9aa15a444.1502417340.git.lucien.xin@gmail.com>
 <5031dc5f40135c4ede57452bc61a1b29dfc76d89.1502417340.git.lucien.xin@gmail.com>
 <58f1f86286c91cf55e9d6eb9395e59e9f1fd4519.1502417340.git.lucien.xin@gmail.com>
 <77692e0783b8134d97fd4c15e37cf0b6e4fa643e.1502417340.git.lucien.xin@gmail.com>
 <bec27150caf5435011467a5488247f853f782409.1502417340.git.lucien.xin@gmail.com>
 <d9ac131331781f85d2662c4c15692344260bb1b6.1502417340.git.lucien.xin@gmail.com>
 <d69e6a88f9cbdc68f0f3ef9c2afd89ccc64f955b.1502417340.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35927 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752403AbdHKCZR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 22:25:17 -0400
In-Reply-To: <d69e6a88f9cbdc68f0f3ef9c2afd89ccc64f955b.1502417340.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1502417340.git.lucien.xin@gmail.com>
References: <cover.1502417340.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_arg_t, and
replace with union sctp_arg in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/command.h | 26 +++++++++++++-------------
 net/sctp/sm_statefuns.c    |  2 +-
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index cbf6798..f5fc425 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -117,7 +117,7 @@ typedef enum {
  */
 #define SCTP_MAX_NUM_COMMANDS 20
 
-typedef union {
+union sctp_arg {
 	void *zero_all;	/* Set to NULL to clear the entire union */
 	__s32 i32;
 	__u32 u32;
@@ -137,24 +137,24 @@ typedef union {
 	struct sctp_packet *packet;
 	struct sctp_sackhdr *sackh;
 	struct sctp_datamsg *msg;
-} sctp_arg_t;
+};
 
 /* We are simulating ML type constructors here.
  *
  * SCTP_ARG_CONSTRUCTOR(NAME, TYPE, ELT) builds a function called
  * SCTP_NAME() which takes an argument of type TYPE and returns an
- * sctp_arg_t.  It does this by inserting the sole argument into the
- * ELT union element of a local sctp_arg_t.
+ * union sctp_arg.  It does this by inserting the sole argument into
+ * the ELT union element of a local union sctp_arg.
  *
  * E.g., SCTP_ARG_CONSTRUCTOR(I32, __s32, i32) builds SCTP_I32(arg),
- * which takes an __s32 and returns a sctp_arg_t containing the
+ * which takes an __s32 and returns a union sctp_arg containing the
  * __s32.  So, after foo = SCTP_I32(arg), foo.i32 == arg.
  */
 
 #define SCTP_ARG_CONSTRUCTOR(name, type, elt) \
-static inline sctp_arg_t	\
+static inline union sctp_arg	\
 SCTP_## name (type arg)		\
-{ sctp_arg_t retval;\
+{ union sctp_arg retval;\
   retval.zero_all = NULL;\
   retval.elt = arg;\
   return retval;\
@@ -179,25 +179,25 @@ SCTP_ARG_CONSTRUCTOR(PACKET,	struct sctp_packet *, packet)
 SCTP_ARG_CONSTRUCTOR(SACKH,	struct sctp_sackhdr *, sackh)
 SCTP_ARG_CONSTRUCTOR(DATAMSG,	struct sctp_datamsg *, msg)
 
-static inline sctp_arg_t SCTP_FORCE(void)
+static inline union sctp_arg SCTP_FORCE(void)
 {
 	return SCTP_I32(1);
 }
 
-static inline sctp_arg_t SCTP_NOFORCE(void)
+static inline union sctp_arg SCTP_NOFORCE(void)
 {
 	return SCTP_I32(0);
 }
 
-static inline sctp_arg_t SCTP_NULL(void)
+static inline union sctp_arg SCTP_NULL(void)
 {
-	sctp_arg_t retval;
+	union sctp_arg retval;
 	retval.zero_all = NULL;
 	return retval;
 }
 
 struct sctp_cmd {
-	sctp_arg_t obj;
+	union sctp_arg obj;
 	sctp_verb_t verb;
 };
 
@@ -226,7 +226,7 @@ static inline int sctp_init_cmd_seq(struct sctp_cmd_seq *seq)
  * to wrap data which goes in the obj argument.
  */
 static inline void sctp_add_cmd_sf(struct sctp_cmd_seq *seq, sctp_verb_t verb,
-				   sctp_arg_t obj)
+				   union sctp_arg obj)
 {
 	struct sctp_cmd *cmd = seq->last_used_slot - 1;
 
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 93b6f42..3394c4d 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -2975,8 +2975,8 @@ sctp_disposition_t sctp_sf_eat_data_6_2(struct net *net,
 					void *arg,
 					struct sctp_cmd_seq *commands)
 {
+	union sctp_arg force = SCTP_NOFORCE();
 	struct sctp_chunk *chunk = arg;
-	sctp_arg_t force = SCTP_NOFORCE();
 	int error;
 
 	if (!sctp_vtag_verify(chunk, asoc)) {
-- 
2.1.0
