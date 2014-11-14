From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 4/7] bpf: fix BPF_MAP_LOOKUP_ELEM command return code
Date: Thu, 13 Nov 2014 17:36:47 -0800
Message-ID: <1415929010-9361-5-git-send-email-ast@plumgrid.com>
References: <1415929010-9361-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415929010-9361-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fix errno of BPF_MAP_LOOKUP_ELEM command as bpf manpage
described it in commit b4fc1a460f30("Merge branch 'bpf-next'"):
-----
BPF_MAP_LOOKUP_ELEM
    int bpf_lookup_elem(int fd, void *key, void *value)
    {
        union bpf_attr attr = {
            .map_fd = fd,
            .key = ptr_to_u64(key),
            .value = ptr_to_u64(value),
        };

        return bpf(BPF_MAP_LOOKUP_ELEM, &attr, sizeof(attr));
    }
    bpf() syscall looks up an element with given key in  a  map  fd.
    If  element  is found it returns zero and stores element's value
    into value.  If element is not found  it  returns  -1  and  sets
    errno to ENOENT.

and further down in manpage:

   ENOENT For BPF_MAP_LOOKUP_ELEM or BPF_MAP_DELETE_ELEM,  indicates  that
          element with given key was not found.
-----

In general all BPF commands return ENOENT when map element is not found
(including BPF_MAP_GET_NEXT_KEY and BPF_MAP_UPDATE_ELEM with
 flags == BPF_MAP_UPDATE_ONLY)

Subsequent patch adds a testsuite to check return values for all of
these combinations.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

I don't think this patch is needed for 'net', since 'net' has syscall shell
only. Actual map types and their implementations are being introduced by
this set of patches.

 kernel/bpf/syscall.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index c0d03bf317a2..088ac0b1b106 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -169,7 +169,7 @@ static int map_lookup_elem(union bpf_attr *attr)
 	if (copy_from_user(key, ukey, map->key_size) != 0)
 		goto free_key;
 
-	err = -ESRCH;
+	err = -ENOENT;
 	rcu_read_lock();
 	value = map->ops->map_lookup_elem(map, key);
 	if (!value)
-- 
1.7.9.5
