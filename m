From: "Michael T Kerrisk" <mtk-lists@gmx.net>
Subject: TCP_CORK 200ms maximum cork time -- expected behaviour?
Date: Fri, 20 Aug 2004 16:00:33 +0200 (MEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <18686.1093010433@www70.gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: michael.kerrisk@gmx.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Gidday,

I tried posting this several weeks back, but got no response. =20
I'll try again, this time with programs (see below) that=20
demonstrate (also see below) what I=92m seeing.

The TCP_CORK socket option allows us to perform multiple=20
write()s (or send()s or sendfile()s) while delaying the=20
transmission of an outgoing TCP segment until the option is=20
disabled (or a segment MSS is filled or the socket is closed).

All is fine and good, but there's one point I'm puzzled=20
about: even when TCP_CORK is set, buffered data will still be=20
transmitted after a 200 millisecond delay (the delay counts=20
from the time that the first corked byte was written),=20
**even if TCP_CORK is still set**.  So, I'm wondering:

1. Is this intended behaviour, or simply an=20
   outgrowth of the combined implementations of=20
   TCP_CORK and TCP_NAGLE_OFF?

2. If it's intended behaviour, what is the=20
   rationale for the ceiling time on corking?

I first observed this behaviour quite some time back, but=20
I've verified that it is still current (2.4.26 and 2.6.8.1=20
kernels).  (In passing: of course, similar behaviour occurs=20
with MSG_MORE on TCP sockets.)

Here's what I see using my two test programs:

tcp_cork_receive port
    This binds to a port, accepts a connection
    and then reads blocks displaying them along
    with the time that the read() completed.

tcp_cork_send [options] server port num-writes buf-size
    Connect to server/port, perform specified number
    ('num-writes') of writes, each containing 'buf-size'
    bytes.  By default, this program enables TCP_CORK
    on the socket.

    Various options are provided, but the only one=20
    needed for the test is '-d usecs' which specifies
    a number of microseconds to usleep() between writes.
   =20
In the following (run on 2.6.8.1), tcp_cork_send is used to=20
write 100 bytes, one at a time, with a 10 millisecond delay=20
between writes:

$ ./tcp_cork_receive 9999 &
[1] 8868
$ ./tcp_cork_send -d 10000 localhost 9999 100 1
[PID 8868] 1093009988.950: Receiver accepted connecton
[PID 8869] 1093009988.951: Enabled TCP_CORK
[PID 8869] 1093009988.951: TCP_CORK=3D1
[PID 8868] 1093009989.152: [received 17 bytes]
[PID 8868] 1093009989.359: [received 17 bytes]
[PID 8868] 1093009989.563: [received 17 bytes]
[PID 8868] 1093009989.767: [received 17 bytes]
[PID 8868] 1093009989.971: [received 17 bytes]
[PID 8869] 1093009990.154: Completed writes
[PID 8868] 1093009990.155: [received 15 bytes]
[1]+  Done                    ./tcp_cork_receive 9999


The "received" messages appear every 200 milliseconds, even
though the sender did not disable TCP_CORK.  Based on what I=92d
read/heard about TCP_CORK, I would have expected to see only=20
one "received" after the sender had closed the socket.  But,=20
instead, there is clearly a 200 millisecond ceiling on corkage.

Cheers,

Michael




/* tcp_cork_receive.c */

#include <sys/types.h>
#include <netinet/tcp.h>
#include <netinet/in.h>
#include <sys/time.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>

#define errMsg(msg)     { perror(msg); }

#define errExit(msg)    { perror(msg); exit(EXIT_FAILURE); }

#define usageErr(msg, progName) \
                        { fprintf(stderr, "Usage: "); \
                          fprintf(stderr, msg, progName); \
                          exit(EXIT_FAILURE); }
static void
traceInfo(void)
{
    struct timeval tv;

    if (gettimeofday(&tv, NULL) =3D=3D -1) errExit("gettimeofday");
    printf("[PID %ld] %8.3f: ", (long) getpid(),
            tv.tv_sec + tv.tv_usec / 1000000.0);
} /* traceInfo */

int
main(int argc, char *argv[])
{
    int lfd, sfd;
    ssize_t numRead;
#define BUF_SIZE 100000
    char buf[BUF_SIZE];
    int optval;
    struct sockaddr_in svaddr;

    if (argc !=3D 2  || strcmp(argv[1], "--help") =3D=3D 0) {
        fprintf(stderr, "%s port\n", argv[0]);
        exit(EXIT_FAILURE);
    }=20

    lfd =3D socket(AF_INET, SOCK_STREAM, 0);
    if (lfd =3D=3D -1) errExit("socket");

    memset(&svaddr, 0, sizeof(struct sockaddr_in));
    svaddr.sin_family =3D AF_INET;
    svaddr.sin_port =3D htons(atoi(argv[1]));
    svaddr.sin_addr.s_addr =3D htonl(INADDR_ANY);

    optval =3D 1;
    if (setsockopt(lfd, SOL_SOCKET, SO_REUSEADDR, &optval,
                sizeof(optval)) =3D=3D -1) errExit("setsockopt");

    if (bind(lfd, (struct sockaddr *) &svaddr, sizeof(struct sockaddr_in)=
)
            =3D=3D -1) errExit("bind");

    if (listen(lfd, 5) =3D=3D -1) errExit("listen");

    sfd =3D accept(lfd, NULL, NULL);
    if (sfd =3D=3D -1) errExit("accept");

    traceInfo();
    printf("Receiver accepted connecton\n");

    for (;;) {
        numRead =3D read(sfd, buf, BUF_SIZE);
        if (numRead =3D=3D -1) errExit("read");
        if (numRead =3D=3D 0)
            break;
        traceInfo();
        /* printf("[received %d bytes] %.*s\n", numRead,
           (int) numRead, buf); */
        printf("[received %d bytes]\n", numRead);
    }=20

    close(lfd);
    close(sfd);
    exit(EXIT_SUCCESS);
} /* main */




/* tcp_cork_send.c */

#define _XOPEN_SOURCE 500   =20
#include <sys/types.h>
#include <unistd.h>
#include <netinet/tcp.h>
#include <netinet/in.h>
#include <sys/time.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include "inet_sockets.h"

typedef enum { FALSE, TRUE } Boolean;

#define errMsg(msg)     { perror(msg); }

#define errExit(msg)    { perror(msg); exit(EXIT_FAILURE); }

#define fatalErr(msg)   { fprintf(stderr, "%s\n", msg); \
                          exit(EXIT_FAILURE); }

static void
traceInfo(void)
{
    struct timeval tv;

    if (gettimeofday(&tv, NULL) =3D=3D -1) errExit("gettimeofday");
    printf("[PID %ld] %8.3f: ", (long) getpid(),
            tv.tv_sec + tv.tv_usec / 1000000.0);
} /* traceInfo */

static void
usageError(char *progName, char *msg)
{
    if (msg !=3D NULL)
        fprintf(stderr, "%s\n", msg);

    fprintf(stderr,
        "%s [options] server port num-write buf-size\n"
        "\tnum-write        Number of writes\n"
        "\tbuf-size         Size of buffer for each write\n"
        "\tOptions are:\n"
        "\t\t-d usecs  Microsecs delay between each write\n"
        "\t\t-n        Don't enable TCP_CORK before writes\n"
        "\t\t-s nsecs  Sleep for 'nsecs' seconds before closing socket\n"
        "\t\t-u        Disable TCP_CORK immediately after sending\n"
        "\t\t-v        Verbose reporting of (delayed) writes\n"
        ,
        progName);
    exit(EXIT_FAILURE);
} /* usageError */

int
main(int argc, char *argv[])
{
    int numWrites, j, sfd;
    useconds_t delayUsecs;
    size_t bufSize;
    char *buf;
    int optval;
    int opt;
    int finalSleepSecs;
    Boolean nocork, uncork, verbose;
    socklen_t optlen;
    struct sockaddr_in svaddr;
    struct hostent *h;
    struct in_addr **addrpp;

    nocork =3D FALSE;
    uncork =3D FALSE;
    verbose =3D FALSE;
    finalSleepSecs =3D 0;
    delayUsecs =3D 0;

    while ((opt =3D getopt(argc, argv, "d:us:vn")) !=3D -1) {
        switch (opt) {
        case 'u':
            uncork =3D TRUE;
            break;

        case 's':
            finalSleepSecs =3D atoi(optarg);
            break;

        case 'n':
            nocork =3D TRUE;
            break;

        case 'v':
            verbose =3D TRUE;
            break;

        case 'd':
            delayUsecs =3D atoi(optarg);
            break;

        default:
            usageError(argv[0], "Bad option");
        } /* switch */
    } /* while */

    if (nocork && uncork)
        fatalErr("Can't specify both -n and -u options");

    if (argc !=3D optind + 4 || strcmp(argv[optind], "--help") =3D=3D 0)
        usageError(argv[0], NULL);

    numWrites =3D atoi(argv[optind + 2]);
    bufSize =3D atoi(argv[optind + 3]);

    buf =3D malloc(bufSize);
    for (j =3D 0; j < bufSize; j++)
        buf[j] =3D 'a' + j % 26;

    sfd =3D socket(AF_INET, SOCK_STREAM, 0);
    if (sfd =3D=3D -1) errExit("socket");

    memset(&svaddr, 0, sizeof(struct sockaddr_in));
    svaddr.sin_family =3D AF_INET;
    svaddr.sin_port =3D htons(atoi(argv[optind + 1]));

    h =3D gethostbyname(argv[optind]);
    if (h =3D=3D NULL)
        fatalErr("host lookup failed (gethostbyname())");
    addrpp =3D (struct in_addr **) h->h_addr_list;
    svaddr.sin_addr.s_addr =3D (*addrpp)->s_addr;

    if (connect(sfd, (struct sockaddr *) &svaddr,
            sizeof(struct sockaddr_in)) =3D=3D -1) errExit("connect");

    if (!nocork) {
        optval =3D 1;
        if (setsockopt(sfd, IPPROTO_TCP, TCP_CORK, &optval,
                sizeof(optval)) =3D=3D -1) errExit("setsockopt");

        traceInfo();
        printf("Enabled TCP_CORK\n");
    }=20

    optlen =3D sizeof(optval);
    if (getsockopt(sfd, IPPROTO_TCP,  TCP_CORK, &optval, &optlen) =3D=3D =
-1)
        errExit("getsockopt");
    traceInfo();
    printf("TCP_CORK=3D%d\n", optval);

    for (j =3D 0; j < numWrites; j++) {
         if (write(sfd, buf, bufSize) !=3D bufSize)
             errExit("write");

         if (delayUsecs > 0) {
             if (verbose) {
                 traceInfo();
                 printf("sleep %d\n", j);
             }=20
             usleep(delayUsecs);
         }=20
    }=20

    traceInfo();
    printf("Completed writes\n");

    if (uncork) {
        traceInfo();
        printf("Disabling TCP_CORK\n");
        optval =3D 0;
        if (setsockopt(sfd, IPPROTO_TCP, TCP_CORK, &optval,
                sizeof(optval)) =3D=3D -1) errExit("setsockopt");
    }=20

    if (finalSleepSecs > 0) {
        traceInfo();
        printf("Sleeping\n");
        sleep(finalSleepSecs);
    }=20

    close(sfd);
    exit(EXIT_SUCCESS);
} /* main */

--=20
Michael Kerrisk
mtk-lists@gmx.net

Superg=FCnstige DSL-Tarife + WLAN-Router f=FCr 0,- EUR*
Jetzt zu GMX wechseln und sparen http://www.gmx.net/de/go/dsl
