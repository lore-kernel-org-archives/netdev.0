From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] ebpf: fix fd refcount leaks related to maps in bpf syscall
Date: Tue,  8 Sep 2015 18:00:09 +0200
Message-ID: <021e4aac946ab776e7f4af1310f7ed2a642ccd08.1441727453.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48774 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754573AbbIHQAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 12:00:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We may already have gotten a proper fd struct through fdget(), so
whenever we return at the end of an map operation, we need to call
fdput(). However, each map operation from syscall side first probes
CHECK_ATTR() to verify that unused fields in the bpf_attr union are
zero.

In case of malformed input, we return with error, but the lookup to
the map_fd was already performed at that time, so that we return
without an corresponding fdput(). Fix it by performing an fdget()
only right before bpf_map_get(). The fdget() invocation on maps in
the verifier is not affected.

Fixes: db20fd2b0108 ("bpf: add lookup/update/delete/iterate methods to BPF maps")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 kernel/bpf/syscall.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index dc9b464..35bac8e 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -155,14 +155,15 @@ static int map_lookup_elem(union bpf_attr *attr)
 	void __user *ukey = u64_to_ptr(attr->key);
 	void __user *uvalue = u64_to_ptr(attr->value);
 	int ufd = attr->map_fd;
-	struct fd f = fdget(ufd);
 	struct bpf_map *map;
 	void *key, *value, *ptr;
+	struct fd f;
 	int err;
 
 	if (CHECK_ATTR(BPF_MAP_LOOKUP_ELEM))
 		return -EINVAL;
 
+	f = fdget(ufd);
 	map = bpf_map_get(f);
 	if (IS_ERR(map))
 		return PTR_ERR(map);
@@ -213,14 +214,15 @@ static int map_update_elem(union bpf_attr *attr)
 	void __user *ukey = u64_to_ptr(attr->key);
 	void __user *uvalue = u64_to_ptr(attr->value);
 	int ufd = attr->map_fd;
-	struct fd f = fdget(ufd);
 	struct bpf_map *map;
 	void *key, *value;
+	struct fd f;
 	int err;
 
 	if (CHECK_ATTR(BPF_MAP_UPDATE_ELEM))
 		return -EINVAL;
 
+	f = fdget(ufd);
 	map = bpf_map_get(f);
 	if (IS_ERR(map))
 		return PTR_ERR(map);
@@ -265,14 +267,15 @@ static int map_delete_elem(union bpf_attr *attr)
 {
 	void __user *ukey = u64_to_ptr(attr->key);
 	int ufd = attr->map_fd;
-	struct fd f = fdget(ufd);
 	struct bpf_map *map;
+	struct fd f;
 	void *key;
 	int err;
 
 	if (CHECK_ATTR(BPF_MAP_DELETE_ELEM))
 		return -EINVAL;
 
+	f = fdget(ufd);
 	map = bpf_map_get(f);
 	if (IS_ERR(map))
 		return PTR_ERR(map);
@@ -305,14 +308,15 @@ static int map_get_next_key(union bpf_attr *attr)
 	void __user *ukey = u64_to_ptr(attr->key);
 	void __user *unext_key = u64_to_ptr(attr->next_key);
 	int ufd = attr->map_fd;
-	struct fd f = fdget(ufd);
 	struct bpf_map *map;
 	void *key, *next_key;
+	struct fd f;
 	int err;
 
 	if (CHECK_ATTR(BPF_MAP_GET_NEXT_KEY))
 		return -EINVAL;
 
+	f = fdget(ufd);
 	map = bpf_map_get(f);
 	if (IS_ERR(map))
 		return PTR_ERR(map);
-- 
1.9.3
