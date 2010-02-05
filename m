From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH for 2.6.33] conntrack: restrict runtime hashsize 	modifications
Date: Fri, 05 Feb 2010 12:25:46 +0100
Message-ID: <4B6C003A.4050102@trash.net>
References: <20100203203929.GA6168@x200> <4B6AF36A.3050402@trash.net>	 <4B6AFE22.20304@trash.net> <20100204194744.GA4185@x200>	 <4B6BEC23.8020101@trash.net> <4B6BFE29.1040204@trash.net> <b6fcc0a1002050319p2ba0ff30y4bc8bdba08ff65d9@mail.gmail.com> <4B6BFF69.6050503@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090504010207010801090602"
Cc: davem@davemloft.net, jonathan@jonmasters.org,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B6BFF69.6050503@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090504010207010801090602
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Alexey Dobriyan wrote:
>> On Fri, Feb 5, 2010 at 1:16 PM, Patrick McHardy <kaber@trash.net> wrote:
>>> OK testing looks fine, although I'm quite surprised that its actually
>>> possible to change module parameters from within non-init namespaces.
>>> How is this supposed to work at all? I don't see how sysfs could
>>> possibly provide a network namespace context ...
>>
>> You can do in write hook
>>
>>     if (!net_eq(current->nsproxy->net_ns, &init_net))
>>             return -EINVAL;
> 
> Right, I see. So we could actually make resizing work for all
> namespaces quite easily. Is there any reason not to do this?
> 

Something like this (untested) patch on top of the previous one.

--------------090504010207010801090602
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index ef1c856..212dac3 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -31,6 +31,7 @@
 #include <linux/socket.h>
 #include <linux/mm.h>
 #include <linux/rculist_nulls.h>
+#include <linux/nsproxy.h>
 
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_l3proto.h>
@@ -1194,6 +1195,7 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 	unsigned int hashsize, old_size;
 	struct hlist_nulls_head *hash, *old_hash;
 	struct nf_conntrack_tuple_hash *h;
+	struct net *net = current->nsproxy->net_ns;
 
 	/* On boot, we can set this without any fancy locking. */
 	if (!nf_conntrack_htable_size)
@@ -1213,9 +1215,9 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 	 * though since that required taking the lock.
 	 */
 	spin_lock_bh(&nf_conntrack_lock);
-	for (i = 0; i < init_net.ct.htable_size; i++) {
-		while (!hlist_nulls_empty(&init_net.ct.hash[i])) {
-			h = hlist_nulls_entry(init_net.ct.hash[i].first,
+	for (i = 0; i < net->ct.htable_size; i++) {
+		while (!hlist_nulls_empty(&net->ct.hash[i])) {
+			h = hlist_nulls_entry(net->ct.hash[i].first,
 					struct nf_conntrack_tuple_hash, hnnode);
 			hlist_nulls_del_rcu(&h->hnnode);
 			bucket = __hash_conntrack(&h->tuple, hashsize,
@@ -1223,13 +1225,13 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 			hlist_nulls_add_head_rcu(&h->hnnode, &hash[bucket]);
 		}
 	}
-	old_size = init_net.ct.htable_size;
-	old_vmalloced = init_net.ct.hash_vmalloc;
-	old_hash = init_net.ct.hash;
+	old_size = net->ct.htable_size;
+	old_vmalloced = net->ct.hash_vmalloc;
+	old_hash = net->ct.hash;
 
-	init_net.ct.htable_size = nf_conntrack_htable_size = hashsize;
-	init_net.ct.hash_vmalloc = vmalloced;
-	init_net.ct.hash = hash;
+	net->ct.htable_size = nf_conntrack_htable_size = hashsize;
+	net->ct.hash_vmalloc = vmalloced;
+	net->ct.hash = hash;
 	spin_unlock_bh(&nf_conntrack_lock);
 
 	nf_ct_free_hashtable(old_hash, old_vmalloced, old_size);

--------------090504010207010801090602--
