From: Patrick McHardy <kaber@trash.net>
Subject: Re: linux-next: Tree for February 18 (netfilter)
Date: Thu, 18 Feb 2010 18:45:14 +0100
Message-ID: <4B7D7CAA.1070605@trash.net>
References: <20100218204937.54a613d2.sfr@canb.auug.org.au> <4B7D70D0.9090003@oracle.com> <4B7D72FF.4010401@trash.net> <4B7D7617.9070600@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000008030609080801050302"
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B7D7617.9070600@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000008030609080801050302
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Randy Dunlap wrote:
> On 02/18/10 09:03, Patrick McHardy wrote:
>> Randy Dunlap wrote:
>>> On 02/18/10 01:49, Stephen Rothwell wrote:
>>>> Hi all,
>>>>
>>>> Changes since 20100217:
>>>>
>>>> The net tree lost its build failure but gained a conflict against the kvm
>>>> tree.
>>>
>>> include/net/netfilter/nf_conntrack.h:94: error: field 'ct_general' has incomplete type
>>> include/net/netfilter/nf_conntrack.h:178: error: 'const struct sk_buff' has no member named 'nfct'
>>> include/net/netfilter/nf_conntrack.h:185: error: implicit declaration of function 'nf_conntrack_put'
>>> include/net/netfilter/nf_conntrack.h:294: error: 'const struct sk_buff' has no member named 'nfct'
>>> net/ipv4/netfilter/nf_defrag_ipv4.c:45: error: 'struct sk_buff' has no member named 'nfct'
>>> net/ipv4/netfilter/nf_defrag_ipv4.c:46: error: 'struct sk_buff' has no member named 'nfct'
>>>
>>> CONFIG_NF_CONNTRACK is not enabled
>>> but CONFIG_NF_DEFRAG_IPV4=y.  It is "select"ed by
>>> NETFILTER_XT_MATCH_SOCKET and NETFILTER_XT_TARGET_TPROXY,
>>> both of which are enabled.
>>>
>>> Hm, NETFILTER_XT_MATCH_SOCKET depends on !NF_CONNTRACK || NF_CONNTRACK.
>>> Maybe NETFILTER_XT_TARGET_TPROXY needs to do that also.  No, that would
>>> go against that config option's help text:
>> No, the problem is use of skb->nfct without CONFIG_NF_CONNTRACK.
>>
>> This patch should fix it.
> 
> Nope:
> 
> In file included from /lnx/src/NEXT/linux-next-20100218/include/net/netfilter/nf_conntrack_extend.h:4,
>                  from /lnx/src/NEXT/linux-next-20100218/include/net/netfilter/nf_conntrack_zones.h:4,
>                  from /lnx/src/NEXT/linux-next-20100218/net/ipv4/netfilter/nf_defrag_ipv4.c:19:
> /lnx/src/NEXT/linux-next-20100218/include/net/netfilter/nf_conntrack.h:94: error: field 'ct_general' has incomplete type
> /lnx/src/NEXT/linux-next-20100218/include/net/netfilter/nf_conntrack.h: In function 'nf_ct_get':

Ah I see, we must not include nf_conntrack.h at all. Eventually
we need to fix this properly by making nf_conntrack.h usable
even with NF_CONNTRACK=n, but that's a more complicated change.

This patch works fine for me using your config:


--------------000008030609080801050302
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/include/net/netfilter/nf_conntrack_zones.h b/include/net/netfilter/nf_conntrack_zones.h
index 0bbb2bd..034efe8 100644
--- a/include/net/netfilter/nf_conntrack_zones.h
+++ b/include/net/netfilter/nf_conntrack_zones.h
@@ -1,10 +1,11 @@
 #ifndef _NF_CONNTRACK_ZONES_H
 #define _NF_CONNTRACK_ZONES_H
 
-#include <net/netfilter/nf_conntrack_extend.h>
-
 #define NF_CT_DEFAULT_ZONE	0
 
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+#include <net/netfilter/nf_conntrack_extend.h>
+
 struct nf_conntrack_zone {
 	u16	id;
 };
@@ -20,4 +21,5 @@ static inline u16 nf_ct_zone(const struct nf_conn *ct)
 	return NF_CT_DEFAULT_ZONE;
 }
 
+#endif /* CONFIG_NF_CONNTRACK || CONFIG_NF_CONNTRACK_MODULE */
 #endif /* _NF_CONNTRACK_ZONES_H */
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index d498a70..cb763ae 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -16,9 +16,11 @@
 
 #include <linux/netfilter_bridge.h>
 #include <linux/netfilter_ipv4.h>
-#include <net/netfilter/nf_conntrack_zones.h>
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 #include <net/netfilter/nf_conntrack.h>
+#endif
+#include <net/netfilter/nf_conntrack_zones.h>
 
 /* Returns new sk_buff, or NULL */
 static int nf_ct_ipv4_gather_frags(struct sk_buff *skb, u_int32_t user)
@@ -42,8 +44,10 @@ static enum ip_defrag_users nf_ct_defrag_user(unsigned int hooknum,
 {
 	u16 zone = NF_CT_DEFAULT_ZONE;
 
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	if (skb->nfct)
 		zone = nf_ct_zone((struct nf_conn *)skb->nfct);
+#endif
 
 #ifdef CONFIG_BRIDGE_NETFILTER
 	if (skb->nf_bridge &&

--------------000008030609080801050302--
