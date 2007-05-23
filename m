From: Anant Nitya <kernel@prachanda.info>
Subject: Re: [BUG] local_softirq_pending storm
Date: Thu, 24 May 2007 04:54:29 +0530
Message-ID: <200705240454.30353.kernel__47210.8887196102$1179963433$gmane$org@prachanda.hub>
References: <200705091942.22920.kernel@prachanda.hub> <46547345.8000808@redhat.com> <46548A30.9000801@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Chuck Ebbert <cebbert@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sumo.dreamhost.com ([66.33.216.29]:60804 "EHLO
	sumo.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756722AbXEWXgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 19:36:39 -0400
Received: from spaceymail-a2.g.dreamhost.com (sd-green-bigip-66.dreamhost.com [208.97.132.66])
	by sumo.dreamhost.com (Postfix) with ESMTP id 86CFF1797E4
	for <netdev@vger.kernel.org>; Wed, 23 May 2007 16:36:09 -0700 (PDT)
In-Reply-To: <46548A30.9000801@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 24 May 2007 00:08:40 Chuck Ebbert wrote:
> Chuck Ebbert wrote:
> > https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=240982
>
> Another; these started to appear after the below patch was merged:
> > Index: linux/kernel/sched.c
> >
> > > ===================================================================
> > > --- linux.orig/kernel/sched.c
> > > +++ linux/kernel/sched.c
> > > @@ -4212,9 +4212,7 @@ int __sched cond_resched_softirq(void)
> > >  	BUG_ON(!in_softirq());
> > >
> > >  	if (need_resched() && system_state == SYSTEM_RUNNING) {
> > > -		raw_local_irq_disable();
> > > -		_local_bh_enable();
> > > -		raw_local_irq_enable();
> > > +		local_bh_enable();
> > >  		__cond_resched();
> > >  		local_bh_disable();
> > >  		return 1;
>
> May 23 19:26:26 localhost kernel: BUG: warning at
> kernel/softirq.c:138/local_bh_enable() (Not tainted) May 23 19:26:26
> localhost kernel:  [<c042b2ef>] local_bh_enable+0x45/0x92 May 23 19:26:26
> localhost kernel:  [<c06036b7>] cond_resched_softirq+0x2c/0x42 May 23
> 19:26:26 localhost kernel:  [<c059d5d0>] release_sock+0x54/0xa3 May 23
> 19:26:26 localhost kernel:  [<c04373af>] prepare_to_wait+0x24/0x3f May 23
> 19:26:26 localhost kernel:  [<c05e267f>] inet_stream_connect+0x116/0x1ff
> May 23 19:26:26 localhost kernel:  [<c0437265>]
> autoremove_wake_function+0x0/0x35 May 23 19:26:26 localhost kernel: 
> [<c059c339>] sys_connect+0x82/0xad May 23 19:26:26 localhost kernel: 
> [<c059d58f>] release_sock+0x13/0xa3 May 23 19:26:26 localhost kernel: 
> [<c0604ad5>] _spin_unlock_bh+0x5/0xd May 23 19:26:26 localhost kernel: 
> [<c059e714>] sock_setsockopt+0x4a8/0x4b2 May 23 19:26:26 localhost kernel: 
> [<c059b6b6>] sock_attach_fd+0x70/0xd2 May 23 19:26:26 localhost kernel: 
> [<c04774a0>] get_empty_filp+0xfc/0x170 May 23 19:26:26 localhost kernel: 
> [<c059b54f>] sys_setsockopt+0x9b/0xa7 May 23 19:26:26 localhost kernel: 
> [<c059cb83>] sys_socketcall+0xac/0x261 May 23 19:26:26 localhost kernel: 
> [<c0404f70>] syscall_call+0x7/0xb

strange, while applying the concerned patch first time I was hand editing __ 
kernel/sched.c __ and stupidly typed _local_bh_enable() instead of 
local_bh_enable() and when did a reboot, as soon as I got inside X I was 
welcomed with following message in system log.

[  152.692609] BUG: at kernel/softirq.c:122 _local_bh_enable()
[  152.692637]  [<b040624d>] show_trace_log_lvl+0x1a/0x2f
[  152.692658]  [<b0406801>] show_trace+0x12/0x14
[  152.692668]  [<b0406885>] dump_stack+0x16/0x18
[  152.692678]  [<b0428d66>] _local_bh_enable+0x8b/0xc3
[  152.692688]  [<b059e497>] cond_resched_softirq+0x2b/0x40
[  152.692700]  [<b05797b6>] established_get_first+0x19/0xad
[  152.692712]  [<b057a831>] tcp_seq_next+0x76/0x8c
[  152.692722]  [<b04875ef>] seq_read+0x17b/0x264
[  152.692733]  [<b047102a>] vfs_read+0xad/0x161
[  152.692745]  [<b04714b6>] sys_read+0x3d/0x61
[  152.692755]  [<b04050d4>] syscall_call+0x7/0xb
[  152.692765]  =======================
[  152.692770] BUG: at kernel/lockdep.c:1937 trace_softirqs_on()
[  152.692777]  [<b040624d>] show_trace_log_lvl+0x1a/0x2f
[  152.692789]  [<b0406801>] show_trace+0x12/0x14
[  152.692800]  [<b0406885>] dump_stack+0x16/0x18
[  152.692810]  [<b043f5a5>] trace_softirqs_on+0x5f/0xa5
[  152.692822]  [<b0428d8e>] _local_bh_enable+0xb3/0xc3
[  152.692831]  [<b059e497>] cond_resched_softirq+0x2b/0x40
[  152.692842]  [<b05797b6>] established_get_first+0x19/0xad
[  152.692852]  [<b057a831>] tcp_seq_next+0x76/0x8c
[  152.692862]  [<b04875ef>] seq_read+0x17b/0x264
[  152.692870]  [<b047102a>] vfs_read+0xad/0x161
[  152.692879]  [<b04714b6>] sys_read+0x3d/0x61
[  152.692889]  [<b04050d4>] syscall_call+0x7/0xb
[  152.692899]  =======================
[  159.257890] NOHZ: local_softirq_pending 22
[  159.266009] NOHZ: local_softirq_pending 22
[  159.273965] NOHZ: local_softirq_pending 22
[  159.281884] NOHZ: local_softirq_pending 22
[  160.712828] NOHZ: local_softirq_pending 22
[  162.609377] NOHZ: local_softirq_pending 22
[  162.609804] NOHZ: local_softirq_pending 22
[  162.610054] NOHZ: local_softirq_pending 22
[  162.610279] NOHZ: local_softirq_pending 22
[  162.610502] NOHZ: local_softirq_pending 22

After realzing my mistake, I changed it to local_bh_enable() as was in patch 
and since then not a single BUG or local_softirq_pending message occurs in 
system log, maybe my system waiting for that condition to happen :).


-- 
Out of many thousands, one may endeavor for perfection, and of
those who have achieved perfection, hardly one knows Me in truth.
				-- Gita Sutra Of Mysticism
