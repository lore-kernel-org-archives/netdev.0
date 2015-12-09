From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: use-after-free in sctp_do_sm
Date: Wed, 9 Dec 2015 14:41:08 -0200
Message-ID: <20151209164108.GB3886@mrl.redhat.com>
References: <20151207185218.GB22989@mrl.redhat.com>
 <5665DF20.9020904@gmail.com>
 <20151207195032.GA22987@mrl.redhat.com>
 <5665EE26.3000706@gmail.com>
 <5665F17B.5030908@gmail.com>
 <CACT4Y+ad0YGve+KB8wiv6f1+eHt9Ci19FGM0SMWQvJFSez+Rcw@mail.gmail.com>
 <20151208174039.GB22987@mrl.redhat.com>
 <CACT4Y+b1OEE9NqN3J5574iN7t8NEi9jPc2Hxoj6AMHZKjCJ-mg@mail.gmail.com>
 <CACT4Y+YYbC53awV4eiDAwjJO=WHYGv3Og3XDh-gTFB1q_w0YXQ@mail.gmail.com>
 <20151209150356.GA3886@mrl.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	syzkaller <syzkaller@googlegroups.com>,
	linux-sctp@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49475 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751332AbbLIQlN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2015 11:41:13 -0500
Content-Disposition: inline
In-Reply-To: <20151209150356.GA3886@mrl.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 09, 2015 at 01:03:56PM -0200, Marcelo Ricardo Leitner wrote:
> On Wed, Dec 09, 2015 at 03:41:29PM +0100, Dmitry Vyukov wrote:
> > On Tue, Dec 8, 2015 at 8:22 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> > > On Tue, Dec 8, 2015 at 6:40 PM, Marcelo Ricardo Leitner
> > > <marcelo.leitner@gmail.com> wrote:
> ...
> > >> The patches were combined already, but this last pick by Vlad is just
> > >> not yet patched. It's not necessary for your testing and I didn't want
> > >> to interrupt it in case you were already testing it.
> > >>
> > >> You can use my last patch here, from 2 emails ago, the one which
> > >> contains this line:
> > >> -       case SCTP_DISPOSITION_ABORT:
> > >
> > >
> > > You are right. I missed that they are combined. Testing with it now.
> > 
> > 
> > 
> > 
> > Use-after-free still happens.
> > I am on commit aa53685549a2cfb5f175b0c4a20bc9aa1e5a1b85 (Dec 8) plus
> > the following sctp-related changes:
> 
> Changes are fine.  Ugh. Ok, I'll try your new reproducer here.

Heh I wasn't going to reproduce this by myself anytime soon, I think.
It's using the same socket to connect to itself, and only happens if the
connect() gets there before the listen() call. Figured this out because
I could only reproduce it under strace at first.

Please give this other patch a try. A state command
(sctp_sf_cookie_wait_prm_abort) was issuing SCTP_CMD_INIT_FAILED, which
leads to SCTP_CMD_DELETE_TCB, but returning SCTP_DISPOSITION_CONSUME,
which fooled the patch.

---8<---
commit 9f84d50e36cee0ce66e4ce9b3b1665e0a1dbcdd3
Author: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date:   Fri Dec 4 15:30:23 2015 -0200

    sctp: fix use-after-free in pr_debug statement
    
    Dmitry Vyukov reported a use-after-free in the code expanded by the
    macro debug_post_sfx, which is caused by the use of the asoc pointer
    after it was freed within sctp_side_effect() scope.
    
    This patch fixes it by allowing sctp_side_effect to clear that asoc
    pointer when the TCB is freed.
    
    As Vlad explained, we also have to cover the SCTP_DISPOSITION_ABORT case
    because it will trigger DELETE_TCB too on that same loop.
    
    Also, there was a place issuing SCTP_CMD_INIT_FAILED but returning
    SCTP_DISPOSITION_CONSUME, which would fool the scheme above. Fix it by
    returning SCTP_DISPOSITION_ABORT instead.
    
    The macro is already prepared to handle such NULL pointer.
    
    Reported-by: Dmitry Vyukov <dvyukov@google.com>

diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 6098d4c42fa9..be23d5c2074f 100644
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
@@ -1174,11 +1174,12 @@ static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
 		break;
 
 	case SCTP_DISPOSITION_DELETE_TCB:
+	case SCTP_DISPOSITION_ABORT:
 		/* This should now be a command. */
+		*asoc = NULL;
 		break;
 
 	case SCTP_DISPOSITION_CONSUME:
-	case SCTP_DISPOSITION_ABORT:
 		/*
 		 * We should no longer have much work to do here as the
 		 * real work has been done as explicit commands above.
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 6f46aa16cb76..d801e151498a 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -4959,12 +4959,10 @@ sctp_disposition_t sctp_sf_cookie_wait_prm_abort(
 	sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk *abort = arg;
-	sctp_disposition_t retval;
 
 	/* Stop T1-init timer */
 	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
 			SCTP_TO(SCTP_EVENT_TIMEOUT_T1_INIT));
-	retval = SCTP_DISPOSITION_CONSUME;
 
 	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(abort));
 
@@ -4983,7 +4981,7 @@ sctp_disposition_t sctp_sf_cookie_wait_prm_abort(
 	sctp_add_cmd_sf(commands, SCTP_CMD_INIT_FAILED,
 			SCTP_PERR(SCTP_ERROR_USER_ABORT));
 
-	return retval;
+	return SCTP_DISPOSITION_ABORT;
 }
 
 /*
