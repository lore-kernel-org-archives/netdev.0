From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPv4]: More fib_alias insertion fixes
Date: Sun, 26 Sep 2004 18:14:49 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CBUBF-00034F-00@gondolin.me.apana.org.au>
References: <Pine.LNX.4.58.0409260857510.1151@u.domain.uli>
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ja@ssi.bg (Julian Anastasov)
In-Reply-To: <Pine.LNX.4.58.0409260857510.1151@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Julian Anastasov <ja@ssi.bg> wrote:
> 
>        But it still needs one exception: the entries with TOS 0
> must be at tail to allow fn_hash_lookup to match by TOS. With
> random TOS insertion this is not guaranteed, the entries with
> TOS=0 (wildcard) will match before the others.

Good point.

>                prev_fa = NULL;
>                list_for_each_entry(fa, head, fa_list) {
>                        if (fa->fa_tos != tos)
> -                               continue;
> +                       {
> +                               if (!prev_fa && fa->fa_tos)
> +                                       continue;
> +                               /* Stop at TOS 0 or after entries from our TOS */
> +                               return fa;
> +                       }

Well if we're doing this then we might as well keep it sorted by TOS.
It makes the code simpler, right?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
===== net/ipv4/fib_hash.c 1.26 vs edited =====
--- 1.26/net/ipv4/fib_hash.c	2004-09-24 06:19:43 +10:00
+++ edited/net/ipv4/fib_hash.c	2004-09-26 18:12:57 +10:00
@@ -442,9 +442,11 @@
 
 		prev_fa = NULL;
 		list_for_each_entry(fa, head, fa_list) {
-			if (fa->fa_tos != tos)
-				continue;
+			if (fa->fa_tos < tos)
+				break;
 			prev_fa = fa;
+			if (fa->fa_tos > tos)
+				continue;
 			if (prio <= fa->fa_info->fib_priority)
 				break;
 		}
@@ -506,6 +508,7 @@
 	 */
 
 	if (fa &&
+	    fa->fa_tos == tos &&
 	    fa->fa_info->fib_priority == fi->fib_priority) {
 		struct fib_alias *fa_orig;
 
