From: Dongli Zhang <dongli.zhang@oracle.com>
Subject: Re: [Xen-devel] [PATCH 1/1] xen-netfront: do not cast grant table
 reference to signed short
Date: Mon, 31 Oct 2016 01:28:48 -0700 (PDT)
Message-ID: <21bd3cd7-68ed-45cd-9728-73c88c79fe65@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: <boris.ostrovsky@oracle.com>, <netdev@vger.kernel.org>,
        <JGross@suse.com>, <xen-devel@lists.xenproject.org>,
        <david.vrabel@citrix.com>, <linux-kernel@vger.kernel.org>
To: <JBeulich@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >                  ref = gnttab_claim_grant_reference(&queue->gref_rx_head);
> > -                BUG_ON((signed short)ref < 0);
> > +                WARN_ON_ONCE(IS_ERR_VALUE((unsigned long)ref));

> You really need to cast to plain (or signed) long here - casting to
> unsigned long will work only in 32-bit configurations, as otherwise
> you lose the sign of the value.

Seems the sign of value would not be lost since casting to unsigned long will
use signed extension. Is my understanding wrong or did I miss anything? I have
verified this with both sample userspace helloworld program and a kernel
module.

> And then just issuing a warning here is insufficient, I think: Either
> you follow David's line of thought assuming that no failure here is

Keeping this can help debug xen-netfront.

> possible at all (in which case the BUG_ON() can be ditched without
> replacement), or you follow your original one (which matches mine)
> that we can't exclude an error here because of a bug elsewhere,
> in which case this either needs to stay BUG_ON() or should be
> followed by some form of bailing out (so that the bad ref won't get
> stored, preventing its later use from causing further damage).

The reason I use warning instead BUG_ON is that Linus suggested use
WARN_ON_ONCE() in a previous email:
http://lkml.iu.edu/hypermail/linux/kernel/1610.0/00878.html

I would change to BUG_ON() if it is OK to you.

Thank you very much!

Dongli Zhang 


----- Original Message -----
From: JBeulich@suse.com
To: dongli.zhang@oracle.com
Cc: david.vrabel@citrix.com, xen-devel@lists.xenproject.org, boris.ostrovsky@oracle.com, JGross@suse.com, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Sent: Monday, October 31, 2016 3:48:03 PM GMT +08:00 Beijing / Chongqing / Hong Kong / Urumqi
Subject: Re: [Xen-devel] [PATCH 1/1] xen-netfront: do not cast grant table reference to signed short

>>> On 31.10.16 at 06:38, <dongli.zhang@oracle.com> wrote:
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -304,7 +304,7 @@ static void xennet_alloc_rx_buffers(struct netfront_queue *queue)
>  		queue->rx_skbs[id] = skb;
>  
>  		ref = gnttab_claim_grant_reference(&queue->gref_rx_head);
> -		BUG_ON((signed short)ref < 0);
> +		WARN_ON_ONCE(IS_ERR_VALUE((unsigned long)ref));

You really need to cast to plain (or signed) long here - casting to
unsigned long will work only in 32-bit configurations, as otherwise
you lose the sign of the value.

And then just issuing a warning here is insufficient, I think: Either
you follow David's line of thought assuming that no failure here is
possible at all (in which case the BUG_ON() can be ditched without
replacement), or you follow your original one (which matches mine)
that we can't exclude an error here because of a bug elsewhere,
in which case this either needs to stay BUG_ON() or should be
followed by some form of bailing out (so that the bad ref won't get
stored, preventing its later use from causing further damage).

Jan
