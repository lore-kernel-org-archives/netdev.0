From: Kyle Moffett <kyle@moffetthome.net>
Subject: Re: [PATCH v2] bonding: move IPv6 support into a separate kernel
	module
Date: Fri, 27 Feb 2009 02:25:54 -0500
Message-ID: <f73f7ab80902262325q2779f3f5y4870bc30a062971d@mail.gmail.com>
References: <49A5ADB3.2010709@hp.com> <28797.1235599858@death.nxdomain.ibm.com>
	 <20090225.141430.166906161.davem@davemloft.net>
	 <49A6C6ED.3070801@hp.com> <22876.1235672073@death.nxdomain.ibm.com>
	 <49A6ED6D.3090508@hp.com> <7418.1235679608@death.nxdomain.ibm.com>
	 <49A70245.9010405@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>, Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>, arvidjaar@mail.ru,
	chuck.lever@oracle.com, tytso@mit.edu, Valdis.Kletnieks@vt.edu,
	rjw@sisk.pl, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, jamagallon@ono.com,
	linux-kernel@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:62058 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757406AbZB0HZ4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 02:25:56 -0500
In-Reply-To: <49A70245.9010405@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2009 at 3:57 PM, Vlad Yasevich
<vladislav.yasevich@hp.com> wrote:
>
> Yes. =C2=A0The bitmask to disable certain family can be useful, but i=
t's orthogonal
> the issue of IPv6 support. =C2=A0As you said, it can be used to disab=
le
> any address family that user wishes. =C2=A0The slight issue with this=
 might
> be, should the settings affect already create sockets?
>
> I guess it comes down how many levels of control to do we want to pro=
vide.
> Things that have been suggested so far:
> =C2=A0 =C2=A0 =C2=A0 =C2=A01) Global on/off switch (i.e module parame=
ter)
> =C2=A0 =C2=A0 =C2=A0 =C2=A02) Per interface on/off switch (currently =
exists, but has bugs).
> =C2=A0 =C2=A0 =C2=A0 =C2=A03) Socket on/off switch (i.e blocker bitma=
sk)
>
> I think numbers 1 and 2 turn off the IPv6 protocol on the wire, while=
 number
> 3 turns off the interface to the user. =C2=A0The two can be done inde=
pendent.

I feel extremely nervous about people discussing disabling IPv6 going
forward.  Current estimates are that the first RIRs will begin to
exhaust their address spaces (after IANA's address space is exhausted)
early in 2011.  If you consider that any change probably won't be in a
released kernel until June or so, there would be all of 18 months left
until IPv6 is *required* to contact some hosts on the internet.

At this point in time, anyone looking at "disabling" IPv6 should be
doing so with standard firewall rules *exactly* the same way that they
would disable IPv4 traffic; adding rules using ip6tables or ebtables
is easy.

You could simply drop all IPv6 ethernet frames:
  ebtables -P INPUT ACCEPT
  ebtables -A INPUT -p IPv6 -j DROP
  ebtables -P FORWARD ACCEPT
  ebtables -A FORWARD -p IPv6 -j DROP
  ebtables -P OUTPUT ACCEPT
  ebtables -A OUTPUT -p IPv6 -j DROP

Alternatively for a per-interface switch you could "ebtables -A INPUT
-i eth4 -p IPv6 -j DROP", etc...

You could also do this instead (this includes IPv6 tunnels and whatnot)=
:
  ip6tables -t raw -P INPUT DROP
  ip6tables -t raw -P OUTPUT DROP

This allows programs which have been written to use AF_INET6 even for
IPv4 sockets to continue to function appropriately (and there are at
least a few).

Cheers,
Kyle Moffett
