From: Shmulik Hen <shmulik.hen@intel.com>
Subject: Re: System hard locks with bonding and tcpdump
Date: Thu, 19 Jun 2003 16:15:02 +0300 (IDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0306191539510.10139-100000@jrslxjul1.npdj.intel.com>
References: <E791C176A6139242A988ABA8B3D9B38A01C6AEFD@hasmsx403.iil.intel.com>
Reply-To: Shmulik Hen <shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: bond-devel <bonding-devel@lists.sourceforge.net>,
   linux-net <linux-net@vger.kernel.org>, linux-netdev <netdev@oss.sgi.com>,
   "Noam, Amir" <amir.noam@intel.com>,
   "Chad N. Tindel" <ctindel@calma.pair.com>,
   "David S. Miller" <davem@redhat.com>, Jay Vosburgh <fubar@us.ibm.com>,
   Jeff Garzik <jgarzik@pobox.com>, "Marom, Noam" <noam.marom@intel.com>,
   "Mendelson, Tsippy" <tsippy.mendelson@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Hen, Shmulik" <shmulik.hen@intel.com>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A01C6AEFD@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 19 Jun 2003, Hen, Shmulik wrote:

> =A0=A0=A0=A0=A0=A0=A0 The system will occasionally freeze. When using t=
he -p option to
> *not* set the interface into promiscuous mode, every thing is OK. Using
> KDB we were able to conclude that this is probably a deadlock between t=
he
> br lock and either dev->queue_lock or dev->xmit_lock (see trace below).
>
>
>
> Entering kdb (current=3D0xc9764000, pid 17303) on processor 2 due to cp=
u switch
> [2]kdb> bt
> 0xc9764000=A0=A0=A0 17303=A0=A0=A0=A0=A0 779=A0 1=A0 002=A0 run=A0=A0 0=
xc9764370*tcpdump
> EBP=A0=A0=A0=A0=A0=A0=A0 EIP=A0=A0=A0=A0=A0=A0=A0 Function (args)
> 0xc9765e80 0xc01062fb __write_lock_failed+0x7 (0xc9765e98, 0xc021bb78, =
0xdebfb520, 0xf72609a0, 0xc981b120)
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 kernel .text 0xc0100000 0xc01062f4 0xc0106314
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0xc026025b .text.lock.brlock+0x5
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 kernel .text 0xc0100000 0xc0260256 0xc0260260
>


	There seems to be more info regarding this bug that points to the
fact that this may be a kernel bug. A more comprehensive investigation
done by Tsippy Mendelson reveals the following details:

	The deadlock is not between the br lock and the dev locks, but
rather between different lock attempts done on the same br lock. Looking
at the transmit flow the TCP packet passes when tcpdump is running, it
looks as though nf_hook_slow() does a br_read_lock_bh(BR_NETPROTO_LOCK)
first, and later, further down the flow, dev_queue_xmit_nit() does a
br_read_lock(BR_NETPROTO_LOCK). In between, tcpdump tries to hold
BR_NETPROTO_LOCK for writing (as seen in the trace) and so, we get a writ=
e
lock waiting on a read lock, and another read lock waiting on the write
lock but is on the same CPU of the first lock - deadlock!

	The funny thing is that just above the place where the first lock
is held the following comment appears:
"We may already have this, but read-locks nest anyway"


Any thoughts/comments about what can be done ?


--=20
| Shmulik Hen                             |
| Israel Design Center (Jerusalem)        |
| LAN Access Division                     |
| Intel Communications Group, Intel corp. |
