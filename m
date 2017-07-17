From: lin zhang <xiaolou4617@gmail.com>
Subject: Re: [PATCH net-next resubmit] skbuff: optimize the pull_pages code in __pskb_pull_tail()
Date: Mon, 17 Jul 2017 16:24:32 +0800
Message-ID: <CAGd-6Zf+op44YT0b3qr2PVVOOxSK=FBarKTMRLX_f2F1VSQsJw@mail.gmail.com>
References: <1500258126-11235-1-git-send-email-xiaolou4617@gmail.com> <1500276760.5566.5.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:33517 "EHLO
        mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751257AbdGQIYe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 04:24:34 -0400
Received: by mail-ua0-f194.google.com with SMTP id z22so9159797uah.0
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 01:24:33 -0700 (PDT)
In-Reply-To: <1500276760.5566.5.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-07-17 15:32 GMT+08:00 Eric Dumazet <eric.dumazet@gmail.com>:
> On Mon, 2017-07-17 at 10:22 +0800, Lin Zhang wrote:
>> In the pull_pages code block, if the first frag size > eat,
>> we can end the loop in advance to avoid extra copy.
>>
>> Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>
>> ---
>>  net/core/skbuff.c | 4 ++++
>>  1 file changed, 4 insertions(+)
>>
>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> index f990eb8..c00a1df 100644
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -1720,6 +1720,10 @@ void *__pskb_pull_tail(struct sk_buff *skb, int delta)
>>                               skb_shinfo(skb)->frags[k].page_offset += eat;
>>                               skb_frag_size_sub(&skb_shinfo(skb)->frags[k], eat);
>>                               eat = 0;
>> +                             if (!i) {
>> +                                     k = skb_shinfo(skb)->nr_frags;
>> +                                     break;
>> +                             }
>>                       }
>>                       k++;
>>               }
>
> -CC lkml  (no need to spam lkml for netdev patches )
>
> Why even reading skb_shinfo(skb)->nr_frags to write it again ?
>
> I would use something like :
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 8b11341ed69ad97d34dd3e9b73c8c44ef7c452ff..a562b0e61afa3faf7abdd7f9209ae9096310fb7d 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -1719,13 +1719,15 @@ void *__pskb_pull_tail(struct sk_buff *skb, int delta)
>                         if (eat) {
>                                 skb_shinfo(skb)->frags[k].page_offset += eat;
>                                 skb_frag_size_sub(&skb_shinfo(skb)->frags[k], eat);
> +                               if (!i)
> +                                       goto end;
>                                 eat = 0;
>                         }
>                         k++;
>                 }
>         }
>         skb_shinfo(skb)->nr_frags = k;
> -
> +end:
>         skb->tail     += delta;
>         skb->data_len -= delta;
>
>
>
>
>
Yes, this change it is looks like better than me. :)


-- 
Lin Zhang
