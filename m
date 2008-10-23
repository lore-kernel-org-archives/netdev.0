From: Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao
	<fernando@oss.ntt.co.jp>
Subject: [RFC][PATCH] xfrm: do not leak ESRCH to user space
Date: Thu, 23 Oct 2008 23:27:19 +0900
Message-ID: <1224772039.4404.56.camel@sebastian.kern.oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from serv2.oss.ntt.co.jp ([222.151.198.100]:40402 "EHLO
	serv2.oss.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561AbYJWO1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 10:27:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

I noticed that, under certain conditions, ESRCH can be leaked from the
xfrm layer to user space through sys_connect. In particular, this seems
to happen reliably when the kernel fails to resolve a template either
because the AF_KEY receive buffer being used by racoon is full or
because the SA entry we are trying to use is in XFRM_STATE_EXPIRED
state.

However, since this could be a transient issue it could be argued that
EAGAIN would be more appropriate. Besides this error code is not even
documented in the man page for sys_connect (as of man-pages 3.07).

What is the expected behavior (I could not find anything in the RFCs)?
Should we just fix the connect(2) man page instead?

---

Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
---

diff -urNp linux-2.6.27-git10/net/xfrm/xfrm_policy.c linux-2.6.27-git10-fix/net/xfrm/xfrm_policy.c
--- linux-2.6.27-git10/net/xfrm/xfrm_policy.c	2008-10-23 22:29:45.000000000 +0900
+++ linux-2.6.27-git10-fix/net/xfrm/xfrm_policy.c	2008-10-23 22:26:31.000000000 +0900
@@ -1251,6 +1251,8 @@ xfrm_tmpl_resolve_one(struct xfrm_policy
 				 -EINVAL : -EAGAIN);
 			xfrm_state_put(x);
 		}
+		else if (error == -ESRCH)
+			error = -EAGAIN;
 
 		if (!tmpl->optional)
 			goto fail;


