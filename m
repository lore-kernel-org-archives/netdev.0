From: Tom Marshall <tmarshall@real.com>
Subject: Re: [Fwd: Problem with dual IPv4/IPv6 connect]
Date: Fri, 19 Nov 2004 10:43:29 -0800
Message-ID: <20041119184328.GB3396@real.com>
References: <20041118184950.GB3972@real.com> <Pine.LNX.4.61.0411190904580.6216@netcore.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_scarface.real.com-16157-1100889827-0001-2"
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0411190904580.6216@netcore.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_scarface.real.com-16157-1100889827-0001-2
Content-Type: multipart/mixed; boundary="0eh6TmSyL6TZE2Uz"
Content-Disposition: inline


--0eh6TmSyL6TZE2Uz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

> I'd suggest you resend it to netdev, but also attach a minimal,=20
> trivial test case .c file which allows anyone to easily experiment=20
> with the behaviour, test a fix, etc.

Recap of the issue:

  s =3D socket(AF_INET6, SOCK_STREAM, 0)
  connect(s, [fec0::203:baff:fe88:5a15]:1554) =3D> EINPROGRESS
  Put socket in select's write set
  Kernel sends TCPv6 SYN
  Kernel receives ICMPv6 Time Exceeded (routing error)
  Socket becomes writable
  getsockopt(s, SO_ERROR) =3D> EHOSTUNREACH
  connect(s, [:ffff:192.168.168.241]:1554) =3D> ECONNABORTED

Okay I've attached a fairly small repro.  Sorry it's not smaller but it
takes a few lines of code to do the required setup.  The trickier part of
the setup is probably getting a ICMPv6 Time Exceeded error.  My particular
setup was using vtun for an IPv6 route through a dumb switch and a bogus
route on the remote vtun endpoint, but there are surely other ways to get
this error.

The app expects you to specify an IPv6 address, an IPv4 address (glibc's
inet_pton requires it be in V4MAPPED form), a port, and a nonblocking value=
=2E=20
The addresses don't necessarily need to be for the same host.

Results for kernel 2.6.9 and 2.6.10-rc2 are the same, as follows:

  $ gcc -Wall -o dualconnect dualconnect.c
  $ ./dualconnect fec0::203:baff:fe88:5a15 ::ffff:192.168.168.241 22 1
  async connect to fec0::203:baff:fe88:5a15 returned No route to host
  sync  connect to ::ffff:192.168.168.241 returned Software caused connecti=
on abort
  async connect to ::ffff:192.168.168.241 returned Success
  $ ./dualconnect fec0::203:baff:fe88:5a15 ::ffff:192.168.168.241 22 0
  sync  connect to fec0::203:baff:fe88:5a15 returned No route to host
  sync  connect to ::ffff:192.168.168.241 returned No route to host
  sync  connect to ::ffff:192.168.168.241 returned Transport endpoint is al=
ready connected

In the nonblocking case (which we use, and prompted the report), the socket
appears to correct its internal state and the second IPv4 connect succeeds.

In the blocking case, the socket appears to actually connect even though it
reports an error.  I just discovered this today because I was hoping to get
a smaller repro by avoiding using select.  :-/

--=20
Don't get suckered in by the comments -- they can be terribly misleading.=
=20
Debug only code.
        -- Dave Storer

--0eh6TmSyL6TZE2Uz
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="dualconnect.c"

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <sys/ioctl.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

int
do_connect(int s, const char* destaddr, unsigned short destport)
{
    struct sockaddr_in6 sa;
    socklen_t len;
    int rc;

    len = sizeof(struct sockaddr_in6);
    memset(&sa, 0, len);
    sa.sin6_family = AF_INET6;
    if (inet_pton(AF_INET6, destaddr, &sa.sin6_addr) <= 0)
    {
        printf("inet_pton failed\n");
        exit(1);
    }
    sa.sin6_port = htons(destport);

    rc = connect(s, (struct sockaddr*)&sa, len);
    if (rc == -1 && errno == EINPROGRESS)
    {
        fd_set fds;
        FD_ZERO(&fds);
        FD_SET(s, &fds);
        do
        {
            rc = select(s+1, NULL, &fds, NULL, NULL);
        }
        while (rc == -1 && errno == EINTR);
        if (rc != 1)
        {
            printf("select failed\n");
            exit(1);
        }
        len = sizeof(rc);
        if (getsockopt(s, SOL_SOCKET, SO_ERROR, &rc, &len) != 0)
        {
            printf("get SO_ERROR failed\n");
            exit(1);
        }
        printf("async connect to %s returned %s\n", destaddr, strerror(rc));
        return rc;
    }
    printf("sync  connect to %s returned %s\n", destaddr, strerror(errno));
    return errno;
}

int
main(int argc, char** argv)
{
    int s;
    int rc;
    int tmp;

    if (argc != 5)
    {
        printf("usage: %s <host6> <host4> <port> <NB>\n", argv[0]);
        exit(1);
    }

    s = socket(AF_INET6, SOCK_STREAM, 0);
    if (s == -1)
    {
        perror("socket");
        exit(1);
    }

    tmp = atoi(argv[4]);
    ioctl(s, FIONBIO, &tmp);

    /* attempt v6 connect, verify EHOSTUNREACH */
    rc = do_connect(s, argv[1], atoi(argv[3]));
    if (rc == 0)
    {
        exit(1);
    }

    /* attempt v4 connect, 2.6.x returns ECONNABORTED */
    rc = do_connect(s, argv[2], atoi(argv[3]));
    if (rc == 0)
    {
        exit(1);
    }

    /* retry, verify success */
    rc = do_connect(s, argv[2], atoi(argv[3]));
    if (rc == 0)
    {
        exit(1);
    }

    close(s);
    return 0;
}

--0eh6TmSyL6TZE2Uz--

--=_scarface.real.com-16157-1100889827-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBnj7QqznSmcYu2m8RAgp/AJ4jx8CJFFbJJGjyIax/hUz2BKF24gCfU8Jw
JCefzxNauyyWjdUR9/pJCos=
=VeTQ
-----END PGP SIGNATURE-----

--=_scarface.real.com-16157-1100889827-0001-2--
