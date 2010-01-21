From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [net-next-2.6 PATCH 2/3] fs_enet: Add support for MPC512x to
 fs_enet driver
Date: Thu, 21 Jan 2010 16:25:38 +0100
Message-ID: <4B5871F2.9090005@grandegger.com>
References: <1264039999-25731-1-git-send-email-agust@denx.de>	<1264039999-25731-3-git-send-email-agust@denx.de> <20100121.012235.161201297.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: agust@denx.de, netdev@vger.kernel.org, dzu@denx.de, wd@denx.de,
	jcrigby@gmail.com, kosmo@semihalf.com, linuxppc-dev@ozlabs.org,
	grant.likely@secretlab.ca
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:37939 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752984Ab0AUP0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 10:26:43 -0500
In-Reply-To: <20100121.012235.161201297.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Anatolij Gustschin <agust@denx.de>
> Date: Thu, 21 Jan 2010 03:13:18 +0100
> 
>>  struct fec_info {
>> -	fec_t __iomem *fecp;
>> +	void __iomem *fecp;

To avoid confusion, the name "base_addr" seems more appropriate as it's
just used to calculate register offsets and for iomap/unmap.

>  ...
>>  /* write */
>> -#define FW(_fecp, _reg, _v) __fs_out32(&(_fecp)->fec_ ## _reg, (_v))
>> +#define FW(_regp, _reg, _v) __fs_out32((_regp)->fec_ ## _reg, (_v))
>  ...
>> +/* register address macros */
>> +#define fec_reg_addr(_type, _reg) \
>> +	(fep->fec.rtbl->fec_##_reg = (u32 __iomem *)((u32)fep->fec.fecp + \
>> +				(u32)&((__typeof__(_type) *)NULL)->fec_##_reg))
>> +
>> +#define fec_reg_mpc8xx(_reg) \
>> +	fec_reg_addr(struct mpc8xx_fec, _reg)
>> +
>> +#define fec_reg_mpc5121(_reg) \
>> +	fec_reg_addr(struct mpc5121_fec, _reg)
> 
> This is a step backwards in my view.
> 
> If you use the "fec_t __iomem *" type for the register
> pointer, you simply use &p->fecp->XXX to get the I/O
> address of register XXX and that's what you pass to
> the appropriate I/O accessor routines.
> 
> Now you've made it typeless, and then you have to walk
> through all of these contortions to get the offset.
> 
> I don't want to apply this, sorry...

The major problem that Anatolij tries to solve are the different
register layouts of the supported SOCs, MPC52xx and MPC8xx. They use the
same registers but at *different* offsets. Therefore we cannot handle
this with a single "fec_t" struct to allow building a single kernel
image. Instead it's handled by filling a table with register addresses:

	if (of_device_is_compatible(ofdev->node, "fsl,mpc5121-fec")) {
		fep->fec.fec_id = FS_ENET_MPC5121_FEC;
		fec_reg_mpc5121(ievent);
		fec_reg_mpc5121(imask);
		...
	} else {
		fec_reg_mpc8xx(ievent);
		fec_reg_mpc8xx(imask);
		...
	}

Do you see a more clever solution to this problem? Nevertheless, the
code could be improved by using "offsetof", I think.

Wolfgang.

