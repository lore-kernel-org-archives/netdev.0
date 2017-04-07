From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] bridge: netlink: register netdevice before
 executing changelink
Date: Fri, 7 Apr 2017 10:10:55 -0400
Message-ID: <20170407101055.745d95d0@plumbers-lap.home.lan>
References: <20170407124915.15508-1-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <bridge@lists.linux-foundation.org>, <mlxsw@mellanox.com>,
        <peter@svinota.eu>, <cera@cera.cz>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:34545 "EHLO
        mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755430AbdDGOLN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 10:11:13 -0400
Received: by mail-io0-f175.google.com with SMTP id b140so50311381iof.1
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 07:11:13 -0700 (PDT)
In-Reply-To: <20170407124915.15508-1-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 7 Apr 2017 15:49:15 +0300
<idosch@mellanox.com> wrote:

> From: Ido Schimmel <idosch@mellanox.com>
> 
> Peter reported a kernel oops when executing the following command:
> 
> $ ip link add name test type bridge vlan_default_pvid 1
> 
> [13634.939408] BUG: unable to handle kernel NULL pointer dereference at
> 0000000000000190
> [13634.939436] IP: __vlan_add+0x73/0x5f0
> [...]
> [13634.939783] Call Trace:
> [13634.939791]  ? pcpu_next_unpop+0x3b/0x50
> [13634.939801]  ? pcpu_alloc+0x3d2/0x680
> [13634.939810]  ? br_vlan_add+0x135/0x1b0
> [13634.939820]  ? __br_vlan_set_default_pvid.part.28+0x204/0x2b0
> [13634.939834]  ? br_changelink+0x120/0x4e0
> [13634.939844]  ? br_dev_newlink+0x50/0x70
> [13634.939854]  ? rtnl_newlink+0x5f5/0x8a0
> [13634.939864]  ? rtnl_newlink+0x176/0x8a0
> [13634.939874]  ? mem_cgroup_commit_charge+0x7c/0x4e0
> [13634.939886]  ? rtnetlink_rcv_msg+0xe1/0x220
> [13634.939896]  ? lookup_fast+0x52/0x370
> [13634.939905]  ? rtnl_newlink+0x8a0/0x8a0
> [13634.939915]  ? netlink_rcv_skb+0xa1/0xc0
> [13634.939925]  ? rtnetlink_rcv+0x24/0x30
> [13634.939934]  ? netlink_unicast+0x177/0x220
> [13634.939944]  ? netlink_sendmsg+0x2fe/0x3b0
> [13634.939954]  ? _copy_from_user+0x39/0x40
> [13634.939964]  ? sock_sendmsg+0x30/0x40
> [13634.940159]  ? ___sys_sendmsg+0x29d/0x2b0
> [13634.940326]  ? __alloc_pages_nodemask+0xdf/0x230
> [13634.940478]  ? mem_cgroup_commit_charge+0x7c/0x4e0
> [13634.940592]  ? mem_cgroup_try_charge+0x76/0x1a0
> [13634.940701]  ? __handle_mm_fault+0xdb9/0x10b0
> [13634.940809]  ? __sys_sendmsg+0x51/0x90
> [13634.940917]  ? entry_SYSCALL_64_fastpath+0x1e/0xad
> 
> The problem is that the bridge's VLAN group is created after setting the
> default PVID, when registering the netdevice and executing its
> ndo_init().
> 
> Fix this by changing the order of both operations, so that
> br_changelink() is only processed after the netdevice is registered,
> when the VLAN group is already initialized.
> 
> The changelink() call is done on a best-effort basis since unregistering
> the netdevice upon failure won't perform a proper cleanup due to a
> missing ndo_uninit(), which I'll try to add for net-next.
> 
> Fixes: b6677449dff6 ("bridge: netlink: call br_changelink() during br_dev_newlink()")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Reported-by: Peter V. Saveliev <peter@svinota.eu>
> ---
> Please consider this for 4.4.y, 4.9.y and 4.10.y as well.

Although this patch fixes the OOPS it breaks all the error handling
of br_changelink. If bad attributes are passed to newlink, you leave a
broken partially configured bridge device. The code needs to cleanup
and return the correct errno.
