From: David Laight <David.Laight@ACULAB.COM>
Subject: [PATCH net-next v2 3/3] net: sctp: Use pointers (not array indexes)
 to access sctp_cmd_seq_t.cmds[].
Date: Fri, 4 Jul 2014 14:35:57 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1726CA67@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David S. Miller" <davem@davemloft.net>
To: Network Development <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:58034 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932196AbaGDOhM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2014 10:37:12 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 25143-05 for <netdev@vger.kernel.org>;
 Fri,  4 Jul 2014 15:37:03 +0100 (BST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using pointers into sctp_cmd_seq_t.cmds[] lets the compiler generate much
better code.
Use the last entry first to optimise the overflow check.

Signed-off-by: David Laight <david.laight@aculab.com>
---

Changes for v2:
	- Delete the initialisers of next_free_slot and next_cmd that
	  v2 of patch 2/3 adds.

 include/net/sctp/command.h | 26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index a4f76d3..059720c 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -203,8 +203,8 @@ typedef struct {
 
 typedef struct {
 	sctp_cmd_t cmds[SCTP_MAX_NUM_COMMANDS];
-	__u8 next_free_slot;
-	__u8 next_cmd;
+	sctp_cmd_t *last_used_slot;
+	sctp_cmd_t *next_cmd;
 } sctp_cmd_seq_t;
 
 
@@ -213,8 +213,9 @@ typedef struct {
  */
 static inline int sctp_init_cmd_seq(sctp_cmd_seq_t *seq)
 {
-	seq->next_free_slot = 0;
-	seq->next_cmd = 0;
+	/* cmds[] is filled backwards to simplify the overflow BUG() check */
+	seq->last_used_slot = seq->cmds + SCTP_MAX_NUM_COMMANDS;
+	seq->next_cmd = seq->last_used_slot;
 	return 1;		/* We always succeed.  */
 }
 
@@ -227,10 +228,13 @@ static inline int sctp_init_cmd_seq(sctp_cmd_seq_t *seq)
 static inline void sctp_add_cmd_sf(sctp_cmd_seq_t *seq, sctp_verb_t verb,
 				   sctp_arg_t obj)
 {
-	BUG_ON(seq->next_free_slot >= SCTP_MAX_NUM_COMMANDS);
+	sctp_cmd_t *cmd = seq->last_used_slot - 1;
 
-	seq->cmds[seq->next_free_slot].verb = verb;
-	seq->cmds[seq->next_free_slot++].obj = obj;
+	BUG_ON(cmd < seq->cmds);
+
+	cmd->verb = verb;
+	cmd->obj = obj;
+	seq->last_used_slot = cmd;
 }
 
 /* Return the next command structure in an sctp_cmd_seq.
@@ -238,12 +242,10 @@ static inline void sctp_add_cmd_sf(sctp_cmd_seq_t *seq, sctp_verb_t verb,
  */
 static inline sctp_cmd_t *sctp_next_cmd(sctp_cmd_seq_t *seq)
 {
-	sctp_cmd_t *retval = NULL;
-
-	if (seq->next_cmd < seq->next_free_slot)
-		retval = &seq->cmds[seq->next_cmd++];
+	if (seq->next_cmd <= seq->last_used_slot)
+		return NULL;
 
-	return retval;
+	return --seq->next_cmd;
 }
 
 #endif /* __net_sctp_command_h__ */
-- 
1.8.1.2
