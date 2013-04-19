From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH v2 net-next 1/4] bnx2x: refactor nvram read
 procedure
Date: Fri, 19 Apr 2013 21:18:32 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F20C0A541@SJEXCHMB06.corp.ad.broadcom.com>
References: <1366280830-26034-1-git-send-email-dmitry@broadcom.com>
 <1366280830-26034-2-git-send-email-dmitry@broadcom.com>
 <20130418231438.GA10380@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1338 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753540Ab3DSVSu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 17:18:50 -0400
In-Reply-To: <20130418231438.GA10380@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Francois Romieu [mailto:romieu@fr.zoreil.com]
> Sent: Friday, April 19, 2013 2:15 AM
> To: Dmitry Kravkov
> Cc: davem@davemloft.net; netdev@vger.kernel.org; Eilon Greenstein
> Subject: Re: [PATCH v2 net-next 1/4] bnx2x: refactor nvram read procedure
> 
> Dmitry Kravkov <dmitry@broadcom.com> :
> > introduce a procedure to read in u32 granularity.
> >
> > CC: Francois Romieu <romieu@fr.zoreil.com>
> > Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> > ---
> >  .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    | 54 +++++++++++++---------
> >  1 file changed, 31 insertions(+), 23 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
> > index 129d6b2..e7e0ac1 100644
> > --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
> > +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
> > @@ -1364,11 +1364,25 @@ static int bnx2x_nvram_read(struct bnx2x *bp, u32 offset, u8 *ret_buf,
> >  	return rc;
> >  }
> >
> > +static int bnx2x_nvram_read32(struct bnx2x *bp, u32 offset, u32 *buf,
> > +			      int buf_size)
> > +{
> > +	int i, rc = bnx2x_nvram_read(bp, offset, (u8 *)buf, buf_size);
> > +	__be32 *be = (__be32 *)buf;
> > +
> > +	if (rc)
> > +		return rc;
> 
> Nit: one of those may be a tad more idiomatic. Not sure.
> 
> 	__be32 *be = (__be32 *)buf;
> 	int i, rc;
> 
> 	rc = bnx2x_nvram_read(bp, offset, (u8 *)buf, buf_size);
> 	if (rc)
> 		...
> or:
> 	int rc;
> 
> 	rc = bnx2x_nvram_read(bp, offset, (u8 *)buf, buf_size);
> 	if (!rc) {
> 		__be32 *be = (__be32 *)buf;
> 
> 		while ((buf_size -= 4) >= 0)
> 			*buf++ = be32_to_cpu(*be++);
> 	}
I will adopt this one :)

> [...]
> > @@ -1383,9 +1397,7 @@ static int bnx2x_get_eeprom(struct net_device *dev,
> >
> >  	/* parameters already validated in ethtool_get_eeprom */
> >
> > -	rc = bnx2x_nvram_read(bp, eeprom->offset, eebuf, eeprom->len);
> > -
> > -	return rc;
> > +	return bnx2x_nvram_read(bp, eeprom->offset, eebuf, eeprom->len);
> >  }
> 
> Nit--: it's a bit off-topic.
Will separate it
 
> [...]
> > @@ -1573,16 +1584,16 @@ static int bnx2x_nvram_write1(struct bnx2x *bp, u32 offset, u8 *data_buf,
> >
> >  	cmd_flags = (MCPR_NVM_COMMAND_FIRST | MCPR_NVM_COMMAND_LAST);
> >  	align_offset = (offset & ~0x03);
> > -	rc = bnx2x_nvram_read_dword(bp, align_offset, &val, cmd_flags);
> > +	rc = bnx2x_nvram_read_dword(bp, align_offset, &val_be, cmd_flags);
> >
> > -	if (rc == 0) {
> > -		val &= ~(0xff << BYTE_OFFSET(offset));
> > -		val |= (*data_buf << BYTE_OFFSET(offset));
> > +	/* nvram data is returned as an array of bytes
> > +	 * convert it back to cpu order
> > +	 */
> > +	val = be32_to_cpu(val_be);
> 
> (1)
> 
> >
> > -		/* nvram data is returned as an array of bytes
> > -		 * convert it back to cpu order
> > -		 */
> > -		val = be32_to_cpu(val);
> > +	if (rc == 0) {
> > +		val &= ~le32_to_cpu(0xff << BYTE_OFFSET(offset));
> > +		val |= le32_to_cpu(*data_buf << BYTE_OFFSET(offset));
> 
> (2)
> 
> Either be32_to_cpu or le32_to_cpu above isn't a nop but the commit
> message only talks of refactoring. It imho lacks a statement about
> a fix.

Good catch  - this one should go to -net,
I will leave it in net-next series as separate patch with proper message to avoid painful merging, if Dave does not objection for this.  
 
> --
> Ueimor
