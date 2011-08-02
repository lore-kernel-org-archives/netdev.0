From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Tue, 02 Aug 2011 18:28:40 +0900
Message-ID: <201108020928.p729Sekl091800@www262.sakura.ne.jp>
References: <201107262021.FCC34304.HMOOFQJVSFLFOt@I-love.SAKURA.ne.jp> <CACLa4pvJ2+eTRf3SRzoXgiW8H+U=BDH-2DKVZ7pGRrPem=JYgg@mail.gmail.com> <201107280336.p6S3aUY7004372@www262.sakura.ne.jp> <20110801.230731.1942061135621106602.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: eparis@parisplace.org, anton@samba.org, casey@schaufler-ca.com,
	mjt@tls.msk.ru, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20110801.230731.1942061135621106602.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> Date: Thu, 28 Jul 2011 12:36:30 +0900
> 
> > Here is an optimized version. Only compile tested.
> 
> Anton, please test this or I'm just going to apply it before it
> gets any testing :-)

Just a moment please. I found a problem (described below).

I tested on TOMOYO using below program

--- Start of test program ---
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <netdb.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <net/if.h>
#include <net/ethernet.h>
#include <linux/if_packet.h>
#include <asm/unistd.h>
#include <errno.h>

#ifndef __NR_sendmmsg
#if defined( __PPC__)
#define __NR_sendmmsg   349
#elif defined(__x86_64__)
#define __NR_sendmmsg   307
#elif defined(__i386__)
#define __NR_sendmmsg   345
#else
#error __NR_sendmmsg not defined
#endif
#endif

struct mmsghdr {
        struct msghdr msg_hdr;
        unsigned int msg_len;
};

static inline int sendmmsg(int fd, struct mmsghdr *mmsg, unsigned vlen,
                           unsigned flags)
{
        return syscall(__NR_sendmmsg, fd, mmsg, vlen, flags, NULL);
}

static unsigned long packets;
static unsigned long packets_prev;

static void sigalrm_handler(int junk)
{
        unsigned long p = packets;

        printf("%ld\n", p - packets_prev);
        packets_prev = p;
        alarm(1);
}

#define NUMDESTS 20
#define NUMBATCH 100

int main(int argc, char *argv[])
{
        const int fd = socket(AF_INET, SOCK_DGRAM, 0);
        unsigned int i;
        char b[10];
        static char buf[NUMBATCH][10];
        static struct iovec iovec[NUMBATCH][1];
        static struct mmsghdr datagrams[NUMBATCH];
        struct sockaddr_in addr[NUMDESTS];

        signal(SIGALRM, sigalrm_handler);
        alarm(1);
        memset(buf, 0, sizeof(buf));
        memset(iovec, 0, sizeof(iovec));
        memset(datagrams, 0, sizeof(datagrams));
        memset(&addr, 0, sizeof(addr));

        for (i = 0; i < sizeof(b); i++)
                b[i]= i;
        for (i = 0; i < NUMDESTS; i++) {
                addr[i].sin_family = AF_INET;
                addr[i].sin_addr.s_addr = htonl(INADDR_LOOPBACK);
                addr[i].sin_port = htons(10000 + (argc == 1 ? i : 0) * 10);
        }
        for (i = 0; i < NUMBATCH; ++i) {
                memcpy(&buf[i], b, sizeof(buf[i]));
                iovec[i][0].iov_base = buf[i];
                iovec[i][0].iov_len = sizeof(buf[i]);
                datagrams[i].msg_hdr.msg_iov = iovec[i];
                datagrams[i].msg_hdr.msg_iovlen = 1;
                datagrams[i].msg_hdr.msg_name = &addr[i % NUMDESTS];
                datagrams[i].msg_hdr.msg_namelen = sizeof(addr[0]);
        }

        while (1) {
                int ret;

                errno = 0;
                ret = sendmmsg(fd, datagrams, NUMBATCH, 0);
                if (ret < 0) {
                        perror("sendmmsg");
                        exit(1);
                }

                if (ret != NUMBATCH) {
                        fprintf(stderr,
                                "sendmmsg returned sent less than batch %d\n", ret);
                }

                packets += ret;
        }
        return 0;
}
--- End of test program ---

and realized that remembering the fact that LSM module has returned an error
code other than -EAGAIN causes subsequent sendmmsg() request to fail with that
error code.

        fput_light(sock->file, fput_needed);

        if (err == 0)
                return datagrams;

        if (datagrams != 0) {
                /*
                 * We may send less entries than requested (vlen) if the
                 * sock is non blocking...
                 */
                if (err != -EAGAIN) {
                        /*
                         * ... or if sendmsg returns an error after we
                         * send some datagrams, where we record the
                         * error to return on the next call or if the
                         * app asks about it using getsockopt(SO_ERROR).
                         */
                        sock->sk->sk_err = -err;
                }

                return datagrams;
        }

        return err;

For example, if TOMOYO returned -EPERM on the 14th datagram,
subsequent sendmmsg() fails with EPERM and the program will exit().

	sendmmsg returned sent less than batch 14
	sendmmsg: Operation not permitted

I think this behavior is not preferable.
In this case, should security_socket_sendmsg() return -EAGAIN rather than
-EPERM?
Or, should sendmmsg() not record errors after some of datagrams were sent?
