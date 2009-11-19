From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Oops in Unix sockets code
Date: Thu, 19 Nov 2009 15:20:29 +0100
Message-ID: <4B05542D.7060401@gmail.com>
References: <20091119132028.GA22427@tuxmaker.boeblingen.de.ibm.com> <200911191440.18949.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Blaschka <frank.blaschka@de.ibm.com>, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60450 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988AbZKSOUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 09:20:25 -0500
In-Reply-To: <200911191440.18949.borntraeger@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christian Borntraeger a =E9crit :
> Am Donnerstag 19 November 2009 14:20:28 schrieb Blaschka:
>>     <1>Unable to handle kernel pointer dereference at virtual kernel=
 address 000000007575e000
>>     <4>Oops: 0011 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> 0011(page translation excepton) and DEBUG_PAGEALLOC might indicate a =
use after free.
>=20
>>     <4>Modules linked in: sunrpc qeth_l3 dm_multipath dm_mod qeth cc=
wgroup chsc_sch
>>     <4>CPU: 0 Not tainted 2.6.31-39.x.20091102-s390xdefault #1
>>     <4>Process hald (pid: 2117, task: 000000007d200c40, ksp: 0000000=
07ab33880)
>>     <4>Krnl PSW : 0704100180000000 00000000003a15f8 (_raw_read_trylo=
ck+0x0/0x28)
>>     <4>           R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:0 CC:1 PM:0=
 EA:3
>>     <4>Krnl GPRS: 16c8a00000000000 000000007d200c40 000000007575ed18=
 0000000000000003
>>     <4>           00000000005853d2 000000007d201470 0000000000000002=
 000000007ab33c30
>>     <4>           0000000075746c78 000000007a74da48 000000000051a16a=
 000000007575ed18
>>     <4>           000000007575ed30 00000000005da190 00000000005853dc=
 000000007ab338c8
>>     <4>Krnl Code: 00000000003a15e8: c03000185811        larl    %r3,=
6ac60a
>>     <4>           00000000003a15ee: c0e5fffffdd9        brasl   %r14=
,3a11a0
>>     <4>           00000000003a15f4: a7f4ffce            brc     15,3=
a1590
>>     <4>          >00000000003a15f8: 58302000            l       %r3,=
0(%r2)
>>     <4>           00000000003a15fc: b9170033            llgtr   %r3,=
%r3
>>     <4>           00000000003a1600: 1853                lr      %r5,=
%r3
>>     <4>           00000000003a1602: 1813                lr      %r1,=
%r3
>>     <4>           00000000003a1604: a75a0001            ahi     %r5,=
1
>>     <4>Call Trace:
>>     <4>([<00000000005853d2>] _read_lock+0x5a/0x98)
>>     <4> [<000000000051a16a>] unix_write_space+0x36/0xb0
> [...]
>=20
> So it looks like that struct sock *sk is already gone in unix_write_s=
pace.
> Since I have no clue about the socket code, I can only guess that the=
re is a
> locking or refcount issue.

2.6.31 has a known bug

2.6.31.4 should correct it

commit 657453424a3c382035983f9a47306fafea730f6d
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Thu Sep 24 10:49:24 2009 +0000

    net: Fix sock_wfree() race
   =20
    [ Upstream commit d99927f4d93f36553699573b279e0ff98ad7dea6 ]
   =20
    Commit 2b85a34e911bf483c27cfdd124aeb1605145dc80
    (net: No more expensive sock_hold()/sock_put() on each tx)
    opens a window in sock_wfree() where another cpu
    might free the socket we are working on.
   =20
    A fix is to call sk->sk_write_space(sk) while still
    holding a reference on sk.
   =20
    Reported-by: Jike Song <albcamus@gmail.com>
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
    Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>


Please try 2.6.31.6 ;)
