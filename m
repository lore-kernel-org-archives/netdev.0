From: "Matthew G. Marsh" <mgm@paktronix.com>
Subject: Re: Resend:  SIOCGIFBRDADDR?
Date: Sun, 18 Aug 2002 19:16:28 -0500 (CDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.43.0208181856210.28686-100000@netmonster.pakint.net>
References: <Pine.LNX.4.44.0208181407480.14268-100000@kaneda.isrd.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Kevin Dwyer <kevin@pheared.net>
In-Reply-To: <Pine.LNX.4.44.0208181407480.14268-100000@kaneda.isrd.lan>
List-Id: netdev.vger.kernel.org

On Sun, 18 Aug 2002, Kevin Dwyer wrote:

> On Sun, 18 Aug 2002, Matthew G. Marsh grunted something like:
> > Why do you use the 'scope link' statements?
>
> Why do I use the 'scope link' argument, or the statement as a whole?
> Those two statements give the same effect as aliases (more or less)
> without having to ifconfig eth0:X for each X.  My understanding was the
> 'scope link' part was useful in keeping the effects of the command local
> to the device.  However, I also did not generate these commands on my own:
> fwbuilder is doing that.  We're trying to get a setup that can be easily
> managed by other people who may not have the same experience with
> command-line tools and such.

Ah OK. I was wondering because if you leave off the 'scope link' then you
get inheritance of the broadcast for secondary ip addrs.

> > And as far as your original question try the following:
> >
> > ip -f inet addr add 10.5.5.8/24 dev eth0 brd +
> > ip -f inet addr add 10.5.5.1 dev eth0 scope link brd 10.5.5.255
> > ip -f inet addr add 10.5.5.2 dev eth0 scope link brd 10.5.5.255
>
> Aha!  At the suggestion of the iproute2 documentation, and another person
> on the linux-ha list, I tried using 'brd +' on the aliased IPs, but
> apparently we were reading the docs wrong.  Setting it explicitly works!

Yep - that is the 'scope link' override that basically tells the system to
ignore any inheritance and treat the address as a special local case. Note
that the order in which the addresses are applied is critical. For
example if you do:

ip addr add 10.5.5.1/24 dev eth0 scope link brd +

Then you get the appropriate broadcast address for the /24 netmask. BUT
then you cannot add in a global address in the same network as in:

ip addr add 10.5.5.8/24 dev eth0 scope global brd 10.5.5.255
RTNETLINK answers: Invalid argument

You have to change the netmask at this point (think scope~=mask).
Essentially you cannot have a primary and secondary address on a single
device exist with different scope. Think of IPv6 scope and it becomes a
little clearer where the addressing conflicts.

Your best bet when in doubt is to always specify the actual broadcast
address you require. The 'brd +' is merly a shortcut to specify the
broadcast address associated with the specified CIDR mask. In fact you can
have way interesting amounts of fun by specifying alternate broadcasts
from CIDR masks as in:

ip addr add 10.5.5.1/24 dev eth0 brd 10.5.255.255

Using this on a "Class B" network allow you to "be seen" by other devices
but only speak to/from devices within your CIDR scope (hint: look at the
output of 'ip ro li tab local') as well as really fsck routers and ARP
tables for the network... ;-}

[snip]

> > And if I am way off base here due to jumping in just ignore me.
>
> Not at all, thanks for the suggestion.  It seems now that I need to try to
> encourage the fwbuilder folks to specify the broadcast address on each
> alias.  At the very least, I should be able to whip out a patch to do
> it, and hopefully they'll accept it.
>
> /* kevin@pheared.net               http://devel.pheared.net/ */
> /* Network Security Engineer       http://pheared.net/~kevin */
> /* Sabotage will set us free.   Throw a rock in the machine. */

--------------------------------------------------
Matthew G. Marsh,  President
Paktronix Systems LLC
1506 North 59th Street
Omaha  NE  68104
Phone: (402) 932-7250 x101
Email: mgm@paktronix.com
WWW:  http://www.paktronix.com
--------------------------------------------------
