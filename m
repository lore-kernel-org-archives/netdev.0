From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next] ieee802154: use helper function to get rid of
 redundancy
Date: Sun, 1 Jun 2014 18:39:28 +0200
Message-ID: <20140601163926.GA1527@omega>
References: <1401579542-17108-1-git-send-email-sakiwit@gmail.com>
 <20140601072655.GA12277@omega>
 <20140601142317.GA19754@mail.gmail.com>
 <20140601143550.GA13168@omega>
 <20140601153546.GA20143@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jean Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:56427 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540AbaFAQjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 12:39:37 -0400
Received: by mail-wg0-f47.google.com with SMTP id x12so4095668wgg.30
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2014 09:39:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140601153546.GA20143@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 01, 2014 at 09:35:47AM -0600, Jean Sacren wrote:
> From: Alexander Aring <alex.aring@gmail.com>
> Date: Sun, 01 Jun 2014 16:35:53 +0200
> >
> > Hi,
> > 
> > On Sun, Jun 01, 2014 at 08:23:17AM -0600, Jean Sacren wrote:
> > > From: Alexander Aring <alex.aring@gmail.com>
> > > Date: Sun, 01 Jun 2014 09:26:57 +0200
> > > 
> > > Hi Alex,
> > > 
> > > Thank you very much for the feedback.
> > > 
> > > > the at86rf230 driver supports several at86rf2xx chips. You split the
> > > > at86rf212_set_channel which is at86rf212 specific in two function which
> > > > are named at86rf230_foo.
> > > 
> > > I didn't "split" at86rf212_set_channel() in two functions. I spliced
> > > those two sections of code and made at86rf212_set_channel() far
> > > succinct and easy to read.
> > > 
> > 
> > yes, but this driver supports more than one chip and it's easier to read
> > if we have one channel_set function for each chip type. Note you also
> > named the specific channel_set function to a another at86rf230_foo
> > function which is at86rf212 specific only. Sorry that will confuse
> > all the people who will ever read this code.
> > 
> > There is a at86rf230_ops and at86rf212_ops struct. The channel_set
> > function it's much easier to have only one callback for each struct,
> > otherwise you have 4 different channel_set functions and nobody knows
> > for which at86rf2xx type that function is for.
> 
> You mean something like the following will be less confusing?

Yes that's less but there are issues and I don't see any reason why we
should do that.

> 
> diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
> index 4517b149ed07..06b494bacc44 100644
> --- a/drivers/net/ieee802154/at86rf230.c
> +++ b/drivers/net/ieee802154/at86rf230.c
> @@ -602,20 +602,21 @@ at86rf212_set_channel(struct at86rf230_local *lp, int page, int channel)
>  {
>  	int rc;
>  
> -	if (channel == 0)
> -		rc = at86rf230_write_subreg(lp, SR_SUB_MODE, 0);
> -	else
> -		rc = at86rf230_write_subreg(lp, SR_SUB_MODE, 1);
> +	if (channel)
> +		channel = 1;
> +
> +	rc = at86rf230_write_subreg(lp, SR_SUB_MODE, channel);
>  	if (rc < 0)
>  		return rc;
>  

First:

This will break the at86rf212_set_channel function. At the end of this
function we need the channel parameter and you overwrite it here.
At the end of this function stands:

"return at86rf230_write_subreg(lp, SR_CHANNEL, channel);"

Second:

The variable channel should be a new variable named sub_mode and initialized
to 0, this fixes the first issue.

But again, I don't see any reasons why we should change that. It's the
same thing like before.

- Alex
