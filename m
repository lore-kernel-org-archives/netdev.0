From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 3.11] genetlink: fix family dump race
Date: Sun, 11 Aug 2013 21:29:42 -0700 (PDT)
Message-ID: <20130811.212942.413012801159758438.davem@davemloft.net>
References: <1375879163-2116-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	tgraf-G/eBtMaohhA@public.gmane.org, andrei.otcheretianski-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	ilan.peer-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1375879163-2116-1-git-send-email-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Wed,  7 Aug 2013 14:39:23 +0200

> When dumping generic netlink families, only the first dump call
> is locked with genl_lock(), which protects the list of families,
> and thus subsequent calls can access the data without locking,
> racing against family addition/removal. This can cause a crash.
> Fix it - the locking needs to be conditional because the first
> time around it's already locked.
> 
> BUG: unable to handle kernel paging request at f8467360
> IP: [<c14c56bb>] ctrl_dumpfamily+0x6b/0xe0
> EIP: 0060:[<c14c56bb>] EFLAGS: 00210297 CPU: 2
> EIP is at ctrl_dumpfamily+0x6b/0xe0
> EAX: f8467378 EBX: f8467340 ECX: 00000000 EDX: ec1610c4
> ESI: 00000001 EDI: c2077cc0 EBP: c46c3c00 ESP: c46c3bd4
>  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> CR0: 80050033 CR2: f8467360 CR3: 26e54000 CR4: 001407d0
> DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> DR6: ffff0ff0 DR7: 00000400
> Process wpa_supplicant (pid: 20081, ti=c46c2000 task=c44640b0 task.ti=c46c2000)
> Call Trace:
>  [<c14c20bc>] netlink_dump+0x5c/0x200
>  [<c14c3450>] __netlink_dump_start+0x140/0x160
>  [<c14c5172>] genl_rcv_msg+0x102/0x270
>  [<c14c4b5e>] netlink_rcv_skb+0x8e/0xb0
>  [<c14c505c>] genl_rcv+0x1c/0x30
>  [<c14c456b>] netlink_unicast+0x17b/0x1c0
>  [<c14c47d4>] netlink_sendmsg+0x224/0x370
>  [<c1485adf>] sock_sendmsg+0xff/0x120

I completely agree with your analysis that we need locking here, but
the crash OOPS backtrace doesn't make any sense to me.

The bug should trigger when we enter the dump continuation path, which
would look like:

	ctrl_dumpfamily()
	netlink_dump()
	netlink_recvmsg()
	...

Since this is the only way we get into ctrl_dumpfamily() without
holding genl_lock().

But in your trace we're going through genl_rcv() which means this is
the first call of the dump, and genl_rcv() takes the necessary locks.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
