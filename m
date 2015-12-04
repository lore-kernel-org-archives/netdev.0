From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: use-after-free in sctp_do_sm
Date: Fri,  4 Dec 2015 15:48:14 -0200
Message-ID: <fcceeb2a58ce2054cedb091f0e251393b36418ba.1449250981.git.marcelo.leitner@gmail.com>
References: <CACT4Y+ZMshfGvb81VhCGuZzbSec2sCBaJUNFb1QQ-ccyH9BPkQ@mail.gmail.com>
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	syzkaller <syzkaller@googlegroups.com>,
	linux-sctp@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60784 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753347AbbLDRs1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 12:48:27 -0500
In-Reply-To: <CACT4Y+ZMshfGvb81VhCGuZzbSec2sCBaJUNFb1QQ-ccyH9BPkQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dmitry,

Can you please test this patch?
I'll re-post with proper subject if it works.

Thanks.

---8<---

Dmitry Vyukov reported a use-after-free in the code expanded by the
macro debug_post_sfx, which is caused by the use of the asoc pointer
after it was freed within sctp_side_effect() scope.

This patch fixes it by allowing sctp_side_effect to clear that asoc
pointer when the TCB is freed.

The macro is already prepared to handle such NULL pointer.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/sm_sideeffect.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 6098d4c42fa91287d3cde36ac05d860f76d4fe32..05594dcd93e0d649cace5215d225bef2713f9310 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -63,7 +63,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
 			     sctp_state_t state,
 			     struct sctp_endpoint *ep,
-			     struct sctp_association *asoc,
+			     struct sctp_association **asoc,
 			     void *event_arg,
 			     sctp_disposition_t status,
 			     sctp_cmd_seq_t *commands,
@@ -1123,7 +1123,7 @@ int sctp_do_sm(struct net *net, sctp_event_t event_type, sctp_subtype_t subtype,
 	debug_post_sfn();
 
 	error = sctp_side_effects(event_type, subtype, state,
-				  ep, asoc, event_arg, status,
+				  ep, &asoc, event_arg, status,
 				  &commands, gfp);
 	debug_post_sfx();
 
@@ -1136,7 +1136,7 @@ int sctp_do_sm(struct net *net, sctp_event_t event_type, sctp_subtype_t subtype,
 static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
 			     sctp_state_t state,
 			     struct sctp_endpoint *ep,
-			     struct sctp_association *asoc,
+			     struct sctp_association **asoc,
 			     void *event_arg,
 			     sctp_disposition_t status,
 			     sctp_cmd_seq_t *commands,
@@ -1151,7 +1151,7 @@ static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
 	 * disposition SCTP_DISPOSITION_CONSUME.
 	 */
 	if (0 != (error = sctp_cmd_interpreter(event_type, subtype, state,
-					       ep, asoc,
+					       ep, *asoc,
 					       event_arg, status,
 					       commands, gfp)))
 		goto bail;
@@ -1175,6 +1175,7 @@ static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
 
 	case SCTP_DISPOSITION_DELETE_TCB:
 		/* This should now be a command. */
+		*asoc = NULL;
 		break;
 
 	case SCTP_DISPOSITION_CONSUME:
-- 
2.5.0
