From: Florian Weimer <fweimer@redhat.com>
Subject: Re: [net-next PATCH 2/3] net: reduce cycles spend on ICMP replies
 that gets rate limited
Date: Sun, 4 Jun 2017 09:11:53 +0200
Message-ID: <7d432179-5e3a-febe-ced7-39ea33ba4906@redhat.com>
References: <20170109150246.30215.63371.stgit@firesoul>
 <20170109150409.30215.34612.stgit@firesoul>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------083A8560C1B3F9B1A2444FC1"
Cc: xiyou.wangcong@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55580 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750847AbdFDHL6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 4 Jun 2017 03:11:58 -0400
In-Reply-To: <20170109150409.30215.34612.stgit@firesoul>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------083A8560C1B3F9B1A2444FC1
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

On 01/09/2017 04:04 PM, Jesper Dangaard Brouer wrote:
> This patch split the global and per (inet)peer ICMP-reply limiter
> code, and moves the global limit check to earlier in the packet
> processing path.  Thus, avoid spending cycles on ICMP replies that
> gets limited/suppressed anyhow.
> 
> The global ICMP rate limiter icmp_global_allow() is a good solution,
> it just happens too late in the process.  The kernel goes through the
> full route lookup (return path) for the ICMP message, before taking
> the rate limit decision of not sending the ICMP reply.
> 
> Details: The kernels global rate limiter for ICMP messages got added
> in commit 4cdf507d5452 ("icmp: add a global rate limitation").  It is
> a token bucket limiter with a global lock.  It brilliantly avoids
> locking congestion by only updating when 20ms (HZ/50) were elapsed. It
> can then avoids taking lock when credit is exhausted (when under
> pressure) and time constraint for refill is not yet meet.

This patch removed the rate limit bypass for localhost.  As a result, it
is impossible to write deterministic UDP client tests tests which
exercise failover behavior in response to unreachable servers.

H.J. Lu noted that a glibc test started failing on kernel 4.11 and
identified the regression:

  https://sourceware.org/ml/libc-alpha/2017-06/msg00167.html

(I have more tests which are afflicted by this, but are not yet in glibc
upstream.)

This is particularly annoying because we already run such tests in a
network namespace for isolation, but the rate limit counter is global,
so that doesn't help here.

I'm attaching a self-contained test case.  It fails for me with:

localhost-icmp: iteration 50: no ICMP message (poll timeout)

On kernel 4.10, it passes and runs within just a few milliseconds.

Would you please fix this in some way?  Thanks.

Florian

--------------083A8560C1B3F9B1A2444FC1
Content-Type: text/x-csrc;
 name="localhost-icmp.c"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="localhost-icmp.c"

#include <arpa/inet.h>
#include <err.h>
#include <netinet/in.h>
#include <stdio.h>
#include <sys/poll.h>
#include <sys/socket.h>
#include <unistd.h>

/* How many UDP packets to send to a non-responding part.  */
enum { ITERATIONS =3D 1000 };

int
main (void)
{
  /* Pick a port number which is likely unused.  */
  unsigned short port;
  {
    int sock =3D socket (AF_INET, SOCK_DGRAM, 0);
    if (sock < 0)
      err (1, "socket");
    struct sockaddr_in sin =3D { .sin_family =3D AF_INET };
    if (bind (sock, (struct sockaddr *) &sin, sizeof (sin)) < 0)
      err (1, "bind");
    socklen_t sinlen =3D sizeof (sin);
    if (getsockname (sock, (struct sockaddr *) &sin, &sinlen))
      err (1, "getsockname");
    if (sinlen !=3D sizeof (sin) || sin.sin_family !=3D AF_INET)
      errx (1, "wrong address information for socket");
    if (close (sock) < 0)
      err (1, "close");
    port =3D sin.sin_port;
  }

  for (int i =3D 0; i < ITERATIONS; ++i)
    {
      int sock =3D socket (AF_INET, SOCK_DGRAM, 0);
      if (sock < 0)
        err (1, "socket");
      struct sockaddr_in sin =3D
        {
          .sin_family =3D AF_INET,
          .sin_addr =3D { ntohl (INADDR_LOOPBACK) },
          .sin_port =3D port,
        };
      if (connect (sock, (struct sockaddr *) &sin, sizeof (sin)) < 0)
        err (1, "connect");
      if (sendto (sock, "", 1, 0, NULL, 0) < 0)
        err (1, "sendto");
      struct pollfd fd =3D { .fd =3D sock, .events =3D POLLIN };
      int ret =3D poll (&fd, 1, 5000);
      if (ret < 0)
        err (1, "poll");
      if (ret =3D=3D 0)
        errx (1, "iteration %d: no ICMP message (poll timeout)", i);
      if (close (sock) < 0)
        err (1, "close");
    }
}

--------------083A8560C1B3F9B1A2444FC1--
