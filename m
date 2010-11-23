From: Tetsuo Handa <penguin-kernel-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>
Subject: Patch for man unix(7)
Date: Tue, 23 Nov 2010 21:59:51 +0900
Message-ID: <201011232159.DFE78143.tSHMFQOLFVFJOO@I-love.SAKURA.ne.jp>
References: <AANLkTimtTazMmDvQFgASsVGa=AYvPZqUaUmyg5p7VVY1@mail.gmail.com>
	<201010171428.DDC17187.FFFJSLtOOHOMQV@I-love.SAKURA.ne.jp>
	<201010262115.FEH09326.OMFJHSVOFLQFOt@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201010262115.FEH09326.OMFJHSVOFLQFOt-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 From f388eedbdc0b099bb9f36ab007f9370432abb300 Mon Sep 17 00:00:00 2001
 From: Tetsuo Handa <penguin-kernel-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>
Date: Tue, 23 Nov 2010 21:34:25 +0900
Subject: [PATCH] unix.7: Fix description of "pathname" sockets

Since unix_mkname() in net/unix/af_unix.c does

  ((char *)sunaddr)[len] = 0;

rather than

  ((char *)sunaddr)[len - 1] = 0;

, sunaddr->sun_path may not be terminated with a null byte if
len == sizeof(*sunaddr).

Therefore, the caller of getsockname(), getpeername(), accept() must not assume
that sunaddr->sun_path contains a null-terminated pathname even if the returned
addrlen is greater than sizeof(sa_family_t) and sun_path[0] != '\0'.

Signed-off-by: Tetsuo Handa <penguin-kernel-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>
---
 man7/unix.7 |   19 ++++++++++++++++---
 1 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/man7/unix.7 b/man7/unix.7
index b53328b..7b0b47c 100644
--- a/man7/unix.7
+++ b/man7/unix.7
@@ -80,10 +80,23 @@ When the address of the socket is returned by
 and
 .BR accept (2),
 its length is
-.IR "offsetof(struct sockaddr_un, sun_path) + strlen(sun_path) + 1" ,
+.IR "offsetof(struct sockaddr_un, sun_path) + strlen(sun_path) + 1".
+Note that this length can be one byte larger than
+.IR "sizeof(struct sockaddr_un)"
+because
+.BR bind (2)
+accepts
+.IR sun_path
+which is not terminated with a null byte ('\\0').
+Therefore, you must not use string manipulation functions (e.g. strlen(),
+printf("%s")) against
+.IR sun_path
+because
+.BR getsockname (2),
+.BR getpeername (2),
 and
-.I sun_path
-contains the null-terminated pathname.
+.BR accept (2)
+may not have stored a null-terminated string.
 .IP *
 .IR unnamed :
 A stream socket that has not been bound to a pathname using
-- 
1.6.1
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
