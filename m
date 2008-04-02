From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [ROSE/AX25] af_rose: rose_release() fix
Date: Wed, 2 Apr 2008 06:41:07 +0000
Message-ID: <20080402064107.GA3975@ff.dom.local>
References: <47E8FCE2.6000308@free.fr> <20080326183538.GA14266@ami.dom.local> <20080328120721.GA11060@ami.dom.local> <47EE3040.3050208@free.fr> <20080329122452.GB3407@ami.dom.local> <47EE38BA.9090500@free.fr> <20080329130451.GC3407@ami.dom.local> <47EF6479.7030702@free.fr> <20080330115958.GA4975@ami.dom.local> <47F29CEE.10307@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bernard Pidoux <bpidoux@free.fr>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:1090 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139AbYDBGiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 02:38:55 -0400
Received: by ug-out-1314.google.com with SMTP id z38so343472ugc.16
        for <netdev@vger.kernel.org>; Tue, 01 Apr 2008 23:38:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <47F29CEE.10307@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 01, 2008 at 10:37:02PM +0200, Bernard Pidoux wrote:
...
> Three Linux boxes have been are running for more than 24 hours now with  
> only patch #5. They handled a lot of AX25 connections with no problems.
>
> Thus, we can reasonably expect that things are going to stay stable.
>
> If you want to commit patch#5 I will sustain it very much.
>
> I hope that it will be accepted quickly in order to make a coherent  
> system with AX25 patches already applied or not yet applied (if any).
>
> Thank you very much Jarek for this very nice job.

The same to you Bernard!


David & Ralf:

Here I resend the testing patch #5 from this thread: (the only change
- it's against current netdev tree, so 1 line offset added).

Thanks,
Jarek P.

-------------------->

Subject: [ROSE/AX25] af_rose: rose_release() fix

rose_release() doesn't release sockets properly, e.g. it skips
sock_orphan(), so OOPSes are triggered in sock_def_write_space(),
which was observed especially while ROSE skbs were kfreed from
ax25_frames_acked(). There is also sock_hold() and lock_sock()
added - similarly to ax25_release(). Thanks to Bernard Pidoux for
substantial help in debugging this problem.


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Reported-and-tested-by: Bernard Pidoux <bpidoux@free.fr>
Cc: Ralf Baechle DL5RB <ralf@linux-mips.org>

---

 net/rose/af_rose.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 92d85c3..d1ff3f8 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -598,17 +598,24 @@ static int rose_release(struct socket *sock)
 
 	if (sk == NULL) return 0;
 
+	sock_hold(sk);
+	sock_orphan(sk);
+	lock_sock(sk);
 	rose = rose_sk(sk);
 
 	switch (rose->state) {
 	case ROSE_STATE_0:
+		release_sock(sk);
 		rose_disconnect(sk, 0, -1, -1);
+		lock_sock(sk);
 		rose_destroy_socket(sk);
 		break;
 
 	case ROSE_STATE_2:
 		rose->neighbour->use--;
+		release_sock(sk);
 		rose_disconnect(sk, 0, -1, -1);
+		lock_sock(sk);
 		rose_destroy_socket(sk);
 		break;
 
@@ -633,6 +640,8 @@ static int rose_release(struct socket *sock)
 	}
 
 	sock->sk = NULL;
+	release_sock(sk);
+	sock_put(sk);
 
 	return 0;
 }
