From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] eexpress: Read buffer overflow
Date: Sun, 26 Jul 2009 18:45:55 -0700 (PDT)
Message-ID: <20090726.184555.56450167.davem@davemloft.net>
References: <4A6B61FB.4050304@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44003
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754507AbZG0Bps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2009 21:45:48 -0400
In-Reply-To: <4A6B61FB.4050304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sat, 25 Jul 2009 21:50:19 +0200

> -	for (i = 0; i < (sizeof(start_code)); i+=32) {
> -		int j;
> -		outw(i, ioaddr + SM_PTR);
> -		for (j = 0; j < 16; j+=2)
> -			outw(start_code[(i+j)/2],
> -			     ioaddr+0x4000+j);
> -		for (j = 0; j < 16; j+=2)
> -			outw(start_code[(i+j+16)/2],
> -			     ioaddr+0x8000+j);
> +	for (i = 0; i < ARRAY_SIZE(start_code); i += 16) {
> +		int j, jmax;
> +		outw(i * 2, ioaddr + SM_PTR);
> +
> +		jmax = min_t(int, 16, ARRAY_SIZE(start_code) - i);
> +		for (j = 0; j < jmax; j++)
> +			outw(start_code[i + j],
> +			     ioaddr + j * 2 + (j < 8 ? 0x4000 : 0x8000 - 16));

This new IO address expression:

	ioaddr + j * 2 + (j < 8 ? 0x4000 : 0x8000 - 16)

DOES NOT match what the existing code does.  That 0x8000 - 16 seems
incorrect, the existing code always writes starting at 0x8000
in two byte increments, it does not start at 0x8000 - 16....

Oh nevermind, I see what you're doing.  Once j gets to 8, we have
to account for that in the IO address computation.

You've murdered this code, it's even more obfuscated now than it was
previously.  I'm not applying this, no way.  To a fix an out of
bounds array access you're going to change the loop iteration factors
and all of the sub-expressions within' 3 loops too?  Get real.

Just add the necessary limit tests, and nothing more, so it's
possible to actually understand your patch.  If it's more than
a 3 line patch, I'm not even going to review it.
