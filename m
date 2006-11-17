From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 6/10][IPV6]: Use kmemdup
Date: Fri, 17 Nov 2006 13:18:36 -0200
Message-ID: <20061117151836.GG17958@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:42126 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1755708AbWKQPSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 10:18:48 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Code diff stats:

[acme@newtoy net-2.6.20]$ codiff /tmp/ipv6.ko.before /tmp/ipv6.ko.after
/pub/scm/linux/kernel/git/acme/net-2.6.20/net/ipv6/ip6_output.c:
  ip6_output      |  -52
  ip6_append_data |   +2
 2 functions changed, 2 bytes added, 52 bytes removed

/pub/scm/linux/kernel/git/acme/net-2.6.20/net/ipv6/addrconf.c:
  addrconf_sysctl_register |  -27
 1 function changed, 27 bytes removed

/pub/scm/linux/kernel/git/acme/net-2.6.20/net/ipv6/tcp_ipv6.c:
  tcp_v6_syn_recv_sock  |  -32
  tcp_v6_parse_md5_keys |  -24
 2 functions changed, 56 bytes removed

/tmp/ipv6.ko.after:
 5 functions changed, 2 bytes added, 135 bytes removed
[acme@newtoy net-2.6.20]$

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/ipv6/addrconf.c   |    3 +--
 net/ipv6/ah6.c        |    3 +--
 net/ipv6/ip6_output.c |    3 +--
 net/ipv6/tcp_ipv6.c   |    9 +++------
 4 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index b41c5d8..a5e8d20 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3969,10 +3969,9 @@ static void addrconf_sysctl_register(str
 	struct addrconf_sysctl_table *t;
 	char *dev_name = NULL;
 
-	t = kmalloc(sizeof(*t), GFP_KERNEL);
+	t = kmemdup(&addrconf_sysctl, sizeof(*t), GFP_KERNEL);
 	if (t == NULL)
 		return;
-	memcpy(t, &addrconf_sysctl, sizeof(*t));
 	for (i=0; t->addrconf_vars[i].data; i++) {
 		t->addrconf_vars[i].data += (char*)p - (char*)&ipv6_devconf;
 		t->addrconf_vars[i].de = NULL;
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 2d9e495..12c5a4d 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -354,10 +354,9 @@ static int ah6_input(struct xfrm_state *
 	if (!pskb_may_pull(skb, ah_hlen))
 		goto out;
 
-	tmp_hdr = kmalloc(hdr_len, GFP_ATOMIC);
+	tmp_hdr = kmemdup(skb->nh.raw, hdr_len, GFP_ATOMIC);
 	if (!tmp_hdr)
 		goto out;
-	memcpy(tmp_hdr, skb->nh.raw, hdr_len);
 	if (ipv6_clear_mutable_options(skb->nh.ipv6h, hdr_len, XFRM_POLICY_IN))
 		goto free_out;
 	skb->nh.ipv6h->priority    = 0;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 85f8892..e05ecbb 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -624,14 +624,13 @@ static int ip6_fragment(struct sk_buff *
 		skb_shinfo(skb)->frag_list = NULL;
 		/* BUILD HEADER */
 
-		tmp_hdr = kmalloc(hlen, GFP_ATOMIC);
+		tmp_hdr = kmemdup(skb->nh.raw, hlen, GFP_ATOMIC);
 		if (!tmp_hdr) {
 			IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_FRAGFAILS);
 			return -ENOMEM;
 		}
 
 		*prevhdr = NEXTHDR_FRAGMENT;
-		memcpy(tmp_hdr, skb->nh.raw, hlen);
 		__skb_pull(skb, hlen);
 		fh = (struct frag_hdr*)__skb_push(skb, sizeof(struct frag_hdr));
 		skb->nh.raw = __skb_push(skb, hlen);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 147ce49..d2170da 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -720,10 +720,9 @@ static int tcp_v6_parse_md5_keys (struct
 		tp->md5sig_info = p;
 	}
 
-	newkey = kmalloc(cmd.tcpm_keylen, GFP_KERNEL);
+	newkey = kmemdup(cmd.tcpm_key, cmd.tcpm_keylen, GFP_KERNEL);
 	if (!newkey)
 		return -ENOMEM;
-	memcpy(newkey, cmd.tcpm_key, cmd.tcpm_keylen);
 	if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_MAPPED) {
 		return tcp_v4_md5_do_add(sk, sin6->sin6_addr.s6_addr32[3],
 					 newkey, cmd.tcpm_keylen);
@@ -1503,12 +1502,10 @@ #ifdef CONFIG_TCP_MD5SIG
 		 * memory, then we end up not copying the key
 		 * across. Shucks.
 		 */
-		char *newkey = kmalloc(key->keylen, GFP_ATOMIC);
-		if (newkey) {
-			memcpy(newkey, key->key, key->keylen);
+		char *newkey = kmemdup(key->key, key->keylen, GFP_ATOMIC);
+		if (newkey != NULL)
 			tcp_v6_md5_do_add(newsk, &inet6_sk(sk)->daddr,
 					  newkey, key->keylen);
-		}
 	}
 #endif
 
-- 
1.4.2.1.g3d5c

