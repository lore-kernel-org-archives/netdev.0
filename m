From: Alan Curry <rlwinm@sdf.org>
Subject: Re: PROBLEM: network data corruption (bisected to e5a4b0bb803b)
Date: Tue, 26 Jul 2016 04:57:03 +0000 (UTC)
Message-ID: <201607260457.u6Q4v3pM010082@sdf.org>
References: <20160724190237.GP2356@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Christian Lamparter <chunkeey@googlemail.com>,
	Alan Curry <rlwinm@sdf.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	alexmcwhirter@triadic.us
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.sdf.org ([192.94.73.20]:51537 "EHLO sdf.lonestar.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755236AbcGZE5b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 00:57:31 -0400
In-Reply-To: <20160724190237.GP2356@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Al Viro wrote:
> On Sun, Jul 24, 2016 at 07:45:13PM +0200, Christian Lamparter wrote:
> 
> > > The symptom is that downloaded files (http, ftp, and probably other
> > > protocols) have small corrupted segments (about 1-2 kilobytes long) in
> > > random locations. Only downloads that sustain a high speed for at least a
> > > few seconds are corrupted. Anything small enough to be received in less
> > > than about 5 seconds is not affected.
> 
> Can that sucker be reproduced with netcat?  That would eliminate all issues
> with multi-iovec recvmsg(2), narrowing the things down quite bit.

netcat seems to be immune. Comparing strace results, I didn't see any
recvmsg() calls in the other programs that have had the problem, but there
is an interesting difference: netcat calls select() to wait for the socket
to be ready for reading, where my other test programs just call read() and
let it block until ready.

So I wrote a small test program to isolate that difference. It downloads
a file using only read() and write() and a hardcoded HTTP request. It has
a select mode (main loop alternates read() and select() on the TCP socket)
and a noselect mode (main loop just read()s the TCP socket).

The program is included at the bottom of this message.

I ran it several times in both modes and got corruption if and only if the
noselect mode was used.

> 
> Another thing (and if that works, it's *NOT* a proper fix - it would be
> papering over the problem, but at least it would show where to look for
> it) - try (on top of mainline) the following delta:
> 
> diff --git a/net/core/datagram.c b/net/core/datagram.c

Will try that patch soon. Meanwhile, here's my test:

/* Demonstration program "dlbug".
   Usage: dlbug select > outfile
          or
          dlbug noselect > outfile
   outfile will contain the full HTTP response. Edit out the HTTP headers
   and what's left should be a valid gzip if the download worked. */

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <sys/select.h>

int main(int argc, char **argv)
{
  const char *request =
    "GET /debian/dists/stable/main/Contents-amd64.gz HTTP/1.0\r\n"
    "Host: ftp.us.debian.org\r\n"
    "\r\n";
  ssize_t request_len = strlen(request), w, r, copied;
  struct addrinfo hints, *host;
  int sock, err, doselect;
  char buf[10240];

  if(argc!=2 || (!strcmp(argv[1], "select") && !strcmp(argv[1], "noselect"))) {
    fprintf(stderr, "Usage: %s {select|noselect}\n", argv[0]);
    return 1;
  }

  doselect = !strcmp(argv[1], "select");

  memset(&hints, 0, sizeof hints);
  hints.ai_family = AF_INET;
  hints.ai_socktype = SOCK_STREAM;

  err = getaddrinfo("ftp.us.debian.org", 0, &hints, &host);
  if(err) {
    fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(err));
    return 1;
  }

  sock = socket(host->ai_family, host->ai_socktype, host->ai_protocol);
  if(sock < 0) {
    perror("socket");
    return 1;
  }

  ((struct sockaddr_in *)host->ai_addr)->sin_port = htons(80);

  if(connect(sock, host->ai_addr, host->ai_addrlen) < 0) {
    perror("connect");
    return 1;
  }

  while(request_len) {
    w = write(sock, request, request_len);
    if(w < 0) {
      perror("write to socket");
      return 1;
    }
    request += w;
    request_len -= w;
  }

  while((r = read(sock, buf, sizeof buf))) {
    if(r < 0) {
      perror("read from socket");
      return 1;
    }

    copied = 0;
    while(copied < r) {
      w = write(1, buf+copied, r-copied);
      if(w < 0) {
        perror("write to stdout");
        return 1;
      }
      copied += w;
    }

    if(doselect) {
      fd_set rfds;
      FD_ZERO(&rfds);
      FD_SET(sock, &rfds);
      select(sock+1, &rfds, 0, 0, 0);
    }
  }

  return 0;
}

-- 
Alan Curry
