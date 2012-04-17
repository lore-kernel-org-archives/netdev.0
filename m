From: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [patch] Fix handling of overlength pathname in AF_UNIX sun_path
Date: Tue, 17 Apr 2012 22:44:15 +1200
Message-ID: <4F8D497F.8060601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Tetsuo Handa <penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>, Willy Tarreau <w@1wt.eu>,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
To: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa sent me a patch to document the kernel's odd 
behavior when asked to create a UNIX domain socket address where the 
pathname completely fills the sun_path field without including a null 
terminator [1]. 

One of the consequences of the current kernel behavior is that 
when a socket address is returned to userspace (via getsockname(), 
getpeername(), accept(), recvfrom()), applications can't reliably 
do things such as:

printf("%s\n", addr.sun_path);

Instead one must either write:

printf("%.*s\n", sizeof(addr.sun_path), addr.sun_path);

or, when retrieving a socket address structure, employ a buffer whose
size is:

sizeof(struct sockaddr_un) + 1

(This ensures that there is enough space to hold the null terminator
for the case where a socket was bound to a sun_path with non-NUL characters
in all 108 bytes. But it entails some casting.)

Tetsuo initially considered there might be a kernel bug here, 
but an attempt to change the kernel behavior met resistance [2].

The patch at the end of this message is a slightly different 
fix for the same problem. There are a few reasons why I think 
it (or some variation) should be considered:

1. Changing the kernel behavior prevents userspace having 
   to go through the sort of contortions described above
   in order to handle the 108-non-NUL-bytes-in-sun_path case.
2. POSIX says that sun_path is a pathname. By (POSIX) definition, 
   a pathname is null terminated.
3. Considering these two sets:

   (a) [applications that rely on the assumption that there
        is a null terminator inside sizeof(sun_path) bytes]
   (b) [applications that would break if the kernel behavior changed]

   I suspect that set (a) is rather larger than set (b)--or, more 
   likely still, applications ensure they go for the lowest common
   denominator limit of 92 (HP-UX) or 104 (historical BSD limit)
   bytes, and so avoid this issue completely.

The accompanying patch changes unix_mkname() to ensure that a terminating 
null byte is always located within the first 108 bytes of sun_path. 
It does change the ABI for the former case where a pathname ran to 108
bytes without a null terminator: for that case, the call now fails with
the error -EINVAL. What are people's thoughts on applying this?

[1] http://thread.gmane.org/gmane.linux.network/174473/focus=1861
[2] http://thread.gmane.org/gmane.linux.kernel/291038

Signed-off-by: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

---

--- net/unix/af_unix.c.orig	2012-04-17 09:50:07.383459311 +1200
+++ net/unix/af_unix.c	2012-04-17 19:49:56.077852639 +1200
@@ -207,14 +207,16 @@ static int unix_mkname(struct sockaddr_u
 	if (!sunaddr || sunaddr->sun_family != AF_UNIX)
 		return -EINVAL;
 	if (sunaddr->sun_path[0]) {
-		/*
-		 * This may look like an off by one error but it is a bit more
-		 * subtle. 108 is the longest valid AF_UNIX path for a binding.
-		 * sun_path[108] doesn't as such exist.  However in kernel space
-		 * we are guaranteed that it is a valid memory location in our
-		 * kernel address buffer.
-		 */
-		((char *)sunaddr)[len] = 0;
+		if (len == sizeof(*sunaddr)) {
+			/*
+			 * If 'sun_path' is completely filled, the user
+			 * must include a terminator
+			 */
+			if (!memchr(sunaddr->sun_path, '\0',
+					sizeof(sunaddr->sun_path)))
+				return -EINVAL;
+		} else
+			((char *)sunaddr)[len] = 0;
 		len = strlen(sunaddr->sun_path)+1+sizeof(short);
 		return len;
 	}
