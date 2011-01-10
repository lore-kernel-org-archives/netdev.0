From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH] net/r8169: Update the function of parsing firmware
Date: Mon, 10 Jan 2011 10:25:15 +0800
Message-ID: <BB1CAEB2DB6746D39E020502E48AB45F@realtek.com.tw>
References: <1294393509-3492-1-git-send-email-hayeswang@realtek.com> <20110107151755.GN3702@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: 'Ben Hutchings' <benh@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:52989 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752452Ab1AJC0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 21:26:20 -0500
In-Reply-To: <20110107151755.GN3702@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Ben Hutchings [mailto:benh@debian.org] 
> Sent: Friday, January 07, 2011 11:18 PM
> To: Hayeswang
> Cc: romieu@fr.zoreil.com; netdev@vger.kernel.org; 
> linux-kernel@vger.kernel.org
> Subject: Re: [PATCH] net/r8169: Update the function of 
> parsing firmware
> 
> On Fri, 2011-01-07 at 17:45 +0800, Hayes Wang wrote:
> > Update rtl_phy_write_fw function. The new function could parse the 
> > complex firmware which is used by RTL8111E and later.
> > The new firmware may read data and do some operations, not just do 
> > writing only.
> > 
> > Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> > ---
> >  drivers/net/r8169.c |  112 
> > ++++++++++++++++++++++++++++++++++++++++++++-------
> >  1 files changed, 97 insertions(+), 15 deletions(-)
> > 
> > diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c index 
> > 27a7c20..2115424 100644
> > --- a/drivers/net/r8169.c
> > +++ b/drivers/net/r8169.c
> [...] 
> > -	while (i-- != 0) {
> > -		u32 action = le32_to_cpu(*phytable);
> > -		u32 data = action & 0x0000ffff;
> > -		u32 reg = (action & 0x0fff0000) >> 16;
> > +	predata = 0;
> > +	count = 0;
> > +
> > +	for (index = 0; index < fw->size / sizeof(*phytable); ) {
> > +		u32 action = le32_to_cpu(phytable[index]);
> > +		u32 data = action & 0x0000FFFF;
> > +		u32 regno = (action & 0x0FFF0000) >> 16;
> > +
> > +		if (!action)
> > +			break;
> >  
> > -		switch(action & 0xf0000000) {
> > +		switch(action & 0xF0000000) {
> [...]
> > +		case PHY_BJMPN:
> > +			index -= regno;
> > +			break;
> [...]
> 
> I'm concerned that this is being extended from a firmware 
> upload interface to a quite general interpreter for PHY 
> initialisation.  I realise that this will make it easier to 
> fix PHY firmware bugs in future but it also allows you to 
> accidentally introduce infinite loops.
> The initialisation programs will obviously not be subject to 
> the same sort of review on netdev that new C code is.
> 
I know the situation which you worry. However, the real action is depend to the
status of the hardware, and it is hard that I couldn't assume any situation to
check the firmware. Thus, I just check if every commands are valid. I could only
promise that there is no infinite loop if the firmware is correct.

> > +		case PHY_DELAY_MS:
> > +			mdelay(data);
> > +			index++;
> > +			break;
> 
> Why mdelay() and not msleep()?  This is not an atomic context.
> 
Accounding to the document, the msleep have to larger than 10ms. It would run
more than 10ms if you set less than 10 for msleep. I think it takes more delay
than which I need. Beside, I don't sure if it would be run during atomic
context, so I think using mdelay is safer.

> > +		case PHY_READ_MAC_BYTE:
> > +		case PHY_WRITE_MAC_BYTE:
> > +		case PHY_WRITE_ERI_WORD:
> >  		default:
> >  			BUG();
> >  		}
> > +
> > +		if (index < 0)
> > +			BUG();
> [...]
> 
> index is unsigned so it can't be < 0.  It looks like the loop 
> condition should catch an out-of-range index, but really the 
> range-checking should be done in the first loop.
> 
I would try to fix this.

> Ben.
> 
> --
> Ben Hutchings
> We get into the habit of living before acquiring the habit of 
> thinking.
>                                                               
> - Albert Camus
> 
> 
> ------Please consider the environment before printing this e-mail. 
> 
> 

