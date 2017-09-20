From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 18/31] net: Define usercopy region in struct proto slab cache
Date: Wed, 20 Sep 2017 13:45:24 -0700
Message-ID: <1505940337-79069-19-git-send-email-keescook@chromium.org>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        David Windsor <dave@nullcore.net>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Paolo Abeni <pabeni@redhat.com>,
        David Howells <dhowells@redhat.com>, netdev@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        kernel-hardening@lists.openwall.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Windsor <dave@nullcore.net>

In support of usercopy hardening, this patch defines a region in the
struct proto slab cache in which userspace copy operations are allowed.
Some protocols need to copy objects to/from userspace, and they can
declare the region via their proto structure with the new usersize and
useroffset fields. Initially, if no region is specified (usersize ==
0), the entire field is marked as whitelisted. This allows protocols
to be whitelisted in subsequent patches. Once all protocols have been
annotated, the full-whitelist default can be removed.

This region is known as the slab cache's usercopy region. Slab caches can
now check that each copy operation involving cache-managed memory falls
entirely within the slab's usercopy region.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log, split off per-proto patches]
[kees: add logic for by-default full-whitelist]
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Paolo Abeni <pabeni@redhat.com>
Cc: David Howells <dhowells@redhat.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/net/sock.h | 2 ++
 net/core/sock.c    | 6 +++++-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 03a362568357..13c2d1b48c86 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1106,6 +1106,8 @@ struct proto {
 	struct kmem_cache	*slab;
 	unsigned int		obj_size;
 	int			slab_flags;
+	size_t			useroffset;	/* Usercopy region offset */
+	size_t			usersize;	/* Usercopy region size */
 
 	struct percpu_counter	*orphan_count;
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 9b7b6bbb2a23..832dfb03102e 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -3165,8 +3165,12 @@ static int req_prot_init(const struct proto *prot)
 int proto_register(struct proto *prot, int alloc_slab)
 {
 	if (alloc_slab) {
-		prot->slab = kmem_cache_create(prot->name, prot->obj_size, 0,
+		prot->slab = kmem_cache_create_usercopy(prot->name,
+					prot->obj_size, 0,
 					SLAB_HWCACHE_ALIGN | prot->slab_flags,
+					prot->usersize ? prot->useroffset : 0,
+					prot->usersize ? prot->usersize
+						       : prot->obj_size,
 					NULL);
 
 		if (prot->slab == NULL) {
-- 
2.7.4
