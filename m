From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] bpf: devmap: pass on return value of bpf_map_precharge_memlock
Date: Mon, 18 Sep 2017 15:03:46 +0200
Message-ID: <20170918130346.10833-1-tklauser@distanz.ch>
Cc: John Fastabend <john.fastabend@gmail.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:46754 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752112AbdIRNEB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 18 Sep 2017 09:04:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If bpf_map_precharge_memlock in dev_map_alloc, -ENOMEM is returned
regardless of the actual error produced by bpf_map_precharge_memlock.
Fix it by passing on the error returned by bpf_map_precharge_memlock.

Also return -EINVAL instead of -ENOMEM if the page count overflow check
fails.

This makes dev_map_alloc match the behavior of other bpf maps' alloc
functions wrt. return values.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 kernel/bpf/devmap.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/devmap.c b/kernel/bpf/devmap.c
index 959c9a07f318..e093d9a2c4dd 100644
--- a/kernel/bpf/devmap.c
+++ b/kernel/bpf/devmap.c
@@ -75,8 +75,8 @@ static u64 dev_map_bitmap_size(const union bpf_attr *attr)
 static struct bpf_map *dev_map_alloc(union bpf_attr *attr)
 {
 	struct bpf_dtab *dtab;
+	int err = -EINVAL;
 	u64 cost;
-	int err;
 
 	/* check sanity of attributes */
 	if (attr->max_entries == 0 || attr->key_size != 4 ||
@@ -108,6 +108,8 @@ static struct bpf_map *dev_map_alloc(union bpf_attr *attr)
 	if (err)
 		goto free_dtab;
 
+	err = -ENOMEM;
+
 	/* A per cpu bitfield with a bit per possible net device */
 	dtab->flush_needed = __alloc_percpu(dev_map_bitmap_size(attr),
 					    __alignof__(unsigned long));
@@ -128,7 +130,7 @@ static struct bpf_map *dev_map_alloc(union bpf_attr *attr)
 free_dtab:
 	free_percpu(dtab->flush_needed);
 	kfree(dtab);
-	return ERR_PTR(-ENOMEM);
+	return ERR_PTR(err);
 }
 
 static void dev_map_free(struct bpf_map *map)
-- 
2.13.0
