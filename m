From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 9/9] fix sparse warnings
Date: Sat, 12 Jan 2008 12:16:13 +0100
Message-ID: <4788A17D.5070903@cosmosbay.com>
References: <20080112064513.803976049@linux-foundation.org> <20080112064646.659443238@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030901070801080408040103"
Cc: David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:57031 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758164AbYALLQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 06:16:24 -0500
In-Reply-To: <20080112064646.659443238@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030901070801080408040103
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

Stephen Hemminger a écrit :
> Make FIB TRIE go through sparse checker without warnings.
> 
> Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>

Hi Stephen

While reviewing your patches (and fib code) I had some questions :

1) I was wondering isn't trie_collect_stats() a potential cpu hog
(big latency) ?

2) struct tnode layout
    If tnode->bits is large enough, we allocate a big area
    of memory but roughly use only first half of it.
    We could use a better scheme with an extra indirection. For small
    nodes, we use space right after tnode, but for big nodes, we allocate
    a power of two set of pages, to exactly match the memory need.

3) 'pos' and 'bits' fields of 'struct tnode' might be converted to
    plain uchar, instead of 5-bits fields, to reduce complexity for
    generated code.

4) full_children & empty_children being 'unsigned short',
    we probably are limited to 2^15 elements, but I could not
    find this limit enforced somewhere.

[FIB]: Reduce text size of net/ipv4/fib_trie.o

In struct tnode, we use two fields of 5 bits for 'pos' and 'bits'.
Switching to plain 'unsigned char' (8 bits) take the same space
because of compiler alignments, and reduce text size by 435 bytes
on i386.

On i386 :
$ size net/ipv4/fib_trie.o.before_patch net/ipv4/fib_trie.o
    text    data     bss     dec     hex filename
   13714       4      64   13782    35d6 net/ipv4/fib_trie.o.before
   13279       4      64   13347    3423 net/ipv4/fib_trie.o

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------030901070801080408040103
Content-Type: text/plain;
 name="fib_trie.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fib_trie.patch"

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 2832610..4e91532 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -119,8 +119,8 @@ struct leaf_info {
 struct tnode {
 	t_key key;
 	unsigned long parent;
-	unsigned short pos:5;		/* 2log(KEYLENGTH) bits needed */
-	unsigned short bits:5;		/* 2log(KEYLENGTH) bits needed */
+	unsigned char pos;		/* 2log(KEYLENGTH) bits needed */
+	unsigned char bits;		/* 2log(KEYLENGTH) bits needed */
 	unsigned short full_children;	/* KEYLENGTH bits needed */
 	unsigned short empty_children;	/* KEYLENGTH bits needed */
 	struct rcu_head rcu;

--------------030901070801080408040103--
