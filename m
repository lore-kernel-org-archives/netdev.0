From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Fix skb_set_peeked use-after-free bug
Date: Tue, 4 Aug 2015 09:15:13 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB7275E@AcuExch.aculab.com>
References: <CAMUH3-WyNR+2tsKgZ2qMNR=p+2Q3WDjcPrQcVSZfVSVyPA1qoA@mail.gmail.com>
 <20150804074247.GA29951@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"khlebnikov@yandex-team.ru" <khlebnikov@yandex-team.ru>
To: 'Herbert Xu' <herbert@gondor.apana.org.au>,
	Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.193]:54244 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755832AbbHDJSO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 05:18:14 -0400
In-Reply-To: <20150804074247.GA29951@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu
> Sent: 04 August 2015 08:43
> Brenden Blanco <bblanco@plumgrid.com> wrote:
> >> [  318.244596] BUG: unable to handle kernel NULL pointer dereference
> >> at 000000000000008e
> >> [  318.245182] IP: [<ffffffff81455e7c>] __skb_recv_datagram+0xbc/0x5a0
> >
> > Replying to myself, and adding commit interested parties...
> >
> > I went through the git log for the function in question, and
> > positively identified that the following commit introduces the crash:
> >
> > 738ac1e net: Clone skb before setting peeked flag
> >
> > Null dereference is at line 224 of net/core/datagram.c (according to
> > my objdump dis-assembly):
> 
> Sorry, brain fart on my part.  Please try this patch.

You've introduced a memory leak if skb_clone() fails.

> The commit 738ac1ebb96d02e0d23bc320302a6ea94c612dec ("net: Clone
> skb before setting peeked flag") introduced a use-after-free bug
> in skb_recv_datagram.  This is because skb_set_peeked may create
> a new skb and free the existing one.  As it stands the caller will
> continue to use the old freed skb.
> 
> This patch fixes it by making skb_set_peeked return the new skb
> (or the old one if unchanged).
...
>  	nskb = skb_clone(skb, GFP_ATOMIC);
>  	if (!nskb)
> -		return -ENOMEM;
> +		return ERR_PTR(-ENOMEM);

Here the original skb is still allocated.

> -				error = skb_set_peeked(skb);
> -				if (error)
> +				skb = skb_set_peeked(skb);

You've now lost the address of the original skb.

> +				error = PTR_ERR(skb);
> +				if (IS_ERR(skb))
>  					goto unlock_err;

	David
