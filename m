From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] liquidio: show NIC's U-Boot version in a
 dev_info() message
Date: Tue, 22 Aug 2017 03:30:11 +0200
Message-ID: <20170822013011.GC24555@lunn.ch>
References: <20170822011944.GA6393@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com, weilin.chang@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38599 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754388AbdHVBaO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 21:30:14 -0400
Content-Disposition: inline
In-Reply-To: <20170822011944.GA6393@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 06:19:44PM -0700, Felix Manlunas wrote:
> From: Weilin Chang <weilin.chang@cavium.com>
> 
> Signed-off-by: Weilin Chang <weilin.chang@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> ---
>  .../net/ethernet/cavium/liquidio/octeon_console.c  | 85 ++++++++++++++++++++++
>  .../net/ethernet/cavium/liquidio/octeon_device.h   |  5 ++
>  2 files changed, 90 insertions(+)
> 
> diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_console.c b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
> index 19e5212..88ef12b 100644
> --- a/drivers/net/ethernet/cavium/liquidio/octeon_console.c
> +++ b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
> @@ -30,6 +30,7 @@
>  #include "liquidio_image.h"
>  #include "octeon_mem_ops.h"
>  
> +static void octeon_get_uboot_version(struct octeon_device *oct);

Hi Felix

Please can we avoid this forward declaration by putting the code in
the correct order.

>  static void octeon_remote_lock(void);
>  static void octeon_remote_unlock(void);
>  static u64 cvmx_bootmem_phy_named_block_find(struct octeon_device *oct,
> @@ -611,6 +612,9 @@ int octeon_add_console(struct octeon_device *oct, u32 console_num,
>  
>  		work = &oct->console_poll_work[console_num].work;
>  
> +		if (oct->uboot_len == 0)
> +			octeon_get_uboot_version(oct);
> +
>  		INIT_DELAYED_WORK(work, check_console);
>  		oct->console_poll_work[console_num].ctxptr = (void *)oct;
>  		oct->console_poll_work[console_num].ctxul = console_num;
> @@ -724,6 +728,87 @@ static int octeon_console_read(struct octeon_device *oct, u32 console_num,
>  	return bytes_to_read;
>  }
>  
> +static void octeon_get_uboot_version(struct octeon_device *oct)
> +{
> +	s32 bytes_read, tries, total_read;
> +	struct octeon_console *console;
> +	u32 console_num = 0;
> +	int i;
> +
> +	if (octeon_console_send_cmd(oct, "setenv stdout pci\n", 50))
> +		return;
> +
> +	console = &oct->console[console_num];
> +	tries = 0;
> +	total_read = 0;
> +
> +	if (octeon_console_send_cmd(oct, "version\n", 1))
> +		return;
> +
> +	do {
> +		/* Take console output regardless of whether it will
> +		 * be logged
> +		 */
> +		bytes_read =
> +			octeon_console_read(oct,
> +					    console_num, oct->uboot_version +
> +					    total_read,
> +					    OCTEON_UBOOT_BUFFER_SIZE - 1 -
> +					    total_read);
> +		if (bytes_read > 0) {
> +			oct->uboot_version[bytes_read] = 0x0;
> +
> +			total_read += bytes_read;
> +			if (console->waiting)
> +				octeon_console_handle_result(oct, console_num);
> +		} else if (bytes_read < 0) {
> +			dev_err(&oct->pci_dev->dev, "Error reading console %u, ret=%d\n",
> +				console_num, bytes_read);
> +		}
> +
> +		tries++;
> +	} while ((bytes_read > 0) && (tries < 16));
> +
> +	/* If nothing is read after polling the console,
> +	 * output any leftovers if any
> +	 */
> +	if ((total_read == 0) && (console->leftover[0])) {
> +		dev_dbg(&oct->pci_dev->dev, "%u: %s\n",
> +			console_num, console->leftover);
> +		console->leftover[0] = '\0';
> +	}
> +
> +	if (octeon_console_send_cmd(oct, "setenv stdout serial\n", 50))
> +		return;
> +
> +	/* U-Boot */
> +	for (i = 0; i < (OCTEON_UBOOT_BUFFER_SIZE - 9); i++) {
> +		if (oct->uboot_version[i] == 'U' &&
> +		    oct->uboot_version[i + 2] == 'B' &&
> +		    oct->uboot_version[i + 3] == 'o' &&
> +		    oct->uboot_version[i + 4] == 'o' &&
> +		    oct->uboot_version[i + 5] == 't') {
> +			oct->uboot_sidx = i;
> +			i++;
> +			for (; oct->uboot_version[i] != 0x0; i++) {

I think you need a test in here to ensure i stays within the buffer.

> +				if (oct->uboot_version[i] == 'm' &&
> +				    oct->uboot_version[i + 1] == 'i' &&
> +				    oct->uboot_version[i + 2] == 'p' &&
> +				    oct->uboot_version[i + 3] == 's') {
> +					oct->uboot_eidx = i - 1;
> +					oct->uboot_version[i - 1] = 0x0;
> +					oct->uboot_len = oct->uboot_eidx -
> +						oct->uboot_sidx + 1;
> +					dev_info(&oct->pci_dev->dev, "%s\n",
> +						 &oct->uboot_version
> +							[oct->uboot_sidx]);
> +					return;
> +				}
> +			}
> +		}
> +	}
> +}
> +

      Andrew
