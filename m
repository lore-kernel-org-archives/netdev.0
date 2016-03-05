From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: use gfp insteaad of GFP_NOWAIT in idr_alloc_cyclic when sctp_assoc_set_id
Date: Sat,  5 Mar 2016 23:59:32 +0800
Message-ID: <ef48b2b8895b4d0fab07b4e72b464d5a11d3bd79.1457193572.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33097 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbcCEP7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2016 10:59:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following call trace appears because of idr_alloc_cyclic(..., GFP_NOWAIT),
that is a stress test, and the reason should be a heavy use. it will cause
sctp_process_init return 0, and make connection init fail.

All the allocations of idr_alloc_cyclic should respect gfp flag.
So we can fix it by using gfp insteaad of GFP_NOWAIT in idr_alloc_cyclic.

[ 2569.797532] Call Trace:
[ 2569.809721]  [<ffffffff8163ed74>] dump_stack+0x19/0x1b
[ 2569.837424]  [<ffffffff81171460>] warn_alloc_failed+0x110/0x180
[ 2569.867013]  [<ffffffff81175be8>] __alloc_pages_nodemask+0x9a8/0xb90
[ 2569.900039]  [<ffffffff811b68d9>] alloc_pages_current+0xa9/0x170
[ 2569.930100]  [<ffffffff811c19dc>] new_slab+0x2ec/0x300
[ 2569.957505]  [<ffffffff8163bcdf>] __slab_alloc+0x315/0x48f
[ 2569.985168]  [<ffffffff812f6bd9>] ? idr_layer_alloc+0x89/0x90
[ 2570.014344]  [<ffffffff812fedae>] ? memzero_explicit+0xe/0x10
[ 2570.044116]  [<ffffffff811c3fa3>] kmem_cache_alloc+0x193/0x1d0
[ 2570.073283]  [<ffffffff812f6bd9>] idr_layer_alloc+0x89/0x90
[ 2570.102684]  [<ffffffff812f72dc>] idr_get_empty_slot+0x24c/0x3c0
[ 2570.132634]  [<ffffffff812f75ac>] idr_alloc+0x5c/0x100
[ 2570.159835]  [<ffffffffa08af6c0>] ? sctp_hash_transport+0x110/0x290 [sctp]
[ 2570.194974]  [<ffffffff812f767b>] idr_alloc_cyclic+0x2b/0x60
[ 2570.223695]  [<ffffffffa089a546>] sctp_assoc_set_id+0x46/0xd0 [sctp]
[ 2570.256245]  [<ffffffffa089f321>] sctp_process_init+0x921/0x940 [sctp]
[ 2570.288574]  [<ffffffffa08ae030>] ? sctp_csum_combine+0x10/0x10 [sctp]
[ 2570.321758]  [<ffffffffa0896788>] sctp_cmd_interpreter.isra.25+0xe18/0x1330 [sctp]
[ 2570.459745]  [<ffffffffa089543f>] sctp_do_sm+0xaf/0x1b0 [sctp]
[ 2570.489725]  [<ffffffffa0899655>] sctp_assoc_bh_rcv+0xd5/0x140 [sctp]
[ 2570.522628]  [<ffffffffa08a137c>] sctp_inq_push+0x4c/0x70 [sctp]
[ 2570.553812]  [<ffffffffa08af160>] sctp_backlog_rcv+0x40/0x130 [sctp]
[ 2570.585534]  [<ffffffff8151cbe1>] release_sock+0xa1/0x170
[ 2570.613632]  [<ffffffffa08a8c1a>] __sctp_connect+0x41a/0x550 [sctp]
[ 2570.644998]  [<ffffffff810a84e0>] ? wake_up_atomic_t+0x30/0x30
[ 2570.675601]  [<ffffffff816463f2>] ? _raw_spin_lock_bh+0x12/0x50
[ 2570.705185]  [<ffffffffa08a8e6d>] sctp_connect+0x4d/0x70 [sctp]
[ 2570.736234]  [<ffffffff815a82ce>] inet_dgram_connect+0x2e/0x80
[ 2570.765514]  [<ffffffff81518387>] SYSC_connect+0xe7/0x120
[ 2570.793691]  [<ffffffff81515450>] ? sock_alloc_file+0xa0/0x140
[ 2570.822558]  [<ffffffff811ffad7>] ? __fd_install+0x47/0x60
[ 2570.851732]  [<ffffffff8151943e>] SyS_connect+0xe/0x10
[ 2570.877433]  [<ffffffff8164f1c9>] system_call_fastpath+0x16/0x1b
[ 2570.908682] SLUB: Unable to allocate memory on node -1 (gfp=0x8000)
[ 2570.939959]   cache: idr_layer_cache, object size: 2112, buffer size: 2112, default order: 3, min order: 0
[ 2570.989683]   node 0: slabs: 839, objs: 11829, free: 0

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/associola.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 2bf8ec9..481187a 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1606,7 +1606,7 @@ int sctp_assoc_set_id(struct sctp_association *asoc, gfp_t gfp)
 		idr_preload(gfp);
 	spin_lock_bh(&sctp_assocs_id_lock);
 	/* 0 is not a valid assoc_id, must be >= 1 */
-	ret = idr_alloc_cyclic(&sctp_assocs_id, asoc, 1, 0, GFP_NOWAIT);
+	ret = idr_alloc_cyclic(&sctp_assocs_id, asoc, 1, 0, gfp);
 	spin_unlock_bh(&sctp_assocs_id_lock);
 	if (preload)
 		idr_preload_end();
-- 
2.1.0
