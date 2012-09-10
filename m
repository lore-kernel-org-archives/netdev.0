From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] staging: r8712u: fix bug in r8712_recv_indicatepkt()
Date: Mon, 10 Sep 2012 13:34:54 -0500
Message-ID: <504E32CE.10108@lwfinger.net>
References: <50369925.3050705@lwfinger.net>  <1345757200.5904.1890.camel@edumazet-glaptop> <50378B35.80307@lwfinger.net>  <20120824.111948.680531915905273128.davem@davemloft.net>  <5037A4B0.3080208@lwfinger.net>  <1345825095.19483.19.camel@edumazet-glaptop>  <1345825432.19483.20.camel@edumazet-glaptop> <5037B2AC.50704@lwfinger.net>  <1345830424.19483.69.camel@edumazet-glaptop>  <503BB49C.5010402@lwfinger.net>  <1347266366.1234.1267.camel@edumazet-glaptop>  <504DFEFF.6060004@lwfinger.net>  <1347289446.1234.1717.camel@edumazet-glaptop> <1347299715.1234.1902.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1347299715.1234.1902.camel@edumazet-glaptop>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/10/2012 12:55 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>
> 64bit arches have a buggy r8712u driver, let's fix it.
>
> Signed-off-by: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> ---
>   drivers/staging/rtl8712/recv_linux.c |    7 +------
>   1 file changed, 1 insertion(+), 6 deletions(-)
>
> diff --git a/drivers/staging/rtl8712/recv_linux.c b/drivers/staging/rtl8712/recv_linux.c
> index 0e26d5f..495ee12 100644
> --- a/drivers/staging/rtl8712/recv_linux.c
> +++ b/drivers/staging/rtl8712/recv_linux.c
> @@ -117,13 +117,8 @@ void r8712_recv_indicatepkt(struct _adapter *padapter,
>   	if (skb == NULL)
>   		goto _recv_indicatepkt_drop;
>   	skb->data = precv_frame->u.hdr.rx_data;
> -#ifdef NET_SKBUFF_DATA_USES_OFFSET
> -	skb->tail = (sk_buff_data_t)(precv_frame->u.hdr.rx_tail -
> -		     precv_frame->u.hdr.rx_head);
> -#else
> -	skb->tail = (sk_buff_data_t)precv_frame->u.hdr.rx_tail;
> -#endif
>   	skb->len = precv_frame->u.hdr.len;
> +	skb_set_tail_pointer(skb, skb->len);
>   	if ((pattrib->tcpchk_valid == 1) && (pattrib->tcp_chkrpt == 1))
>   		skb->ip_summed = CHECKSUM_UNNECESSARY;
>   	else

Eric,

Thanks for this. It works for me. I had looked at this code a number of times, 
but for some reason, I thought that the u.hdr.rx_yyyy parameters were like 
32-bit systems and that all 4 values were pointers, and not like 64-bit systems, 
thus the funny conversion. Strange that the bug was never triggered until commit 
c8628155ece3 - this code has not changed since the driver was accepted into 2.6.37.

A few points on the patch. As the driver is in staging, the patch needs to go to 
Greg Kroah-Hartman. In addition, please add the "Cc: Stable 
<stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" line. You may also give an a s-o-b for me. Finally, 
this patch should fix https://bugzilla.redhat.com/show_bug.cgi?id=847525, and 
https://bugzilla.kernel.org/show_bug.cgi?id=45071.

Larry

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
