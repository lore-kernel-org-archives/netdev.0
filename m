From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH net-next] bpf: fix oops on allocation failure
Date: Fri, 25 Aug 2017 23:27:14 +0300
Message-ID: <20170825202714.64ivixeindjph3z6@mwanda>
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

"err" is set to zero if bpf_map_area_alloc() fails so it means we return
ERR_PTR(0) which is NULL.  The caller, find_and_alloc_map(), is not
expecting NULL returns and will oops.

Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/kernel/bpf/sockmap.c b/kernel/bpf/sockmap.c
index 78b2bb9370ac..a11b9f52ea4a 100644
--- a/kernel/bpf/sockmap.c
+++ b/kernel/bpf/sockmap.c
@@ -497,6 +497,7 @@ static struct bpf_map *sock_map_alloc(union bpf_attr *attr)
 	if (err)
 		goto free_stab;
 
+	err = -ENOMEM;
 	stab->sock_map = bpf_map_area_alloc(stab->map.max_entries *
 					    sizeof(struct sock *),
 					    stab->map.numa_node);
