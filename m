From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] isdn: avm: potential signedness issue in loading firmware
Date: Fri, 9 May 2014 20:52:44 +0300
Message-ID: <20140509175244.GL4963@mwanda>
References: <20140509102724.GF4963@mwanda>
 <20140509115437.GA31764@mwanda>
 <20140509.132403.531379541580867189.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org, security@kernel.org,
	henry@henryhoggard.co.uk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:36163 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756360AbaEIRw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 13:52:57 -0400
Content-Disposition: inline
In-Reply-To: <20140509.132403.531379541580867189.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 09, 2014 at 01:24:03PM -0400, David Miller wrote:
> From: Dan Carpenter <dan.carpenter@oracle.com>
> Date: Fri, 9 May 2014 14:54:37 +0300
> 
> > The concern here is that a negative value for "len" could lead underflow
> > the "while (left > FWBUF_SIZE) {" test and lead to memory corruption.
> > I do not believe this is possible because we test for negatives in
> > old_capi_manufacturer(), "if (ldef.t4file.len <= 0) {".
> > 
> > But it sort of makes the code nicer to only deal with positive lengths
> > so I have made it unsigned.  The length is still not capped and so if we
> > get a too large value, we keep on writing it out to the firmware byte by
> > byte until the writes start failing.
> > 
> > Loading the firmware requires CAP_SYS_ADMIN.
> > 
> > Reported-by: Henry Hoggard <henry@henryhoggard.co.uk>
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > 
> > diff --git a/drivers/isdn/hardware/avm/b1.c b/drivers/isdn/hardware/avm/b1.c
> > index 4d9b195..7f2ed49 100644
> > --- a/drivers/isdn/hardware/avm/b1.c
> > +++ b/drivers/isdn/hardware/avm/b1.c
> > @@ -153,7 +153,8 @@ int b1_load_t4file(avmcard *card, capiloaddatapart *t4file)
> >  {
> >  	unsigned char buf[FWBUF_SIZE];
> >  	unsigned char *dp;
> > -	int i, left;
> > +	unsigned int left;
> > +	int i;
> >  	unsigned int base = card->port;
> 
> Are you sure this is an improvement?
> 
> As you say, if we get a negative length, we'll run that "while (left >
> FWBUF_SIZE)" loop a LOT.
> 
> Whereas if you keep the signedness, it won't run even one time if we somehow
> were given a negative t4file->len.
> 
> To me, the only real option is to make this function itself guard against
> negative lengths, and return -EINVAL if it sees one.
> 
> Then you can perhaps also kill such checks from the callers.

I would be fine if we did nothing here and left the code as is.

If we're going to kill duplicative checks then we should keep the
current code.  The check is in the one central place directly after we
get the length from the user.

Adding a check for negative would make the code scanner happy but it's
a bit meaningless because we don't have a way to know what the upper
limit should be.  We just keep writing the firmware until we're done or
b1_save_put_byte() returns an error code.

Let's just leave this as is.

regards,
dan carpenter
