From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: unix_dgram_recvmsg wakeups [test results & programs]
Date: Thu, 26 Nov 2015 19:19:07 +0000
Message-ID: <878u5klgb8.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[to be followed by a patch]

Currently, unix_dgram_recvmsg does a wake up on the peer_wait queue of a
socket after every received datagram. This seems excessive, especially
considering that only SOCK_DGRAM client sockets in an n:1 asssociation
with a server socket ever wait for the associated condition.

Values are based on 500 runs of either test program.

SOCK_SEQPACKET throughput (B/s)

		stock			patched
---------------------------------------------------------------                
avg		14714579.91		17898665.25	+26.64%
median		14409539.95		16429584.38     +14.02%
dev		 1582631.52	 	 3475160.01

min		13588814.36		14864694.12
max		25960203		27264811.18


SOCK_DGRAM 100 clients/ 1 server (B/s)

		stock			patched
---------------------------------------------------------------                
avg		57394.06		58222.93	+1.44%
median		55878.12		56993.55	+2%
dev		 3540.02		3488.49

min		54167.33		53165.51
max		67971.15		66466.99


SOCK_SEQPACKET test program
---------------------------
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
--------------------------


SOCK_DGRAM test program
-----------------------
#include <inttypes.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/poll.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <sys/un.h>
#include <sys/wait.h>
#include <unistd.h>

#define SERVER_ADDR	"\0dgt-2"

enum {
    MSG_SZ =	16,
    MSGS =	1000
};

static char msg[MSG_SZ];
static struct sockaddr_un server_sun;

static uint64_t tv2u(struct timeval *tv)
{
    uint64_t u;

    u = tv->tv_sec;
    u *= 1000000;
    return u + tv->tv_usec;
}

static void server(int sk, unsigned want)
{
    struct timeval start, stop;
    char buf[MSG_SZ];
    uint64_t t_diff;
    double rate;
    
    gettimeofday(&start, 0);
    do read(sk, buf, sizeof(buf)); while (--want);
    gettimeofday(&stop, 0);

    t_diff = tv2u(&stop);
    t_diff -= tv2u(&start);
    rate = MSG_SZ * MSGS;
    rate /= t_diff;
    rate *= 1000000;
    printf("%f\n", rate);
}

static void client(void)
{
    unsigned remain;
    int sk;

    sk = socket(AF_UNIX, SOCK_DGRAM, 0);
    connect(sk, (struct sockaddr *)&server_sun, sizeof(server_sun));
    
    remain = MSGS;
    do write(sk, msg, sizeof(msg)); while (--remain);

    _exit(0);
}

int main(int argc, char **argv)
{
    unsigned n_clients, want;
    int sk;

    n_clients = atoi(argv[1]);

    server_sun.sun_family = AF_UNIX;
    memcpy(server_sun.sun_path, SERVER_ADDR, sizeof(SERVER_ADDR));
    sk = socket(AF_UNIX, SOCK_DGRAM, 0);
    bind(sk, (struct sockaddr *)&server_sun, sizeof(server_sun));

    want = n_clients * MSGS;
    do if (fork() == 0) client(); while (--n_clients);
    
    server(sk, want);
    return 0;
}
