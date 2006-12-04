From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPSEC][6/7] inter address family ipsec tunnel
Date: Sun, 03 Dec 2006 17:58:47 -0800 (PST)
Message-ID: <20061203.175847.08320724.davem@davemloft.net>
References: <20061124143901.0db589b8.kazunori@miyazawa.org>
	<20061130.170503.35356518.davem@davemloft.net>
	<456FB878.4080109@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: miika@iki.fi, Diego.Beltrami@hiit.fi, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52450
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1758354AbWLDB7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 20:59:30 -0500
To: kazunori@miyazawa.org
In-Reply-To: <456FB878.4080109@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Kazunori, a bug from the changes I did apply:

[  761.318131] kernel BUG at net/key/af_key.c:1925!
[  761.318285] Caller[000000001010c0e0]: pfkey_send_policy_notify+0x6c/0x250 [af_key]
[  761.318296] Caller[000000000062f6dc]: km_policy_notify+0x28/0x50
[  761.318309] Caller[000000001014a94c]: xfrm_add_policy+0xd8/0x100 [xfrm_user]
[  761.318326] Caller[0000000010148b68]: xfrm_user_rcv_msg+0x1a4/0x1d0 [xfrm_user]
[  761.318336] Caller[00000000005ecef4]: netlink_run_queue+0x60/0x138
[  761.318346] Caller[00000000101487b0]: xfrm_netlink_rcv+0x28/0x48 [xfrm_user]
[  761.318356] Caller[00000000005ecffc]: netlink_data_ready+0x30/0x70
[  761.318363] Caller[00000000005eaa18]: netlink_sendskb+0x28/0x50
[  761.318370] Caller[00000000005ecc70]: netlink_sendmsg+0x2f0/0x300
[  761.318377] Caller[00000000005d22d0]: sock_aio_write+0xe0/0xec
[  761.318391] Caller[0000000000490ccc]: do_sync_write+0x88/0xd0
[  761.318400] Caller[00000000004913c8]: vfs_write+0x90/0x124
[  761.318408] Caller[0000000000491928]: sys_write+0x34/0x60
[  761.318415] Caller[0000000000406a54]: linux_sparc_syscall32+0x3c/0x40
[  761.318428] Caller[0000000000035cc8]: 0x35cd0

I think there is a mistake about the guarentees of the application
causing the xp->family field to be set properly.

Or in this specific case, xfrm_user netlink setting p->sel.family
in the struct xfrm_userpolicy of a XFRM_MSG_NEWPOLICY or
XFRM_MSG_UPDPOLICY netlink message.

This was with openswan.

But the user application doesn't matter, if we have requirements
about xp->family, we should enforce it, and this does not happen
which is why the above BUG() is able to trigger.
