From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH net-next] bpf: return errno -ENOMEM when exceeding
 RLIMIT_MEMLOCK
Date: Mon, 20 Feb 2017 16:35:10 +0100
Message-ID: <148760491056.17885.7344022207445355578.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58180 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932084AbdBTPfM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 10:35:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is confusing users of samples/bpf that exceeding the resource
limits for RLIMIT_MEMLOCK result in an "Operation not permitted"
message.  This is due to bpf limits check return -EPERM.

Instead return -ENOMEM, like most other users of this API.

Fixes: aaac3ba95e4c ("bpf: charge user for creation of BPF maps and programs")
Fixes: 6c9059817432 ("bpf: pre-allocate hash map elements")
Fixes: 5ccb071e97fb ("bpf: fix overflow in prog accounting")
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 kernel/bpf/syscall.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 08a4d287226b..37387a9b0d46 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -85,7 +85,7 @@ int bpf_map_precharge_memlock(u32 pages)
 	cur = atomic_long_read(&user->locked_vm);
 	free_uid(user);
 	if (cur + pages > memlock_limit)
-		return -EPERM;
+		return -ENOMEM;
 	return 0;
 }
 
@@ -101,7 +101,7 @@ static int bpf_map_charge_memlock(struct bpf_map *map)
 	if (atomic_long_read(&user->locked_vm) > memlock_limit) {
 		atomic_long_sub(map->pages, &user->locked_vm);
 		free_uid(user);
-		return -EPERM;
+		return -ENOMEM;
 	}
 	map->user = user;
 	return 0;
@@ -658,7 +658,7 @@ int __bpf_prog_charge(struct user_struct *user, u32 pages)
 		user_bufs = atomic_long_add_return(pages, &user->locked_vm);
 		if (user_bufs > memlock_limit) {
 			atomic_long_sub(pages, &user->locked_vm);
-			return -EPERM;
+			return -ENOMEM;
 		}
 	}
 
