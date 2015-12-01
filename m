From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [RFC PATCH] af_unix: fix entry locking in unix_dgram_recvmsg
Date: Tue, 01 Dec 2015 17:02:33 +0000
Message-ID: <871tb6nlue.fsf@doppelsaurus.mobileactivedefense.com>
References: <87h9k41pyq.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:35047 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756163AbbLARCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 12:02:45 -0500
In-Reply-To: <87h9k41pyq.fsf@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Sun, 29 Nov 2015 20:59:57 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rainer Weikusat <rw@doppelsaurus.mobileactivedefense.com> writes:

[...]

> Insofar I understand the comment in this code block correctly,
>
>         err = mutex_lock_interruptible(&u->readlock);
>         if (unlikely(err)) {
>                 /* recvmsg() in non blocking mode is supposed to return -EAGAIN
>                  * sk_rcvtimeo is not honored by mutex_lock_interruptible()
>                  */
>                 err = noblock ? -EAGAIN : -ERESTARTSYS;
>                 goto out;
>         }
>
> setting a receive timeout for an AF_UNIX datagram socket also doesn't
> work as intended because of this: In case of n readers with the same
> timeout, the nth reader will end up blocking n times the timeout.

Test program which confirms this. It starts four concurrent reads on the
same socket with a receive timeout of 3s. This means the whole program
should take a little more than 3s to execute as each read should time
out at about the same time. But it takes 12s instead as the reads
pile up on the readlock mutex and each then gets its own timeout once it
could enter the receive loop.

-------
#include <stdio.h>
#include <sys/signal.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <sys/un.h>
#include <sys/wait.h>
#include <unistd.h>

#define SERVER_ADDR	"\0multi-timeout"
#define RCV_TIMEO	3

static void set_rcv_timeo(int sk)
{
    struct timeval tv;

    tv.tv_sec = RCV_TIMEO;
    tv.tv_usec = 0;
    setsockopt(sk, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
}

int main(void)
{
    struct sockaddr_un sun;
    struct timeval tv_start, tv_end;
    int sk, dummy;
    
    sun.sun_family = AF_UNIX;
    memcpy(sun.sun_path, SERVER_ADDR, sizeof(SERVER_ADDR));
    sk = socket(AF_UNIX, SOCK_DGRAM, 0);
    bind(sk, (struct sockaddr *)&sun, sizeof(sun));
    set_rcv_timeo(sk);

    gettimeofday(&tv_start, NULL);
    
    if (fork() == 0) {
	read(sk, &dummy, sizeof(dummy));
	_exit(0);
    }
    
    if (fork() == 0) {
	read(sk, &dummy, sizeof(dummy));
	_exit(0);
    }
    
    if (fork() == 0) {
	read(sk, &dummy, sizeof(dummy));
	_exit(0);
    }

    read(sk, &dummy, sizeof(dummy));
    
    while (waitpid(-1, NULL, 0) > 0);

    gettimeofday(&tv_end, NULL);
    printf("Waited for %u timeouts\n",
	   (unsigned)((tv_end.tv_sec - tv_start.tv_sec) / RCV_TIMEO));
    
    return 0;
}
