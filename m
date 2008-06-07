From: Patrick McHardy <kaber@trash.net>
Subject: Re: Oops in nf_nat_core.c:find_appropriate_src(), kernel 2.6.25.4
Date: Sat, 07 Jun 2008 17:14:29 +0200
Message-ID: <484AA5D5.10404@trash.net>
References: <484A9E75.8000601@redhat.com> <484AA276.9090407@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010309010309030105080802"
Cc: Netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47035 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756616AbYFGPOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jun 2008 11:14:33 -0400
In-Reply-To: <484AA276.9090407@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010309010309030105080802
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Chuck Ebbert wrote:
>> Reported at https://bugzilla.redhat.com/show_bug.cgi?id=449315
>>
>> In find_appropriate_src():
>>
>>         hlist_for_each_entry_rcu(nat, n, &bysource[h], bysource) {
>>                 ct = nat->ct;
>>                 if (same_src(ct, tuple)) {
>>
>> Dereference of ct in same_src() causes the oops. This only seems to
>> happen on heavily loaded firewall machines. Kernel 2.6.24.7 works.
>>
>> The reporter identifies commit 4d354c5782dc352cec187845d17eedc2c2bfcf67
>> ("[NETFILTER]: nf_nat: use RCU for bysource hash") as a possible cause
>> of the problem.
> 
> We have a similar looking report, but that one also affects 2.6.24:
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=10875
> 
> Anyways, does this patch help? When reallocating storage
> for a conntrack, it is replaced in the list before assigning
> the nat->ct pointer.


I'm afraid we also need this one on top - when reallocating
an extension, we must not free the old storage since it may
still be used in a RCU read side.



--------------010309010309030105080802
Content-Type: text/plain;
 name="x2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x2"

diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
index f736e84..f80c0ed 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -15,6 +15,7 @@ enum nf_ct_ext_id
 
 /* Extensions: optional stuff which isn't permanently in struct. */
 struct nf_ct_ext {
+	struct rcu_head rcu;
 	u8 offset[NF_CT_EXT_NUM];
 	u8 len;
 	char data[0];
diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
index bcc19fa..90d4a74 100644
--- a/net/netfilter/nf_conntrack_extend.c
+++ b/net/netfilter/nf_conntrack_extend.c
@@ -59,12 +59,19 @@ nf_ct_ext_create(struct nf_ct_ext **ext, enum nf_ct_ext_id id, gfp_t gfp)
 	if (!*ext)
 		return NULL;
 
+	INIT_RCU_HEAD(&(*ext)->rcu);
 	(*ext)->offset[id] = off;
 	(*ext)->len = len;
 
 	return (void *)(*ext) + off;
 }
 
+static void __nf_ct_ext_destroy_rcu(struct rcu_head *head)
+{
+	struct nf_ct_ext *ext = container_of(head, struct nf_ct_ext, rcu);
+	kfree(ext);
+}
+
 void *__nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp)
 {
 	struct nf_ct_ext *new;
@@ -106,7 +113,7 @@ void *__nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp)
 					(void *)ct->ext + ct->ext->offset[i]);
 			rcu_read_unlock();
 		}
-		kfree(ct->ext);
+		call_rcu(&ct->ext->rcu, __nf_ct_ext_destroy_rcu);
 		ct->ext = new;
 	}
 

--------------010309010309030105080802--
