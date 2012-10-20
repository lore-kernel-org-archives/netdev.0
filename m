From: Andrew Savchenko <bircoph@gmail.com>
Subject: Re: [BUG] Kernel recieves DNS reply, but doesn't deliver it to a
 waiting application
Date: Sun, 21 Oct 2012 03:25:43 +0400
Message-ID: <20121021032543.09d1844f.bircoph@gmail.com>
References: <20121003232548.eb6b6b22.bircoph@gmail.com>
	<20121013163639.87abca00.bircoph@gmail.com>
	<1350135860.21172.14606.camel@edumazet-glaptop>
	<20121014031119.a60263d6.bircoph@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Sun__21_Oct_2012_03_25_43_+0400_lvVzhk.G22t2JzK="
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:41917 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753480Ab2JTX0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 19:26:11 -0400
Received: by mail-la0-f46.google.com with SMTP id h6so963432lag.19
        for <netdev@vger.kernel.org>; Sat, 20 Oct 2012 16:26:09 -0700 (PDT)
In-Reply-To: <20121014031119.a60263d6.bircoph@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Sun__21_Oct_2012_03_25_43_+0400_lvVzhk.G22t2JzK=
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

On Sun, 14 Oct 2012 03:11:19 +0400 Andrew Savchenko wrote:
> On Sat, 13 Oct 2012 15:44:20 +0200 Eric Dumazet wrote:
> > On Sat, 2012-10-13 at 16:36 +0400, Andrew Savchenko wrote:
> > > On Wed, 3 Oct 2012 23:25:48 +0400 Andrew Savchenko wrote:
> > > > I encountered a very weird bug: after a while of uptime kernel stop=
s to deliver
> > > > DNS reply to applications. Tcpdump shows that correct reply is reci=
eved, but=20
> > > > strace shows inquiring application never recieves it and ends with =
timeout,
> > > > epoll_wait() always returns 0:
> > > > a slice from: $ host kernel.org 8.8.8.8:
> [...]
> > > > In a few days I'll try 3.4.12 (I need to rebuild kernel anyway due =
to unrelated
> > > > issue) and will report if this bug will occur again. But please not=
e it may
> > > > take several weeks to check this.
> > >=20
> > > I got this problem again with 3.4.12 kernel. System lasted less than
> > > a week and reboot was the only option...
> >=20
> > You should investigate and check where the incoming packet is lost
> >=20
> > Tools :
> >=20
> > netstat -s
> >=20
> > drop_monitor module and dropwatch command
> >=20
> > cat /proc/net/udp
>=20
> Thank you for you reply; I updated my kernel to 3.4.14, enabled
> CONFIG_NET_DROP_MONITOR, and installed dropwatch utility.
>=20
> I will report back when the bug will struck again.
> This may take a weak or two, however.

This bug is back again on kernel 3.4.14, but this time I was able to
get debug data and to recover running kernel without reboot.

Drowpatch showed that DNS UDP replies are always dropped here:
1 drops at __udp_queue_rcv_skb+61 (0xffffffff813bd670)

Another observations:
- only UDP replies are lost, TCP works fine;
- if network load is dropped dramatically (ip_forward disabled, most
network daemons are stopped) UDP DNS queries work again; but with
gradual load increase replies became first slow and than cease at all.
- CPU load is very low (uptime is below 0.05), so this shouldn't be
an insufficient computing power issue.

I found __udp_queue_rcv_skb function in net/ipv4/udp.c. From the code
and observations above it follows that this is likely to be a ENOMEM
condition leading to a packet loss.

This is a memory data after bug happened:
# cat /proc/meminfo
MemTotal:        1021576 kB
MemFree:           32056 kB
Buffers:          105204 kB
Cached:           646716 kB
SwapCached:          236 kB
Active:           205932 kB
Inactive:         587156 kB
Active(anon):      20636 kB
Inactive(anon):    22488 kB
Active(file):     185296 kB
Inactive(file):   564668 kB
Unevictable:        2152 kB
Mlocked:            2152 kB
SwapTotal:        995992 kB
SwapFree:         995020 kB
Dirty:                 0 kB
Writeback:             0 kB
AnonPages:         43120 kB
Mapped:             7504 kB
Shmem:               148 kB
Slab:             176004 kB
SReclaimable:     118636 kB
SUnreclaim:        57368 kB
KernelStack:         688 kB
PageTables:         2948 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     1506780 kB
Committed_AS:      62708 kB
VmallocTotal:   34359738367 kB
VmallocUsed:      262732 kB
VmallocChunk:   34359474615 kB
AnonHugePages:         0 kB
DirectMap4k:       33536 kB
DirectMap2M:     1013760 kB

# sysctl -a | grep mem
net.core.optmem_max =3D 20480
net.core.rmem_default =3D 229376
net.core.rmem_max =3D 131071
net.core.wmem_default =3D 229376
net.core.wmem_max =3D 131071
net.ipv4.igmp_max_memberships =3D 20
net.ipv4.tcp_mem =3D 22350        29801   44700
net.ipv4.tcp_rmem =3D 4096        87380   6291456
net.ipv4.tcp_wmem =3D 4096        16384   4194304
net.ipv4.udp_mem =3D 24150        32202   48300
net.ipv4.udp_rmem_min =3D 4096
net.ipv4.udp_wmem_min =3D 4096
vm.lowmem_reserve_ratio =3D 256   256     32
vm.overcommit_memory =3D 0

Sysctl memory parameters are system defaults, I haven't changed them
via sysctl or /proc interfaces.

I tried to increase udm_mem values to the following:
net.ipv4.udp_mem =3D 100000       150000  200000

This solved my issue, at least for a while: DNS queries are working
fine now.

But I suspect that there is some memory loss in the kernel UDP stack,
because this issue never happens after reboot and always after about
a week of network operation. So this memory increase should help only
for a month or so, if memory loss is linear.

If you need some memory debug information, let me know which one and
what tools will be needed.

Best regards,
Andrew Savchenko

--Signature=_Sun__21_Oct_2012_03_25_43_+0400_lvVzhk.G22t2JzK=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAlCDMwAACgkQ2anJBBcsZw1RnwCeIxuFAKNtLPFtt3kllTL5V75S
i4EAnjxUASK2oEnSN+0cRQa30oK/r95Q
=PntF
-----END PGP SIGNATURE-----

--Signature=_Sun__21_Oct_2012_03_25_43_+0400_lvVzhk.G22t2JzK=--
