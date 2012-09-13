From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V3 1/2] IB/ipoib: Add rtnl_link_ops support
Date: Thu, 13 Sep 2012 14:28:35 +0300
Message-ID: <5051C363.7030505@mellanox.com>
References: <1345724119-32110-1-git-send-email-ogerlitz@mellanox.com> <1345724119-32110-2-git-send-email-ogerlitz@mellanox.com> <Pine.GSO.4.63.1208291450330.1098@stinky-local.trash.net> <5050668B.1010105@mellanox.com> <CAKoUAr=8zZA9EgvJEVrd0a-Uw=zzksHj+5P2Sp3Lb4vXgSJRYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>, Shlomo Pongratz <shlomop@mellanox.com>
To: Rami Rosen <roszenrami@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:46986 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756392Ab2IML2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 07:28:41 -0400
In-Reply-To: <CAKoUAr=8zZA9EgvJEVrd0a-Uw=zzksHj+5P2Sp3Lb4vXgSJRYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/09/2012 17:53, Rami Rosen wrote:
>  From the dump of CPU #1, it seems indeed not related at all to "modprobe -r".
>
> Could it be that there is some IB stack sysfs write activity?
> (regardless of the modprobe -r" you issued) ?  I see some candidates for it.
>
> delete_child() is a method of the IB stack (ipoib/ipoib_main.c)
>
> Maybe in order to help debug the problem, you might try to add in
> delete_child() method, print of the name of the attribute which is being deleted?
>
> (struct device_attribute has a a member "struct attribute attr",
> which in turn has  "const char *name").
>

> the existing dependency chain (in reverse order) is:
>
> -> #1 (rtnl_mutex){+.+.+.}:
>        [<ffffffff81072b30>] lock_acquire+0x14f/0x19b
>        [<ffffffff81396a43>] mutex_lock_nested+0x64/0x2ce
>        [<ffffffff812fc103>] rtnl_lock+0x12/0x14
>        [<ffffffff812eecf1>] netdev_run_todo+0xa5/0x27e
>        [<ffffffff812fc0dd>] rtnl_unlock+0x9/0xb
>        [<ffffffffa0394889>] ipoib_vlan_delete+0x111/0x148 [ib_ipoib]
>        [<ffffffffa038d29b>] delete_child+0x44/0x60 [ib_ipoib]
>        [<ffffffff81247bd8>] dev_attr_store+0x1b/0x1d
>        [<ffffffff8114e223>] sysfs_write_file+0x103/0x13f
>        [<ffffffff810f206b>] vfs_write+0xae/0x133
>        [<ffffffff810f21a9>] sys_write+0x45/0x6c
>        [<ffffffff813a05e2>] system_call_fastpath+0x16/0x1b 

I've added code in ipoib_delete_child to print the caller PID and dump 
the stack,
its triggeredwhen I do "echo 0x8001 > /sys/class/net/ib0/delete_child" 
but the lockdep
warningis raised only when I actually unload the module, and no print... 
that is
ipoib_delete_child  isn't called.

Or.
