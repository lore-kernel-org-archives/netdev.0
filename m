From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] Re: [Bugme-new] [Bug 4189] New: IPv6 link local
 addresses are not assigned correctly on multiple-bonding enviromrnts
Date: Thu, 10 Feb 2005 10:17:06 -0800
Message-ID: <200502101817.j1AIH6p7000602@death.nxdomain.ibm.com>
References: <yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=euc-jp
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, ikebe.takashi@lab.ntt.co.jp, davem@davemloft.net,
        akpm@osdl.org, ctindel@users.sourceforge.net,
        bonding-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: Message from YOSHIFUJI Hideaki /
 =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
   of "Thu, 10 Feb 2005 18:22:25 +0900."
 <20050210.182225.07335127.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =B5=C8=C6=A3=B1=D1=CC=C0 <yoshfuji@linux-ipv6.org> wr=
ote:

>> It create ipv6 address from MAC address, however it seems dev->dev_add=
r is "0"
>> in the case of bonding.
>
>I don't think it is the case.

	Given the below sequence, i.e., ifconfig bond0 up before
ifenslave, then, yes, the dev_addr is all zeroes when the ifconfig up
happens.  The bonding master device (bond0) uses the ethernet address of
the first slave to be added, so if there are no slaves, the dev_addr is
all zeros.

># ifconfig bond0 up <=3D here fe80::200:ff:fe00:0/64 is assigned
># ifenslave bond0 eth0 ...
>
>IPv6 Link-local address is configured just after the
>corresponding device is enabled. MAC should be configured
>before you bring up the interface.
>
>So, currently, you need to do this:
>
># ip link set bond0 address 00:01:02:03:04:05
># ifconfig bond0 up <=3D here fe80::200:ff:fe00:0/64 is assigned
># ifenslave bond0 eth0 ...
>
>BTW, why is it required to bring up bonding device before its configurat=
oin?

	I can't say for sure why it was originally done that way, but a
lot of initialization in done in the device open function, and that
happens at "ifconfig up" time.  For IPv4 it's not a problem (nothing
really happens at "ifconfig bond0 up", the device can't really
communicate until at least one slave is added, and the MAC address can
be gleaned at that time).  The general model for bonding is that down
means "no slaves," so "ifconfig bond0 down" releases the slaves (and the
module can be removed at that point).

	The model used by the bridge device is probably a better way to
go, particularly given that IPv6 link local addresses are created at
"ifconfig up" time.  In that case, bonding would insist on having at
least one slave before ifconfig up can succeed, and a ifconfig down
wouldn't necessarily release the slaves (although that part can be more
flexible; we could preserve the current "ifconfig down releases all
slaves" behavior).

	Changing this is a significant change to the user interface.
Making it backwards compatible with the current scheme while still
preventing users from ending up with bogus IPv6 link local addresses
seems difficult (I can't think of a way offhand; one method requires
that ifenslave happen before ifconfig up, the other requires the
opposite).

	I'll have to give this some thought; it will have to change
somehow, since IPv6 doesn't work properly with the current scheme.

>Ethernet devices is not allowed to change its MAC during it is up.

	Some of the bonding modes alter a slave's MAC addresses while
up, typically to have a slave masquerade as one of the other slaves (if,
e.g., the other slave fails).  Not all of the device drivers support
this, so it doesn't work with all devices.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
