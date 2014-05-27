From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: [PATCH/RFC] Re: recvmmsg() timeout behavior strangeness [RESEND]
Date: Tue, 27 May 2014 18:35:17 +0200
Message-ID: <5384BEC5.2080607@gmail.com>
References: <536101C9.9090601@gmail.com> <CAKgNAkgA_xTfRZhpyVwuACpCY7xMK89e0bK4PuVMG9reNV6Skw@mail.gmail.com> <20140512143451.GB13801@kernel.org> <20140521210535.GA5414@kernel.org> <537E0961.8040005@gmail.com> <20140526134647.GB8176@kernel.org> <20140526211706.GA25474@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages@gmail.com, lkml <linux-kernel@vger.kernel.org>,
	"linux-man@vger.kernel.org" <linux-man@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?T25kxZllaiBCw61sa2E=?= <neleai@seznam.cz>,
	Caitlin Bestler <caitlin.bestler@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Elie De Brauwer <eliedebrauwer@gmail.com>,
	David Miller <davem@davemloft.net>,
	Steven Whitehouse <steve@chygwyn.com>,
	=?UTF-8?B?UsOpbWkgRGVuaXMtQ291cm1v?= =?UTF-8?B?bnQ=?=
	<remi.denis-courmont@nokia.com>, Paul Moore <paul@paul-moore.com>,
	Chris Friesen <chris.friesen@windriver.com>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140526211706.GA25474@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arnaldo,

On 05/26/2014 11:17 PM, Arnaldo Carvalho de Melo wrote:
> Em Mon, May 26, 2014 at 10:46:47AM -0300, Arnaldo Carvalho de Melo escreveu:
>> Em Thu, May 22, 2014 at 04:27:45PM +0200, Michael Kerrisk (man-pages) escreveu:
>>> Thanks! I applied this patch against 3.15-rc6.
> 
>>> recvmmsg() now (mostly) does what I expect: 
>>> * it waits until either the timeout expires or vlen messages 
>>>   have been received
>>> * If no message is received before timeout, it returns -1/EAGAIN.
>>> * If vlen messages are received before the timeout expires, then
>>>   the remaining time is returned in timeout.
> 
>>> One question: in the event that the call is interrupted by a signal 
>>> handler, it fails (as expected) with EINTR, but the 'timeout' value is 
>>> not updated with the remaining time on the timer. Would it be desirable 
>>> to emulate the behavior of select() (and other syscalls) in this 
>>> respect, and instead return the remaining time if interrupted by 
>>> a signal?
>  
>> I think so, will check how to achieve that!
> 
> Can you try the attached patch on top of the first one?

Patches on patches is a way to make your testers work unnecessarily
harder. Also, it means that anyone else who was interested in this
thread likely got lost at this point, because they probably didn't 
save the first patch. All of this to say: it makes life much easier 
if you provide a complete new self-contained patch on each iteration.

> It starts adding explicit parentheses on a ternary, as David requested,
> and then should return the remaining timeouts in cases like signals,
> etc.
> 
> Please let me know if this is enough.

Nope, it doesn't fix the problem. (I applied both patches against 3.15-rc7)

> P.S. compile testing while sending this message :-)

Okay -- how about some real testing for the next version ;-). I've appended
my test program below. You can use it as follows:

./t_recvmmsg <port> <timeout-in-secs> <bufsize>...

(The timeout can also be '-' meaning use NULL as the timeout argument.)

Cheers,

Michael


/* t_recvmmsg.c

   A simple test program for the Linux-specific recvmmsg() system call.
*/
#define _GNU_SOURCE
#include <sys/time.h>
#include <signal.h>
#include <sys/socket.h>
#include <netdb.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>


#define errExit(msg) 	do { perror(msg); exit(EXIT_FAILURE); \
                        } while (0)


static int		/* Public interfaces: inetBind() and inetListen() */
createBoundSocket(const char *service, int type, socklen_t *addrlen)
{
    struct addrinfo hints;
    struct addrinfo *result, *rp;
    int sfd, optval, s;

    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_canonname = NULL;
    hints.ai_addr = NULL;
    hints.ai_next = NULL;
    hints.ai_socktype = type;
    hints.ai_family = AF_UNSPEC;	/* Allows IPv4 or IPv6 */
    hints.ai_flags = AI_PASSIVE;	/* Use wildcard IP address */

    s = getaddrinfo(NULL, service, &hints, &result);
    if (s != 0)
        return -1;

    /* Walk through returned list until we find an address structure
       that can be used to successfully create and bind a socket */

    optval = 1;
    for (rp = result; rp != NULL; rp = rp->ai_next) {
        sfd = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
        if (sfd == -1)
            continue;			/* On error, try next address */

        if (bind(sfd, rp->ai_addr, rp->ai_addrlen) == 0)
            break;			/* Success */

        /* bind() failed: close this socket and try next address */

        close(sfd);
    }

    if (rp != NULL && addrlen != NULL)
        *addrlen = rp->ai_addrlen;  	/* Return address structure size */

    freeaddrinfo(result);

    return (rp == NULL) ? -1 : sfd;
}


static void
handler()
{
    /* Just interrupt a syscall */
}


int
main(int argc, char *argv[])
{
    int sfd, vlen, j, s;
    struct mmsghdr *msgvecp;
    struct timespec ts;
    struct timespec *tsp;
    struct sigaction sa;

    if (argc < 4) {
        fprintf(stderr, "Usage: %s port tmo-secs buf-len...\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    sfd = createBoundSocket(argv[1], SOCK_DGRAM, NULL);
    if (sfd == -1) {
        fprintf(stderr, "Could not create server socket (%s)",
                strerror(errno));
        exit(EXIT_FAILURE);
    }

    /* Handle a signal, so we can test behaviour when recvmmsg()
       is interrupted by a signal */
    
    sa.sa_handler = handler;
    sa.sa_flags = 0;
    sigemptyset(&sa.sa_mask);
    if (sigaction (SIGQUIT, &sa, NULL) == -1)
        errExit("sigaction");

    /* argv[2] specifies recvmmsg() timeout in seconds, or is '-', meaning
       using NULL argument to get infinite timeout */

    if (argv[2][0] == '-') {
        tsp = NULL;

    } else {
        ts.tv_sec = atoi(argv[2]);
        ts.tv_nsec = 0;
        tsp = &ts;
    }

    /* Remaining command-line arguments specify the size of recvmmsg()
       buffers */

    /* The second argument to recvmmsg() is a pointer to an array of
       mmsghdr structures. Each element of that array has a field, 
       'struct msghdr msg_hdr', that is used to store information from a
       single received datagram. Among the fields in the msghdr structure
       is a 'struct iovec *msg_iov'--that is, a pointer to a scatter/gather
       I/O vector. To keep things simple for this example, our scatter/gather
       vectors always consists of a single element.
    */

    /* Allocate the mmssghdr vector, whose size corresponds to the
       number of remaining command-line arguments */

    vlen = argc - 3;

    msgvecp = calloc(vlen, sizeof(struct mmsghdr));
    if (msgvecp == NULL)
        errExit("calloc");

    for (j = 0; j < vlen; j++) {
        msgvecp[j].msg_hdr.msg_name = NULL;
        msgvecp[j].msg_hdr.msg_namelen = 0;
        msgvecp[j].msg_hdr.msg_control = NULL;
        msgvecp[j].msg_hdr.msg_controllen = 0;

        /* Allocate an iovec for this mmsghdr element. The vector
           contains just a single item. */

        msgvecp[j].msg_hdr.msg_iovlen = 1;

        msgvecp[j].msg_hdr.msg_iov = malloc(sizeof(struct iovec));
        if (msgvecp[j].msg_hdr.msg_iov == NULL)
            errExit("malloc");

        /* The single iovec element contains a pointer to a buffer
           that is sized according to the number given in the 
           corresponding command-line argument */

        s = atoi(argv[j + 3]);
        msgvecp[j].msg_hdr.msg_iov[0].iov_len = s;
        msgvecp[j].msg_hdr.msg_iov[0].iov_base = malloc(s);
    }

    if (tsp != NULL)
        printf("Timespec before call = %ld.%09ld\n",
                (long) tsp->tv_sec, (long) tsp->tv_nsec);

    /* Now we're ready to make the recvmmsg() call */

    s = recvmmsg(sfd, msgvecp, vlen, 0, tsp);
    if (s == -1) {
        if (errno == EINTR)
            printf("EINTR! (interrupted system call)\n");
        else
            errExit("recvmmsg");
    } 

    printf("recvmmsg() returned %d\n", s);

    if (tsp != NULL)
        printf("Timespec after call = %ld.%09ld\n",
                (long) tsp->tv_sec, (long) tsp->tv_nsec);

    /* Display datagrams retrieved by recvmmsg() */

    for (j = 0; j < s; j++) {
        printf("%d: %u - %.*s\n", j,
                msgvecp[j].msg_len, msgvecp[j].msg_len,
                (char *) msgvecp[j].msg_hdr.msg_iov[0].iov_base);
    }

    exit(EXIT_SUCCESS);
}

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
