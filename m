From: Dmitry Popov <ixaphire@qrator.net>
Subject: [PATCH] ip_tunnel: fix i_key matching in ip_tunnel_find
Date: Sun, 8 Jun 2014 03:03:08 +0400
Message-ID: <20140608030308.77bc67a743827807737268f1@qrator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some tunnels (though only vti as for now) can use i_key just for internal use: 
for example vti uses it for fwmark'ing incoming packets. So raw i_key value 
shouldn't be treated as a distinguisher for them. ip_tunnel_key_match exists for
cases when we want to compare two ip_tunnel_parms' i_keys.

Example bug:
ip link add type vti ikey 1 local 1.0.0.1 remote 2.0.0.2
ip link add type vti ikey 2 local 1.0.0.1 remote 2.0.0.2
spawned two tunnels, although it doesn't make sense.

Signed-off-by: Dmitry Popov <ixaphire@qrator.net>
---
 net/ipv4/ip_tunnel.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 2acc233..cf67fe1 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -268,6 +268,7 @@ static struct ip_tunnel *ip_tunnel_find(struct ip_tunnel_net *itn,
 	__be32 remote = parms->iph.daddr;
 	__be32 local = parms->iph.saddr;
 	__be32 key = parms->i_key;
+	__be16 flags = parms->i_flags;
 	int link = parms->link;
 	struct ip_tunnel *t = NULL;
 	struct hlist_head *head = ip_bucket(itn, parms);
@@ -275,9 +276,9 @@ static struct ip_tunnel *ip_tunnel_find(struct ip_tunnel_net *itn,
 	hlist_for_each_entry_rcu(t, head, hash_node) {
 		if (local == t->parms.iph.saddr &&
 		    remote == t->parms.iph.daddr &&
-		    key == t->parms.i_key &&
 		    link == t->parms.link &&
-		    type == t->dev->type)
+		    type == t->dev->type &&
+		    ip_tunnel_key_match(&t->parms, flags, key))
 			break;
 	}
 	return t;
