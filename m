From: "Charles (Chas) Williams" <3chas3@gmail.com>
Subject: Re: [PATCH 1/4] ozwpan: Use proper check to prevent heap overflow
Date: Sat, 16 May 2015 06:20:15 -0400
Message-ID: <1431771615.1844.4.camel@gmail.com>
References: <1431542014-3239-1-git-send-email-Jason@zx2c4.com>
	 <1431542014-3239-2-git-send-email-Jason@zx2c4.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB36893@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "'Jason A. Donenfeld'" <Jason@zx2c4.com>,
	"shigekatsu.tateno@atmel.com" <shigekatsu.tateno@atmel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"oss-security@lists.openwall.com" <oss-security@lists.openwall.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB36893@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-05-15 at 15:02 +0000, David Laight wrote:
> From: Jason A. Donenfeld
> > Sent: 13 May 2015 19:34
> > Since elt->length is a u8, we can make this variable a u8. Then we can
> > do proper bounds checking more easily. Without this, a potentially
> > negative value is passed to the memcpy inside oz_hcd_get_desc_cnf,
> > resulting in a remotely exploitable heap overflow with network
> > supplied data.
> ...
> > diff --git a/drivers/staging/ozwpan/ozusbsvc1.c b/drivers/staging/ozwpan/ozusbsvc1.c
> > index d434d8c..cd6c63e 100644
> > --- a/drivers/staging/ozwpan/ozusbsvc1.c
> > +++ b/drivers/staging/ozwpan/ozusbsvc1.c
> > @@ -390,8 +390,10 @@ void oz_usb_rx(struct oz_pd *pd, struct oz_elt *elt)
> >  	case OZ_GET_DESC_RSP: {
> >  			struct oz_get_desc_rsp *body =
> >  				(struct oz_get_desc_rsp *)usb_hdr;
> > -			int data_len = elt->length -
> > +			u8 data_len = elt->length -
> >  					sizeof(struct oz_get_desc_rsp) + 1;
> > +			if (data_len > elt->length)
> > +				break;

This check already seems bogus?  It's really:

	if (sizeof(struct oz_get_desc_rsp) - 1 < 0)
