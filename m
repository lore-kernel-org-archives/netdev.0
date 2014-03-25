From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 05/54] bfin_mac: Call dev_consume_skb_any instead of
 dev_kfree_skb.
Date: Tue, 25 Mar 2014 06:10:32 -0700
Message-ID: <1395753032.12610.113.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-5-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:51243 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbaCYNKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 09:10:35 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so419176pdb.0
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 06:10:35 -0700 (PDT)
In-Reply-To: <1395727540-12148-5-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:04 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace dev_kfree_skb with dev_consume_skb_any in _tx_reclaim_skb that
> can be called in hard irq and other contexts.
> 
> dev_consume_skb is used as _tx_reclaim_skb is called after a packet
> has been successfully transmitted.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  drivers/net/ethernet/adi/bfin_mac.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
> index 83a8cdbcd936..95779b6b7394 100644
> --- a/drivers/net/ethernet/adi/bfin_mac.c
> +++ b/drivers/net/ethernet/adi/bfin_mac.c
> @@ -1087,7 +1087,7 @@ static inline void _tx_reclaim_skb(void)
>  		tx_list_head->desc_a.config &= ~DMAEN;
>  		tx_list_head->status.status_word = 0;
>  		if (tx_list_head->skb) {
> -			dev_kfree_skb(tx_list_head->skb);
> +			dev_consume_skb_any(tx_list_head->skb);
>  			tx_list_head->skb = NULL;
>  		}
>  		tx_list_head = tx_list_head->next;

Acked-by: Eric Dumazet <edumazet@google.com>

Note this driver has a race in tx_reclaim_skb_timeout(), calling
tx_reclaim_skb() without any lock (under timer interrupt, thats all)
