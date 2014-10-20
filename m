From: Dave Jones <davej@redhat.com>
Subject: Re: localed stuck in recent 3.18 git in copy_net_ns?
Date: Mon, 20 Oct 2014 16:43:26 -0400
Message-ID: <20141020204326.GA25668@redhat.com>
References: <20141020141515.0688bf33@voldemort.scrye.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kevin Fenzi <kevin@scrye.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28224 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752864AbaJTUnh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Oct 2014 16:43:37 -0400
Content-Disposition: inline
In-Reply-To: <20141020141515.0688bf33@voldemort.scrye.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 20, 2014 at 02:15:15PM -0600, Kevin Fenzi wrote:
 
 > I'm seeing suspend/resume failures with recent 3.18 git kernels. 
 > 
 > Full dmesg at: http://paste.fedoraproject.org/143615/83287914/
 > 
 > The possibly interesting parts: 
 > 
 > [   78.373144] PM: Syncing filesystems ... done.
 > [   78.411180] PM: Preparing system for mem sleep
 > [   78.411995] Freezing user space processes ... 
 > [   98.429955] Freezing of tasks failed after 20.001 seconds (1 tasks refusing to freeze, wq_busy=0):
 > [   98.429971] (-localed)      D ffff88025f214c80     0  1866      1 0x00000084
 > [   98.429975]  ffff88024e777df8 0000000000000086 ffff88009b4444b0 0000000000014c80
 > [   98.429978]  ffff88024e777fd8 0000000000014c80 ffff880250ffb110 ffff88009b4444b0
 > [   98.429981]  0000000000000000 ffffffff81cec1a0 ffffffff81cec1a4 ffff88009b4444b0
 > [   98.429983] Call Trace:
 > [   98.429991]  [<ffffffff8175d619>] schedule_preempt_disabled+0x29/0x70
 > [   98.429994]  [<ffffffff8175f433>] __mutex_lock_slowpath+0xb3/0x120
 > [   98.429997]  [<ffffffff8175f4c3>] mutex_lock+0x23/0x40
 > [   98.430001]  [<ffffffff8163e325>] copy_net_ns+0x75/0x140
 > [   98.430005]  [<ffffffff810b8c2d>] create_new_namespaces+0xfd/0x1a0
 > [   98.430008]  [<ffffffff810b8e5a>] unshare_nsproxy_namespaces+0x5a/0xc0
 > [   98.430012]  [<ffffffff81098813>] SyS_unshare+0x193/0x340
 > [   98.430015]  [<ffffffff817617a9>] system_call_fastpath+0x12/0x17

I've seen similar soft lockup traces from the sys_unshare path when running my
fuzz tester.  It seems that if you create enough network namespaces,
it can take a huge amount of time for them to be iterated.
(Running trinity with '-c unshare' you can see the slow down happen. In
 some cases, it takes so long that the watchdog process kills it --
 though the SIGKILL won't get delivered until the unshare() completes)

Any idea what this machine had been doing prior to this that may have
involved creating lots of namespaces ?

	Dave
