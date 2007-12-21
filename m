From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] [IPROUTE]: A workaround to make larger rto_min printed
	correctly
Date: Fri, 21 Dec 2007 09:34:31 +0100
Message-ID: <20071221083431.GA1708@ff.dom.local>
References: <d72b7ace0712201824k3754962cse377256cb5452b8a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Satoru SATOH <satoru.satoh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.190]:32018 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585AbXLUI3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 03:29:13 -0500
Received: by fk-out-0910.google.com with SMTP id z23so300088fkz.5
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2007 00:29:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <d72b7ace0712201824k3754962cse377256cb5452b8a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21-12-2007 03:24, Satoru SATOH wrote:
> 2007/12/21, Jarek Poplawski <jarkao2@gmail.com>:
>> Jarek Poplawski wrote, On 12/20/2007 09:24 PM:
>> ...
>>
>>> but since it's your patch, I hope you do some additional checking
>>> if it's always like this...
>>
>> ...or maybe only changing this all a little bit will make it look safer!
>>
>> Jarek P.
> 
> 
> OK, how about this?
> 
> Signed-off-by: Satoru SATOH <satoru.satoh@gmail.com>
> 
>  ip/iproute.c |   12 ++++++++----
>  1 files changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/ip/iproute.c b/ip/iproute.c
> index f4200ae..c771b34 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -510,16 +510,20 @@ int print_route(const struct sockaddr_nl *who,
> struct nlmsghdr *n, void *arg)
>  				fprintf(fp, " %u", *(unsigned*)RTA_DATA(mxrta[i]));
>  			else {
>  				unsigned val = *(unsigned*)RTA_DATA(mxrta[i]);
> +				unsigned hz1 = hz;
> +				if (hz1 > 1000)

Looks OK (safe) to me: it's compatible both with old and new way.
I'd only suggest to maybe change this to '(hz1 > 1024)', because
it's the biggest HZ currently in the kernel, so this compatibility
should be 100%. I think, you could leave 1 empty line before this
'if', as well. (Btw., aren't these overflows connected with
CONFIG_HIGH_RES_TIMERS?)

On the other hand this 'hz' still looks 'strange' here - I don't
understand, why, a bit earlier it's:

	if (!hz)
		hz = get_hz();

while 'else' would use: hz == get_user_hz();
So, probably I miss something, but even after your patch, there
could be different outputs here...

Thanks,
Jarek P.

PS: did you CC Stephen Hemminger on this?

> +					hz1 /= 1000;
> +				else
> +					val *= 1000;
> 
> -				val *= 1000;
>  				if (i == RTAX_RTT)
>  					val /= 8;
>  				else if (i == RTAX_RTTVAR)
>  					val /= 4;
> -				if (val >= hz)
> -					fprintf(fp, " %ums", val/hz);
> +				if (val >= hz1)
> +					fprintf(fp, " %ums", val/hz1);
>  				else
> -					fprintf(fp, " %.2fms", (float)val/hz);
> +					fprintf(fp, " %.2fms", (float)val/hz1);
>  			}
>  		}
>  	}
> 
> 
> Thanks,
> Satoru SATOH
