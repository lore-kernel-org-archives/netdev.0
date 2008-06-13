From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [TCP]: TCP_DEFER_ACCEPT causes leak sockets
Date: Fri, 13 Jun 2008 13:09:13 +0200
Message-ID: <20080613110913.GB9867@elte.hu>
References: <20080611.165255.242691774.davem@davemloft.net> <20080612.163212.148965080.davem@davemloft.net> <20080613063037.GA16943@elte.hu> <20080613.023208.78649628.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, vgusev@openvz.org, mcmanus@ducksong.com,
	xemul@openvz.org, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760230AbYFMLJu@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080613.023208.78649628.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> Date: Fri, 13 Jun 2008 08:30:37 +0200
> 
> > the 3 reverts have been extensively tested in -tip via:
> > 
> >  # tip/out-of-tree: 9e5b6ca: tcp: revert DEFER_ACCEPT modifications
> > 
> > and the distcc problems are fixed. (The locking fix alone did not fix it 
> > conclusively in my testing, possibly due to the follow-on observations 
> > outlined in your description.)
> > 
> > Tested-by: Ingo Molnar <mingo@elte.hu>
> 
> I didn't revert all three changes, just the final part of that 3 part 
> series.
> 
> Please test the patch I actually applied.

i just updated all my testsystems to revert the change i tested so far, 
and updated it to yours. The delta between the two is the 3 lines patch 
below.

A few testsystems already booted into your patch, so if i dont report a 
hung TCP connection in the next 6 hours consider it:

Tested-by: Ingo Molnar <mingo@elte.hu>

	Ingo

--------------->
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index ec83448..045e799 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -466,9 +466,9 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 		reqp=&lopt->syn_table[i];
 		while ((req = *reqp) != NULL) {
 			if (time_after_eq(now, req->expires)) {
-				if ((req->retrans < thresh ||
-				     (inet_rsk(req)->acked && req->retrans < max_retries))
-				    && !req->rsk_ops->rtx_syn_ack(parent, req)) {
+				if ((req->retrans < (inet_rsk(req)->acked ? max_retries : thresh)) &&
+				    (inet_rsk(req)->acked ||
+				     !req->rsk_ops->rtx_syn_ack(parent, req))) {
 					unsigned long timeo;
 
 					if (req->retrans++ == 0)
