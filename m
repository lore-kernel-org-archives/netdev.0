From: David Laight <David.Laight@ACULAB.COM>
Subject: [PATCH net-next 2/3] net: sctp: Optimise the way 'sctp_arg_t'
 values are initialised
Date: Mon, 30 Jun 2014 13:01:07 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17269789@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David S. Miller" <davem@davemloft.net>
To: Network Development <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:56262 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753201AbaF3NCH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 09:02:07 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 13222-02 for <netdev@vger.kernel.org>;
 Mon, 30 Jun 2014 14:01:58 +0100 (BST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even if memset() is inlined (as on x86) using it to zero the union
generates a memory word write of zero, followed by a write of the
smaller field, and then a read of the word.
As well as being a lot of instructions the sequence is unlikely to
be optimised by the store-load forward hardware so will be slow.

Instead allocate a field of the union that is the same size as the
entire union and write a zero value to it. The compiler will then
generate the required value in a register.

Signed-off-by: David Laight <david.laight@aculab.com>
---
 include/net/sctp/command.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index 020eb95..5fcd1a7 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -118,6 +118,7 @@ typedef enum {
 #define SCTP_MAX_NUM_COMMANDS 18
 
 typedef union {
+	void *zero_all;	/* Set to NULL to clear the entire union */
 	__s32 i32;
 	__u32 u32;
 	__be32 be32;
@@ -154,7 +155,7 @@ typedef union {
 static inline sctp_arg_t	\
 SCTP_## name (type arg)		\
 { sctp_arg_t retval;\
-  memset(&retval, 0, sizeof(sctp_arg_t));\
+  retval.zero_all = NULL;\
   retval.elt = arg;\
   return retval;\
 }
@@ -191,7 +192,7 @@ static inline sctp_arg_t SCTP_NOFORCE(void)
 static inline sctp_arg_t SCTP_NULL(void)
 {
 	sctp_arg_t retval;
-	memset(&retval, 0, sizeof(sctp_arg_t));
+	retval.zero_all = NULL;
 	return retval;
 }
 
@@ -212,7 +213,6 @@ typedef struct {
  */
 static inline int sctp_init_cmd_seq(sctp_cmd_seq_t *seq)
 {
-	memset(seq, 0, sizeof(sctp_cmd_seq_t));
 	return 1;		/* We always succeed.  */
 }
 
-- 
1.8.1.2
