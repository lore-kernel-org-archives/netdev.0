From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPv4]: More fib_alias insertion fixes
Date: Sat, 25 Sep 2004 20:14:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040925201425.16fbcb6c.davem@davemloft.net>
References: <Pine.LNX.4.58.0409252249150.1175@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.58.0409252249150.1175@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 25 Sep 2004 23:09:11 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

> - modify fib_find_alias to stop before the desired alias, even
> if reaching different TOS. If no alias is found we have to append
> at end of fn_alias.
> 
> - properly prepend/append new alias with same prefix/tos/prio
> 
> - use list_for_each_entry_continue
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Two things:

1) I applied a version of the list_for_each_entry_continue fix
   I got privately from Alexey, can you repatch relative to
   that?  It is included below.

2) The fib_alias list is not meant at all to be sorted by TOS
   value. Within a TOS it _is_ sorted by priority.  This was
   intentional, and I believe your changes assume I meant to
   keep the "aliases ordered by TOS" property.  I did not.

Please give test cases when posting fixes of this nature.
I wouldn't have to guess about #2 if you gave a bunch of
"ip route foo" commands that gave behavior you think is
incorrect.

Thanks.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/25 19:47:58-07:00 kuznet@ms2.inr.ac.ru 
#   [IPV4]: Fix fa_list walking in fib_hash.c
#   
#   Prevent accidently referencing f->fn_alias list
#   head as a real fib_alias object.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/ipv4/fib_hash.c
#   2004/09/25 19:47:27-07:00 kuznet@ms2.inr.ac.ru +4 -4
#   [IPV4]: Fix fa_list walking in fib_hash.c
#   
#   Prevent accidently referencing f->fn_alias list
#   head as a real fib_alias object.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
diff -Nru a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
--- a/net/ipv4/fib_hash.c	2004-09-25 19:54:08 -07:00
+++ b/net/ipv4/fib_hash.c	2004-09-25 19:54:08 -07:00
@@ -537,7 +537,8 @@
 		 * information.
 		 */
 		fa_orig = fa;
-		list_for_each_entry(fa, fa_orig->fa_list.prev, fa_list) {
+		fa = list_entry(fa->fa_list.prev, struct fib_alias, fa_list);
+		list_for_each_entry_continue(fa, &f->fn_alias, fa_list) {
 			if (fa->fa_tos != tos)
 				break;
 			if (fa->fa_info->fib_priority != fi->fib_priority)
@@ -611,7 +612,6 @@
 	struct fn_hash *table = (struct fn_hash*)tb->tb_data;
 	struct fib_node *f;
 	struct fib_alias *fa, *fa_to_delete;
-	struct list_head *fa_head;
 	int z = r->rtm_dst_len;
 	struct fn_zone *fz;
 	u32 key;
@@ -637,8 +637,8 @@
 		return -ESRCH;
 
 	fa_to_delete = NULL;
-	fa_head = fa->fa_list.prev;
-	list_for_each_entry(fa, fa_head, fa_list) {
+	fa = list_entry(fa->fa_list.prev, struct fib_alias, fa_list);
+	list_for_each_entry_continue(fa, &f->fn_alias, fa_list) {
 		struct fib_info *fi = fa->fa_info;
 
 		if (fa->fa_tos != tos)
