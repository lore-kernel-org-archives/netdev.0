From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] unix: avoid use-after-free in ep_remove_wait_queue (w/ Fixes:)
Date: Wed, 18 Nov 2015 18:15:27 +0000
Message-ID: <87ziyb6uo0.fsf@doppelsaurus.mobileactivedefense.com>
References: <87a8qhspfm.fsf@doppelsaurus.mobileactivedefense.com>
	<876111wpza.fsf@doppelsaurus.mobileactivedefense.com>
	<87ziydvasn.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<20151117.151421.249423864481324472.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rweikusat@mobileactivedefense.com, jbaron@akamai.com,
	dvyukov@google.com, syzkaller@googlegroups.com, mkubecek@suse.cz,
	viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, hannes@stressinduktion.org,
	dhowells@redhat.com, paul@paul-moore.com, salyzyn@android.com,
	sds@tycho.nsa.gov, ying.xue@windriver.com, netdev@vger.kernel.org,
	kcc@google.com, glider@google.com, andreyknvl@google.com,
	sasha.levin@oracle.com, jln@google.com, keescook@google.com,
	minipli@googlemail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151117.151421.249423864481324472.davem@davemloft.net> (David
	Miller's message of "Tue, 17 Nov 2015 15:14:21 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:
> From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
> Date: Mon, 16 Nov 2015 22:28:40 +0000
>
>> An AF_UNIX datagram socket being the client in an n:1

[...]

> So because of a corner case of epoll handling and sender socket release,
> every single datagram sendmsg has to do a double lock now?
>
> I do not dispute the correctness of your fix at this point, but that
> added cost in the fast path is really too high.

Some more information on this: Running the test program included below
on my 'work' system (otherwise idle, after logging in via VT with no GUI
running)/ quadcore AMD A10-5700, 3393.984 for 20 times/ patched 4.3 resulted in the
following throughput statistics[*]:

avg		13.617  M/s
median		13.393  M/s
max		17.14   M/s
min		13.047  M/s
deviation	0.85

I'll try to post the results for 'unpatched' later as I'm also working
on a couple of other things.

[*] I do not use my fingers for counting, hence, these are binary and
not decimal units.

------------
#include <inttypes.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <sys/wait.h>
#include <unistd.h>

enum {
    MSG_SZ =	16,
    MSGS =	1000000
};

static char msg[MSG_SZ];

static uint64_t tv2u(struct timeval *tv)
{
    uint64_t u;

    u = tv->tv_sec;
    u *= 1000000;
    return u + tv->tv_usec;
}

int main(void)
{
    struct timeval start, stop;
    uint64_t t_diff;
    double rate;
    int sks[2];
    unsigned remain;
    char buf[MSG_SZ];

    socketpair(AF_UNIX, SOCK_SEQPACKET, 0, sks);

    if (fork() == 0) {
	close(*sks);
	
	gettimeofday(&start, 0);
	while (read(sks[1], buf, sizeof(buf)) > 0);
	gettimeofday(&stop, 0);

	t_diff = tv2u(&stop);
	t_diff -= tv2u(&start);
	rate = MSG_SZ * MSGS;
	rate /= t_diff;
	rate *= 1000000;
	printf("rate %fM/s\n", rate / (1 << 20));

	fflush(stdout);
	_exit(0);
    }

    close(sks[1]);
    
    remain = MSGS;
    do write(*sks, msg, sizeof(msg)); while (--remain);
    close(*sks);

    wait(NULL);
    return 0;
}
