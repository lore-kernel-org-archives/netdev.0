From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: deadlock in 2.6.18.2 related to bridging?
Date: Wed, 14 Feb 2007 13:12:05 -0800
Message-ID: <20070214131205.1ace04ba@freekitty>
References: <45D26479.7030103@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:45930 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932598AbXBNVMH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Feb 2007 16:12:07 -0500
In-Reply-To: <45D26479.7030103@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Feb 2007 17:23:05 -0800
Ben Greear <greearb@candelatech.com> wrote:

> I think I may have found a deadlock bug in 2.6.18.2.  This is
> with my hacked kernel, but my binary module has not been loaded.
> 
> I have several bridges configured, including some containing
> my redirect-device virtual devices and ethernet devices.
> 
> I believe the deadlock is this:
> 
> The work-queue process is calling this, and is blocked on
> rtnl:
> 
>   [<c0337ede>] __mutex_lock_slowpath+0xbe/0x2a0
>   [<c03380dc>] mutex_lock+0x1c/0x20
>   [<c02dd1db>] __rtnl_lock+0x1b/0x40
>   [<df909dc2>] port_carrier_check+0x22/0xa0 [bridge]
>   [<c012d21b>] run_workqueue+0x7b/0x100
>   [<c012d9cf>] worker_thread+0x10f/0x130
>   [<c01304b5>] kthread+0xd5/0xe0
>   [<c0101005>] kernel_thread_helper+0x5/0x10

It is waiting for the other function to finish (in this case the ioctl).
 
> 
> But, the 'ip' program already has rtnl (acquired in devinet_ioctl),
> and is trying to flush the work-queue:
> 
> ip            D D9C34000  6600  2780   2775                     (NOTLB)
>         d9c35e1c 00000046 deeebae8 d9c34000 c010327f 00000001 d9c34000 00000260
>         deeeba80 00000001 d9c542b0 e548f009 0000001a 00020224 d9c543c0 0000007b
>         0000007b 00335517 00000000 deeeba80 deeebae8 00000053 d9c35e44 c012d30b
> Call Trace:
>   [<c012d30b>] flush_cpu_workqueue+0x6b/0xb0
>   [<c012d388>] flush_workqueue+0x38/0x50
>   [<c012d3fd>] flush_scheduled_work+0xd/0x10
>   [<df819665>] rtl8139_close+0x165/0x1a0 [8139too]
>   [<c02d4bd4>] dev_close+0x54/0x70
>   [<c02d3e31>] dev_change_flags+0x51/0x110
>   [<c0314e90>] devinet_ioctl+0x4b0/0x6a0
>   [<c031579b>] inet_ioctl+0x6b/0x80
>   [<c02c9627>] sock_ioctl+0x77/0x250
>   [<c017e1f8>] do_ioctl+0x28/0x80
>   [<c017e2a7>] vfs_ioctl+0x57/0x2b0
>   [<c017e539>] sys_ioctl+0x39/0x60
>   [<c01031ad>] sysenter_past_esp+0x56/0x99
>   [<b7fd5410>] 0xb7fd5410

The bug is in r8139too.c driver. It calls flush_scheduled_work
with RTNL mutex held, so any other work using it will get stuck.

> 
> Has this been fixed in later releases?

No but a different race (with device removal) has been fixed.



-- 
Stephen Hemminger <shemminger@linux-foundation.org>
