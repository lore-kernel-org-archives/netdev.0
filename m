From: Phil Oester <kernel@linuxace.com>
Subject: Re: [PATCH] Conntrack leak with raw sockets
Date: Fri, 25 Mar 2005 22:05:43 -0800
Message-ID: <20050326060543.GA4791@linuxace.com>
References: <20050325201127.GA3400@linuxace.com> <4244766D.2020001@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="2fHTh5uZTiUOsy+g"
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4244766D.2020001@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Mar 25, 2005 at 09:37:01PM +0100, Patrick McHardy wrote:
> Great work tracking this down. But I fear the problem will come back
> haunt us with this patch. The are more places where a packet can be
> queued indefinitely, for example stopped qdiscs. IMO the best fix
> is to drop the conntrack reference once the packet leaves IP, so we
> don't have to make any assumptions about what will happen to the
> packet - this would be in ip_finish_output2(). Could you send a patch

Something like the attached?

Phil



--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=patch-ref2

diff -ru linux-orig/net/ipv4/ip_output.c linux-new/net/ipv4/ip_output.c
--- linux-orig/net/ipv4/ip_output.c	2005-03-25 14:48:13.543911760 -0500
+++ linux-new/net/ipv4/ip_output.c	2005-03-26 01:01:13.064616240 -0500
@@ -195,6 +195,8 @@
 	nf_debug_ip_finish_output2(skb);
 #endif /*CONFIG_NETFILTER_DEBUG*/
 
+	nf_reset(skb);
+
 	if (hh) {
 		int hh_alen;
 
diff -ru linux-orig/net/ipv4/netfilter/ip_conntrack_standalone.c linux-new/net/ipv4/netfilter/ip_conntrack_standalone.c
--- linux-orig/net/ipv4/netfilter/ip_conntrack_standalone.c	2005-03-25 14:48:13.550910696 -0500
+++ linux-new/net/ipv4/netfilter/ip_conntrack_standalone.c	2005-03-26 01:03:09.916852000 -0500
@@ -423,13 +423,6 @@
 				        const struct net_device *out,
 				        int (*okfn)(struct sk_buff *))
 {
-#if !defined(CONFIG_IP_NF_NAT) && !defined(CONFIG_IP_NF_NAT_MODULE)
-	/* Previously seen (loopback)?  Ignore.  Do this before
-           fragment check. */
-	if ((*pskb)->nfct)
-		return NF_ACCEPT;
-#endif
-
 	/* Gather fragments. */
 	if ((*pskb)->nh.iph->frag_off & htons(IP_MF|IP_OFFSET)) {
 		*pskb = ip_ct_gather_frags(*pskb,

--2fHTh5uZTiUOsy+g--
