From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] af_unix: Don't set err in unix_stream_read_generic unless there was an error
Date: Mon, 08 Feb 2016 18:05:38 +0000
Message-ID: <87twljrsb1.fsf@doppelsaurus.mobileactivedefense.com>
References: <56B4EF04.2060407@canonical.com>
	<87zivebxjr.fsf@doppelsaurus.mobileactivedefense.com>
	<87lh6wl44b.fsf@doppelsaurus.mobileactivedefense.com>
	<87bn7rtdwe.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rweikusat@mobileactivedefense.com, hannes@stressinduktion.org,
	edumazet@google.com, dhowells@redhat.com, ying.xue@windriver.com,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"stable\@vger.kernel.org" <stable@vger.kernel.org>,
	Joseph Salisbury <joseph.salisbury@canonical.com>
To: "davem\@davemloft.net" <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <87bn7rtdwe.fsf@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Mon, 08 Feb 2016 15:33:53 +0000")
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The present unix_stream_read_generic contains various code sequences of
the form

err = -EDISASTER;
if (<test>)
	goto out;

This has the unfortunate side effect of possibly causing the error code
to bleed through to the final

out:
	return copied ? : err;

and then to be wrongly returned if no data was copied because the caller
didn't supply a data buffer, as demonstrated by the program available at

http://pad.lv/1540731

Change it such that err is only set if an error condition was detected.

Fixes: 3822b5c2fc62 ("af_unix: Revert 'lock_interruptible' in stream receive code")
Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>
---

With Fixes: fixed.

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 49d5093..c1e4dd7 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2277,13 +2277,15 @@ static int unix_stream_read_generic(struct unix_stream_read_state *state)
 	size_t size = state->size;
 	unsigned int last_len;
 
-	err = -EINVAL;
-	if (sk->sk_state != TCP_ESTABLISHED)
+	if (unlikely(sk->sk_state != TCP_ESTABLISHED)) {
+		err = -EINVAL;
 		goto out;
+	}
 
-	err = -EOPNOTSUPP;
-	if (flags & MSG_OOB)
+	if (unlikely(flags & MSG_OOB)) {
+		err = -EOPNOTSUPP;
 		goto out;
+	}
 
 	target = sock_rcvlowat(sk, flags & MSG_WAITALL, size);
 	timeo = sock_rcvtimeo(sk, noblock);
@@ -2329,9 +2331,11 @@ again:
 				goto unlock;
 
 			unix_state_unlock(sk);
-			err = -EAGAIN;
-			if (!timeo)
+			if (!timeo) {
+				err = -EAGAIN;
 				break;
+			}
+
 			mutex_unlock(&u->readlock);
 
 			timeo = unix_stream_data_wait(sk, timeo, last,
