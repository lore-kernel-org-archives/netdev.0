From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH 1/1] net: fix cipso packet validation when !NETLABEL
Date: Fri, 18 Oct 2013 17:01:11 -0400
Message-ID: <1569451.pWV9BbDlmr@sifl>
References: <1382067201-8286-1-git-send-email-seif.mazareeb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, seif@marvell.com
To: Seif Mazareeb <seif.mazareeb@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f41.google.com ([209.85.128.41]:35124 "EHLO
	mail-qe0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543Ab3JRVBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 17:01:15 -0400
Received: by mail-qe0-f41.google.com with SMTP id x7so2312425qeu.28
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 14:01:15 -0700 (PDT)
In-Reply-To: <1382067201-8286-1-git-send-email-seif.mazareeb@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, October 17, 2013 08:33:21 PM Seif Mazareeb wrote:
> From: Seif Mazareeb <seif@marvell.com>
> 
> When CONFIG_NETLABEL is disabled, the cipso_v4_validate() function could
> loop forever in the main loop if opt[opt_iter +1] == 0, this will causing a
> kernel crash in an SMP system, since the CPU executing this function will
> stall /not respond to IPIs.
> 
> This problem can be reproduced by running the IP Stack Integrity Checker
> (http://isic.sourceforge.net) using the following command on a Linux machine
> connected to DUT:
> 
> "icmpsic -s rand -d <DUT IP address> -r 123456"
> wait (1-2 min)
> 
> Signed-off-by: Seif Mazareeb <seif@marvell.com>

This version imported properly for me.

Acked-by: Paul Moore <paul@paul-moore.com>

> ---
>  include/net/cipso_ipv4.h | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/cipso_ipv4.h b/include/net/cipso_ipv4.h
> index a7a683e..a8c2ef6 100644
> --- a/include/net/cipso_ipv4.h
> +++ b/include/net/cipso_ipv4.h
> @@ -290,6 +290,7 @@ static inline int cipso_v4_validate(const struct sk_buff
> *skb, unsigned char err_offset = 0;
>  	u8 opt_len = opt[1];
>  	u8 opt_iter;
> +	u8 tag_len;
> 
>  	if (opt_len < 8) {
>  		err_offset = 1;
> @@ -302,11 +303,12 @@ static inline int cipso_v4_validate(const struct
> sk_buff *skb, }
> 
>  	for (opt_iter = 6; opt_iter < opt_len;) {
> -		if (opt[opt_iter + 1] > (opt_len - opt_iter)) {
> +		tag_len = opt[opt_iter + 1];
> +		if ((tag_len == 0) || (opt[opt_iter + 1] > (opt_len - opt_iter))) {
>  			err_offset = opt_iter + 1;
>  			goto out;
>  		}
> -		opt_iter += opt[opt_iter + 1];
> +		opt_iter += tag_len;
>  	}
> 
>  out:

-- 
paul moore
www.paul-moore.com
