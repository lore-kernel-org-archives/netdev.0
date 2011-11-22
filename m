From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH net-next] atm: use SKB_TRUESIZE() in
 atm_guess_pdu2truesize()
Date: Tue, 22 Nov 2011 15:22:07 -0500
Message-ID: <20111122152207.114bcd68@thirdoffive.cmf.nrl.navy.mil>
References: <1321941094.27077.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:53494 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754496Ab1KVUgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 15:36:53 -0500
In-Reply-To: <1321941094.27077.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

it doesnt seem like a good idea to create a wrapper for a one to one
call.  perhaps this whole bit of nonsense should be removed.  the
iphase driver should be returning skb->truesize like everyone.  

if atm_alloc_charge() just uses SKB_TRUESIZE() then we konw that guess
will be the same as skb->truesize and atm_alloc_charge() can be
simplified by removing atomic_add(skb->truesize - guess, which will be
0 in all cases.

something like:

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 3d0c2b0..9e373ba 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -1320,8 +1320,8 @@ static void rx_dle_intr(struct atm_dev *dev)
           if (ia_vcc == NULL)
           {
              atomic_inc(&vcc->stats->rx_err);
+             atm_return(vcc, skb->truesize);
              dev_kfree_skb_any(skb);
-             atm_return(vcc, atm_guess_pdu2truesize(len));
              goto INCR_DLE;
            }
           // get real pkt length  pwang_test
@@ -1334,8 +1334,8 @@ static void rx_dle_intr(struct atm_dev *dev)
              atomic_inc(&vcc->stats->rx_err);
              IF_ERR(printk("rx_dle_intr: Bad  AAL5 trailer %d (skb len %d)", 
                                                             length, skb->len);)
+             atm_return(vcc, skb->truesize);
              dev_kfree_skb_any(skb);
-             atm_return(vcc, atm_guess_pdu2truesize(len));
              goto INCR_DLE;
           }
           skb_trim(skb, length);
diff --git a/net/atm/atm_misc.c b/net/atm/atm_misc.c
index f41f026..073fd99 100644
--- a/net/atm/atm_misc.c
+++ b/net/atm/atm_misc.c
@@ -26,19 +26,16 @@ struct sk_buff *atm_alloc_charge(struct atm_vcc *vcc, int pdu_size,
                                 gfp_t gfp_flags)
 {
        struct sock *sk = sk_atm(vcc);
-       int guess = atm_guess_pdu2truesize(pdu_size);
+       int truesize = SKB_TRUESIZE(pdu_size);
 
-       atm_force_charge(vcc, guess);
+       atm_force_charge(vcc, truesize);
        if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf) {
                struct sk_buff *skb = alloc_skb(pdu_size, gfp_flags);
 
-               if (skb) {
-                       atomic_add(skb->truesize-guess,
-                                  &sk->sk_rmem_alloc);
+               if (skb)
                        return skb;
-               }
        }
-       atm_return(vcc, guess);
+       atm_return(vcc, truesize);
        atomic_inc(&vcc->stats->rx_drop);
        return NULL;
 }


On Tue, 22 Nov 2011 06:51:34 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> SKB_TRUESIZE() provides a better approximation of expected skb truesize.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  include/linux/atmdev.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/atmdev.h b/include/linux/atmdev.h
> index 49a83ca..43ea1b2 100644
> --- a/include/linux/atmdev.h
> +++ b/include/linux/atmdev.h
> @@ -452,7 +452,7 @@ void atm_dev_release_vccs(struct atm_dev *dev);
>  
>  static inline int atm_guess_pdu2truesize(int size)
>  {
> -	return SKB_DATA_ALIGN(size) + sizeof(struct skb_shared_info);
> +	return SKB_TRUESIZE(size);
>  }
>  
>  
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
