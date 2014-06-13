From: David Laight <David.Laight@ACULAB.COM>
Subject: [PATCH RFC] sctp: optimise sctp/command.[ch]
Date: Fri, 13 Jun 2014 16:12:16 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725C577@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:47589 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752473AbaFMQNO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2014 12:13:14 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 11303-03 for <netdev@vger.kernel.org>;
 Fri, 13 Jun 2014 17:13:05 +0100 (BST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This an RFC because net-next is closed :-)

It might deserve a couple of real patches.

I was looking at the code in sctp/command.[ch] and realised that is was rather
sub-optimal.

All the functions in command.c are only used from within the sctp module
so there is no reason they shouldn't be inlined.
With all the patches the new version is 4k smaller (and64 from lsmod).

Even on x86 (where memset() gets inlined) there are memory store-load pairs
with different byte enables that are unlikely to be fast pathed - so are
very slow. If memset() is a function call it will be horrific.

Instead of using memset() to zero the union, just write to a member that
is the size of the union itself.
Any of the 'pointer' entries would do - but I've added a special one.

There is no need to zero the entire structure before use.
Indeed it shouldn't be necessary to zero the rest of the union.
If the values are picked up from the wrong field then big-endian
systems won't work.

Using array indexing for cmds[] is a lot slower than using pointers.
If the array slots are used 'backwards' the check for overflow is
simplified (the compiler has the base address of the structure).

I've increased SCTP_MAX_NUM_COMMANDS because another patch needs it.

net/sctp/command.c should be deleted and include/net/sctp/command.h patched.

	David

diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index 4b7cd69..74a8d3d 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -113,11 +113,15 @@ typedef enum {
 /* How many commands can you put in an sctp_cmd_seq_t?
  * This is a rather arbitrary number, ideally derived from a careful
  * analysis of the state functions, but in reality just taken from
- * thin air in the hopes othat we don't trigger a kernel panic.
+ * thin air in the hopes that we don't trigger a kernel panic.
+ *
+ * 17 slots are needed for a duplicate COOKIE_ECHO that hits an association
+ * that is waiting for a DATA ack in order to do a graceful shutdown.
  */
-#define SCTP_MAX_NUM_COMMANDS 14
+#define SCTP_MAX_NUM_COMMANDS 18
 
 typedef union {
+	void *zero_all;	/* Set to NULL to clear the entire union */
 	__s32 i32;
 	__u32 u32;
 	__be32 be32;
@@ -154,7 +158,7 @@ typedef union {
 static inline sctp_arg_t	\
 SCTP_## name (type arg)		\
 { sctp_arg_t retval;\
-  memset(&retval, 0, sizeof(sctp_arg_t));\
+  retval.zero_all = NULL;\
   retval.elt = arg;\
   return retval;\
 }
@@ -191,7 +195,8 @@ static inline sctp_arg_t SCTP_NOFORCE(void)
 static inline sctp_arg_t SCTP_NULL(void)
 {
 	sctp_arg_t retval;
-	memset(&retval, 0, sizeof(sctp_arg_t));
+	
+	retval.zero_all = NULL;
 	return retval;
 }
 
@@ -202,27 +207,44 @@ typedef struct {
 
 typedef struct {
 	sctp_cmd_t cmds[SCTP_MAX_NUM_COMMANDS];
-	__u8 next_free_slot;
-	__u8 next_cmd;
+	sctp_cmd_t *last_used_slot;
+	sctp_cmd_t *next_cmd;
 } sctp_cmd_seq_t;
 
+static inline int
+sctp_init_cmd_seq(sctp_cmd_seq_t *seq)
+{
+	/* cmds[] is filled backwards to simplify the overflow BUG() check */
 
-/* Initialize a block of memory as a command sequence.
- * Return 0 if the initialization fails.
- */
-int sctp_init_cmd_seq(sctp_cmd_seq_t *seq);
+	seq->last_used_slot = seq->next_cmd = seq->cmds + SCTP_MAX_NUM_COMMANDS;
+	return 1;		/* We always succeed.  */
+}
 
-/* Add a command to an sctp_cmd_seq_t.
- *
- * Use the SCTP_* constructors defined by SCTP_ARG_CONSTRUCTOR() above
- * to wrap data which goes in the obj argument.
- */
-void sctp_add_cmd_sf(sctp_cmd_seq_t *seq, sctp_verb_t verb, sctp_arg_t obj);
+/* Add a command to a sctp_cmd_seq_t. */
 
-/* Return the next command structure in an sctp_cmd_seq.
- * Return NULL at the end of the sequence.
+static inline void
+sctp_add_cmd_sf(sctp_cmd_seq_t *seq, sctp_verb_t verb, sctp_arg_t obj)
+{
+	sctp_cmd_t *cmd = seq->last_used_slot - 1;
+
+	BUG_ON(cmd < seq->cmds);
+	
+	cmd->verb = verb;
+	cmd->obj = obj;
+	seq->last_used_slot = cmd;
+}
+
+/* Return the next command structure in a sctp_cmd_seq.
+ * Returns NULL at the end of the sequence.
  */
-sctp_cmd_t *sctp_next_cmd(sctp_cmd_seq_t *seq);
+static inline sctp_cmd_t
+*sctp_next_cmd(sctp_cmd_seq_t *seq)
+{
+	if (seq->next_cmd <= seq->last_used_slot)
+		return NULL;
+
+	return --seq->next_cmd;
+}
 
 #endif /* __net_sctp_command_h__ */
