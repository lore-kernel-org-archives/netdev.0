From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: isdn: pcbit: another off-by-one issue?
Date: Thu, 11 Jun 2015 11:28:03 +0200
Message-ID: <87mw06egrg.fsf@rasmusvillemoes.dk>
References: <87381zqr4y.fsf@rasmusvillemoes.dk>
	<20150611075852.GE11734@mwanda>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>,
	netdev@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:35493 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752762AbbFKJ2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 05:28:06 -0400
Received: by lbbtu8 with SMTP id tu8so970949lbb.2
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 02:28:05 -0700 (PDT)
In-Reply-To: <20150611075852.GE11734@mwanda> (Dan Carpenter's message of "Thu,
	11 Jun 2015 10:58:52 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[adding some emails I should Cc'ed in the first place]

On Thu, Jun 11 2015, Dan Carpenter <dan.carpenter@oracle.com> wrote:

> On Wed, Jun 10, 2015 at 09:50:53PM +0200, Rasmus Villemoes wrote:
>> Hi Dan
>> 
>> You were last to touch drivers/isdn/pcbit/drv.c (7bcc6738eef), but I
>> think there may still be an off-by-one in pcbit_set_msn: At the end of
>> the loop, sp is incremented by len, but if the string contained a comma,
>> sp will now point at that. At that point, we seem to be stuck in an
>> infinite loop where we'll always get cp==sp and len==0, until we run out
>> of memory.
>> 
>> Am I reading this completely wrong?
>
> Nope.  You're right.  That bug has been there since before the start of
> git.  We could fix it by doing:
>
> diff --git a/drivers/isdn/pcbit/drv.c b/drivers/isdn/pcbit/drv.c
> index 4172e22..b156d5b 100644
> --- a/drivers/isdn/pcbit/drv.c
> +++ b/drivers/isdn/pcbit/drv.c
> @@ -1053,7 +1053,7 @@ static void pcbit_set_msn(struct pcbit_dev *dev, char *list)
>  		else
>  			back->next = ptr;
>  		back = ptr;
> -		sp += len;
> +		sp += len + 1;
>  	} while (cp);
>  }

Yep, that's also what I would do. 

Since nobody seems to have been hit by this ever, I wonder whether it's
stable@ material. It probably doesn't make sense to fix this without
also backporting 7bcc6738eef.

Rasmus
