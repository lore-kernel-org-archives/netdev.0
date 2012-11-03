From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: iptables/tc: page allocation failures question
Date: Sat, 03 Nov 2012 12:34:59 +0100
Message-ID: <1351942499.21634.1640.camel@edumazet-glaptop>
References: <CAO0uZ+_AZG2cT4NvvLKrbkKjMm09vi_Dqd6d49h0hE5Lh9+pmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Miroslav Kratochvil <exa.exa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:42749 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864Ab2KCLfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 07:35:04 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so1666523eaa.19
        for <netdev@vger.kernel.org>; Sat, 03 Nov 2012 04:35:03 -0700 (PDT)
In-Reply-To: <CAO0uZ+_AZG2cT4NvvLKrbkKjMm09vi_Dqd6d49h0hE5Lh9+pmA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-11-03 at 11:27 +0100, Miroslav Kratochvil wrote:
> Hello everyone,
> 
> I've got several linux boxes that do mostly routing and traffic
> shaping stuff. The load isn't any dramatic - it's around 100Mbit of
> traffic shaping over a HFSC qdisc with ~10k classes/filters.
> 
> Recently I started seeing messages like this in dmesg:
> 
> iptables: page allocation failure: order:9, mode:0xc0d0
> 
> tc: page allocation failure (....)
> 
> (full messages are attached below)
> 
> I understood that it means the kernel couldn't allocate memory for
> execution of given command - it is usually triggered by stuff like 'tc
> class add' or 'iptables -A something'.
> 
> The boxes, on the other hand, still have pretty much free memory
> (alloc+buffers+cache fill around 400MB of 2 gigs available, swap is
> empty). I guess the problem is caused by the fact that the allocation
> is constrained by something (like GFP_ATOMIC, or that they can only
> allocate lower memory). Is this true? If so, is there some possibility
> to avoid such constraint?
> 
> What also worries me is that when the box at some point starts to do
> memory allocation failures, I've been unable to make it stop, even if
> I delete all qdiscs/iptable entries, clear every cache I know about
> and restart most of userspace, which should hopefully free a good
> amount of memory, nothing can be added back.
> 
> I'm attaching the dmesg of the failure below. Could anyone provide a
> comment on this, or possibly point me to what can cause this behavior?
> Is there any better debug output that could clarify this?
> 
> Thanks in advance,
> Mirek Kratochvil

You apparently load xt_recent module with a big ip_list_tot value
(default is 100), and kzalloc() wants an order-9 page (contiguous 2MB of
ram), and it fails.

I guess following patch should solve your problem

diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 4635c9b..ceebd8b 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -29,6 +29,7 @@
 #include <linux/skbuff.h>
 #include <linux/inet.h>
 #include <linux/slab.h>
+#include <linux/vmalloc.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
@@ -310,6 +311,14 @@ out:
 	return ret;
 }
 
+static void recent_table_free(void *addr)
+{
+	if (is_vmalloc_addr(addr))
+		vfree(addr);
+	else
+		kfree(addr);
+}
+
 static int recent_mt_check(const struct xt_mtchk_param *par,
 			   const struct xt_recent_mtinfo_v1 *info)
 {
@@ -322,6 +331,7 @@ static int recent_mt_check(const struct xt_mtchk_param *par,
 #endif
 	unsigned int i;
 	int ret = -EINVAL;
+	size_t sz;
 
 	if (unlikely(!hash_rnd_inited)) {
 		get_random_bytes(&hash_rnd, sizeof(hash_rnd));
@@ -360,8 +370,11 @@ static int recent_mt_check(const struct xt_mtchk_param *par,
 		goto out;
 	}
 
-	t = kzalloc(sizeof(*t) + sizeof(t->iphash[0]) * ip_list_hash_size,
-		    GFP_KERNEL);
+	sz = sizeof(*t) + sizeof(t->iphash[0]) * ip_list_hash_size;
+	if (sz <= PAGE_SIZE)
+		t = kzalloc(sz, GFP_KERNEL);
+	else
+		t = vzalloc(sz);
 	if (t == NULL) {
 		ret = -ENOMEM;
 		goto out;
@@ -377,14 +390,14 @@ static int recent_mt_check(const struct xt_mtchk_param *par,
 	uid = make_kuid(&init_user_ns, ip_list_uid);
 	gid = make_kgid(&init_user_ns, ip_list_gid);
 	if (!uid_valid(uid) || !gid_valid(gid)) {
-		kfree(t);
+		recent_table_free(t);
 		ret = -EINVAL;
 		goto out;
 	}
 	pde = proc_create_data(t->name, ip_list_perms, recent_net->xt_recent,
 		  &recent_mt_fops, t);
 	if (pde == NULL) {
-		kfree(t);
+		recent_table_free(t);
 		ret = -ENOMEM;
 		goto out;
 	}
@@ -434,7 +447,7 @@ static void recent_mt_destroy(const struct xt_mtdtor_param *par)
 		remove_proc_entry(t->name, recent_net->xt_recent);
 #endif
 		recent_table_flush(t);
-		kfree(t);
+		recent_table_free(t);
 	}
 	mutex_unlock(&recent_mutex);
 }
