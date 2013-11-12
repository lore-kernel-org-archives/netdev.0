From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: shutdown(3) and bluetooth.
Date: Wed, 13 Nov 2013 07:32:09 +0900
Message-ID: <FC5CE013-B077-4EA5-81C1-A7D8B4A5EF85@holtmann.org>
References: <20131112211125.GA2912@redhat.com> <DF4C2B40-BD87-4E88-911D-E3E5F488CAE4@holtmann.org> <20131112221038.GA6689@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1822\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org development"
	<linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20131112221038.GA6689-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

>>> Is shutdown() allowed to block indefinitely ? The man page doesn't say either way,
>>> and I've noticed that my fuzz tester occasionally hangs for days spinning in bt_sock_wait_state()
>>> 
>>> Is there something I should be doing to guarantee that this operation
>>> will either time out, or return instantly ?
>>> 
>>> In this specific case, I doubt anything is on the "sender" end of the socket, so
>>> it's going to be waiting forever for a state change that won't arrive.
>> 
>> can you give us some extra information here. What kind of Bluetooth socket is this actually. From the top of my head, I have no idea why we would even wait forever. Normally when all low-level links are gone, the socket will shut down anyway.
> 
> Here's the info I found in the logs, it looks like this was the only bluetooth socket.
> 
> fd[195] = domain:31 (PF_BLUETOOTH) type:0x5 protocol:2
> Setsockopt(1 d 2134000 8) on fd 195

this is a bit confusing. Protocol 2 is actually SCO, but the stack trace shows RFCOMM.

> it doesn't look like any further operations were done on this fd during the fuzzers runtime.
> 
> Quick way to reproduce:
> 
> ./trinity -P PF_BLUETOOTH -l off -c setsockopt
> 
> let it run a few seconds, and then ctrl-c.  The main process will never exit.
> 
> 5814 pts/6    Ss     0:00              |       \_ bash
> 5876 pts/6    S+     0:00              |       |   \_ ./trinity -P PF_BLUETOOTH -l off -c setsockopt
> 5877 pts/6    Z+     0:00              |       |       \_ [trinity] <defunct>
> 5878 pts/6    S+     0:01              |       |       \_ [trinity-main]
> 
> $ sudo cat /proc/5878/stack
> [<ffffffffa04397a2>] bt_sock_wait_state+0xc2/0x190 [bluetooth]
> [<ffffffffa0847a75>] rfcomm_sock_shutdown+0x85/0xb0 [rfcomm]
> [<ffffffffa0847ad9>] rfcomm_sock_release+0x39/0xb0 [rfcomm]
> [<ffffffff81532fcf>] sock_release+0x1f/0x80
> [<ffffffff81533042>] sock_close+0x12/0x20
> [<ffffffff811a9ac1>] __fput+0xe1/0x230
> [<ffffffff811a9c5e>] ____fput+0xe/0x10
> [<ffffffff8108534c>] task_work_run+0xbc/0xe0
> [<ffffffff8106944c>] do_exit+0x2bc/0xa20
> [<ffffffff81069c2f>] do_group_exit+0x3f/0xa0
> [<ffffffff81069ca4>] SyS_exit_group+0x14/0x20
> [<ffffffff81656b27>] tracesys+0xdd/0xe2
> [<ffffffffffffffff>] 0xffffffffffffffff

What kernel did you run this against? It is a shot in the dark, but can you try linux-next quickly. There was a socket related fix for the socket options where we confused RFCOMM vs L2CAP struct sock.

Regards

Marcel
