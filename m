From: "Michael T Kerrisk" <mtk-lists@gmx.net>
Subject: SO_REUSEADDR behavior different from BSD
Date: Wed, 4 Aug 2004 16:25:27 +0200 (MEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16224.1091629527@www2.gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Gidday,

In the classical BSD sockets implementation, the=20
SO_REUSEADDR socket option serves two purposes:

(a) to permit a socket to be bound to a port that currently=20
    has a bound endpoint in the TIME_WAIT state, and

(b) to allow a terminated server to be restarted (and once
    again be bound to it's well-known port), even if there=20
    is a child of the previous server still serving a=20
    connection.

On Linux SO_REUSEADDR does serve this purpose.  However,=20
other second scenario is mot permitted by SO_REUSEADDR. =20
To make it clear what I mean, I=92ll detail the scenario. =20
Suppose we have the following:

                      Server (host Y)
                   =20
                      Create listening socket -- fd 4
                      bind() to INADDR_ANY:9999
                      listen()
                      accept()

Client (host X)

Create socket
connect() to Y:9999   <accept unblocks, fd 5 returned>

                      server forks --------+
                                            \ <child>
                      server terminates      closes fd 4
                                             <keeps running, with
                                             fd 5 holding the
                                             connection to client>

At this point, netstat on host Y shows the tuple=20

    [local=3DY-IP-addr:9999, remote=3DX-IP-addr:ephem-port] ESTABLISHED

                      New Server started
                      Create listening socket -- fd 4
                      set SO_REUSEADDR to 1 for fd 4

                      bind() fd 4 to port INADDR_ANY:9999
                      WHAT HAPPENS?

On FreeBSD, the bind() succeeds, and then using "netstat =96an"=20
on host Y shows:

    [local=3DY-IP-addr:9999, remote=3DX-IP-addr:ephem-port] ESTABLISHED
and
    [local=3D*:9999, remote=3D*.*] CLOSED

But on Linux (2.6), the bind() fails with EADDRINUSE.

Why does Linux behave differently in this scenario?

Cheers,

Michael

--=20
Michael Kerrisk
mtk-lists@gmx.net

NEU: WLAN-Router f=FCr 0,- EUR* - auch f=FCr DSL-Wechsler!
GMX DSL =3D superg=FCnstig & kabellos http://www.gmx.net/de/go/dsl
