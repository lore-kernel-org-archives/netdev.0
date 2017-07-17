From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next resubmit] skbuff: optimize the pull_pages code
 in __pskb_pull_tail()
Date: Mon, 17 Jul 2017 00:32:40 -0700
Message-ID: <1500276760.5566.5.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1500258126-11235-1-git-send-email-xiaolou4617@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Lin Zhang <xiaolou4617@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33764 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751257AbdGQHco (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 03:32:44 -0400
Received: by mail-wr0-f194.google.com with SMTP id 40so1890708wrw.0
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 00:32:43 -0700 (PDT)
In-Reply-To: <1500258126-11235-1-git-send-email-xiaolou4617@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-07-17 at 10:22 +0800, Lin Zhang wrote:
> In the pull_pages code block, if the first frag size > eat,
> we can end the loop in advance to avoid extra copy.
> 
> Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>
> ---
>  net/core/skbuff.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index f990eb8..c00a1df 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -1720,6 +1720,10 @@ void *__pskb_pull_tail(struct sk_buff *skb, int delta)
>  				skb_shinfo(skb)->frags[k].page_offset += eat;
>  				skb_frag_size_sub(&skb_shinfo(skb)->frags[k], eat);
>  				eat = 0;
> +				if (!i) {
> +					k = skb_shinfo(skb)->nr_frags;
> +					break;
> +				}
>  			}
>  			k++;
>  		}

-CC lkml  (no need to spam lkml for netdev patches )

Why even reading skb_shinfo(skb)->nr_frags to write it again ?

I would use something like :

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 8b11341ed69ad97d34dd3e9b73c8c44ef7c452ff..a562b0e61afa3faf7abdd7f9209ae9096310fb7d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1719,13 +1719,15 @@ void *__pskb_pull_tail(struct sk_buff *skb, int delta)
 			if (eat) {
 				skb_shinfo(skb)->frags[k].page_offset += eat;
 				skb_frag_size_sub(&skb_shinfo(skb)->frags[k], eat);
+				if (!i)
+					goto end;
 				eat = 0;
 			}
 			k++;
 		}
 	}
 	skb_shinfo(skb)->nr_frags = k;
-
+end:
 	skb->tail     += delta;
 	skb->data_len -= delta;
 
