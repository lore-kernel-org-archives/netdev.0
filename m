From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [V4.4-rc6 Regression] af_unix: Revert 'lock_interruptible' in stream receive code
Date: Fri, 05 Feb 2016 21:44:15 +0000
Message-ID: <87bn7ude8g.fsf@doppelsaurus.mobileactivedefense.com>
References: <56B4EF04.2060407@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rweikusat@mobileactivedefense.com, hannes@stressinduktion.org,
	edumazet@google.com, dhowells@redhat.com, ying.xue@windriver.com,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"stable\@vger.kernel.org" <stable@vger.kernel.org>,
	Joseph Salisbury <joseph.salisbury@canonical.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56B4EF04.2060407@canonical.com> (Joseph Salisbury's message of
	"Fri, 5 Feb 2016 13:50:44 -0500")
Sender: linux-kernel-owner@vger.kernel.org
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

Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>
---
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 49d5093..138787d 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2277,13 +2277,15 @@ static int unix_stream_read_generic(struct unix_stream_read_state *state)
 	size_t size = state->size;
 	unsigned int last_len;
 
-	err = -EINVAL;
-	if (sk->sk_state != TCP_ESTABLISHED)
+	if (sk->sk_state != TCP_ESTABLISHED) {
+		err = -EINVAL;
 		goto out;
+	}
 
-	err = -EOPNOTSUPP;
-	if (flags & MSG_OOB)
+	if (flags & MSG_OOB) {
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
