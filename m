From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: randconfig build error with next-20140911, in
 net/ipv6/netfilter/nf_nat_masquerade_ipv6.c
Date: Thu, 11 Sep 2014 17:01:56 +0200
Message-ID: <20140911150156.GA5798@salvia>
References: <CA+r1ZhgA_3eYymnfBbTcBG+KoOW_k0hAqO-Z-JPemJCgOMsR=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="XsQoSWH+UP9D9v3l"
Content-Transfer-Encoding: 8bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jim Davis <jim.epost@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+r1ZhgA_3eYymnfBbTcBG+KoOW_k0hAqO-Z-JPemJCgOMsR=A@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--XsQoSWH+UP9D9v3l
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Thu, Sep 11, 2014 at 07:41:33AM -0700, Jim Davis wrote:
> Building with the attached random configuration file,
> 
> net/ipv6/netfilter/nf_nat_masquerade_ipv6.c: In function
> ‘nf_nat_masquerade_ipv6’:
> net/ipv6/netfilter/nf_nat_masquerade_ipv6.c:41:14: error: ‘struct
> nf_conn_nat’ has no member named ‘masq_index’
>   nfct_nat(ct)->masq_index = out->ifindex;
>               ^
> net/ipv6/netfilter/nf_nat_masquerade_ipv6.c: In function ‘device_cmp’:
> net/ipv6/netfilter/nf_nat_masquerade_ipv6.c:61:12: error: ‘const
> struct nf_conn_nat’ has no member named ‘masq_index’
>   return nat->masq_index == (int)(long)ifindex;
>             ^
> net/ipv6/netfilter/nf_nat_masquerade_ipv6.c:62:1: warning: control
> reaches end of non-void function [-Wreturn-type]
>  }
>  ^
> make[3]: *** [net/ipv6/netfilter/nf_nat_masquerade_ipv6.o] Error 1

Patch attached, thanks for reporting.

--XsQoSWH+UP9D9v3l
Content-Type: text/x-diff; charset=utf-8
Content-Disposition: attachment; filename="0001-netfilter-fix-compilation-of-masquerading-without-IP.patch"
Content-Transfer-Encoding: 8bit

>From bc96cd5a3f47e9a6401bc5fb0f7b26145271f6a0 Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu, 11 Sep 2014 16:55:04 +0200
Subject: [PATCH nf-next] netfilter: fix compilation of masquerading without IP_NF_TARGET_MASQUERADE
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

 CONFIG_NF_NAT_MASQUERADE_IPV6=m
 # CONFIG_IP6_NF_TARGET_MASQUERADE is not set

results in:

net/ipv6/netfilter/nf_nat_masquerade_ipv6.c: In function ‘nf_nat_masquerade_ipv6’:
net/ipv6/netfilter/nf_nat_masquerade_ipv6.c:41:14: error: ‘struct nf_conn_nat’ has no member named ‘masq_index’
  nfct_nat(ct)->masq_index = out->ifindex;
              ^
net/ipv6/netfilter/nf_nat_masquerade_ipv6.c: In function ‘device_cmp’:
net/ipv6/netfilter/nf_nat_masquerade_ipv6.c:61:12: error: ‘const struct nf_conn_nat’ has no member named ‘masq_index’
  return nat->masq_index == (int)(long)ifindex;
            ^
net/ipv6/netfilter/nf_nat_masquerade_ipv6.c:62:1: warning: control
reaches end of non-void function [-Wreturn-type]
 }
 ^
make[3]: *** [net/ipv6/netfilter/nf_nat_masquerade_ipv6.o] Error 1

Fix this by using the new NF_NAT_MASQUERADE_IPV4 and _IPV6 symbols
in include/net/netfilter/nf_nat.h.

Reported-by: Jim Davis <jim.epost@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_nat.h |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/include/net/netfilter/nf_nat.h b/include/net/netfilter/nf_nat.h
index a71dd33..344b1ab 100644
--- a/include/net/netfilter/nf_nat.h
+++ b/include/net/netfilter/nf_nat.h
@@ -32,10 +32,8 @@ struct nf_conn_nat {
 	struct hlist_node bysource;
 	struct nf_conn *ct;
 	union nf_conntrack_nat_help help;
-#if defined(CONFIG_IP_NF_TARGET_MASQUERADE) || \
-    defined(CONFIG_IP_NF_TARGET_MASQUERADE_MODULE) || \
-    defined(CONFIG_IP6_NF_TARGET_MASQUERADE) || \
-    defined(CONFIG_IP6_NF_TARGET_MASQUERADE_MODULE)
+#if IS_ENABLED(CONFIG_NF_NAT_MASQUERADE_IPV4) || \
+    IS_ENABLED(CONFIG_NF_NAT_MASQUERADE_IPV6)
 	int masq_index;
 #endif
 };
@@ -68,8 +66,8 @@ static inline bool nf_nat_oif_changed(unsigned int hooknum,
 				      struct nf_conn_nat *nat,
 				      const struct net_device *out)
 {
-#if IS_ENABLED(CONFIG_IP_NF_TARGET_MASQUERADE) || \
-    IS_ENABLED(CONFIG_IP6_NF_TARGET_MASQUERADE)
+#if IS_ENABLED(CONFIG_NF_NAT_MASQUERADE_IPV4) || \
+    IS_ENABLED(CONFIG_NF_NAT_MASQUERADE_IPV6)
 	return nat->masq_index && hooknum == NF_INET_POST_ROUTING &&
 	       CTINFO2DIR(ctinfo) == IP_CT_DIR_ORIGINAL &&
 	       nat->masq_index != out->ifindex;
-- 
1.7.10.4


--XsQoSWH+UP9D9v3l--
