From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 20/31] caif: Define usercopy region in caif proto slab cache
Date: Wed, 20 Sep 2017 13:45:26 -0700
Message-ID: <1505940337-79069-21-git-send-email-keescook@chromium.org>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        David Windsor <dave@nullcore.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        kernel-hardening@lists.openwall.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Windsor <dave@nullcore.net>

The CAIF channel connection request parameters need to be copied to/from
userspace. In support of usercopy hardening, this patch defines a region
in the struct proto slab cache in which userspace copy operations are
allowed.

example usage trace:

    net/caif/caif_socket.c:
        setsockopt(...):
            ...
            copy_from_user(&cf_sk->conn_req.param.data, ..., ol)

This region is known as the slab cache's usercopy region. Slab caches can
now check that each copy operation involving cache-managed memory falls
entirely within the slab's usercopy region.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: split from network patch, provide usage trace]
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/caif/caif_socket.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 632d5a416d97..c76d513b9a7a 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -1032,6 +1032,8 @@ static int caif_create(struct net *net, struct socket *sock, int protocol,
 	static struct proto prot = {.name = "PF_CAIF",
 		.owner = THIS_MODULE,
 		.obj_size = sizeof(struct caifsock),
+		.useroffset = offsetof(struct caifsock, conn_req.param),
+		.usersize = sizeof_field(struct caifsock, conn_req.param)
 	};
 
 	if (!capable(CAP_SYS_ADMIN) && !capable(CAP_NET_ADMIN))
-- 
2.7.4
