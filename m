From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: [patch] isdn: fix a wrapping bug in isdn_ppp_ioctl()
Date: Wed, 10 Oct 2012 14:05:01 +0200
Message-ID: <m21uh67csy.fsf@igel.home>
References: <20121010093816.GA3669@elgon.mountain>
	<1349864358.2386.27.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	Masanari Iida <standby24x7@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:47082 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144Ab2JJMFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 08:05:06 -0400
In-Reply-To: <1349864358.2386.27.camel@joe-AO722> (Joe Perches's message of
	"Wed, 10 Oct 2012 03:19:18 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches <joe@perches.com> writes:

> @@ -589,16 +589,15 @@ isdn_ppp_ioctl(int min, struct file *file, unsigned int cmd, unsigned long arg)
>  		break;
>  	case PPPIOCGCOMPRESSORS:
>  	{
> -		unsigned long protos[8] = {0,};
> +		DECLARE_BITMAP(protos, BITS_PER_LONG * 8) = { 0, };
>  		struct isdn_ppp_compressor *ipc = ipc_head;
> +
>  		while (ipc) {
> -			j = ipc->num / (sizeof(long) * 8);
> -			i = ipc->num % (sizeof(long) * 8);
> -			if (j < 8)
> -				protos[j] |= (0x1 << i);
> +			if (ipc->num < BITS_PER_LONG * 8)
> +				set_bit(ipc->num, protos);
>  			ipc = ipc->next;
>  		}
> -		if ((r = set_arg(argp, protos, 8 * sizeof(long))))
> +		if ((r = set_arg(argp, protos, sizeof(protos))))

This changes the bit endianess.  Since protos is exported to user space
it is an ABI change.

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
