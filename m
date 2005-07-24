From: "Michael Richardson" <mcr@sandelman.ottawa.on.ca>
Subject: multicast on loopback: mcast networking at the cottage
Date: Sun, 24 Jul 2005 19:35:29 -0400
Message-ID: <6048.1122248129__17071.266010362$1122311175$gmane$org@marajade.sandelman.ottawa.on.ca>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: user-mode-linux-devel <user-mode-linux-devel@lists.sourceforge.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----


I got frustrated at the cottage just now while testing code using
multiple user mode linux boxes, because I hit the annoying:

  Configuring network interfaces: mcast_open: IP_ADD_MEMBERSHIP failed, error = 19
  There appears not to be a multicast-capable network interface on the host.
  eth0 should be configured in order to use the multicast transport.
  SIOCSIFFLAGS: Invalid argument
  mcast_open: IP_ADD_MEMBERSHIP failed, error = 19

I would just use a script that switched me to daemon networking, but I
thought I'd look into this more. 

I was always going on the assumption that this was because
drivers/net/loopback.c was missing a set_multicast_list call.

Presence of that function is checked in net/core/dev.c. I wrote one (it
doesn't need to do anything...) for fun, rebooted, and noticed that it
didn't help.   

What did help was:
      route add -net 224.0.0.0 netmask 240.0.0.0 dev lo

and it worked even on a stock kernel (2.6.11.8 is what I have).
[thus there is no patch attached here...]

Thinking back, BSD and Solaris do this whenever an interface that has
IFF_MULTICAST set is configured up.  Normally configuring "eth0" and
giving it a default route works --- the check for a route to the
multicast address gives you a valid interface, and all is well.

I suspect that for people who want to do multicast between hosts on an
actual wire won't want to have just a route to lo, they may want a route
for 224.0.0.0/4 on all of their interfaces.  Maybe that should be automatic?

I think that applications that are multicast aware are supposed to
figure out which interfaces that they want to bind to anyway, so they
should not be confused by the multiple routes.

- -- 
] Michael Richardson          Xelerance Corporation, Ottawa, ON |  firewalls  [
] mcr @ xelerance.com           Now doing IPsec training, see   |net architect[
] http://www.sandelman.ca/mcr/    www.xelerance.com/training/   |device driver[
]                    I'm a dad: http://www.sandelman.ca/lrmr/                 [

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)
Comment: Finger me for keys

iQCVAwUBQuQlvIqHRg3pndX9AQGi7QP9FajMsWOj2AZUyPrDtj+T02z5T+Zc1oej
8qobkO624XYhgKlRW/FiBTRNrYOS+MclM2pqeKxOSF7frzt2azZUfOLb0OdNiv1B
d8MBTA4MgPTLVeSapXrMA0JImy8KtquRWsn2ApumW/Odsor9OQjqhlYVsYqCMnTD
xyFcpSMvArc=
=jRE9
-----END PGP SIGNATURE-----
