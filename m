From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdn: avm: potential signedness issue in loading
 firmware
Date: Fri, 09 May 2014 13:24:03 -0400 (EDT)
Message-ID: <20140509.132403.531379541580867189.davem@davemloft.net>
References: <20140509102724.GF4963@mwanda>
	<20140509115437.GA31764@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org, security@kernel.org,
	henry@henryhoggard.co.uk
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38351 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756779AbaEIRYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 13:24:05 -0400
In-Reply-To: <20140509115437.GA31764@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 9 May 2014 14:54:37 +0300

> The concern here is that a negative value for "len" could lead underflow
> the "while (left > FWBUF_SIZE) {" test and lead to memory corruption.
> I do not believe this is possible because we test for negatives in
> old_capi_manufacturer(), "if (ldef.t4file.len <= 0) {".
> 
> But it sort of makes the code nicer to only deal with positive lengths
> so I have made it unsigned.  The length is still not capped and so if we
> get a too large value, we keep on writing it out to the firmware byte by
> byte until the writes start failing.
> 
> Loading the firmware requires CAP_SYS_ADMIN.
> 
> Reported-by: Henry Hoggard <henry@henryhoggard.co.uk>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/isdn/hardware/avm/b1.c b/drivers/isdn/hardware/avm/b1.c
> index 4d9b195..7f2ed49 100644
> --- a/drivers/isdn/hardware/avm/b1.c
> +++ b/drivers/isdn/hardware/avm/b1.c
> @@ -153,7 +153,8 @@ int b1_load_t4file(avmcard *card, capiloaddatapart *t4file)
>  {
>  	unsigned char buf[FWBUF_SIZE];
>  	unsigned char *dp;
> -	int i, left;
> +	unsigned int left;
> +	int i;
>  	unsigned int base = card->port;

Are you sure this is an improvement?

As you say, if we get a negative length, we'll run that "while (left >
FWBUF_SIZE)" loop a LOT.

Whereas if you keep the signedness, it won't run even one time if we somehow
were given a negative t4file->len.

To me, the only real option is to make this function itself guard against
negative lengths, and return -EINVAL if it sees one.

Then you can perhaps also kill such checks from the callers.
