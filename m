From: Patrick McHardy <kaber@trash.net>
Subject: Re: Still oopsing in nf_nat_move_storage()
Date: Sat, 02 Feb 2008 12:02:01 +0100
Message-ID: <47A44DA9.20907@trash.net>
References: <479F5E5A.8050108@redhat.com> <479F5FDC.5040903@trash.net> <47A20D57.5040907@redhat.com> <47A3AE41.6070104@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050602090602000407000201"
Cc: Netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Thomas Woerner <twoerner@redhat.com>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47A3AE41.6070104@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050602090602000407000201
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Chuck Ebbert wrote:
> On 01/31/2008 01:03 PM, Chuck Ebbert wrote:
>> On 01/29/2008 12:18 PM, Patrick McHardy wrote:
>>> Chuck Ebbert wrote:
>>>> nf_nat_move_storage():
>>>> /usr/src/debug/kernel-2.6.23/linux-2.6.23.i686/net/ipv4/netfilter/nf_nat_core.c:612
>>>>
>>>>       87:       f7 47 64 80 01 00 00    testl  $0x180,0x64(%edi)
>>>>       8e:       74 39                   je     c9
>>>> <nf_nat_move_storage+0x65>
>>>>
>>>> line 612:
>>>>         if (!(ct->status & IPS_NAT_DONE_MASK))
>>>>                 return;
>>>>
>>>> ct is NULL
>>> The current kernel (and 2.6.23-stable) have:
>>>
>>>         if (!ct || !(ct->status & IPS_NAT_DONE_MASK))
>>>                 return;
>>>
>>> so it seems you're using an old version.
> 
> So, it is now oopsing after the test for NULL and only x86_64 is
> catching the invalid address because it is non-canonical. Checking
> for NULL is obviously not enough...


Could you try whether this patch fixes it please?


--------------050602090602000407000201
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 6953954cc566c19a84b7ca9647c16dabe4646c03
Author: Patrick McHardy <kaber@trash.net>
Date:   Sat Feb 2 12:01:03 2008 +0100

    [NETFILTER]: nf_conntrack: fix ct_extend ->move operation
    
    The ->move operation has two bugs:
    
    - It is called with the same extension as source and destination,
      so it doesn't update the new extension.
    
    - The address of the old extension is calculated incorrectly,
      instead of (void *)ct->ext + ct->ext->offset[i] it uses
      ct->ext + ct->ext->offset[i].
    
    Should fix a crash on x86_64 reported by Chuck Ebbert <cebbert@redhat.com>
    and Thomas Woerner <twoerner@redhat.com>.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
index 73b5711..49aac63 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -67,7 +67,7 @@ struct nf_ct_ext_type
 	void (*destroy)(struct nf_conn *ct);
 	/* Called when realloacted (can be NULL).
 	   Contents has already been moved. */
-	void (*move)(struct nf_conn *ct, void *old);
+	void (*move)(void *new, void *old);
 
 	enum nf_ct_ext_id id;
 
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index dd07362..0d5fa3a 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -600,10 +600,10 @@ static void nf_nat_cleanup_conntrack(struct nf_conn *ct)
 	spin_unlock_bh(&nf_nat_lock);
 }
 
-static void nf_nat_move_storage(struct nf_conn *conntrack, void *old)
+static void nf_nat_move_storage(void *new, void *old)
 {
-	struct nf_conn_nat *new_nat = nf_ct_ext_find(conntrack, NF_CT_EXT_NAT);
-	struct nf_conn_nat *old_nat = (struct nf_conn_nat *)old;
+	struct nf_conn_nat *new_nat = new;
+	struct nf_conn_nat *old_nat = old;
 	struct nf_conn *ct = old_nat->ct;
 
 	if (!ct || !(ct->status & IPS_NAT_DONE_MASK))
diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
index cf6ba66..8b9be1e 100644
--- a/net/netfilter/nf_conntrack_extend.c
+++ b/net/netfilter/nf_conntrack_extend.c
@@ -109,7 +109,8 @@ void *__nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp)
 			rcu_read_lock();
 			t = rcu_dereference(nf_ct_ext_types[i]);
 			if (t && t->move)
-				t->move(ct, ct->ext + ct->ext->offset[i]);
+				t->move((void *)new + new->offset[i],
+					(void *)ct->ext + ct->ext->offset[i]);
 			rcu_read_unlock();
 		}
 		kfree(ct->ext);

--------------050602090602000407000201--
