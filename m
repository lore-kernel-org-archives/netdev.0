From: walter harms <wharms@bfs.de>
Subject: Re: [patch v2] isdn: icn: buffer overflow in icn_command()
Date: Wed, 16 Apr 2014 14:10:07 +0200
Message-ID: <534E731F.6060701@bfs.de>
References: <20140416112516.GA12917@mwanda>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01-fr.bfs.de ([193.174.231.67]:37546 "EHLO mx01-fr.bfs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753471AbaDPMKO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2014 08:10:14 -0400
In-Reply-To: <20140416112516.GA12917@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Am 16.04.2014 13:25, schrieb Dan Carpenter:
> This buffer over was detected using static analysis:
> 
> 	drivers/isdn/icn/icn.c:1325 icn_command()
> 	error: format string overflow. buf_size: 60 length: 98
> 
> The calculation for the length of the string is off because it assumes
> that the dial[] buffer holds a 50 character string, but actually it is
> at most 31 characters and NUL.  I have removed the dial[] buffer because
> it isn't needed.
> 
> The maximum length of the string is actually 79 characters and a NUL.  I
> have made the cbuf[] array large enough to hold it and changed the
> sprintf() to an snprintf() as a further safety enhancement.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> v2: update changelog.
> 
> diff --git a/drivers/isdn/icn/icn.c b/drivers/isdn/icn/icn.c
> index 53d487f..88c0603 100644
> --- a/drivers/isdn/icn/icn.c
> +++ b/drivers/isdn/icn/icn.c
> @@ -1155,7 +1155,7 @@ icn_command(isdn_ctrl *c, icn_card *card)
>  	ulong a;
>  	ulong flags;
>  	int i;
> -	char cbuf[60];
> +	char cbuf[80];
>  	isdn_ctrl cmd;
>  	icn_cdef cdef;
>  	char __user *arg;
> @@ -1309,7 +1309,6 @@ icn_command(isdn_ctrl *c, icn_card *card)
>  			break;
>  		if ((c->arg & 255) < ICN_BCH) {
>  			char *p;
> -			char dial[50];
>  			char dcode[4];
>  
>  			a = c->arg;
> @@ -1321,10 +1320,10 @@ icn_command(isdn_ctrl *c, icn_card *card)
>  			} else
>  				/* Normal Dial */
>  				strcpy(dcode, "CAL");
> -			strcpy(dial, p);
> -			sprintf(cbuf, "%02d;D%s_R%s,%02d,%02d,%s\n", (int) (a + 1),
> -				dcode, dial, c->parm.setup.si1,
> -				c->parm.setup.si2, c->parm.setup.eazmsn);
> +			snprintf(cbuf, sizeof(cbuf),
> +				 "%02d;D%s_R%s,%02d,%02d,%s\n", (int) (a + 1),
> +				 dcode, p, c->parm.setup.si1,
> +				 c->parm.setup.si2, c->parm.setup.eazmsn);
>  			i = icn_writecmd(cbuf, strlen(cbuf), 0, card);
>  		}
>  		break;
> 

if someone is still working on this ...
maybe a vararg version of icn_writecmd() would be a nice helper.

re,
 wh
