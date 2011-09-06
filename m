From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Tue, 06 Sep 2011 15:08:40 -0700
Message-ID: <1315346920.2576.3089.camel@schen9-DESK>
References: <4E631032.6050606@intel.com>
	 <1315326326.2576.2980.camel@schen9-DESK>
	 <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315335019.2576.3048.camel@schen9-DESK>
	 <1315335660.3400.7.camel@edumazet-laptop>
	 <1315337580.2576.3066.camel@schen9-DESK>
	 <1315338186.3400.20.camel@edumazet-laptop>
	 <1315339157.2576.3079.camel@schen9-DESK>
	 <1315340388.3400.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Yan, Zheng" <zheng.z.yan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"sedat.dilek@gmail.com" <sedat.dilek@gmail.com>, alex.shi@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:6911 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751507Ab1IFWGX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Sep 2011 18:06:23 -0400
In-Reply-To: <1315340388.3400.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-09-06 at 22:19 +0200, Eric Dumazet wrote:

> 
> unless scm_ref really means scm_noref ?
> 
> I really hate this patch. I mean it. 
> 
> I read it 10 times, spent 2 hours and still dont understand it.
> 

Eric,

I've tried another patch to fix my original one.  I've used a boolean
ref_avail to indicate if there is an outstanding ref to scm not yet
encoded into the skb.  Hopefully the logic is clearer in this new patch.

> 
> As I said, we should revert the buggy patch, and rewrite a performance
> fix from scratch, with not a single get_pid()/put_pid() in fast path.
> 
> read()/write() on AF_UNIX sockets should not use a single
> get_pid()/put_pid().
> 
> This is a serious regression we should fix at 100%, not 50% or even 75%,
> adding serious bugs.

That will be ideal if there is another way to fix it 100%, other than reverting
commit 7361c36c.  Probably if there is some way we know beforehand that 
both sender and receiver share the same pid, which is quite common, a
lot of these pid code can be bypassed. 

Tim


Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 136298c..78be921 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1582,11 +1582,13 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	struct scm_cookie tmp_scm;
 	bool fds_sent = false;
 	int max_level;
+	bool ref_avail; /* scm ref not yet used in skb */
 
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
 	wait_for_unix_gc();
 	err = scm_send(sock, msg, siocb->scm);
+	ref_avail = true;
 	if (err < 0)
 		return err;
 
@@ -1642,11 +1644,18 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		size = min_t(int, size, skb_tailroom(skb));
 
 
-		/* Only send the fds and no ref to pid in the first buffer */
-		err = unix_scm_to_skb(siocb->scm, skb, !fds_sent, fds_sent);
+		/* encode scm in skb and use the scm ref */
+		ref_avail = false;
+		if (sent + size < len) { 
+			/* Only send the fds in the first buffer */
+			/* get additional ref if more skbs will be created */
+			err = unix_scm_to_skb(siocb->scm, skb, !fds_sent, true);
+			ref_avail = true;
+		} else
+			err = unix_scm_to_skb(siocb->scm, skb, !fds_sent, false);
 		if (err < 0) {
 			kfree_skb(skb);
-			goto out;
+			goto out_err;
 		}
 		max_level = err + 1;
 		fds_sent = true;
@@ -1654,7 +1663,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
 		if (err) {
 			kfree_skb(skb);
-			goto out;
+			goto out_err;
 		}
 
 		unix_state_lock(other);
@@ -1671,10 +1680,10 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		sent += size;
 	}
 
-	if (skb)
-		scm_release(siocb->scm);
-	else
+	if (ref_avail)
 		scm_destroy(siocb->scm);
+	else
+		scm_release(siocb->scm);
 	siocb->scm = NULL;
 
 	return sent;
@@ -1687,9 +1696,10 @@ pipe_err:
 		send_sig(SIGPIPE, current, 0);
 	err = -EPIPE;
 out_err:
-	if (skb == NULL)
+	if (ref_avail)
 		scm_destroy(siocb->scm);
-out:
+	else
+		scm_release(siocb->scm);
 	siocb->scm = NULL;
 	return sent ? : err;
 }
