From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [s390] networking related oops during boot on Hercules (was:
 build failure)
Date: Wed, 28 Nov 2007 10:42:24 -0800
Message-ID: <20071128104224.6c270553@freepuppy.rosehill>
References: <200711281127.30051.elendil@planet.nl>
	<200711281151.58236.borntraeger@de.ibm.com>
	<200711281324.02748.elendil@planet.nl>
	<200711281718.48661.borntraeger@de.ibm.com>
	<m1mysye0xf.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Christian Borntraeger <borntraeger@de.ibm.com>,
	Frans Pop <elendil@planet.nl>, linux-s390@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ursula Braun <braunu@de.ibm.com>,
	Peter Tiedemann <ptiedem@de.ibm.com>, <netdev@vger.kernel.org>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42215 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751274AbXK1SnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 13:43:16 -0500
In-Reply-To: <m1mysye0xf.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 28 Nov 2007 10:26:36 -0700
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Christian Borntraeger <borntraeger@de.ibm.com> writes:
> 
> > Am Mittwoch, 28. November 2007 schrieb Frans Pop:
> > [...]
> >> During boot I get the following oops in the Hercules emulator.
> >> 2.6.22 runs fine on Hercules; I've not tried .23 on it.
> > [...]
> >> ------------  cut here !------------
> >> kernel BUG at net/core/dev.c:852 +
> >> illegal operation: 0001  #1!
> >> Modules linked in: ctc fsm tape_34xx cu3088 tape ccwgroup tape_class dm_mirror
> > d
> >> m_snapshot dm_mod dasd_eckd_mod dasd_mod
> >> CPU:    1    Not tainted
> >> Process hwup (pid: 990, task: 0f034c00, ksp: 0f305be0)
> >> Krnl PSW : 070c0000 8019d0da (dev_alloc_name+0x1e/0x58)
> >>            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:0 CC:0 PM:0
> >> Krnl GPRS: 00132700 00000000 0f398800 0f398800
> >>            00000000 80132796 0f305d7a 00000002
> >>            0f1ada00 0f3c1f08 0f3c1f00 0f398800
> >>            0f398800 8019d0c2 0f305ca0 0f305c30
> >> Krnl Code: 8019d0cc: f000bf1f2460       srp     3871(1,%r11),1120(%r2),0
> >>            8019d0d2: a7740004           brc     7,8019d0da
> >>            8019d0d6: a7f40001           brc     15,8019d0d8
> >>           >8019d0da: 5810d04e           l       %r1,78(%r13)
> >>            8019d0de: 41a0f060           la      %r10,96(%r15)
> >>            8019d0e2: 5820c460           l       %r2,1120(%r12)
> >>            8019d0e6: 184a               lr      %r4,%r10
> >>            8019d0e8: 0de1               basr    %r14,%r1
> >> Call Trace:
> >> ( <0000000000000000>! _ehead+0xfffee000/0x80)
> >>   <000000000019d710>! register_netdev+0x34/0x6c
> >>   <00000000108a561e>! ctc_new_device+0x3ee/0x590  ctc!
> >>   <0000000010861398>! ccwgroup_online_store+0xb0/0x13c  ccwgroup!
> >>   <00000000000c962a>! sysfs_write_file+0xca/0x130
> >> <00000000000840e6>! vfs_write+0x92/0x128 +
> >>   <00000000000847e8>! sys_write+0x40/0x70
> >>   <000000000002098a>! sysc_do_restart+0x12/0x16
> >>   <0000000077f0abaa>! 0x77f0abaa
> >
> >
> > This seems to be related to the new network namespace code by Eric
> > Biederman (CCed). Can you try the following (untested) patch? I also 
> > CCed Ursula and Peter as they know the ctc code better than me.
> 
> Can you instead change the allocation to be alloc_netdev instead of
> just a plain old kzalloc.    That will fix the problem in a much
> more forward compatible way.  The current code is also going to
> have problems with dynamically sized array at the end of struct
> net_device.
> 
> You ought to also be able to make the allocation unconditional
> as that function only has one caller and it does not pass in
> a struct net_device.
> 
> Eric
> 

Any code that calls register_netdev with a kzalloc'd pointer is
fundamentally flawed.  Read Documentation/networking/netdevices

