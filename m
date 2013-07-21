From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: cancel work queue when interface goes down
Date: Sun, 21 Jul 2013 20:35:51 +0200
Message-ID: <20130721183551.GA10925@electric-eye.fr.zoreil.com>
References: <1574882.LCoXNHVmA8@al>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:45130 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755958Ab3GUSgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 14:36:01 -0400
Content-Disposition: inline
In-Reply-To: <1574882.LCoXNHVmA8@al>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Wu <lekensteyn@gmail.com> :
> Currently, the work queue is initialised in rtl_open, used to dispatch rtl_task
> and canceled in rtl_remove_one (when the PCI device gets removed). This causes a
> lockdep warning when the work queue is uninitialised:

Ok.

> [  106.005403] INFO: trying to register non-static key.
> [  106.005416] the code is fine but needs lockdep annotation.
> [  106.005419] turning off the locking correctness validator.
> [  106.005426] CPU: 3 PID: 2576 Comm: tee Tainted: G        W  O 3.11.0-rc1-cold-00021-g3aaf2fe-dirty #1
> [  106.005429] Hardware name: Gigabyte Technology Co., Ltd. To be filled by O.E.M./Z68X-UD3H-B3, BIOS U1l 03/08/2013
> [  106.005433]  ffff8806014fbf60 ffff880601521b58 ffffffff8166d3e7 0000000000000000
> [  106.005498]  ffff8805fc0598f8 ffff880601521bf8 ffffffff810ad6d6 ffff880601521bb8
> [  106.005508]  ffffffff00000000 ffff880600000000 0000000600000000 ffff880601521ce0
> [  106.005520] Call Trace:
[snip]

Subject: fix work queue lockdep warning when interface goes down

-> you tell what you do. You do not need to tell how.

[45 lines long explanation]

Your analysis is good but the search of a solution could be shortened a bit.

cancel_work_sync expects rtl_task to proceed synchronously. rtl_task depends
on the availability of rtl_lock_work. cancel_work_sync must thus be done
outside of rtl_lock_work section.

-> these are facts. Any reader can check the code and we can Acked-by.

rtl_task is an entry point for low-priority (wrt Rx / Tx) work. It takes a
slow, sleepable lock: rtl_lock_work.

If the code took much longer for you to reach the "Wellwellwell" state than
you had hoped for, it could be more informative to add a comment before the
'wk' struct in rtl8169_private than to leave it in the commit message. I did
put everyting rtl_task-related in the 'wk' struct but a small comment about
the intent would not had hurt.

The patch should be a two-liner with a few lines of explanations.
It's a small problem. Let's save bandwidth for ugly ones and big
features.

Ok ?

-- 
Ueimor
