From: Ben McKeegan <ben@netservers.co.uk>
Subject: Re: [PATCH] ppp_generic: fix multilink fragment sizes
Date: Wed, 02 Jun 2010 16:55:35 +0100
Message-ID: <4C067EF7.9040609@netservers.co.uk>
References: <4C0670E2.1090708@netservers.co.uk> <1275491094-9526-1-git-send-email-ben@netservers.co.uk> <DF7BB929B28FCF479E888E3D9F8D9E88D3E16B5A@irsmsx502.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"alan@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>,
	"linux-ppp@vger.kernel.org" <linux-ppp@vger.kernel.org>,
	"paulus@samba.org" <paulus@samba.org>
To: "Paoloni, Gabriele" <gabriele.paoloni@intel.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <DF7BB929B28FCF479E888E3D9F8D9E88D3E16B5A@irsmsx502.ger.corp.intel.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paoloni, Gabriele wrote:
> The proposed patch looks wrong to me.
> 
> nbigger is already doing the job; I didn't use DIV_ROUND_UP because in general we don't have always to roundup, otherwise we would exceed the total bandwidth.

I was basing this on the original code prior to your patch, which used 
DIV_ROUND_UP to get the fragment size.  Looking more closely I see your 
point, the original code was starting with the larger fragment size and 
decrementing rather than starting with the smaller size and incrementing 
as your code does, so that makes sense.


> 
>  		flen = len;
>  		if (nfree > 0) {
>  			if (pch->speed == 0) {
> -				flen = totlen/nfree;
> +				if (nfree > 1)
> +					flen = DIV_ROUND_UP(len, nfree);
>  				if (nbigger > 0) {
>  					flen++;
>  					nbigger--;

The important change here is the use of 'len' instead of 'totlen'. 
'nfree' and 'len' should decrease roughly proportionally with each 
iteration of the loop whereas 'totlen' remains unchanged.  Thus 
(totlen/nfree) gets bigger on each iteration whereas len/nfree should 
give roughly the same.  However, without rounding up here I'm not sure 
the logic is right either, since the side effect of nbigger is to make 
len decrease faster so it is not quite proportional to the decrease in 
nfree.  Is there a risk of ending up on the nfree == 1 iteration with 
flen == len - 1 and thus generating a superfluous extra 1 byte long 
fragment?  This would be a far worse situation than a slight imbalance 
in the size of the fragments.

Perhaps the solution is to go back to a precalculated fragment size for 
the pch->speed == 0 case as per original code?

Regards,
Ben.
