From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: (usagi-users 03606) [PATCH] [NET]: NETFILTER: remove duplicated operation and fix
 order in skb_clone().
Date: Fri, 17 Feb 2006 21:51:01 +0900 (JST)
Message-ID: <20060217.215101.09874309.yoshfuji@linux-ipv6.org>
References: <43F5A7B2.90803@6wind.com>
Reply-To: usagi-users@linux-ipv6.org
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-users@linux-ipv6.org, olivier.matz@6wind.com,
        yoshfuji@linux-ipv6.org
Return-path: <usagi-users-admin@linux-ipv6.org>
To: davem@davemloft.net
In-Reply-To: <43F5A7B2.90803@6wind.com>
List-Software: fml [fml 4.0.3 release (20011202/4.0.3)]
List-Post: <mailto:usagi-users@linux-ipv6.org>
List-Owner: <mailto:usagi-users-admin@linux-ipv6.org>
List-Help: <mailto:usagi-users-ctl@linux-ipv6.org?body=help>
List-Unsubscribe: <mailto:usagi-users-ctl@linux-ipv6.org?body=unsubscribe>
List-Id: netdev.vger.kernel.org

Hello.

In article <43F5A7B2.90803@6wind.com> (at Fri, 17 Feb 2006 11:38:42 +0100), Olivier MATZ <olivier.matz@6wind.com> says:

> in skb_clone(), the following code is done twice :
> 
> #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
> 	C(nfct_reasm);
> 	nf_conntrack_get_reasm(skb->nfct_reasm);
> #endif

David, please apply the fillowing patch.

Thank you.

---
[NET]: NETFILTER: remove duplicated lines and fix order in skb_clone().

Some of netfilter-related members are initalized / copied twice in
skb_clone(). Remove one. Pointed out by Olivier MATZ <olivier.matz@6wind.com>.

And this patch also fixes order of copying / clearing members.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 6766f11..2144952 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -411,6 +411,9 @@ struct sk_buff *skb_clone(struct sk_buff
 	C(pkt_type);
 	C(ip_summed);
 	C(priority);
+#if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
+	C(ipvs_property);
+#endif
 	C(protocol);
 	n->destructor = NULL;
 #ifdef CONFIG_NETFILTER
@@ -422,13 +425,6 @@ struct sk_buff *skb_clone(struct sk_buff
 	C(nfct_reasm);
 	nf_conntrack_get_reasm(skb->nfct_reasm);
 #endif
-#if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
-	C(ipvs_property);
-#endif
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
-	C(nfct_reasm);
-	nf_conntrack_get_reasm(skb->nfct_reasm);
-#endif
 #ifdef CONFIG_BRIDGE_NETFILTER
 	C(nf_bridge);
 	nf_bridge_get(skb->nf_bridge);

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
