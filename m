From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [RFC PATCH 7/8] [SCTP]: uninline sctp_add_cmd_sf
Date: Wed, 20 Feb 2008 17:16:24 -0500
Message-ID: <47BCA6B8.5000904@hp.com>
References: <1203515238-22848-1-git-send-email-ilpo.jarvinen@helsinki.fi> <1203515238-22848-2-git-send-email-ilpo.jarvinen@helsinki.fi> <1203515238-22848-3-git-send-email-ilpo.jarvinen@helsinki.fi> <1203515238-22848-4-git-send-email-ilpo.jarvinen@helsinki.fi> <1203515238-22848-5-git-send-email-ilpo.jarvinen@helsinki.fi> <1203515238-22848-6-git-send-email-ilpo.jarvinen@helsinki.fi> <1203515238-22848-7-git-send-email-ilpo.jarvinen@helsinki.fi> <1203515238-22848-8-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030809010504030708020408"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:13362 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532AbYBTWQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 17:16:13 -0500
In-Reply-To: <1203515238-22848-8-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030809010504030708020408
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

Ilpo Järvinen wrote:
> I added inline to sctp_add_cmd and appropriate comment there to
> avoid adding another call into the call chain. This works at least
> with "gcc (GCC) 4.1.2 20070626 (Red Hat 4.1.2-13)". Alternatively,
> __sctp_add_cmd could be introduced to .h.
> 

My only concern was performance regressions, but it looks like it
doesn't effect anything from the few quick runs I've made.

Since we are putting sctp_add_cmd_sf() on the call stack, we might
as well get rid of sctp_add_cmd() and reduce it a bit more.

-vlad

--------------030809010504030708020408
Content-Type: text/plain;
 name="p"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="p"

diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index 10ae2da..4263af8 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -205,12 +205,11 @@ typedef struct {
 int sctp_init_cmd_seq(sctp_cmd_seq_t *seq);
 
 /* Add a command to an sctp_cmd_seq_t.
- * Return 0 if the command sequence is full.
  *
  * Use the SCTP_* constructors defined by SCTP_ARG_CONSTRUCTOR() above
  * to wrap data which goes in the obj argument.
  */
-int sctp_add_cmd(sctp_cmd_seq_t *seq, sctp_verb_t verb, sctp_arg_t obj);
+void sctp_add_cmd_sf(sctp_cmd_seq_t *seq, sctp_verb_t verb, sctp_arg_t obj);
 
 /* Return the next command structure in an sctp_cmd_seq.
  * Return NULL at the end of the sequence.
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index ef9e7ed..2481173 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -385,14 +385,6 @@ static inline int ADDIP_SERIAL_gte(__u16 s, __u16 t)
 	return (((s) == (t)) || (((t) - (s)) & ADDIP_SERIAL_SIGN_BIT));
 }
 
-
-/* Run sctp_add_cmd() generating a BUG() if there is a failure.  */
-static inline void sctp_add_cmd_sf(sctp_cmd_seq_t *seq, sctp_verb_t verb, sctp_arg_t obj)
-{
-	if (unlikely(!sctp_add_cmd(seq, verb, obj)))
-		BUG();
-}
-
 /* Check VTAG of the packet matches the sender's own tag. */
 static inline int
 sctp_vtag_verify(const struct sctp_chunk *chunk,
diff --git a/net/sctp/command.c b/net/sctp/command.c
index bb97733..3a06513 100644
--- a/net/sctp/command.c
+++ b/net/sctp/command.c
@@ -51,19 +51,16 @@ int sctp_init_cmd_seq(sctp_cmd_seq_t *seq)
 
 /* Add a command to a sctp_cmd_seq_t.
  * Return 0 if the command sequence is full.
+ *
+ * Inline here is not a mistake, this way sctp_add_cmd_sf doesn't need extra
+ * calls, size penalty is of insignificant magnitude here
  */
-int sctp_add_cmd(sctp_cmd_seq_t *seq, sctp_verb_t verb, sctp_arg_t obj)
+void sctp_add_cmd_sf(sctp_cmd_seq_t *seq, sctp_verb_t verb, sctp_arg_t obj)
 {
-	if (seq->next_free_slot >= SCTP_MAX_NUM_COMMANDS)
-		goto fail;
+	BUG_ON(seq->next_free_slot >= SCTP_MAX_NUM_COMMANDS);
 
 	seq->cmds[seq->next_free_slot].verb = verb;
 	seq->cmds[seq->next_free_slot++].obj = obj;
-
-	return 1;
-
-fail:
-	return 0;
 }
 
 /* Return the next command structure in a sctp_cmd_seq.
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index f2ed647..1475a29 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3135,12 +3135,8 @@ sctp_disposition_t sctp_sf_operr_notify(const struct sctp_endpoint *ep,
 		if (!ev)
 			goto nomem;
 
-		if (!sctp_add_cmd(commands, SCTP_CMD_EVENT_ULP,
-				  SCTP_ULPEVENT(ev))) {
-			sctp_ulpevent_free(ev);
-			goto nomem;
-		}
-
+		sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
+				SCTP_ULPEVENT(ev));
 		sctp_add_cmd_sf(commands, SCTP_CMD_PROCESS_OPERR,
 				SCTP_CHUNK(chunk));
 	}

--------------030809010504030708020408--
