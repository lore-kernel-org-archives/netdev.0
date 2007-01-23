From: dean gaudet <dean@arctic.org>
Subject: why would EPIPE cause socket port to change?
Date: Mon, 22 Jan 2007 20:01:05 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0701221954250.11520@twinlark.arctic.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from twinlark.arctic.org ([207.29.250.54]:38461 "EHLO
	twinlark.arctic.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932991AbXAWEBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jan 2007 23:01:06 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

in the test program below the getsockname result on a TCP socket changes 
across a write which produces EPIPE... here's a fragment of the strace:

getsockname(3, {sa_family=AF_INET, sin_port=htons(37636), sin_addr=inet_addr("127.0.0.1")}, [17863593746633850896]) = 0
...
write(3, "hi!\n", 4)                    = 4
write(3, "hi!\n", 4)                    = -1 EPIPE (Broken pipe)
--- SIGPIPE (Broken pipe) @ 0 (0) ---
getsockname(3, {sa_family=AF_INET, sin_port=htons(59882), sin_addr=inet_addr("127.0.0.1")}, [16927060683038654480]) = 0

why does the port# change?  this is on 2.6.19.1.

(fwiw this is one of two reasons i've found for libnss-ldap to leak 
sockets... causing nscd to crash.)

-dean

reproduce like:

make test-sockname-change
nc -l -p 9999 -c "exit 0" &
strace ./test-sockname-change 127.0.0.1 9999

--- snip ---

#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <stdlib.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/uio.h>
#include <errno.h>
#include <signal.h>
#include <fcntl.h>

#ifndef INADDR_NONE
#define INADDR_NONE (-1ul)
#endif

int main(int argc, char **argv)
{
  struct sockaddr_in server_addr;
  struct sockaddr_in before, after;
  socklen_t slen;
  int s;
  struct iovec vector[3];
  char buf[100];
  int i;
  const int just_say_no = 1;

  if (argc != 3) {
usage:
    fprintf(stderr, "usage: test-sigpipe a.b.c.d port#\n");
    exit(1);
  }
  server_addr.sin_family = AF_INET;
  server_addr.sin_addr.s_addr = inet_addr(argv[1]);
  if (server_addr.sin_addr.s_addr == INADDR_NONE) {
    fprintf(stderr, "bogus address\n");
    goto usage;
  }
  server_addr.sin_port = htons(atoi(argv[2]));

  s = socket(AF_INET, SOCK_STREAM, 0);
  if (s < 0) {
    perror("socket");
    exit(1);
  }
  if (connect(s, (struct sockaddr *)&server_addr, sizeof(server_addr)) != 0) {
    perror("connect");
    exit(1);
  }

  if (setsockopt(s, IPPROTO_TCP, TCP_NODELAY, (char*)&just_say_no, sizeof(just_say_no)) != 0) {
    perror( "TCP_NODELAY" );
    exit(1);
  }

  fcntl(s, F_SETFL, fcntl(s, F_GETFL) | O_NONBLOCK);

  slen = sizeof(before);
  if (getsockname(s, (struct sockaddr *)&before, &slen)) {
    perror("getsockname before");
  }

  signal(SIGPIPE, SIG_IGN);

  sleep(1);

  do {
    i = write(s, "hi!\n", 4);
  } while (i >= 0);
  if (errno != EPIPE) {
    fprintf(stderr, "was expecting EPIPE from write\n");
    exit(1);
  }

  slen = sizeof(after);
  if (getsockname(s, (struct sockaddr *)&after, &slen)) {
    perror("getsockname after");
  }

  printf("before = %d, after = %d\n", ntohs(before.sin_port), ntohs(after.sin_port));

  return 0;
}
