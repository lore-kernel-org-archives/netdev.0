From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2] r8152: Add support for setting MAC to system's
 Auxiliary MAC address
Date: Thu, 2 Jun 2016 10:48:08 -0700
Message-ID: <20160602174808.GA32131@kroah.com>
References: <1464886687-16284-1-git-send-email-mario_limonciello@dell.com>
 <1464886687-16284-2-git-send-email-mario_limonciello@dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang@realtek.com, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Linux USB <linux-usb@vger.kernel.org>, pali.rohar@gmail.com,
	anthony.wong@canonical.com
To: Mario Limonciello <mario_limonciello@dell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1464886687-16284-2-git-send-email-mario_limonciello@dell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 02, 2016 at 11:58:07AM -0500, Mario Limonciello wrote:
> Dell systems with Type-C ports have support for a persistent system
> specific MAC address when used with Dell Type-C docks and dongles.
> This means a dock plugged into two different systems will show different
> (but persistent) MAC addresses.  Dell Type-C docks and dongles use the
> r8152 driver.
> 
> This information for the system's persistent MAC address is burned in when
> the HW is built and available under _SB\AMAC in the DSDT at runtime.
> 
> More information about the technology is available here:
> http://www.dell.com/support/article/us/en/04/SLN301147
> 
> Signed-off-by: Mario Limonciello <mario_limonciello@dell.com>
> ---
>  drivers/net/usb/r8152.c | 53 +++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 53 insertions(+)
> 
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index 3f9f6ed..6dea542 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
> @@ -26,6 +26,8 @@
>  #include <linux/mdio.h>
>  #include <linux/usb/cdc.h>
>  #include <linux/suspend.h>
> +#include <linux/acpi.h>
> +#include <linux/dmi.h>
>  
>  /* Information for net-next */
>  #define NETNEXT_VERSION		"08"
> @@ -500,6 +502,7 @@ enum rtl8152_flags {
>  	SELECTIVE_SUSPEND,
>  	PHY_RESET,
>  	SCHEDULE_NAPI,
> +	MAC_PASSTHRU = 0,

Does setting that to 0 really work?  You just did this for two enum
values, what is the compiler supposed to do?

>  };
>  
>  /* Define these values to match your device */
> @@ -653,6 +656,7 @@ enum tx_csum_stat {
>   */
>  static const int multicast_filter_limit = 32;
>  static unsigned int agg_buf_sz = 16384;
> +static bool mac_passthru_active;

very generic name for a platform-specific feature :(


>  
>  #define RTL_LIMITED_TSO_SIZE	(agg_buf_sz - sizeof(struct tx_desc) - \
>  				 VLAN_ETH_HLEN - VLAN_HLEN)
> @@ -1030,6 +1034,49 @@ out1:
>  	return ret;
>  }
>  
> +static int get_auxiliary_addr(struct r8152 *tp, struct sockaddr *sa)

What about the platform mac address api that was pointed out?

> +{
> +	acpi_status status;
> +	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
> +	union acpi_object *obj;
> +	int ret = -1;
> +	unsigned char buf[6];
> +
> +	if (!dmi_name_in_vendors("Dell Inc.") || mac_passthru_active)
> +		return -1;

Don't make up random error values, please use "real" ones.

And you want to check this for all Dell devices?  Please be model
specific, I doubt a bunch of Dell servers wants to run this code...

> +
> +	/* returns _AUXMAC_#AABBCCDDEEFF# */
> +	status = acpi_evaluate_object(NULL, "\\_SB.AMAC", NULL, &buffer);
> +	obj = (union acpi_object *)buffer.pointer;
> +	if (ACPI_SUCCESS(status)) {
> +		if (obj->type != ACPI_TYPE_BUFFER ||
> +		    obj->string.length != 0x17) {
> +			pr_warn("r8152: get_auxiliary_addr: Invalid buffer");
> +			goto amacout;
> +		}
> +		if (strncmp(obj->string.pointer, "_AUXMAC_#", 9) != 0) {
> +			pr_warn("r8152: get_auxiliary_addr: Invalid header");
> +			goto amacout;
> +		}
> +		ret = hex2bin(buf, obj->string.pointer + 9, 6);
> +		if (ret < 0) {
> +			pr_warn("r8152: get_auxiliary_addr: Invalid MAC");
> +			goto amacout;
> +		}
> +		memcpy(sa->sa_data, buf, 6);
> +		ether_addr_copy(tp->netdev->dev_addr, sa->sa_data);
> +		netdev_info(tp->netdev, "Using system MAC address %pM\n",
> +			    sa->sa_data);
> +		set_bit(MAC_PASSTHRU, &tp->flags);
> +		mac_passthru_active = true;
> +		ret = 1;

1 is not a "all is good" return value.

> +	}
> +
> +amacout:
> +	kfree(obj);
> +	return ret;
> +}
> +
>  static int set_ethernet_addr(struct r8152 *tp)
>  {
>  	struct net_device *dev = tp->netdev;
> @@ -1041,6 +1088,10 @@ static int set_ethernet_addr(struct r8152 *tp)
>  	else
>  		ret = pla_ocp_read(tp, PLA_BACKUP, 8, sa.sa_data);
>  
> +	/* if system provides auxiliary MAC address */
> +	if (get_auxiliary_addr(tp, &sa))
> +		ret = 0;

	ret = my_dell_specific_function();

But again, I don't like this, but I'm not the network subsystem
maintainer, I'll defer to them as to if this is something they want in
individual drivers...

thanks,

greg k-h
