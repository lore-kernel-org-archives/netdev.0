From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH net-next] bpf: dev_map_alloc() shouldn't return NULL
Date: Sat, 22 Jul 2017 10:40:04 +0300
Message-ID: <20170722074004.3abeucov67n3sbqs@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.fastabend@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We forgot to set the error code on two error paths which means that we
return ERR_PTR(0) which is NULL.  The caller, find_and_alloc_map(), is
not expecting that and will have a NULL dereference.

Fixes: 546ac1ffb70d ("bpf: add devmap, a map for storing net device references")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/kernel/bpf/devmap.c b/kernel/bpf/devmap.c
index 899364d097f5..d439ee0eadb1 100644
--- a/kernel/bpf/devmap.c
+++ b/kernel/bpf/devmap.c
@@ -114,6 +114,7 @@ static struct bpf_map *dev_map_alloc(union bpf_attr *attr)
 	if (err)
 		goto free_dtab;
 
+	err = -ENOMEM;
 	/* A per cpu bitfield with a bit per possible net device */
 	dtab->flush_needed = __alloc_percpu(
 				BITS_TO_LONGS(attr->max_entries) *
