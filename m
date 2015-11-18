From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: more statistics (was: [PATCH] unix: avoid use-after-free in ep_remove_wait_queue (w/ Fixes:))
Date: Wed, 18 Nov 2015 23:39:32 +0000
Message-ID: <87wpteq3m3.fsf_-_@doppelsaurus.mobileactivedefense.com>
References: <87a8qhspfm.fsf@doppelsaurus.mobileactivedefense.com>
	<876111wpza.fsf@doppelsaurus.mobileactivedefense.com>
	<87ziydvasn.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<20151117.151421.249423864481324472.davem@davemloft.net>
	<87ziyb6uo0.fsf@doppelsaurus.mobileactivedefense.com>
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
In-Reply-To: <87ziyb6uo0.fsf@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Wed, 18 Nov 2015 18:15:27 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rainer Weikusat <rw@doppelsaurus.mobileactivedefense.com> writes:

[...]

> Some more information on this: Running the test program included below
> on my 'work' system (otherwise idle, after logging in via VT with no GUI
> running)/ quadcore AMD A10-5700, 3393.984 for 20 times/ patched 4.3 resulted in the
> following throughput statistics[*]:

Since the results were too variable with only 20 runs, I've also tested
this with 100 for three kernels, stock 4.3, 4.3 plus the published
patch, 4.3 plus the published patch plus the "just return EAGAIN"
modification". The 1st and the 3rd perform about identical for the
test program I used (slightly modified version included below), the 2nd
is markedly slower. This is most easily visible when grouping the
printed data rates (B/s) 'by millions':

stock 4.3
---------
13000000.000-13999999.000       3       (3%)
14000000.000-14999999.000       82      (82%)
15000000.000-15999999.000       15      (15%)


4.3 + patch
-----------
13000000.000-13999999.000       54      (54%)
14000000.000-14999999.000       35      (35%)
15000000.000-15999999.000       7       (7%)
16000000.000-16999999.000       1       (1%)
18000000.000-18999999.000       1       (1%)
22000000.000-22999999.000       2       (2%)


4.3 + modified patch
--------------------
13000000.000-13999999.000       3       (3%)
14000000.000-14999999.000       82      (82%)
15000000.000-15999999.000       14      (14%)
24000000.000-24999999.000       1       (1%)


IMHO, the 3rd option would be the way to go if this was considered an
acceptable option (ie, despite it returns spurious errors in 'rare
cases').


modified test program
=====================
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
	printf("%f\n", rate);

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
