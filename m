From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Tue, 26 Aug 2008 20:32:31 +0200
Message-ID: <48B44C3F.6020006@cosmosbay.com>
References: <bug-459782-176318@bugzilla.redhat.com> <200808261549.m7QFnVUN032543@bz-web1.app.phx.redhat.com> <20080826163719.GA25066@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, j.w.r.degoede@hhs.nl
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.orange.fr ([80.12.242.50]:11303 "EHLO smtp23.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753459AbYHZSch convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 14:32:37 -0400
In-Reply-To: <20080826163719.GA25066@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones a =E9crit :
> Just had this bug reported against our development tree..
>=20
> 	Dave
>=20
> On Tue, Aug 26, 2008 at 11:49:31AM -0400, bugzilla@redhat.com wrote:
>  > Please do not reply directly to this email. All additional
>  > comments should be made in the comments box of this bug.
>  >=20
>  > https://bugzilla.redhat.com/show_bug.cgi?id=3D459782
>  >=20
>  > Hans de Goede <j.w.r.degoede@hhs.nl> changed:
>  >=20
>  >            What    |Removed                     |Added
>  > ------------------------------------------------------------------=
----------
>  >                  CC|                            |j.w.r.degoede@hhs=
=2Enl
>  >           Component|gkrellm                     |kernel
>  >          AssignedTo|j.w.r.degoede@hhs.nl        |kernel-maint@redh=
at.com
>  >             Summary|gkrellmd consumes about 75% |cat /proc/net/tcp=
 takes 0.5
>  >                    |cpu time                    |seconds on x86_64=
, 0.5
>  >                    |                            |seconds !!
>  >=20
>  > --- Comment #2 from Hans de Goede <j.w.r.degoede@hhs.nl>  2008-08-=
26 11:49:30 EDT ---
>  > Thanks for reporting this some stracing of gkrellmd has found that=
 reading from
>  > /proc/net/tcp and reading from /proc/net/tcp6 is the culprit, try =
this on your
>  > x86_64 machine to confirm:
>  >=20
>  > "time cat /proc/net/tcp"
>  >=20
>  > To give you an idea on my rawhide x86_64 machine:
>  > [hans@localhost devel]$ time cat /proc/net/tcp
>  > <snip>
>  > real    0m0.520s
>  > user    0m0.000s
>  > sys     0m0.446s
>  >=20
>  > Thats amazingly slow, esp as I only have 8 tcp connections open.
>  >=20
>  > Some maybe usefull info: top reports a very high load (50%) from s=
oft IRQ's.
>  >=20
>  > Anyways changing this to a kernel bug.
>=20

I wonder why this qualifies as a "kernel bug". This is a well known pro=
blem.

At least, current kernel versions no longer block softirq for long peri=
ods while doing this...

cat /proc/net/tcp is slow and deprecated, since it uses a O(N^2) algo.

tcp hash table size might be a litle bit too large for typical setups (=
few tcp session, even on a 16 GB machine)
Unfortunatly it is fixed at boot time and not dynamic (yet)

You can :

1) Boot your machine with a boot cmd "thash_entries=3D1024" to reduce s=
ize of TCP hash table
(typical size on a 4GB machine is : TCP established hash table entries:=
 262144 (order: 10, 4194304 bytes))

(max size is 524288 entries for machines with >=3D 8GB memory if no "th=
ash_entries=3D..." specified, since October 2007
see http://kerneltrap.org/mailarchive/linux-netdev/2007/10/26/359198 )

2) Switch to netlink interface instead of /proc/net/tcp[6] legacy file.
 Example : netstat -N
   http://www.ducksong.com/misc/netstat-netlink-diag-patch.txt

3) Use both 1) & 2) :)

4) Submit a patch to dynamically grow tcp hash table :)

Links:

http://kerneltrap.org/mailarchive/linux-netdev/2007/11/1/375782
http://kerneltrap.org/mailarchive/linux-netdev/2007/11/1/376907

Time difference between /proc/net/tcp and netlink on a 4GB x86_64 machi=
ne :

# dmesg | grep "TCP established hash"
TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
# time cat /proc/net/tcp >/dev/null

real    0m0.091s
user    0m0.001s
sys     0m0.090s
# time ss -n >/dev/null # ss uses netlink interface

real    0m0.022s
user    0m0.000s
sys     0m0.022s




