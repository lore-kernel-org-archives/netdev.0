From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 7/7] [SCTP]: Remove sctp_add_cmd_sf wrapper bloat
Date: Thu, 27 Mar 2008 14:38:06 +0200
Message-ID: <1206621486-5408-8-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1206621486-5408-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1206621486-5408-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1206621486-5408-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1206621486-5408-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1206621486-5408-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1206621486-5408-6-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1206621486-5408-7-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55645 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759879AbYC0MiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 08:38:11 -0400
In-Reply-To: <1206621486-5408-7-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With a was number of callsites sctp_add_cmd_sf wrapper bloats
kernel by some amount. Due to unlikely tracking allyesconfig,
with the initial result were around ~7kB (thus caught my
attention) while a non-debug config produced only ~2.3kB effect.

I (ij) proposed first a patch to uninline it but Vlad responded
with a patch that removed the only sctp_add_cmd call which is
wrapped by sctp_add_cmd_sf (I wasn't sure if I could do that).
I did minor cleanup to Vlad's patch.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/command.h |    3 +--
 include/net/sctp/sm.h      |    8 --------
 net/sctp/command.c         |   10 ++--------
 net/sctp/sm_statefuns.c    |    8 ++------
 4 files changed, 5 insertions(+), 24 deletions(-)

diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index 10ae2da..4263af8 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -205,12 +205,11 @@ typedef struct {
 int sctp_init_cmd_seq(sctp_cmd_seq_t *seq);
=20
 /* Add a command to an sctp_cmd_seq_t.
- * Return 0 if the command sequence is full.
  *
  * Use the SCTP_* constructors defined by SCTP_ARG_CONSTRUCTOR() above
  * to wrap data which goes in the obj argument.
  */
-int sctp_add_cmd(sctp_cmd_seq_t *seq, sctp_verb_t verb, sctp_arg_t obj=
);
+void sctp_add_cmd_sf(sctp_cmd_seq_t *seq, sctp_verb_t verb, sctp_arg_t=
 obj);
=20
 /* Return the next command structure in an sctp_cmd_seq.
  * Return NULL at the end of the sequence.
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index ef9e7ed..2481173 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -385,14 +385,6 @@ static inline int ADDIP_SERIAL_gte(__u16 s, __u16 =
t)
 	return (((s) =3D=3D (t)) || (((t) - (s)) & ADDIP_SERIAL_SIGN_BIT));
 }
=20
-
-/* Run sctp_add_cmd() generating a BUG() if there is a failure.  */
-static inline void sctp_add_cmd_sf(sctp_cmd_seq_t *seq, sctp_verb_t ve=
rb, sctp_arg_t obj)
-{
-	if (unlikely(!sctp_add_cmd(seq, verb, obj)))
-		BUG();
-}
-
 /* Check VTAG of the packet matches the sender's own tag. */
 static inline int
 sctp_vtag_verify(const struct sctp_chunk *chunk,
diff --git a/net/sctp/command.c b/net/sctp/command.c
index bb97733..c004401 100644
--- a/net/sctp/command.c
+++ b/net/sctp/command.c
@@ -52,18 +52,12 @@ int sctp_init_cmd_seq(sctp_cmd_seq_t *seq)
 /* Add a command to a sctp_cmd_seq_t.
  * Return 0 if the command sequence is full.
  */
-int sctp_add_cmd(sctp_cmd_seq_t *seq, sctp_verb_t verb, sctp_arg_t obj=
)
+void sctp_add_cmd_sf(sctp_cmd_seq_t *seq, sctp_verb_t verb, sctp_arg_t=
 obj)
 {
-	if (seq->next_free_slot >=3D SCTP_MAX_NUM_COMMANDS)
-		goto fail;
+	BUG_ON(seq->next_free_slot >=3D SCTP_MAX_NUM_COMMANDS);
=20
 	seq->cmds[seq->next_free_slot].verb =3D verb;
 	seq->cmds[seq->next_free_slot++].obj =3D obj;
-
-	return 1;
-
-fail:
-	return 0;
 }
=20
 /* Return the next command structure in a sctp_cmd_seq.
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 6545b5f..b534dbe 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3135,12 +3135,8 @@ sctp_disposition_t sctp_sf_operr_notify(const st=
ruct sctp_endpoint *ep,
 		if (!ev)
 			goto nomem;
=20
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
--=20
1.5.2.2

