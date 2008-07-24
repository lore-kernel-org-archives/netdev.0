From: Patrick McHardy <kaber@trash.net>
Subject: Re: [regression] nf_iterate(), BUG: unable to handle kernel NULL
 pointer dereference
Date: Thu, 24 Jul 2008 14:49:53 +0200
Message-ID: <48887A71.5010209@trash.net>
References: <20080724060448.GA10203@elte.hu>	 <E1KLwlD-0001Ub-00@gondolin.me.apana.org.au>	 <20080724.022259.113079007.davem@davemloft.net>	 <20080724093411.GA12001@elte.hu> <20080724115625.GA23994@elte.hu>	 <20080724115957.GA25701@elte.hu> <48886FA6.6050908@trash.net> <84144f020807240544q507e1b7cv220d1afbae0ee0f0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000407000007070409030807"
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, w@1wt.eu, davidn@davidnewall.com,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stefanr@s5r6.in-berlin.de, rjw@sisk.pl, ilpo.jarvinen@helsinki.fi,
	Dave Jones <davej@redhat.com>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35686 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751062AbYGXMt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 08:49:57 -0400
In-Reply-To: <84144f020807240544q507e1b7cv220d1afbae0ee0f0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000407000007070409030807
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Pekka Enberg wrote:
> On Thu, Jul 24, 2008 at 3:03 PM, Patrick McHardy <kaber@trash.net> wrote:
>> Ingo Molnar wrote:
>>> * Ingo Molnar <mingo@elte.hu> wrote:
>>>
>>>> here's a new type of crash a -tip testbox triggered today:
>>>>
>>>> BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
>>>> IP: [<0000000000000000>] 0x0
>>>> ...
>>>> Call Trace:
>>>>  [<ffffffff80777f25>] ? ipv4_confirm+0x8d/0x122
>>>>  [<ffffffff80733107>] nf_iterate+0x43/0xa5
>> Does reverting 31d8519c fix this?
> 
> Hmm, why do you think it's related? It looks like elem->hook() is a
> NULL pointer but my patch shouldn't make any difference here...

No, its already in ipv4_confirm, so its most likely helper->help()
thats NULL, which is contained in an extension.

The reason why I think its this patch is (quoting from an old
email that I never got a response to):

---
Your patch introduced a use-after-free and double-free.
krealloc() frees the old pointer, but it is still used
for the ->move operations, then freed again.

To fix this I think we need a __krealloc() that doesn't
free the old memory, especially since it must not be
freed immediately because it may still be used in a RCU
read side (see the last part in the patch attached to
this mail (based on a kernel without your patch)).
---

I've attached that patch again.

--------------000407000007070409030807
Content-Type: text/x-diff;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

netfilter: nf_nat: fix RCU races

Fix three ct_extend/NAT extension related races:

- When cleaning up the extension area and removing it from the bysource hash,
  the nat->ct pointer must not be set to NULL since it may still be used in
  a RCU read side

- When replacing a NAT extension area in the bysource hash, the nat->ct
  pointer must be assigned before performing the replacement

- When reallocating extension storage in ct_extend, the old memory must
  not be freed immediately since it may still be used by a RCU read side

Possibly fixes https://bugzilla.redhat.com/show_bug.cgi?id=449315
and/or http://bugzilla.kernel.org/show_bug.cgi?id=10875

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 8d4c178a5e17c19cf7a781b0e5e416c4e22b1ff2
tree 2c4651788906d120cb7636006e2178dbd7a283c4
parent ec0a196626bd12e0ba108d7daa6d95a4fb25c2c5
author Patrick McHardy <kaber@trash.net> Sat, 14 Jun 2008 12:42:45 +0200
committer Patrick McHardy <kaber@trash.net> Sat, 14 Jun 2008 12:42:45 +0200

 include/net/netfilter/nf_conntrack_extend.h |    1 +
 net/ipv4/netfilter/nf_nat_core.c            |    3 +--
 net/netfilter/nf_conntrack_extend.c         |    9 ++++++++-
 3 files changed, 10 insertions(+), 3 deletions(-)

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
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 0457859..d2a887f 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -556,7 +556,6 @@ static void nf_nat_cleanup_conntrack(struct nf_conn *ct)
 
 	spin_lock_bh(&nf_nat_lock);
 	hlist_del_rcu(&nat->bysource);
-	nat->ct = NULL;
 	spin_unlock_bh(&nf_nat_lock);
 }
 
@@ -570,8 +569,8 @@ static void nf_nat_move_storage(void *new, void *old)
 		return;
 
 	spin_lock_bh(&nf_nat_lock);
-	hlist_replace_rcu(&old_nat->bysource, &new_nat->bysource);
 	new_nat->ct = ct;
+	hlist_replace_rcu(&old_nat->bysource, &new_nat->bysource);
 	spin_unlock_bh(&nf_nat_lock);
 }
 
diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
index bcc19fa..8a3f8b3 100644
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
 
+static void __nf_ct_ext_free_rcu(struct rcu_head *head)
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
+		call_rcu(&ct->ext->rcu, __nf_ct_ext_free_rcu);
 		ct->ext = new;
 	}
 

--------------000407000007070409030807--
