From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: fix potential huge kmalloc() calls in
 TCP_REPAIR
Date: Thu, 19 Nov 2015 04:31:32 -0800
Message-ID: <1447936292.22599.199.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447909413.22599.191.camel@edumazet-glaptop2.roam.corp.google.com>
	 <564DA9AD.80400@parallels.com>
	 <1447935955.22599.195.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36365 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758550AbbKSMbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 07:31:34 -0500
Received: by pacdm15 with SMTP id dm15so80201472pac.3
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 04:31:33 -0800 (PST)
In-Reply-To: <1447935955.22599.195.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-11-19 at 04:25 -0800, Eric Dumazet wrote:
> On Thu, 2015-11-19 at 13:51 +0300, Pavel Emelyanov wrote:
> > On 11/19/2015 08:03 AM, Eric Dumazet wrote:
> > > From: Eric Dumazet <edumazet@google.com>
> > > 
> > > tcp_send_rcvq() is used for re-injecting data into tcp receive queue.
> > > 
> > > Problems :
> > > 
> > > - No check against size is performed, allowed user to fool kernel in
> > >   attempting very large memory allocations, eventually triggering
> > >   OOM when memory is fragmented.
> > 
> > Doesn't the tcp_try_rmem_schedule() protect us from doing this "eventually"?
> > I mean first we would be allowed to do it, but then the sock will be charged
> > with the previous allocations and will not add more memory to socket.
> 
> But this tcp_try_rmem_schedule() is done _after_ allocation was
> attempted. This is too late :(

Simple reproducer allocating 2 Mbytes of contiguous kernel memory :

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/tcp.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

static void fail(const char *str)
{
        perror(str);
        exit(1);
}

void usage(int code)
{
        exit(1);
}

int main(int argc, char *argv[])
{
        int res, c, repair = 1;
        int queue = TCP_RECV_QUEUE;
        int fd = socket(AF_INET, SOCK_STREAM, 0);
        size_t sz = 2*1024*1024 - 1024;
        char *buffer;
        struct sockaddr_in src, dst;

        while ((c = getopt(argc, argv, "m:")) != -1) {
                switch (c) {
                case 'm' :
                        sz = atoi(optarg);
                        break;
                default : usage(1);
                }
        }
        if (setsockopt(fd, SOL_TCP, TCP_REPAIR, &repair, sizeof(repair)) == -1)
                fail("TCP_REPAIR");
        memset(&src, 0, sizeof(src));
        src.sin_family = AF_INET;
        src.sin_port = htons(8888);
        src.sin_addr.s_addr = htonl(0x7f000001);
        if (bind(fd, (struct sockaddr *)&src, sizeof(src)) == -1)
                fail("bind");
        memset(&dst, 0, sizeof(dst));
        dst.sin_family = AF_INET;
        dst.sin_port = htons(9999);
        dst.sin_addr.s_addr = htonl(0x7f000001);
        if (connect(fd, (struct sockaddr *)&dst, sizeof(dst)) == -1)
                fail("connect");
        if (setsockopt(fd, SOL_TCP, TCP_REPAIR_QUEUE, &queue, sizeof(queue)) == -1)
                fail("TCP_REPAIR_QUEUE");
        buffer = malloc(sz);
        if (!buffer)
                buffer = malloc(1000);
        res = send(fd, buffer, sz, 0);
        printf("send() res=%d errno=%d\n", res, errno);
        if (res != -1)
                sleep(1000);
        return 0;
} 
