From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] netfilter: fix stringop-overflow warning with UBSAN
Date: Mon, 31 Jul 2017 12:09:03 +0200
Message-ID: <20170731100913.465530-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Johannes Berg <johannes.berg@intel.com>,
        Alexey Dobriyan <adobriyan@gmail.com>,
        Aaron Conole <aconole@bytheb.org>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using gcc-7 with UBSAN enabled, we get this false-positive warning:

net/netfilter/ipset/ip_set_core.c: In function 'ip_set_sockfn_get':
net/netfilter/ipset/ip_set_core.c:1998:3: error: 'strncpy' writing 32 bytes into a region of size 2 overflows the destination [-Werror=stringop-overflow=]
   strncpy(req_get->set.name, set ? set->name : "",
   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    sizeof(req_get->set.name));
    ~~~~~~~~~~~~~~~~~~~~~~~~~~

This seems completely bogus, and I could not find a nice workaround.
To work around it in a less elegant way, I change the ?: operator
into an if()/else() construct.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/netfilter/ipset/ip_set_core.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index e495b5e484b1..d7ebb021003b 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1995,8 +1995,12 @@ ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
 		}
 		nfnl_lock(NFNL_SUBSYS_IPSET);
 		set = ip_set(inst, req_get->set.index);
-		strncpy(req_get->set.name, set ? set->name : "",
-			IPSET_MAXNAMELEN);
+		if (set)
+			strncpy(req_get->set.name, set->name,
+				sizeof(req_get->set.name));
+		else
+			memset(req_get->set.name, '\0',
+			       sizeof(req_get->set.name));
 		nfnl_unlock(NFNL_SUBSYS_IPSET);
 		goto copy;
 	}
-- 
2.9.0
