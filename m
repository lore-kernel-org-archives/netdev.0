From: Patrick McHardy <kaber@trash.net>
Subject: Re: CONFIG_NETFILTER_DEBUG spew
Date: Sun, 01 May 2005 17:17:01 +0200
Message-ID: <4274F2ED.9080404@trash.net>
References: <20050501032809.3d0b4cda.akpm@osdl.org>
	<20050501111507.GA2133@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070805040200040001000308"
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050501111507.GA2133@gondor.apana.org.au>
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

This is a multi-part message in MIME format.
--------------070805040200040001000308
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> On Sun, May 01, 2005 at 10:28:09AM +0000, Andrew Morton wrote:
> 
>>With the below .config, `telnet localhost' spews stuff like this:
>>
>>[  179.995229] ip_local_deliver: bad loopback skb: PRE_ROUTING LOCAL_IN 
>>[  179.995274] skb: pf=2 (unowned) dev=lo len=54
>>[  179.995304] PROTO=6 127.0.0.1:23 127.0.0.1:2737 L=54 S=0x10 I=37030 F=0x4000 T=64
>>
>>2.6.12-rc3 doesn't do this - it's something to do with changes in Linus's
>>tree post-2.6.12-rc3.
>
> Patrick, looks like we need to fix nf_debug_ip_local_deliver to
> reflect the newly added nf_reset on the ip_output path.

You're right. I'm tempted to remove the entire nf_debug stuff,
as far as I know it has never found a real bug. But for now
I've only fixed the warning.

> BTW, should we do nf_reset in ip_dev_loopback_xmit as well?

I think so. I'll send a patch later, I'm a bit in a hurry right now.

Regards
Patrick

--------------070805040200040001000308
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NETFILTER]: Fix nf_debug_ip_local_deliver()

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit a91b6fa8bc4b1626d413d58c21cfcfecabbb4a61
tree 9544bb88b28c2e3ca4b0a66fedfa2bb540ec06e2
parent e8108c98dd6d65613fa0ec9d2300f89c48d554bf
author Patrick McHardy <kaber@trash.net> 1114952978 +0200
committer Patrick McHardy <kaber@trash.net> 1114952978 +0200

Index: net/core/netfilter.c
===================================================================
--- 3608de2fc88b062070a9d197eda9cac1fb9635d3/net/core/netfilter.c  (mode:100644 sha1:e51cfa46950cf8f1f4dea42be94e71d76d8c3c5b)
+++ 9544bb88b28c2e3ca4b0a66fedfa2bb540ec06e2/net/core/netfilter.c  (mode:100644 sha1:92c51824797dd15018e579eb5753cc372e04fd3d)
@@ -217,21 +217,10 @@
 	 * NF_IP_RAW_INPUT and NF_IP_PRE_ROUTING.  */
 	if (!skb->dev) {
 		printk("ip_local_deliver: skb->dev is NULL.\n");
-	}
-	else if (strcmp(skb->dev->name, "lo") == 0) {
-		if (skb->nf_debug != ((1 << NF_IP_LOCAL_OUT)
-				      | (1 << NF_IP_POST_ROUTING)
-				      | (1 << NF_IP_PRE_ROUTING)
-				      | (1 << NF_IP_LOCAL_IN))) {
-			printk("ip_local_deliver: bad loopback skb: ");
-			debug_print_hooks_ip(skb->nf_debug);
-			nf_dump_skb(PF_INET, skb);
-		}
-	}
-	else {
+	} else {
 		if (skb->nf_debug != ((1<<NF_IP_PRE_ROUTING)
 				      | (1<<NF_IP_LOCAL_IN))) {
-			printk("ip_local_deliver: bad non-lo skb: ");
+			printk("ip_local_deliver: bad skb: ");
 			debug_print_hooks_ip(skb->nf_debug);
 			nf_dump_skb(PF_INET, skb);
 		}

--------------070805040200040001000308--
