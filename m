From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] key: fix setkey(8) policy set breakage
Date: Fri, 31 Oct 2008 16:40:51 -0700 (PDT)
Message-ID: <20081031.164051.20530760.davem@davemloft.net>
References: <20081031221312.GA10575@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34241
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751279AbYJaXlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 19:41:17 -0400
In-Reply-To: <20081031221312.GA10575@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sat, 1 Nov 2008 01:13:13 +0300

> Steps to reproduce:
> 
> 	#/usr/sbin/setkey -f
> 	flush;
> 	spdflush;
> 
> 	add 192.168.0.42 192.168.0.1 ah 24500 -A hmac-md5 "1234567890123456";
> 	add 192.168.0.42 192.168.0.1 esp 24501 -E 3des-cbc "123456789012123456789012";
> 
> 	spdadd 192.168.0.42 192.168.0.1 any -P out ipsec
> 		esp/transport//require
> 		ah/transport//require;
> 
> setkey: invalid keymsg length
> 
> Policy dump will bail out with the same message after that.
> 
> -recv(4, "\2\16\0\0\32\0\3\0\0\0\0\0\37\r\0\0\3\0\5\0\377 \0\0\2\0\0\0\300\250\0*\0"..., 32768, 0) = 208
> +recv(4, "\2\16\0\0\36\0\3\0\0\0\0\0H\t\0\0\3\0\5\0\377 \0\0\2\0\0\0\300\250\0*\0"..., 32768, 0) = 208
> 
> Dunno how to explain this, but the following patch works. :^)
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Thanks for this fix Alexey, applied.

> --- a/net/key/af_key.c
> +++ b/net/key/af_key.c
> @@ -2075,7 +2075,6 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, struct xfrm_policy *xp, in
>  			req_size += socklen * 2;
>  		} else {
>  			size -= 2*socklen;
> -			socklen = 0;
>  		}
>  		rq = (void*)skb_put(skb, req_size);
>  		pol->sadb_x_policy_len += req_size/8;

Curious, I wonder why Yoshifuji-san zeros out this value in the first
place.  The default initialization of socklen never gets actually used
because of it.
