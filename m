From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Question on UNIX domain socket.
Date: Tue, 26 Oct 2010 21:15:25 +0900
Message-ID: <201010262115.FEH09326.OMFJHSVOFLQFOt@I-love.SAKURA.ne.jp>
References: <AANLkTimtTazMmDvQFgASsVGa=AYvPZqUaUmyg5p7VVY1@mail.gmail.com>
	<201010171428.DDC17187.FFFJSLtOOHOMQV@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: mtk.manpages@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:61347 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933006Ab0JZMP3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Oct 2010 08:15:29 -0400
In-Reply-To: <201010171428.DDC17187.FFFJSLtOOHOMQV@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Is the latest manpage for UNIX domain socket is at
http://www.kernel.org/doc/man-pages/online/pages/man7/unix.7.html ?

I got a question. Above page says

   pathname: a UNIX domain socket can be bound to a null-terminated file
   system pathname using bind(2).  When the address of the socket is returned
   by getsockname(2), getpeername(2), and accept(2), its length is
   offsetof(struct sockaddr_un, sun_path) + strlen(sun_path) + 1, and sun_path
   contains the null-terminated pathname.

However, running below program results in
"sun_path *not* containing the null-terminated pathname" (and therefore it is
not safe to use printf("%s", sun_path) even if sun_path[0] != '\0').

Should "sun_path contains the null-terminated pathname" be corrected?

Regards.

----- Test program start -----
#include <stdio.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
	union {
		struct sockaddr_un addr;
		char buf[512];
	} u;
	socklen_t len = sizeof(u.addr);
	int fd = socket(PF_UNIX, SOCK_STREAM, 0);
	u.addr.sun_family = AF_UNIX;
	snprintf(u.addr.sun_path, sizeof(u.buf) - 2, "/"
		 "1234567890123456789012345678901234567890"
		 "1234567890123456789012345678901234567890"
		 "1234567890123456789012345678901234567890"
		 "1234567890123456789012345678901234567890");
	if (bind(fd, (struct sockaddr *) &u.addr, sizeof(u.addr)) == EOF)
		return 1;
	memset(&u, 0, sizeof(u)); /* You may comment out this line. */
	printf("len=%d\n", len);
	if (getsockname(fd, (struct sockaddr *) &u.addr, &len) == EOF)
		return 1;
	printf("strlen=%d len=%d\n", strlen(u.addr.sun_path), len);
	return 0;
}
----- Test program end -----

----- Output of test program -----
len=110
strlen=108 len=111
