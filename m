From: James Bottomley <James.Bottomley@suse.de>
Subject: Re: [PATCH net-next] drivers/scsi: Remove warnings after vsprintf
 %pV introduction
Date: Tue, 27 Jul 2010 08:12:23 -0500
Message-ID: <1280236343.2833.7.camel@mulgrave.site>
References: <20100707.174522.148565561.davem@davemloft.net>
	 <20100707.181847.62350965.davem@davemloft.net>
	 <1278562423.1712.43.camel@Joe-Laptop>
	 <20100710.195210.200371025.davem@davemloft.net>
	 <1278824921.1501.37.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, gregkh@suse.de,
	Matthew Wilcox <matthew@wil.cx>,
	linux-scsi <linux-scsi@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46871 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751975Ab0G0NMa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 09:12:30 -0400
In-Reply-To: <1278824921.1501.37.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-07-10 at 22:08 -0700, Joe Perches wrote:
> On Sat, 2010-07-10 at 19:52 -0700, David Miller wrote:
> > Could you take a stab at this and the other scsi bits that
> > trigger this warning?
> 
> Remove warnings introduced by conversions of dev_<level>
> macros to functions.
> 
> Compile tested only.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/scsi/constants.c            |   63 ++++++++++++++++++++---------------
>  drivers/scsi/sd.c                   |    6 ++--
>  drivers/scsi/sym53c8xx_2/sym_hipd.c |   10 ++---
>  3 files changed, 43 insertions(+), 36 deletions(-)
> 
> diff --git a/drivers/scsi/constants.c b/drivers/scsi/constants.c
> index cd05e04..f95de51 100644
> --- a/drivers/scsi/constants.c
> +++ b/drivers/scsi/constants.c
> @@ -1226,29 +1226,38 @@ scsi_extd_sense_format(unsigned char asc, unsigned char ascq) {
>  }
>  EXPORT_SYMBOL(scsi_extd_sense_format);
>  
> +static void scsi_show_extd_sense_args(const char *fmt, ...)
> +{
> +	va_list args;
> +	struct va_format vaf;
> +
> +	va_start(args, fmt);
> +
> +	vaf.fmt = fmt;
> +	vaf.va = &args;
> +
> +	printk(KERN_CONT "Add. Sense: %pV\n", &vaf);
> +
> +	va_end(args);
> +}
> +

This doesn't have a place in the patch, it's an unnecessary conversion

>  void
>  scsi_show_extd_sense(unsigned char asc, unsigned char ascq)
>  {
>          const char *extd_sense_fmt = scsi_extd_sense_format(asc, ascq);
>  
>  	if (extd_sense_fmt) {
> -		if (strstr(extd_sense_fmt, "%x")) {
> -			printk("Add. Sense: ");
> -			printk(extd_sense_fmt, ascq);
> -		} else
> -			printk("Add. Sense: %s", extd_sense_fmt);
> +		scsi_show_extd_sense_args(extd_sense_fmt, ascq);
>  	} else {
>  		if (asc >= 0x80)
> -			printk("<<vendor>> ASC=0x%x ASCQ=0x%x", asc,
> -			       ascq);
> +			printk(KERN_CONT "<<vendor>> ASC=0x%x ASCQ=0x%x",
> +			       asc, ascq);
>  		if (ascq >= 0x80)
> -			printk("ASC=0x%x <<vendor>> ASCQ=0x%x", asc,
> -			       ascq);
> +			printk(KERN_CONT "ASC=0x%x <<vendor>> ASCQ=0x%x\n",
> +			       asc, ascq);
>  		else
> -			printk("ASC=0x%x ASCQ=0x%x", asc, ascq);
> +			printk(KERN_CONT "ASC=0x%x ASCQ=0x%x\n", asc, ascq);

And half these KERN_CONT additions are spurious since you'd not
otherwise touch the line

>  	}
> -
> -	printk("\n");
>  }
>  EXPORT_SYMBOL(scsi_show_extd_sense);
>  
> @@ -1310,15 +1319,15 @@ scsi_decode_sense_buffer(const unsigned char *sense_buffer, int sense_len,
>  	if (0 == res) {
>  		/* this may be SCSI-1 sense data */
>  		num = (sense_len < 32) ? sense_len : 32;
> -		printk("Unrecognized sense data (in hex):");
> +		printk(KERN_CONT "Unrecognized sense data (in hex):");
>  		for (k = 0; k < num; ++k) {
>  			if (0 == (k % 16)) {
> -				printk("\n");
> -				printk(KERN_INFO "        ");
> +				printk(KERN_CONT "\n");
> +				printk(KERN_INFO "       ");
>  			}
> -			printk("%02x ", sense_buffer[k]);
> +			printk(KERN_CONT " %02x", sense_buffer[k]);
>  		}
> -		printk("\n");
> +		printk(KERN_CONT "\n");
>  		return;
>  	}
>  }
> @@ -1364,22 +1373,22 @@ scsi_decode_sense_extras(const unsigned char *sense_buffer, int sense_len,
>  			res += snprintf(buff + res, blen - res, "ILI");
>  		}
>  		if (res > 0)
> -			printk("%s\n", buff);
> +			printk(KERN_CONT "%s\n", buff);
>  	} else if (sshdr->additional_length > 0) {
>  		/* descriptor format with sense descriptors */
>  		num = 8 + sshdr->additional_length;
>  		num = (sense_len < num) ? sense_len : num;
> -		printk("Descriptor sense data with sense descriptors "
> +		printk(KERN_CONT "Descriptor sense data with sense descriptors "
>  		       "(in hex):");
>  		for (k = 0; k < num; ++k) {
>  			if (0 == (k % 16)) {
> -				printk("\n");
> -				printk(KERN_INFO "        ");
> +				printk(KERN_CONT "\n");
> +				printk(KERN_INFO "       ");
>  			}
> -			printk("%02x ", sense_buffer[k]);
> +			printk(KERN_CONT " %02x", sense_buffer[k]);
>  		}
>  
> -		printk("\n");
> +		printk(KERN_CONT "\n");
>  	}
>  
>  }
> @@ -1404,13 +1413,13 @@ void scsi_print_sense(char *name, struct scsi_cmnd *cmd)
>  {
>  	struct scsi_sense_hdr sshdr;
>  
> -	scmd_printk(KERN_INFO, cmd, "");
> +	scmd_printk(KERN_INFO, cmd, " ");
>  	scsi_decode_sense_buffer(cmd->sense_buffer, SCSI_SENSE_BUFFERSIZE,
>  				 &sshdr);
>  	scsi_show_sense_hdr(&sshdr);
>  	scsi_decode_sense_extras(cmd->sense_buffer, SCSI_SENSE_BUFFERSIZE,
>  				 &sshdr);
> -	scmd_printk(KERN_INFO, cmd, "");
> +	scmd_printk(KERN_INFO, cmd, " ");
>  	scsi_show_extd_sense(sshdr.asc, sshdr.ascq);
>  }
>  EXPORT_SYMBOL(scsi_print_sense);
> @@ -1443,7 +1452,7 @@ void scsi_show_result(int result)
>  
>  void scsi_show_result(int result)
>  {
> -	printk("Result: hostbyte=0x%02x driverbyte=0x%02x\n",
> +	printk(KERN_CONT "Result: hostbyte=0x%02x driverbyte=0x%02x\n",
>  	       host_byte(result), driver_byte(result));
>  }
>  
> @@ -1453,7 +1462,7 @@ EXPORT_SYMBOL(scsi_show_result);
>  
>  void scsi_print_result(struct scsi_cmnd *cmd)
>  {
> -	scmd_printk(KERN_INFO, cmd, "");
> +	scmd_printk(KERN_INFO, cmd, " ");
>  	scsi_show_result(cmd->result);
>  }
>  EXPORT_SYMBOL(scsi_print_result);
> diff --git a/drivers/scsi/sd.c b/drivers/scsi/sd.c
> index 829cc37..2fddadd 100644
> --- a/drivers/scsi/sd.c
> +++ b/drivers/scsi/sd.c
> @@ -2550,15 +2550,15 @@ module_exit(exit_sd);
>  static void sd_print_sense_hdr(struct scsi_disk *sdkp,
>  			       struct scsi_sense_hdr *sshdr)
>  {
> -	sd_printk(KERN_INFO, sdkp, "");
> +	sd_printk(KERN_INFO, sdkp, " ");
>  	scsi_show_sense_hdr(sshdr);
> -	sd_printk(KERN_INFO, sdkp, "");
> +	sd_printk(KERN_INFO, sdkp, " ");
>  	scsi_show_extd_sense(sshdr->asc, sshdr->ascq);
>  }
>  
>  static void sd_print_result(struct scsi_disk *sdkp, int result)
>  {
> -	sd_printk(KERN_INFO, sdkp, "");
> +	sd_printk(KERN_INFO, sdkp, " ");
>  	scsi_show_result(result);
>  }
>  
> diff --git a/drivers/scsi/sym53c8xx_2/sym_hipd.c b/drivers/scsi/sym53c8xx_2/sym_hipd.c
> index a7bc8b7..d740a5b 100644
> --- a/drivers/scsi/sym53c8xx_2/sym_hipd.c
> +++ b/drivers/scsi/sym53c8xx_2/sym_hipd.c
> @@ -72,10 +72,7 @@ static void sym_printl_hex(u_char *p, int n)
>  
>  static void sym_print_msg(struct sym_ccb *cp, char *label, u_char *msg)
>  {
> -	if (label)
> -		sym_print_addr(cp->cmd, "%s: ", label);
> -	else
> -		sym_print_addr(cp->cmd, "");
> +	sym_print_addr(cp->cmd, "%s: ", label);
>  
>  	spi_print_msg(msg);
>  	printf("\n");
> @@ -4558,7 +4555,8 @@ static void sym_int_sir(struct sym_hcb *np)
>  			switch (np->msgin [2]) {
>  			case M_X_MODIFY_DP:
>  				if (DEBUG_FLAGS & DEBUG_POINTER)
> -					sym_print_msg(cp, NULL, np->msgin);
> +					sym_print_msg(cp, "extended msg ",
> +						      np->msgin);
>  				tmp = (np->msgin[3]<<24) + (np->msgin[4]<<16) + 
>  				      (np->msgin[5]<<8)  + (np->msgin[6]);
>  				sym_modify_dp(np, tp, cp, tmp);
> @@ -4585,7 +4583,7 @@ static void sym_int_sir(struct sym_hcb *np)
>  		 */
>  		case M_IGN_RESIDUE:
>  			if (DEBUG_FLAGS & DEBUG_POINTER)
> -				sym_print_msg(cp, NULL, np->msgin);
> +				sym_print_msg(cp, "half byte ", np->msgin);
>  			if (cp->host_flags & HF_SENSE)
>  				OUTL_DSP(np, SCRIPTA_BA(np, clrack));
>  			else

OK, so please resend on the necessary bits.  That's "" -> " " in the
X_printk() statements.  If you remove the space from a continuation
line, then KERN_CONT is appropriate to keep checkpatch quiet.

James


