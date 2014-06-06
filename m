From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: net: llc: NULL ptr deref in llc_ui_sendmsg
Date: Fri, 06 Jun 2014 21:51:03 +0400
Message-ID: <5391FF87.1010000@cogentembedded.com>
References: <5391D971.4030001@oracle.com> <20140606154231.GA7629@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Dave Jones <davej@redhat.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:38496 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743AbaFFRux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 13:50:53 -0400
Received: by mail-la0-f43.google.com with SMTP id mc6so1743205lab.16
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 10:50:51 -0700 (PDT)
In-Reply-To: <20140606154231.GA7629@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/06/2014 07:42 PM, Dave Jones wrote:

>   > Hi all,

>   > While fuzzing with trinity inside a KVM tools guest running the latest -next
>   > kernel I've stumbled on the following spew:

>   > [  269.531162] BUG: unable to handle kernel NULL pointer dereference at 000000000000021e
>   > [  269.531217] IP: llc_ui_sendmsg (net/llc/af_llc.c:912)

>   905         /* must bind connection to sap if user hasn't done it. */
>   906         if (sock_flag(sk, SOCK_ZAPPED)) {
>   907                 /* bind to sap with null dev, exclusive. */
>   908                 rc = llc_ui_autobind(sock, addr);
>   909                 if (rc)
>   910                         goto release;
>   911         }
>   912         hdrlen = llc->dev->hard_header_len + llc_ui_header_len(sk, addr);

> looks like llc->dev was null, (understandable, given Trinity doesn't really know
> how to set up llc beyond random socket()/setsockopt() calls).

> llc_ui_autobind returns -ENODEV in that case, so it looks like the SOCK_ZAPPED test
> was false. Something like the patch below maybe ? It feels ugly to be duplicating that
> test there, but if this is agreed upon I'll resubmit this properly.

> 	Dave

> diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
> index 0080d2b0a8ae..9b192db9883b 100644
> --- a/net/llc/af_llc.c
> +++ b/net/llc/af_llc.c
> @@ -908,6 +908,11 @@ static int llc_ui_sendmsg(struct kiocb *iocb, struct socket *sock,
>   		rc = llc_ui_autobind(sock, addr);
>   		if (rc)
>   			goto release;
> +	} else {
> +		if (!llc->dev) {

	} else if (!llc->dev) {

> +			rc = -ENODEV;
> +			goto release;
> +		}
>   	}
>   	hdrlen = llc->dev->hard_header_len + llc_ui_header_len(sk, addr);
>   	size = hdrlen + len;

WBR, Sergei
