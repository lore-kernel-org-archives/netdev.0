From: Patrick McHardy <kaber@trash.net>
Subject: Re: linux-next: Tree for February 18 (netfilter)
Date: Thu, 18 Feb 2010 18:03:59 +0100
Message-ID: <4B7D72FF.4010401@trash.net>
References: <20100218204937.54a613d2.sfr@canb.auug.org.au> <4B7D70D0.9090003@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020007050903060109090705"
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36556 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758548Ab0BRREE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 12:04:04 -0500
In-Reply-To: <4B7D70D0.9090003@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020007050903060109090705
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Randy Dunlap wrote:
> On 02/18/10 01:49, Stephen Rothwell wrote:
>> Hi all,
>>
>> Changes since 20100217:
>>
>> The net tree lost its build failure but gained a conflict against the kvm
>> tree.
> 
> 
> include/net/netfilter/nf_conntrack.h:94: error: field 'ct_general' has incomplete type
> include/net/netfilter/nf_conntrack.h:178: error: 'const struct sk_buff' has no member named 'nfct'
> include/net/netfilter/nf_conntrack.h:185: error: implicit declaration of function 'nf_conntrack_put'
> include/net/netfilter/nf_conntrack.h:294: error: 'const struct sk_buff' has no member named 'nfct'
> net/ipv4/netfilter/nf_defrag_ipv4.c:45: error: 'struct sk_buff' has no member named 'nfct'
> net/ipv4/netfilter/nf_defrag_ipv4.c:46: error: 'struct sk_buff' has no member named 'nfct'
> 
> CONFIG_NF_CONNTRACK is not enabled
> but CONFIG_NF_DEFRAG_IPV4=y.  It is "select"ed by
> NETFILTER_XT_MATCH_SOCKET and NETFILTER_XT_TARGET_TPROXY,
> both of which are enabled.
> 
> Hm, NETFILTER_XT_MATCH_SOCKET depends on !NF_CONNTRACK || NF_CONNTRACK.
> Maybe NETFILTER_XT_TARGET_TPROXY needs to do that also.  No, that would
> go against that config option's help text:

No, the problem is use of skb->nfct without CONFIG_NF_CONNTRACK.

This patch should fix it.

--------------020007050903060109090705
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index d498a70..b822ade 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -42,8 +42,10 @@ static enum ip_defrag_users nf_ct_defrag_user(unsigned int hooknum,
 {
 	u16 zone = NF_CT_DEFAULT_ZONE;
 
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	if (skb->nfct)
 		zone = nf_ct_zone((struct nf_conn *)skb->nfct);
+#endif
 
 #ifdef CONFIG_BRIDGE_NETFILTER
 	if (skb->nf_bridge &&

--------------020007050903060109090705--
