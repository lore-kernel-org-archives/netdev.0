From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 1/3] netns: publish net_generic correctly
Date: Fri, 2 Dec 2016 04:11:34 +0300
Message-ID: <20161202011134.GB31170@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xemul@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:35494 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754322AbcLAXLp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 18:11:45 -0500
Received: by mail-lf0-f66.google.com with SMTP id p100so20466918lfg.2
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 15:11:44 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Publishing net_generic pointer is done with silly mistake: new array is
published BEFORE setting freshly acquired pernet subsystem pointer.

	memcpy
	rcu_assign_pointer
	kfree_rcu
	ng->ptr[id - 1] = data;

This bug was introduced with commit dec827d174d7f76c457238800183ca864a639365
("[NETNS]: The generic per-net pointers.") in the glorious days of
chopping networking stack into containers proper 8.5 years ago (whee...)

How it didn't trigger for so long?
Well, you need quite specific set of conditions:

*) race window opens once per pernet subsystem addition
   (read: modprobe or boot)

*) not every pernet subsystem is eligible (need ->id and ->size)

*) not every pernet subsystem is vulnerable (need incorrect or absense
   of ordering of register_pernet_sybsys() and actually using net_generic())

*) to hide the bug even more, default is to preallocate 13 pointers which
   is actually quite a lot. You need IPv6, netfilter, bridging etc together
   loaded to trigger reallocation in the first place. Trimmed down
   config are OK.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/core/net_namespace.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -64,9 +64,10 @@ static int net_assign_generic(struct net *net, unsigned int id, void *data)
 
 	old_ng = rcu_dereference_protected(net->gen,
 					   lockdep_is_held(&net_mutex));
-	ng = old_ng;
-	if (old_ng->len >= id)
-		goto assign;
+	if (old_ng->len >= id) {
+		old_ng->ptr[id - 1] = data;
+		return 0;
+	}
 
 	ng = net_alloc_generic();
 	if (ng == NULL)
@@ -84,11 +85,10 @@ static int net_assign_generic(struct net *net, unsigned int id, void *data)
 	 */
 
 	memcpy(&ng->ptr, &old_ng->ptr, old_ng->len * sizeof(void*));
+	ng->ptr[id - 1] = data;
 
 	rcu_assign_pointer(net->gen, ng);
 	kfree_rcu(old_ng, rcu);
-assign:
-	ng->ptr[id - 1] = data;
 	return 0;
 }
 
