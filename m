From: David Laight <David.Laight@ACULAB.COM>
Subject: [PATCH net-next 1/3] net: sctp: Inline the functions from command.c
Date: Mon, 30 Jun 2014 13:01:04 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1726978C@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David S. Miller" <davem@davemloft.net>
To: Network Development <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:56251 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753131AbaF3NCE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 09:02:04 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 10924-04 for <netdev@vger.kernel.org>;
 Mon, 30 Jun 2014 14:01:55 +0100 (BST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_init_cmd_seq() and sctp_next_cmd() are only called from one place.
The call sequence for sctp_add_cmd_sf() is likely to be longer than
the inlined code.
With sctp_add_cmd_sf() inlined the compiler can optimise repeated calls.


Signed-off-by: David Laight <david.laight@aculab.com>
---
 include/net/sctp/command.h | 27 +++++++++++++++---
 net/sctp/Makefile          |  2 +-
 net/sctp/command.c         | 68 ----------------------------------------------
 3 files changed, 24 insertions(+), 73 deletions(-)
 delete mode 100644 net/sctp/command.c

diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index 6547ab7..020eb95 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -210,19 +210,38 @@ typedef struct {
 /* Initialize a block of memory as a command sequence.
  * Return 0 if the initialization fails.
  */
-int sctp_init_cmd_seq(sctp_cmd_seq_t *seq);
+static inline int sctp_init_cmd_seq(sctp_cmd_seq_t *seq)
+{
+	memset(seq, 0, sizeof(sctp_cmd_seq_t));
+	return 1;		/* We always succeed.  */
+}
+
 
 /* Add a command to an sctp_cmd_seq_t.
  *
  * Use the SCTP_* constructors defined by SCTP_ARG_CONSTRUCTOR() above
  * to wrap data which goes in the obj argument.
  */
-void sctp_add_cmd_sf(sctp_cmd_seq_t *seq, sctp_verb_t verb, sctp_arg_t obj);
+static inline void sctp_add_cmd_sf(sctp_cmd_seq_t *seq, sctp_verb_t verb,
+				   sctp_arg_t obj)
+{
+	BUG_ON(seq->next_free_slot >= SCTP_MAX_NUM_COMMANDS);
+
+	seq->cmds[seq->next_free_slot].verb = verb;
+	seq->cmds[seq->next_free_slot++].obj = obj;
+}
 
 /* Return the next command structure in an sctp_cmd_seq.
  * Return NULL at the end of the sequence.
  */
-sctp_cmd_t *sctp_next_cmd(sctp_cmd_seq_t *seq);
+static inline sctp_cmd_t *sctp_next_cmd(sctp_cmd_seq_t *seq)
+{
+	sctp_cmd_t *retval = NULL;
 
-#endif /* __net_sctp_command_h__ */
+	if (seq->next_cmd < seq->next_free_slot)
+		retval = &seq->cmds[seq->next_cmd++];
+
+	return retval;
+}
 
+#endif /* __net_sctp_command_h__ */
diff --git a/net/sctp/Makefile b/net/sctp/Makefile
index 5c30b7a..3b4ffb0 100644
--- a/net/sctp/Makefile
+++ b/net/sctp/Makefile
@@ -8,7 +8,7 @@ obj-$(CONFIG_NET_SCTPPROBE) += sctp_probe.o
 sctp-y := sm_statetable.o sm_statefuns.o sm_sideeffect.o \
 	  protocol.o endpointola.o associola.o \
 	  transport.o chunk.o sm_make_chunk.o ulpevent.o \
-	  inqueue.o outqueue.o ulpqueue.o command.o \
+	  inqueue.o outqueue.o ulpqueue.o \
 	  tsnmap.o bind_addr.o socket.o primitive.o \
 	  output.o input.o debug.o ssnmap.o auth.o
 
diff --git a/net/sctp/command.c b/net/sctp/command.c
deleted file mode 100644
index dd73758..0000000
--- a/net/sctp/command.c
+++ /dev/null
@@ -1,68 +0,0 @@
-/* SCTP kernel implementation Copyright (C) 1999-2001
- * Cisco, Motorola, and IBM
- * Copyright 2001 La Monte H.P. Yarroll
- *
- * This file is part of the SCTP kernel implementation
- *
- * These functions manipulate sctp command sequences.
- *
- * This SCTP implementation is free software;
- * you can redistribute it and/or modify it under the terms of
- * the GNU General Public License as published by
- * the Free Software Foundation; either version 2, or (at your option)
- * any later version.
- *
- * This SCTP implementation is distributed in the hope that it
- * will be useful, but WITHOUT ANY WARRANTY; without even the implied
- *                 ************************
- * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
- * See the GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, see
- * <http://www.gnu.org/licenses/>.
- *
- * Please send any bug reports or fixes you make to the
- * email address(es):
- *    lksctp developers <linux-sctp@vger.kernel.org>
- *
- * Written or modified by:
- *    La Monte H.P. Yarroll <piggy@acm.org>
- *    Karl Knutson <karl@athena.chicago.il.us>
- */
-
-#include <linux/types.h>
-#include <net/sctp/sctp.h>
-#include <net/sctp/sm.h>
-
-/* Initialize a block of memory as a command sequence. */
-int sctp_init_cmd_seq(sctp_cmd_seq_t *seq)
-{
-	memset(seq, 0, sizeof(sctp_cmd_seq_t));
-	return 1;		/* We always succeed.  */
-}
-
-/* Add a command to a sctp_cmd_seq_t.
- * Return 0 if the command sequence is full.
- */
-void sctp_add_cmd_sf(sctp_cmd_seq_t *seq, sctp_verb_t verb, sctp_arg_t obj)
-{
-	BUG_ON(seq->next_free_slot >= SCTP_MAX_NUM_COMMANDS);
-
-	seq->cmds[seq->next_free_slot].verb = verb;
-	seq->cmds[seq->next_free_slot++].obj = obj;
-}
-
-/* Return the next command structure in a sctp_cmd_seq.
- * Returns NULL at the end of the sequence.
- */
-sctp_cmd_t *sctp_next_cmd(sctp_cmd_seq_t *seq)
-{
-	sctp_cmd_t *retval = NULL;
-
-	if (seq->next_cmd < seq->next_free_slot)
-		retval = &seq->cmds[seq->next_cmd++];
-
-	return retval;
-}
-
-- 
1.8.1.2
