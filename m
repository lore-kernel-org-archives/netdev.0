From: Andreas Henriksson <andreas@fatal.se>
Subject: Bug#497278: [PATCH] Re: Bug#497278: tunnel name "he" invalid, but nowhere documented
Date: Mon, 01 Sep 2008 00:23:46 +0200
Message-ID: <1220221426.6106.19.camel@amd64.fatal.se>
References: <20080831141550.GA18957@lapse.rw.madduck.net>
Reply-To: Andreas Henriksson <andreas@fatal.se>, 497278@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: martin f krafft <madduck@debian.org>
To: Stephen Hemminger <shemminger@vyatta.com>, netdev <netdev@vger.kernel.org>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.497278.B497278.12202211493002@bugs.debian.org>
In-Reply-To: <20080831141550.GA18957@lapse.rw.madduck.net>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

On s=C3=B6n, 2008-08-31 at 15:15 +0100, martin f krafft wrote:
> I cannot create a tunnel named "he", but "HE" and "ab" work. If
> I try "he", I just get the usage output. This is confusing and
> I could not figure it out, other than he being parsed as help.
>=20
>   ip tun add he mode sit remote 1.2.3.4 ttl 64
>=20
> I wouldn't expect "help" at this point. I think the parser shouldn't
> either.
>=20

>From the ip manpage:
"The help command is  available  for all objects.  It prints out a list
of available commands and argument syntax conventions."
... so it doesn't look like a documentation problem to me.

To make it more obvious maybe we could add a "helpusage" wrapper that
prints out which argument was interpreted as a call for help.

... if (matches(*argv, "help"))
	helpusage(*argv);
...

void helpusage(char *arg) {
	fprintf(stderr, "Argument '%s' interpreted as a call for help.\n\n", arg);
	usage();
}

Would be lots of places to update to call the new helper function, so
I'm holding off on creating a patch for that until I get some feedback
if people think it would be a good idea.


Anyway, here's a patch that makes it possible to add and, probably more
importantly as it could have been added by other tool (ifconfig), delete
tunnels matching help if you explicitly state the name argument. (ip tun
del name he)

Signed-off-by: Andreas Henriksson <andreas@fatal.se>


diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 769e845..0d9a17f 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -196,8 +196,7 @@ static int parse_args(int argc, char **argv, int cmd, s=
truct ip_tunnel_parm *p)
 		} else {
 			if (strcmp(*argv, "name") =3D=3D 0) {
 				NEXT_ARG();
-			}
-			if (matches(*argv, "help") =3D=3D 0)
+			} else if (matches(*argv, "help") =3D=3D 0)
 				usage();
 			if (p->name[0])
 				duparg2("name", *argv);
