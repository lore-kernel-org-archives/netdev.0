From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH net-next v3 05/10] drivers: base: Add device_find_class()
Date: Sun, 15 Jan 2017 12:04:55 +0100
Message-ID: <20170115110455.GE26374@kroah.com>
References: <20170114214713.28109-1-f.fainelli@gmail.com>
 <20170114214713.28109-6-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        "moderated list:ARM SUB-ARCHITECTURES"
        <linux-arm-kernel@lists.infradead.org>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170114214713.28109-6-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 14, 2017 at 01:47:08PM -0800, Florian Fainelli wrote:
> Add a helper function to lookup a device reference given a class name.
> This is a preliminary patch to remove adhoc code from net/dsa/dsa.c and
> make it more generic.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/base/core.c    | 19 +++++++++++++++++++
>  include/linux/device.h |  1 +
>  2 files changed, 20 insertions(+)
> 
> diff --git a/drivers/base/core.c b/drivers/base/core.c
> index 020ea7f05520..3dd6047c10d8 100644
> --- a/drivers/base/core.c
> +++ b/drivers/base/core.c
> @@ -2065,6 +2065,25 @@ struct device *device_find_child(struct device *parent, void *data,
>  }
>  EXPORT_SYMBOL_GPL(device_find_child);
>  
> +static int dev_is_class(struct device *dev, void *class)
> +{
> +	if (dev->class != NULL && !strcmp(dev->class->name, class))
> +		return 1;
> +
> +	return 0;
> +}
> +
> +struct device *device_find_class(struct device *parent, char *class)

Why are you using the char * for a class, and not just a pointer to
"struct class"?  That seems to be the most logical one, no need to rely
on string comparisons here.

Also, what is this being used for?  You aren't trying to walk up the
device heirachy to find a specific "type" of device, are you?  If so,
ugh, I ranted about this in the past when the hyperv driver was trying
to do such a thing...

> +{
> +	if (dev_is_class(parent, class)) {
> +		get_device(parent);
> +		return parent;
> +	}
> +
> +	return device_find_child(parent, class, dev_is_class);

You are trying to find a peer device with the same parent that belongs
to a specific class?

Again, what is this being used for?

And all exported driver core functions should have full kerneldoc
information for them so that people know how to use them, and what the
constraints are (see device_find_child() as an example.)  Please do that
here as well because you are returning a pointer to a structure with the
reference count incremented, callers need to know that.

thanks,

greg k-h
