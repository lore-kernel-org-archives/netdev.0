From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [Oops] fib_trie with ip route add throw since 2.6.25
Date: Mon, 7 Jul 2008 20:57:45 +0100
Message-ID: <20080707195744.GE28029@solarflare.com>
References: <20080707184144.GA17506@yuri.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stephen.hemminger@vyatta.com
To: William Boughton <bill@boughton.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.mbr-roch.zen.net.uk ([212.23.3.141]:34041 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754306AbYGGT5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 15:57:48 -0400
Content-Disposition: inline
In-Reply-To: <20080707184144.GA17506@yuri.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Boughton wrote:
> 
> Hello,

Hello again!

> ip route add throw 192.168.0.1
> 
> ping 192.168.0.1
> 
> Oppses when CONFIG_IP_FIB_TRIE=y
> 
> Reproduced on both x86_64 and 32 on Xen and a normal
> kernel running in qemu/kvm.
> 
> It seems this problem was introduced in 2.6.25
> 
> git bisect reports that it may have been caused by:
> 
> a07f5f508a4d9728c8e57d7f66294bf5b254ff7f is first bad commit                    
> commit a07f5f508a4d9728c8e57d7f66294bf5b254ff7f                                 
> Author: Stephen Hemminger <stephen.hemminger@vyatta.com>                        
> Date:   Tue Jan 22 21:53:36 2008 -0800                                          
>                                                                                 
>     [IPV4] fib_trie: style cleanup                                              
>                                                                                 
>     Style cleanups:                                                             
>           * make check_leaf return -1 or plen, rather than by reference         
[...]

The changes to check_leaf() and fn_trie_lookup() seem to be wrong - where
fn_trie_lookup() would previously return a negative error value from
check_leaf(), it now returns 0.

Now fn_trie_lookup() doesn't appear to care about plen, so we could revert
check_leaf() to returning the error value.  How does this work?

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 394db9c..43ed894 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1357,17 +1357,17 @@ static int check_leaf(struct trie *t, struct leaf *l,
 			t->stats.semantic_match_miss++;
 #endif
 		if (err <= 0)
-			return plen;
+			return err;
 	}
 
-	return -1;
+	return 1;
 }
 
 static int fn_trie_lookup(struct fib_table *tb, const struct flowi *flp,
 			  struct fib_result *res)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
-	int plen, ret = 0;
+	int ret;
 	struct node *n;
 	struct tnode *pn;
 	int pos, bits;
@@ -1391,10 +1391,7 @@ static int fn_trie_lookup(struct fib_table *tb, const struct flowi *flp,
 
 	/* Just a leaf? */
 	if (IS_LEAF(n)) {
-		plen = check_leaf(t, (struct leaf *)n, key, flp, res);
-		if (plen < 0)
-			goto failed;
-		ret = 0;
+		ret = check_leaf(t, (struct leaf *)n, key, flp, res);
 		goto found;
 	}
 
@@ -1419,11 +1416,9 @@ static int fn_trie_lookup(struct fib_table *tb, const struct flowi *flp,
 		}
 
 		if (IS_LEAF(n)) {
-			plen = check_leaf(t, (struct leaf *)n, key, flp, res);
-			if (plen < 0)
+			ret = check_leaf(t, (struct leaf *)n, key, flp, res);
+			if (ret > 0)
 				goto backtrace;
-
-			ret = 0;
 			goto found;
 		}
--- END ---

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
