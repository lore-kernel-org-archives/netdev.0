From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: EINVAL when using connect() for udp sockets
Date: Wed, 22 Mar 2017 22:18:07 -0700
Message-ID: <1490246287.16816.201.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAEnbY+cYpX8naDpRkXgwCP=i64AwWgK9=_7AacmYip-ykot7mQ@mail.gmail.com>
         <CAEnbY+fPLamzXF8nOF-SEFE8LaE88XAyKNt81zs6bM866R4oGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, William Ahern <william@25thandclement.com>,
        "Santi T." <santitm99@gmail.com>
To: Daurnimator <quae@daurnimator.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35394 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932117AbdCWIFs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 04:05:48 -0400
Received: by mail-pf0-f196.google.com with SMTP id n11so19173282pfg.2
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 01:05:47 -0700 (PDT)
In-Reply-To: <CAEnbY+fPLamzXF8nOF-SEFE8LaE88XAyKNt81zs6bM866R4oGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-03-23 at 13:22 +1100, Daurnimator wrote:
> On 9 March 2017 at 14:10, Daurnimator <quae@daurnimator.com> wrote:
> > When debugging https://github.com/daurnimator/lua-http/issues/73 which
> > uses https://github.com/wahern/dns we ran into an issue where modern
> > linux kernels return EINVAL if you try and re-use a udp socket.
> > The issue seems to occur if you go from a local destination ip to a
> > non-local one.
> 
> Did anyone get a chance to look into this issue?

I believe man page is not complete.

A disconnect is needed before another connect()

eg :

#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <netinet/ip.h>
#include <arpa/inet.h>
#include <errno.h>

int main() {
    int fd = socket(PF_INET, SOCK_DGRAM|SOCK_CLOEXEC|SOCK_NONBLOCK, IPPROTO_IP);
    if (fd == -1)
        exit(1);
    if (bind(fd, (struct sockaddr*)&(struct
sockaddr_in){.sin_family=AF_INET, .sin_port=htons(57997),
.sin_addr=inet_addr("0.0.0.0")}, 16))
        exit(2);
    if (connect(fd, (struct sockaddr*)&(struct
sockaddr_in){.sin_family=AF_INET, .sin_port=htons(53),
.sin_addr=inet_addr("127.0.0.2")}, 16))
        exit(3);
    if (-1 == sendto(fd, "test", 4, 0, NULL, 0))
        exit(4);
    char buf[200];
    if (-1 != recvfrom(fd, buf, 200, 0, 0, 0) && errno != ECONNREFUSED)
        exit(5);
    /* okay, try next server... */

/* disconnect */
    if (connect(fd, (struct sockaddr*)&(struct sockaddr_in){.sin_family=AF_UNSPEC}, 16))
	exit(6);

    if (connect(fd, (struct sockaddr*)&(struct
sockaddr_in){.sin_family=AF_INET, .sin_port=htons(53),
.sin_addr=inet_addr("8.8.8.8")}, 16))
        exit(7);
    exit(0);
}
