From: "Michael T Kerrisk" <mtk-lists@gmx.net>
Subject: Re: SO_REUSEADDR behavior different from BSD
Date: Thu, 5 Aug 2004 18:36:17 +0200 (MEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <19686.1091723777@www48.gmx.net>
References: <20040805141444.GA2292@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> On Wed, Aug 04, 2004 at 04:25:27PM +0200, Michael T Kerrisk wrote:
>=20
> > But on Linux (2.6), the bind() fails with EADDRINUSE.
>=20
> This scenario has previously worked for me. Can you show the exact sour=
ce
> which exhibits this problem?

Okay, sorry for the delay.  I had to hack together a simpler=20
program to demonstrate this.  I've attached the program below=20
(it is both server and client, depending on command line options).

Do note that in my original description, on the first time through,
the server did NOT use SO_REUSEADDR.

In other words, using my program, we do the following:

SERVER HOST                  CLIENT HOST =20

./reuseaddr_test -s -n
(The above does NOT use=20
SO_REUSEADDR)
                             ./reuseaddr_test -c <server-host>

(At this point the server parent exists, but the server
client and child are connected)

./reuseaddr_test -s
(The above DOES use=20
SO_REUSEADDR)


Now, on Linux, at this point, the second instance of the=20
server fails with EADDRINUSE, even though it did use=20
SO_REUSEADDR.  On FreeBSD 5.1, the second server instance=20
does successfully bind.

On Linux, if the *first* instance also used SO_REUSEADDR,
then the second instance can bind.  FreeBSD does not require
this. =20

I realise that the scenario that delivers EADDRINUSE=20
above is slightly unusual, because normally a server always
specifies SO_REUSEADDR, but my question is why the scenario
I'm describing does differ from FreeBSD, which I'm assuming
conforms to the canonical BSD behaviour.

Cheers,

Michael

=3D=3D

/* reuseaddr_test.c

   Michael Kerrisk, Aug 2004

   IPv4 for simplicity...
*/
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>

#define DEF_PORT "55555"

#define DEF_SLEEP_TIME 60

#define errMsg(msg)     { perror(msg); }

#define errExit(msg)    { perror(msg); exit(EXIT_FAILURE); }

#define fatalErr(msg)   { fprintf(stderr, "%s\n", msg); \
                          exit(EXIT_FAILURE); }

static void
usageError(char *progName, char *msg)
{
    if (msg !=3D NULL)
        printf("%s", msg);
    fprintf(stderr, "Usage: %s [options] -s \n"
                    "   or: %s [options] -c host\n",
                        progName, progName);
    fprintf(stderr, "Options are:\n");
    fprintf(stderr, "\t-c host   Run as client, connecting to 'host'\n");
    fprintf(stderr, "\t-s        Run as server\n");
    fprintf(stderr, "\t-p port   Use given 'port' number (def=3D%s)\n",
            DEF_PORT);
    fprintf(stderr, "\t-n        *Don't* use SO_REUSEADDR in server\n");
    fprintf(stderr, "\t-w nsecs  Child sleep interval (def=3D%d)\n",
            DEF_SLEEP_TIME);
    exit(EXIT_FAILURE);
} /* usageError */

/* Return Internet address as string: "(host, port#)" */

static char *
inet4AddressString(const struct sockaddr_in *addr)
{
    static char buf[1024];
    struct hostent *hent;
    char *host;

    hent =3D gethostbyaddr((char *) &addr->sin_addr,
                sizeof(addr->sin_addr), addr->sin_family);

    /* Return host name, or dotted address if not found */

    host =3D (hent !=3D NULL) ? hent->h_name : inet_ntoa(addr->sin_addr);

    snprintf(buf, sizeof(buf), "(%s, %u)", host, ntohs(addr->sin_port));
    return buf;
} /* inet4AddressString */

int
main(int argc, char *argv[])
{
    int opt, sfd, cfd;
    int client, server, reuse;
    char *pstr =3D DEF_PORT;
    char *host;
    struct sockaddr_in svaddr, claddr;
    struct hostent *h;
    struct in_addr **addrpp;
    char buf[1];
    socklen_t s;
    int optval;
    int stime;
#define CMD_SIZE 1024
    char cmd[CMD_SIZE];

    server =3D 0;
    client =3D 0;
    reuse =3D 1;
    stime =3D DEF_SLEEP_TIME;

    while ((opt =3D getopt(argc, argv, "c:sp:nw:")) !=3D -1) {
        switch (opt) {
        case 'c':
            client =3D 1;
            host =3D optarg;
            break;

        case 's':
            server =3D 1;
            break;

        case 'p':
            pstr =3D optarg;
            break;

        case 'w':
            stime =3D atoi(optarg);
            break;

        case 'n':
            reuse =3D 0;
            break;

        default:
            usageError(argv[0], NULL);
            break;
        } /* switch */
    } /* while */

    if ((server && client) || (!server && !client))
        usageError(argv[0], NULL);

    sfd =3D socket(AF_INET, SOCK_STREAM, 0);
    if (sfd =3D=3D -1) errExit("socket");

    memset(&svaddr, 0, sizeof(struct sockaddr_in));
    svaddr.sin_family =3D AF_INET;
    svaddr.sin_port =3D htons(atoi(pstr));

    if (server) {
        svaddr.sin_addr.s_addr =3D htonl(INADDR_ANY);
    } else { /* client */
        h =3D gethostbyname(host);
        if (h =3D=3D NULL)
            fatalErr("host lookup failed (gethostbyname())");
        addrpp =3D (struct in_addr **) h->h_addr_list;
        svaddr.sin_addr.s_addr =3D (*addrpp)->s_addr;
    }=20

    if (server) {

        if (reuse) {
            optval =3D 1;
            if (setsockopt(sfd, SOL_SOCKET, SO_REUSEADDR, &optval,
                    sizeof(optval)) =3D=3D -1) errExit("setsockopt");
        }=20

        if (bind(sfd, (struct sockaddr *) &svaddr,
                    sizeof(struct sockaddr_in)) =3D=3D -1) errExit("bind"=
);

        if (listen(sfd, 5) =3D=3D -1) errExit("listen");

        printf("Server listen() completed; about to accept()\n");

        s =3D sizeof(struct sockaddr_in);
        cfd =3D accept(sfd, (struct sockaddr *) &claddr, &s);
        if (cfd =3D=3D -1) errExit("accept");

        printf("Server received connection from: %s\n",
                inet4AddressString(&claddr));

        snprintf(cmd, CMD_SIZE, "netstat -an | grep %s", pstr);
        printf("cmd: %s\n", cmd);
        //system(cmd);

        switch(fork()) {
        case -1:
            errExit("fork");

        case 0:
            close(sfd);         /* Close listening socket */
            sleep(2);           /* Give parent a moment to exit */
            printf("Server child started\n");
            system(cmd);
            printf("Server child about to sleep %d seconds\n", stime);

            sleep(stime);

            printf("Server child exiting\n");
            exit(EXIT_FAILURE);

        default:
            printf("Server parent exiting\n");
            exit(EXIT_FAILURE);
        }=20

    } else { /* client */

        if (connect(sfd, (struct sockaddr *) &svaddr,
                    sizeof(struct sockaddr_in)) =3D=3D -1)
            errExit("connect");
        printf("Client connected, now about to read\n");
        read(sfd, buf, 1);
        printf("Client exiting\n");
    }=20

    exit(EXIT_SUCCESS);
} /* main */

--=20
Michael Kerrisk
mtk-lists@gmx.net

NEU: WLAN-Router f=FCr 0,- EUR* - auch f=FCr DSL-Wechsler!
GMX DSL =3D superg=FCnstig & kabellos http://www.gmx.net/de/go/dsl
