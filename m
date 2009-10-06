From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: query: TCPCT setsockopt kmalloc's
Date: Tue, 06 Oct 2009 11:53:15 -0400
Message-ID: <4ACB67EB.6080000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:36829 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757941AbZJFPx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 11:53:57 -0400
Received: by fxm27 with SMTP id 27so3790427fxm.17
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2009 08:53:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On both the client and server side, the setsockopt does a kmalloc().  Only
once per connect on the client side, once per listen on the server side.

However, after Miller's expressed concern, it seems possible to reorganize
the code to do the kmalloc() before the lock_sock().  Does that mean that it
should be GFP_KERNEL?  Or should it still be GFP_ATOMIC?

[Not that anybody cares, but based on recent discussion on the list about
internal kernel coding standards, I've changed Adam's old sizeof(struct)
to sizeof(*tcvp).  Previously, I was trying to make as few changes as
possible, thinking everything was already correct.]

===
new:

+		/* Allocate ancillary memory before locking.
+		 */
+		if ((0 < tcd.tcpcd_used
...
+		 && NULL == (tcvp = kmalloc(sizeof(*tcvp) + tcd.tcpcd_used,
+					    GFP_KERNEL))) {
+			return -ENOMEM;
+		}
+
+		lock_sock(sk);
...
+		} else {
+			if (unlikely(NULL != tp->cookie_values)) {
+				kref_put(&tp->cookie_values->kref,
+					 tcp_cookie_values_release);
+			}
+			kref_init(&tcvp->kref);
...
+			tp->cookie_values = tcvp;
+		}
+
+		release_sock(sk);
+		return err;

===
old:

+		lock_sock(sk);
...
+		} else if (NULL != (tsdplp =
+				    kmalloc(sizeof(struct tcp_s_data_payload)
+					    + tcd.tcpcd_used,
+					    GFP_ATOMIC))) {
+			if (unlikely(tp->s_data_payload)) {
+				kref_put(&tp->s_data_payload->kref,
+					 tcp_s_data_payload_release);
+			}
+			kref_init(&tsdplp->kref);
...
+			tp->s_data_payload = tsdplp;
+		} else {
+			err = -ENOMEM;
+		}
+
+		release_sock(sk);
+		return err;
