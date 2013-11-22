From: wangweidong <wangweidong1@huawei.com>
Subject: [PATCH] tipc: fix a lockdep warning
Date: Fri, 22 Nov 2013 16:18:54 +0800
Message-ID: <528F136E.1030506@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <dingtianhong@huawei.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <jon.maloy@ericsson.com>, <allan.stephens@windriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:58288 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638Ab3KVITX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 03:19:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PC1:tipc-config -netid=1234 -a=1.1.2 -be=eth:eth0/1.1.0
PC2:tipc-config -netid=1234 -a=1.1.3 -be=eth:eth0/1.1.0

I used a server code Like this:
----------------
    sk=socket(AF_TIPC,SOCK_RDM,0);
    bind(sk, &addr, len);
    while(1) {
        recvfrom(sk,...);
        ...
        sendto(sk,...);
    }
----------------

when I did ./server in PC1, I got a lockdep as bellow:

======================================================
[ INFO: possible circular locking dependency detected ]
3.12.0-lockdep+ #4 Not tainted
-------------------------------------------------------
server/3772 is trying to acquire lock:
(tipc_net_lock){++.-..}, at: [<ffffffffa02e324f>] tipc_link_send+0x2f/0xc0 [tipc]

but task is already holding lock:
(tipc_nametbl_lock){++--..}, at: [<ffffffffa02e83e6>] tipc_nametbl_publish+0x46/0xc0 [tipc]
 which lock already depends on the new lock.

the existing dependency chain (in reverse order) is:
 -> #1 (tipc_nametbl_lock){++--..}:
        [<ffffffff810a2547>] validate_chain+0x6a7/0x7d0
        [<ffffffff810a29d1>] __lock_acquire+0x361/0x610
        [<ffffffff810a2d62>] lock_acquire+0xe2/0x110
        [<ffffffff8151e061>] _raw_write_lock_bh+0x31/0x40
        [<ffffffffa02e5d40>] tipc_named_reinit+0x10/0x70 [tipc]
        [<ffffffffa02e8512>] tipc_net_start+0x22/0x80 [tipc]
        [<ffffffffa02dff0e>] tipc_core_start_net+0xe/0x40 [tipc]
        [<ffffffffa02df625>] cfg_set_own_addr+0x75/0xc0 [tipc]
        [<ffffffffa02df8f5>] tipc_cfg_do_cmd+0x135/0x550 [tipc]
        [<ffffffffa02e87f9>] handle_cmd+0x49/0xe0 [tipc]
        [<ffffffff814764fd>] genl_family_rcv_msg+0x22d/0x3c0
        [<ffffffff81476700>] genl_rcv_msg+0x70/0xd0
        [<ffffffff81474dc9>] netlink_rcv_skb+0x89/0xb0
        [<ffffffff81475f87>] genl_rcv+0x27/0x40
        [<ffffffff81474b1e>] netlink_unicast+0x14e/0x1a0
        [<ffffffff81475735>] netlink_sendmsg+0x245/0x420
        [<ffffffff814294f6>] __sock_sendmsg+0x66/0x80
        [<ffffffff814295c2>] sock_aio_write+0xb2/0xc0
        [<ffffffff811968f0>] do_sync_write+0x60/0x90
        [<ffffffff81198891>] vfs_write+0x1d1/0x1e0
        [<ffffffff811989bd>] SyS_write+0x5d/0xa0
        [<ffffffff81527522>] system_call_fastpath+0x16/0x1b

 -> #0 (tipc_net_lock){++.-..}:
        [<ffffffff810a1e2e>] check_prev_add+0x41e/0x490
        [<ffffffff810a2547>] validate_chain+0x6a7/0x7d0
        [<ffffffff810a29d1>] __lock_acquire+0x361/0x610
        [<ffffffff810a2d62>] lock_acquire+0xe2/0x110
        [<ffffffff8151e2f4>] _raw_read_lock_bh+0x34/0x50
        [<ffffffffa02e324f>] tipc_link_send+0x2f/0xc0 [tipc]
        [<ffffffffa02e617b>] named_cluster_distribute+0x6b/0x80 [tipc]
        [<ffffffffa02e62ab>] tipc_named_publish+0x7b/0x90 [tipc]
        [<ffffffffa02e841b>] tipc_nametbl_publish+0x7b/0xc0 [tipc]
        [<ffffffffa02e9958>] tipc_publish+0x98/0xf0 [tipc]
        [<ffffffffa02ebf58>] bind+0x78/0xb0 [tipc]
        [<ffffffff81428dc0>] SyS_bind+0xb0/0xd0
        [<ffffffff81527522>] system_call_fastpath+0x16/0x1b

 other info that might help us debug this:

  Possible unsafe locking scenario:

        CPU0                    CPU1
        ----                    ----
   lock(tipc_nametbl_lock);
                                lock(tipc_net_lock);
                                lock(tipc_nametbl_lock);
   lock(tipc_net_lock);

  *** DEADLOCK ***
----------------------------------------------------------

problem is that tipc_nametbl_publish which will hold tipc_nametbl_lock
and acquire tipc_net_lock, while the tipc_net_start which hold
tipc_net_lock and acquir tipc_nametbl_lock, so the dead lock occurs.

tipc_link_send protected by tipc_net_lock, we can unlock the
tipc_nametbl_lock, and it no need the tipc_nametbl_lock to protect it.
so I just unlock the tbl_lock before it, and lock the tbl_lock after it.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/tipc/name_distr.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index e0d0805..ab8f96c 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -138,7 +138,9 @@ static void named_cluster_distribute(struct sk_buff *buf)
 			if (!buf_copy)
 				break;
 			msg_set_destnode(buf_msg(buf_copy), n_ptr->addr);
+			write_unlock_bh(&tipc_nametbl_lock);
 			tipc_link_send(buf_copy, n_ptr->addr, n_ptr->addr);
+			write_lock_bh(&tipc_nametbl_lock);
 		}
 	}
 
-- 
1.7.12
