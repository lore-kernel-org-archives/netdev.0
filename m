From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC] add missing flow_cache_genid update to xfrm_policy_delete()
Date: Thu, 05 Aug 2004 22:01:40 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1BsgwG-0000O6-00@gondolin.me.apana.org.au>
References: <20040805071459.GA31551@gate.ebshome.net>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ebs@ebshome.net (Eugene Surovegin)
In-Reply-To: <20040805071459.GA31551@gate.ebshome.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Eugene Surovegin <ebs@ebshome.net> wrote:
> 
> Attached patch is against recent 2.6 BK, although I debugged this problem 
> on 2.4 + IPSec backport. From quick look 2.6 still needs this fix (but I 
> couldn't test 2.6 on our hw).

Thanks for the diagnosis and patch.  Looks like I had created yet another
policy timer bug :)

> Also, I think xfrm_sk_policy_insert() doesn't require similar change, but 
> I'm not 100% sure. Could IPSec gurus confirm this? 

Correct.  sk policies are not stored in the flow cache so they don't and
shouldn't cause genid to be incremented.

> ===== net/xfrm/xfrm_policy.c 1.52 vs edited =====
> --- 1.52/net/xfrm/xfrm_policy.c 2004-07-23 13:23:33 -07:00
> +++ edited/net/xfrm/xfrm_policy.c       2004-08-04 18:18:45 -07:00
> @@ -536,8 +536,10 @@
>        write_lock_bh(&xfrm_policy_lock);
>        pol = __xfrm_policy_unlink(pol, dir);
>        write_unlock_bh(&xfrm_policy_lock);
> -       if (pol)
> +       if (pol){
> +               atomic_inc(&flow_cache_genid);

Please add a dir < XFRM_POLICY_MAX check before the atomic_inc so that
dying sockets with policies don't blow away the flow cache.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
