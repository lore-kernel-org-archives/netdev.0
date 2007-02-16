From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Fw: [Bug 8013] New: select for write hangs on a socket after write returned ECONNRESET
Date: Fri, 16 Feb 2007 18:25:57 +0300
Message-ID: <20070216152557.GA20641@2ka.mipt.ru>
References: <20070215160405.3bd30b05@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="vkogqOf2sHV7VnPd"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:37121 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945916AbXBPP0K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 10:26:10 -0500
Content-Disposition: inline
In-Reply-To: <20070215160405.3bd30b05@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--vkogqOf2sHV7VnPd
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline

On Thu, Feb 15, 2007 at 04:04:05PM -0800, Stephen Hemminger (shemminger@linux-foundation.org) wrote:
> Someone want to take a stab at fixing this??

Works for me with attached application - select on connreset socket
immediately returns one ready descriptor.

$ ./a.out 192.168.0.48 22
select: err: 1, errno: 0.
write: err: 128, errno: 0.
select: err: 1, errno: 0.
write: err: 128, errno: 0.
select: err: 1, errno: 0.
write: err: -1, errno: 104.
on exit: select: err: 1, errno: 104.

-- 
	Evgeniy Polyakov

--vkogqOf2sHV7VnPd
Content-Type: text/plain; charset=koi8-r
Content-Disposition: attachment; filename="select.c"

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/resource.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/poll.h>
#include <sys/sendfile.h>

#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <fcntl.h>
#include <time.h>
#include <ctype.h>
#include <netdb.h>

#define ulog(f, a...) fprintf(stderr, f, ##a)
#define ulog_err(f, a...) ulog(f ": %s [%d].\n", ##a, strerror(errno), errno)

int main(int argc, char *argv[])
{
	struct hostent *h;
	int s, err;
	char buf[128];
	struct sockaddr_in sa;
	fd_set rfds;
	struct timeval tv;

	if (argc != 3) {
		ulog("Usage: %s <addr> <port>\n", argv[0]);
		return -1;
	}
	
	h = gethostbyname(argv[1]);
	if (!h) {
		ulog_err("%s: Failed to get address of %s.\n", __func__, argv[1]);
		return -1;
	}

	s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (s == -1) {
		ulog_err("%s: Failed to create server socket", __func__);
		return -1;
	}
	
	memcpy(&(sa.sin_addr.s_addr), h->h_addr_list[0], 4);
	sa.sin_port = htons(atoi(argv[2]));
	sa.sin_family = AF_INET;

	if (connect(s, (struct sockaddr *)&sa, sizeof(sa))) {
		ulog_err("%s: Failed to connect to %s:%s", __func__, argv[1], argv[2]);
		return -1;
	}

	do {
		FD_ZERO(&rfds);
		FD_SET(s, &rfds);

		tv.tv_sec = 500;
		tv.tv_usec = 0;

		err = select(s+1, &rfds, NULL, NULL, &tv);
		ulog("select: err: %d, errno: %d.\n", err, errno);

		err = write(s, buf, sizeof(buf));
		ulog("write: err: %d, errno: %d.\n", err, errno);
	} while (err > 0);

	FD_ZERO(&rfds);
	FD_SET(s, &rfds);

	tv.tv_sec = 500;
	tv.tv_usec = 0;

	err = select(s+1, &rfds, NULL, NULL, &tv);

	ulog("on exit: select: err: %d, errno: %d.\n", err, errno);
}

--vkogqOf2sHV7VnPd--
