From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] netfilter: x_tables: avoid stack-out-of-bounds read in
 xt_copy_counters_from_user
Date: Thu, 05 Oct 2017 02:50:07 -0700
Message-ID: <1507197007.14419.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        netdev <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

syzkaller reports an out of bound read in strlcpy(), triggered
by xt_copy_counters_from_user()

Fix this by using memcpy(), then forcing a zero byte at the last position
of the destination, as Florian did for the non COMPAT code.

Fixes: d7591f0c41ce ("netfilter: x_tables: introduce and use xt_copy_counters_from_user")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 net/netfilter/x_tables.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index c83a3b5e1c6c2a91b713b6681a794bd79ab3fa08..d8571f4142080a3c121fc90f0b52d81ee9df6712 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -892,7 +892,7 @@ void *xt_copy_counters_from_user(const void __user *user, unsigned int len,
 		if (copy_from_user(&compat_tmp, user, sizeof(compat_tmp)) != 0)
 			return ERR_PTR(-EFAULT);
 
-		strlcpy(info->name, compat_tmp.name, sizeof(info->name));
+		memcpy(info->name, compat_tmp.name, sizeof(info->name) - 1);
 		info->num_counters = compat_tmp.num_counters;
 		user += sizeof(compat_tmp);
 	} else
@@ -905,9 +905,9 @@ void *xt_copy_counters_from_user(const void __user *user, unsigned int len,
 		if (copy_from_user(info, user, sizeof(*info)) != 0)
 			return ERR_PTR(-EFAULT);
 
-		info->name[sizeof(info->name) - 1] = '\0';
 		user += sizeof(*info);
 	}
+	info->name[sizeof(info->name) - 1] = '\0';
 
 	size = sizeof(struct xt_counters);
 	size *= info->num_counters;


