From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: Add "-f" option to flash a firmware image
	from the specified file to a device.
Date: Wed, 19 Aug 2009 18:23:58 +0100
Message-ID: <1250702638.2874.30.camel@achroite>
References: <20090818112522.GA22134@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jgarzik@pobox.com, netdev@vger.kernel.org
To: Ajit Khaparde <ajitk@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:42774 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751952AbZHSRYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 13:24:04 -0400
In-Reply-To: <20090818112522.GA22134@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-08-18 at 16:55 +0530, Ajit Khaparde wrote:
> This patch adds a new "-f" option to the ethtool utility
> to flash a firmware image specified by a file, to a network device.
> The filename is passed to the network driver which will flash the image
> on the chip using the request_firmware path.
> The region to be flashed - like redboot, phy can be specified as an argument,
> which will be passed to the driver.
> More options for other flash regions can be added in future.
> The default behavior is to flash all the regions on the chip.
> 
> Usage:
> ethtool -f <interface name> <filename of firmware image>
> 
> ethtool -f <interface name> <filename of firmware image> [ all|redboot|phy ]
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
> ---
>  ethtool-copy.h |   16 ++++++++++++
>  ethtool.c      |   71 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 86 insertions(+), 1 deletions(-)
> 
> diff --git a/ethtool-copy.h b/ethtool-copy.h
> index 3ca4e2c..a7d11fb 100644
> --- a/ethtool-copy.h
> +++ b/ethtool-copy.h
> @@ -272,6 +272,21 @@ struct ethtool_perm_addr {
>  	__u8	data[0];
>  };
>  
> +#define ETHTOOL_FLASH_MAX_FILENAME	128
> +#define ETHTOOL_FLASH_OP_TYPE_SIZE	32

These are missing from your patch to the in-kernel ethtool.h.  What do
they mean?   They are inconsistent with the ethtool_flash::data field.

[...]
> @@ -516,6 +525,10 @@ static void parse_cmdline(int argc, char **argp)
>  				if (phys_id_time < 0)
>  					show_usage(1);
>  				break;
> +			} else if (mode == MODE_FLASHDEV) {
> +				sprintf(flash_file, "%s", argp[i]);

This is missing a length check.

[...]
> @@ -2398,6 +2424,49 @@ static int do_grxclass(int fd, struct ifreq
> *ifr)
>  	return 0;
>  }
>  
> +static int do_flash(int fd, struct ifreq *ifr)
> +{
> +	struct ethtool_flash efl;
> +	int err;
> +	char path[ETHTOOL_FLASH_MAX_FILENAME * 2] = "/lib/firmware/";
> +	FILE *f;
> +
> +	if (flash < 0) {
> +		fprintf(stdout, "Missing filename argument\n");
> +		show_usage(1);
> +		return -EPERM;

This doesn't follow the ethtool convention for error codes, which is to
use unique positive numbers.

> +	}
> +
> +	strcat(path, flash_file);
> +
> +	if (strlen(flash_file) > ETHTOOL_FLASH_MAX_FILENAME) {
> +		fprintf(stdout, "Filename too long\n");
> +		return -EINVAL;
> +	}
> +
> +	f = fopen(path, "r");
> +	if (!f) {
> +		perror(path);
> +		return -ENOENT;
> +	}
> +	fclose(f);

request_firmware() relies on a user-space agent to load firmware;
normally this is udev's firmware_agent which can be configured to look
in directories other than /lib/firmware/.  So this check is too strict.
The driver should report back any error from request_firmware(), so it
should not be necessary to check here at all.

> +	efl.cmd = ETHTOOL_FLASHDEV;
> +	sprintf(efl.data, "%s", flash_file);
[...]

What's wrong with strcpy() anyway?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

