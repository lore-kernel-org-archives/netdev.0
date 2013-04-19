From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH v2 net-next 2/4] bnx2x: add additional regions for
 CRC memory test
Date: Fri, 19 Apr 2013 21:44:46 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F20C0A5E3@SJEXCHMB06.corp.ad.broadcom.com>
References: <1366280830-26034-1-git-send-email-dmitry@broadcom.com>
 <1366280830-26034-3-git-send-email-dmitry@broadcom.com>
 <20130418231515.GB10380@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2533 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933393Ab3DSVpE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 17:45:04 -0400
In-Reply-To: <20130418231515.GB10380@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Francois Romieu [mailto:romieu@fr.zoreil.com]
> Sent: Friday, April 19, 2013 2:15 AM
> To: Dmitry Kravkov
> Cc: davem@davemloft.net; netdev@vger.kernel.org; Eilon Greenstein
> Subject: Re: [PATCH v2 net-next 2/4] bnx2x: add additional regions for CRC memory test
> 
> Dmitry Kravkov <dmitry@broadcom.com> :
> [...]
> > diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
> > index e7e0ac1..65ac870 100644
> > --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
> > +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
> > @@ -2593,14 +2593,138 @@ static int bnx2x_test_ext_loopback(struct bnx2x *bp)
> >  	return rc;
> >  }
> >
> > +struct code_entry {
> > +	u32 sram_start_addr;
> > +	u32 code_attribute;
> > +#define CODE_IMAGE_TYPE_MASK			0xf0800003
> > +#define CODE_IMAGE_VNTAG_PROFILES_DATA		0xd0000003
> > +#define CODE_IMAGE_LENGTH_MASK			0x007ffffc
> > +#define CODE_IMAGE_TYPE_EXTENDED_DIR		0xe0000000
> > +	u32 nvm_start_addr;
> > +};
> > +
> > +#define CODE_ENTRY_MAX			16
> > +#define CODE_ENTRY_EXTENDED_DIR_IDX	15
> > +#define MAX_IMAGES_IN_EXTENDED_DIR	64
> > +
> >  #define CRC32_RESIDUAL			0xdebb20e3
> > +#define CRC_BUFF_SIZE			256
> > +
> > +static int bnx2x_nvram_crc(struct bnx2x *bp,
> > +			   int offset,
> > +			   int size,
> > +			   u8 *buff)
> 
> static int bnx2x_nvram_crc(struct bnx2x *bp, int offset, int size, u8 *buff)
> 
> > +{
> > +	u32 crc = ~0;
> > +	int done = 0;
> > +
> > +	DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
> > +	   "NVRAM CRC from 0x%08x to 0x%08x\n", offset, offset + size);
> > +
> > +	while (done < size) {
> > +		int count = min_t(int, size - done, CRC_BUFF_SIZE);
> > +
> > +		if (bnx2x_nvram_read(bp, offset + done, buff, count))
> > +			return -EIO;
> 
> You may propagate the status code from bnx2x_nvram_read.
> 
> > +		crc = crc32_le(crc, buff, count);
> > +		done += count;
> > +	}
> > +
> > +	if (crc != CRC32_RESIDUAL)
> > +		return -EINVAL;
> > +
> > +	return 0;
> 
> A ternary operator could be used. Your choice of style.
> 
> > +}
> > +
> > +static int bnx2x_test_nvram_dir(struct bnx2x *bp,
> > +				struct code_entry *entry,
> > +				u8 *buff)
> > +{
> > +	size_t size = entry->code_attribute & CODE_IMAGE_LENGTH_MASK;
> > +	u32 type = entry->code_attribute & CODE_IMAGE_TYPE_MASK;
> > +	int rc = 0;
> 
> Useless init.
To be fixed

> > +
> > +	/* Zero-length images and AFEX profiles do not have CRC */
> > +	if (size == 0 || type == CODE_IMAGE_VNTAG_PROFILES_DATA)
> > +		return 0;
> > +
> > +	rc = bnx2x_nvram_crc(bp, entry->nvm_start_addr, size, buff);
> > +	if (rc == -EIO)
> > +		DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
> > +		   "Unable to read image %x\n", type);
> > +	else if (rc)
> > +		DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
> > +		   "image %x has wrong crc value\n", type);
> 
> It's a bit ugly.
> 
> bnx2x_nvram_crc perfectly knowns if a read failure or a crc problem
> happened. It can print messages and you won't need to analyze the
> failure status. You may still print some different message in its
> callers (here and bnx2x_test_nvram_tbl).
I will fix to common mesaage for type only 
> 
> I must stop here, sorry.
Thank you!!

> --
> Ueimor
