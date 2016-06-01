From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] r8152: Add support for setting MAC to system's Auxiliary
 MAC address
Date: Wed, 1 Jun 2016 16:05:35 -0700
Message-ID: <20160601230535.GA29279@kroah.com>
References: <1464817844-27206-1-git-send-email-mario_limonciello@dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang@realtek.com, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Linux USB <linux-usb@vger.kernel.org>, pali.rohar@gmail.com,
	anthony.wong@canonical.com
To: Mario Limonciello <mario_limonciello@dell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1464817844-27206-1-git-send-email-mario_limonciello@dell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 01, 2016 at 04:50:44PM -0500, Mario Limonciello wrote:
> Dell systems with Type-C ports have support for a persistent system
> specific MAC address when used with Dell Type-C docks and dongles.
> This means a dock plugged into two different systems will show different
> (but persistent) MAC addresses.  Dell Type-C docks and dongles use the
> r8152 driver.
> 
> This information for the system's persistent MAC address is burned in when
> the HW is built and avilable under _SB\AMAC in the DSDT at runtime.
> 
> More information about the technology is available here:
> http://www.dell.com/support/article/us/en/04/SLN301147
> 
> Signed-off-by: Mario Limonciello <mario_limonciello@dell.com>
> ---
>  drivers/net/usb/Kconfig |  1 +
>  drivers/net/usb/r8152.c | 37 +++++++++++++++++++++++++++++++++++++
>  2 files changed, 38 insertions(+)
> 
> diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
> index cdde590..c320930 100644
> --- a/drivers/net/usb/Kconfig
> +++ b/drivers/net/usb/Kconfig
> @@ -98,6 +98,7 @@ config USB_RTL8150
>  config USB_RTL8152
>  	tristate "Realtek RTL8152/RTL8153 Based USB Ethernet Adapters"
>  	select MII
> +	depends on ACPI
>  	help
>  	  This option adds support for Realtek RTL8152 based USB 2.0
>  	  10/100 Ethernet adapters and RTL8153 based USB 3.0 10/100/1000
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index 3f9f6ed..62af3b4 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
> @@ -26,6 +26,7 @@
>  #include <linux/mdio.h>
>  #include <linux/usb/cdc.h>
>  #include <linux/suspend.h>
> +#include <linux/acpi.h>
>  
>  /* Information for net-next */
>  #define NETNEXT_VERSION		"08"
> @@ -1030,6 +1031,39 @@ out1:
>  	return ret;
>  }
>  
> +static u8 amac_ascii_to_hex(int c)
> +{
> +	if (c <= 0x39)
> +		return (u8)(c - 0x30);
> +	else if (c <= 0x46)
> +		return (u8)(c - 0x37);
> +	return (u8)(c - 0x57);
> +}

We really don't have such a function somewhere in the kernel already?

And why 'int', isn't "c" really a u8?

> +static void set_auxiliary_addr(struct sockaddr *sa)
> +{
> +	acpi_status status;
> +	acpi_handle handle;
> +	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
> +	union acpi_object *obj;
> +	int i;
> +	char *ptr;
> +
> +	acpi_get_handle(NULL, "\\_SB", &handle);
> +	status = acpi_evaluate_object(handle, "AMAC", NULL, &buffer);

Is this field in the ACPI standard, or should this only be "trusted" on
a limited number of machines (i.e. with Dell DMI strings?)

And finally, this seems odd overall given that a MAC address should be
associated with the specific network device, not the overall system.
What if you have 2 types of devices plugged into the same machine, with
this patch you suddenly have the same MAC address for both of them.
That doesn't seem correct...

thanks,

greg k-h
