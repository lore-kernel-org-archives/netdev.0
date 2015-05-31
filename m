From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: 4.0.4 - bnx2x - DEBUG_LOCKS_WARN_ON(in_interrupt())
Date: Sun, 31 May 2015 11:34:50 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63DAB354@avmb3.qlogic.org>
References: <20150527161037.GF20255@pcnci.linuxbox.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Nikola Ciprich <nikola.ciprich@linuxbox.cz>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:45877 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751337AbbEaLfN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 May 2015 07:35:13 -0400
In-Reply-To: <20150527161037.GF20255@pcnci.linuxbox.cz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi,
> 
> just wanted to report, that I'm getting following trace on 4.0.4 kernel:
> 
> [  +0.301517] ------------[ cut here ]------------ [  +0.000227] WARNING: CPU: 0
> PID: 0 at kernel/locking/mutex.c:877 mutex_trylock+0x15d/0x190() [
> +0.000376] DEBUG_LOCKS_WARN_ON(in_interrupt())
...
> 0000000000000001 [  +0.000622] Call Trace:
> [  +0.000215]  <IRQ>  [<ffffffff814ab37b>] dump_stack+0x4f/0x74 [  +0.000351]
> [<ffffffff8104f715>] warn_slowpath_common+0x95/0xe0 [  +0.000224]
> [<ffffffff8104f816>] warn_slowpath_fmt+0x46/0x70 [  +0.000224]
> [<ffffffff814acd3d>] mutex_trylock+0x15d/0x190 [  +0.004247]
> [<ffffffffa055f7d7>] bnx2x_stats_handle+0x47/0x190 [bnx2x] [  +0.000230]
> [<ffffffffa051107d>] bnx2x_timer+0x19d/0x1b0 [bnx2x] [  +0.000228]
...
> 
> It's x86_64 4.0.4 kernel, running on supermicro X10DRW box.

Hi, thanks for the notice Nikola.

his was introduced by dff173de8495
("bnx2x: Fix statistics locking scheme") Which apparently took the
wrong assumption that mutex_trylock() can be called from a timer.

Looks like we'll have to change the implementation into using a
semaphore instead, which can be used from software interrupt context.

[Notice that it's possible that the only thing enforcing this and
Thus causing the warn is CONFIG_DEBUG_MUTEXES; So for now,
You might consider removing such an option as a temporary solution]

Thanks,
Yuval
