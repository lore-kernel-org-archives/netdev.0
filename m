From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPv4]: More fib_alias insertion fixes
Date: Sun, 26 Sep 2004 22:32:34 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CBYCg-0000RG-00@gondolin.me.apana.org.au>
References: <Pine.LNX.4.58.0409261224350.8973@u.domain.uli>
Cc: herbert@gondor.apana.org.au, davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ja@ssi.bg (Julian Anastasov)
In-Reply-To: <Pine.LNX.4.58.0409261224350.8973@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Julian Anastasov <ja@ssi.bg> wrote:
> 
>        As for your last change, it is wrong:
> 
>>                 prev_fa = NULL;
>>                 list_for_each_entry(fa, head, fa_list) {
>> -                       if (fa->fa_tos != tos)
>> -                               continue;
>> +                       if (fa->fa_tos < tos)
> 
>        here prev_fa can be NULL but we require to stop at fa.
> It happens when we are creating first entry in our subchain.

If fa->fa_tos < tos, then we should add the new entry before fa.
If prev_fa is not NULL, then adding after prev_fa is obviously
correct.  If prev_fa is NULL, the caller will add it after the
head of the list which is also correct since fa must've been the
first element in the list.

>> +                               break;
>>                         prev_fa = fa;
>> +                       if (fa->fa_tos > tos)
>> +                               continue;
>>                         if (prio <= fa->fa_info->fib_priority)
>>                                 break;
> 
>        here if fa is the last one it is wrong to return prev_fa!=NULL,
> we need to return NULL (append) because we have to append
> new entry in our subchain (which is last in this case).

I still haven't figured out what you mean here, but I've found a bug :)
When prio < fa->fa_info->fib_priority, this returns the wrong entry.

> - fib_find_alias can return exact match: the desired TOS & PRIO.
> This is the first entry in a subchain where append and prepend
> matter (NLM_F_APPEND).

Ack.

> - the return value should be used in this way: if NULL then we have
> to append the new entry at end of list. Else, it is a fa with

Not quite.  If it's NULL we add it at the *head* of the list.  We
call list_add and not list_add_tail.  Actually your patch changes the
list_add call to list_add_tail so your comment would be correct if your
patch had been applied :)

> fa_tos<desired_TOS || (fa_tos==desired_TOS && fib_priority >= desired PRIO)
> We are going to insert the new entry before this fa (even if it is
> not exact match, even if it is from next subchain). Saying it in
> another way: use append only if there is no place to insert.

Again this is only true if we apply your patch.  As it is find_alias
returns (and is expected to return) the entry *before* where the new
entry should be added.

Whether it *should* be before or after is obviously a deep philosophical
question :)

So here are two patches to fix the fib_priority problem.  The first one
returns the entry before as we do now while the second one returns the
entry afterwards.

Actually, I just noticed that this philosophical question does have
practical implications :) The list_for_each_entry_continue() loop in
fn_hash_delete will fail if fa is the entry before the correct position.

Therefore I withdraw my endorsement for the "entry before" interpretation :)
So patch 1 is only present for review purposes, please don't apply it.

Patch 2 is good as far as I can see.  So,

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
-- patch 1
===== net/ipv4/fib_hash.c 1.26 vs edited =====
--- 1.26/net/ipv4/fib_hash.c	2004-09-24 06:19:43 +10:00
+++ edited/net/ipv4/fib_hash.c	2004-09-26 22:02:51 +10:00
@@ -442,11 +442,15 @@
 
 		prev_fa = NULL;
 		list_for_each_entry(fa, head, fa_list) {
-			if (fa->fa_tos != tos)
-				continue;
-			prev_fa = fa;
-			if (prio <= fa->fa_info->fib_priority)
+			if (fa->fa_tos < tos)
 				break;
+			if (fa->fa_tos == tos) {
+				if (prio == fa->fa_info->fib_priority)
+					prev_fa = fa;
+				if (prio <= fa->fa_info->fib_priority)
+					break;
+			}
+			prev_fa = fa;
 		}
 		return prev_fa;
 	}
@@ -506,6 +510,7 @@
 	 */
 
 	if (fa &&
+	    fa->fa_tos == tos &&
 	    fa->fa_info->fib_priority == fi->fib_priority) {
 		struct fib_alias *fa_orig;

-- patch 2
===== net/ipv4/fib_hash.c 1.27 vs edited =====
--- 1.27/net/ipv4/fib_hash.c	2004-09-26 22:11:38 +10:00
+++ edited/net/ipv4/fib_hash.c	2004-09-26 22:25:10 +10:00
@@ -432,23 +432,23 @@
 }
 
 /* Return the first fib alias matching TOS with
- * priority less than or equal to PRIO.
+ * the same priority or the point where the node should be inserted.
  */
 static struct fib_alias *fib_find_alias(struct fib_node *fn, u8 tos, u32 prio)
 {
 	if (fn) {
 		struct list_head *head = &fn->fn_alias;
-		struct fib_alias *fa, *prev_fa;
+		struct fib_alias *fa;
 
-		prev_fa = NULL;
 		list_for_each_entry(fa, head, fa_list) {
-			if (fa->fa_tos != tos)
+			if (fa->fa_tos < tos)
+				break;
+			if (fa->fa_tos > tos)
 				continue;
-			prev_fa = fa;
 			if (prio <= fa->fa_info->fib_priority)
 				break;
 		}
-		return prev_fa;
+		return fa;
 	}
 	return NULL;
 }
@@ -506,6 +506,7 @@
 	 */
 
 	if (fa &&
+	    fa->fa_tos == tos &&
 	    fa->fa_info->fib_priority == fi->fib_priority) {
 		struct fib_alias *fa_orig;
 
@@ -586,7 +587,7 @@
 	write_lock_bh(&fib_hash_lock);
 	if (new_f)
 		fib_insert_node(fz, new_f);
-	list_add(&new_fa->fa_list,
+	list_add_tail(&new_fa->fa_list,
 		 (fa ? &fa->fa_list : &f->fn_alias));
 	write_unlock_bh(&fib_hash_lock);
 
