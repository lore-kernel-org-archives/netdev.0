From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Fri, 23 Oct 2015 09:00:11 -0700
Message-ID: <1445616011.22974.158.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151021185104.GM22011@ZenIV.linux.org.uk>
	 <20151021.182955.1434243485706993231.davem@davemloft.net>
	 <5628636E.1020107@oracle.com> <20151022044458.GP22011@ZenIV.linux.org.uk>
	 <20151022060304.GQ22011@ZenIV.linux.org.uk>
	 <201510220634.t9M6YJLD017883@room101.nl.oracle.com>
	 <20151022172146.GS22011@ZenIV.linux.org.uk>
	 <201510221824.t9MIOp6n003978@room101.nl.oracle.com>
	 <20151022190701.GV22011@ZenIV.linux.org.uk>
	 <201510221951.t9MJp5LC005892@room101.nl.oracle.com>
	 <20151022215741.GW22011@ZenIV.linux.org.uk>
	 <201510230952.t9N9qYZJ021998@room101.nl.oracle.com>
	 <1445605340.22974.140.camel@edumazet-glaptop2.roam.corp.google.com>
	 <562A37A3.8000705@oracle.com>
	 <1445610118.22974.153.camel@edumazet-glaptop2.roam.corp.google.com>
	 <562A563D.6020600@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Casper.Dik@oracle.com, Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:32941 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977AbbJWQAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 12:00:13 -0400
Received: by pabrc13 with SMTP id rc13so121553236pab.0
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 09:00:13 -0700 (PDT)
In-Reply-To: <562A563D.6020600@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-10-23 at 16:46 +0100, Alan Burlison wrote:
> On 23/10/2015 15:21, Eric Dumazet wrote:
> 
> > I claim nothing. If you believe a man page should be fixed, please send
> > a patch to man page maintainer.
> 
> Ermm, you *really* want me to submit a patch removing 'Conforms to 
> POSIX.1-2001' from *every* Linux manpage?

Only on the pages you think there is an error that matters.

> 
> > Have you tested the patch I sent ?
> 
> The AF_UNIX poll one? No, I don't have the means to do so, and in any 
> case that's not a POSIX issue, just a plain bug. I'm happy to log a bug 
> if that helps.

We submit patches when someone needs a fix.

If not, we have more urgent issues to solve first.

I wrote following test case, and confirmed the patch fixes the issue.

I will submit it formally.

Thanks.

#include <pthread.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <poll.h>

static void fail(const char *str)
{
	perror(str);
	printf("FAIL\n");
	exit(1);
}

int main(int argc, char *argv[])
{
	int listener = socket(AF_UNIX, SOCK_STREAM, 0);
	struct pollfd pfd;
	struct sockaddr_un addr;
	int res;

	if (listener == -1)
		perror("socket()");
	memset(&addr, 0, sizeof(addr));
	addr.sun_family = AF_UNIX;
	if (bind(listener, (struct sockaddr *)&addr, sizeof(addr)) == -1)
		fail("bind()");  
	if (listen(listener, 10) == -1)
		fail("listen()");
	pfd.fd = listener;
	pfd.events = -1;
	res = poll(&pfd, 1, 10);
	if (res == -1)
		fail("poll()");
	if (res == 1 && pfd.revents & (POLLOUT|POLLWRNORM|POLLWRBAND)) {
		fprintf(stderr, "poll(af_unix listener) returned a POLLOUT status !\n");
		printf("FAIL\n");
		return 1;
	}
	printf("OK\n");
	return 0;
}
