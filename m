From: Michael Vittrup Larsen <michael.vittrup.larsen@ericsson.com>
Subject: Re: [PATCH] tcp: efficient port randomisation
Date: Fri, 5 Nov 2004 12:03:58 +0200
Message-ID: <200411051103.59032.michael.vittrup.larsen@ericsson.com>
References: <20041027092531.78fe438c@guest-251-240.pdx.osdl.net> <200411020854.44745.michael.vittrup.larsen@ericsson.com> <20041104100104.570e67cd@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041104100104.570e67cd@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 04 November 2004 19:01, Stephen Hemminger wrote:
> But because of the hashing most ports will be scattered all over the po=
rt
> space, because they come from different hosts.
>
> Also, Linux TCP will reuse ports if (saddr, daddr, sport) are different.
> Look at __tcp_v4_check_established. =A0This means that the ports actual=
ly
> have to be in use with real connections to the same host.

__tcp_v4_check_established is the linux version of the uniqueness test fr=
om=20
the draft, and of course ports ports can be reused when at least one of t=
he=20
other parameters (saddr, daddr, sport) are different.

I focus on the situation where (saddr, daddr, sport) is constant since th=
is is=20
where we get collisions and need to try another port.  Not storing the po=
rt=20
found to be unused will result in situations like:

tcp_rover_next is say 2000

Ports 2000-2010 are already used because you are browsing www.osdl.org

Your search will find 2011 to be unused after 10 retries and tcp_rover_ne=
xt=20
will be 2001.

Your next search (you continue to browse www.osdl.org) will result in 201=
2 -=20
again after 10 retries.

In a simple browsing scenario like this, you will usually not have holes=20
because of TCP TIME-WAIT and your rover will continue to lag behind and y=
ou=20
will continue to make 10 retries on ports.

The question is then, when do the rover begin to lack behind?

Everytime you meet a long-lived connection in the port space your rover w=
ill=20
lag one port behind the real 'unused' rover.  Using wget and browsing=20
www.osdl.org may easily produce this problem.

I understand your argument for not holding the lock, and maybe the follow=
ing=20
algorithm is a compromise:

1. Use the current algorithm that does not hold the lock

2. If a port was found in first try, then exit (you have already
   incremented tcp_rover_next by 1 so this is up to date as per
   the old algorithm).

3. If more than one port try was necessary, compute the difference betwee=
n
   the initial rover to the current unused port, and atomic_add() this to
   tcp_rover_next.

The only drawback of this is, that tcp_rover_next may 'run' a little too =
fast=20
in contention cases, which only has theoretical impact on performance. Al=
so,=20
this only happens when we meet a long-lived connection, which we usually =
do=20
not have many of.
