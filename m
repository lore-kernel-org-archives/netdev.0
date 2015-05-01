From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/3] net: dsa: introduce module_switch_driver macro
Date: Fri, 01 May 2015 16:34:21 -0700
Message-ID: <55440D7D.4060504@gmail.com>
References: <1430518155-29565-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>, kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430518155-29565-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/05/15 15:09, Vivien Didelot wrote:
> This commit introduces a new module_switch_driver macro, similar to
> module_platform_driver and such, to reduce boilerplate when declaring
> DSA switch drivers.
> 
> In order to use the module_driver macro, register_switch_driver needed
> to be changed to return an int instead of void, so make it return 0.

Do we get much benefit from having this change, the diffstat looks
pretty neutral, ultimately register_switch_driver() might be gone (see:
http://www.spinics.net/lists/netdev/msg326900.html) and mv88e6xxx cannot
be converted to it due to how it is designed. This is not a strong
objection though, the changes look fine to me.

> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  include/net/dsa.h | 13 ++++++++++++-
>  net/dsa/dsa.c     |  4 +++-
>  2 files changed, 15 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index fbca63b..927f16a 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -11,6 +11,7 @@
>  #ifndef __LINUX_NET_DSA_H
>  #define __LINUX_NET_DSA_H
>  
> +#include <linux/device.h>
>  #include <linux/if_ether.h>
>  #include <linux/list.h>
>  #include <linux/timer.h>
> @@ -304,8 +305,18 @@ struct dsa_switch_driver {
>  			       unsigned char *addr, bool *is_static);
>  };
>  
> -void register_switch_driver(struct dsa_switch_driver *type);
> +int register_switch_driver(struct dsa_switch_driver *type);
>  void unregister_switch_driver(struct dsa_switch_driver *type);
> +
> +/* module_switch_driver() - Helper macro for drivers that don't do anything
> + * special in module init/exit. This eliminates a lot of boilerplate. Each
> + * module may only use this macro once, and calling it replaces module_init()
> + * and module_exit()
> + */
> +#define module_switch_driver(__switch_driver) \
> +	module_driver(__switch_driver, register_switch_driver, \
> +			unregister_switch_driver)
> +
>  struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
>  
>  static inline void *ds_to_priv(struct dsa_switch *ds)
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index e6f6cc3..9630522 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -31,11 +31,13 @@ char dsa_driver_version[] = "0.1";
>  static DEFINE_MUTEX(dsa_switch_drivers_mutex);
>  static LIST_HEAD(dsa_switch_drivers);
>  
> -void register_switch_driver(struct dsa_switch_driver *drv)
> +int register_switch_driver(struct dsa_switch_driver *drv)
>  {
>  	mutex_lock(&dsa_switch_drivers_mutex);
>  	list_add_tail(&drv->list, &dsa_switch_drivers);
>  	mutex_unlock(&dsa_switch_drivers_mutex);
> +
> +	return 0;
>  }
>  EXPORT_SYMBOL_GPL(register_switch_driver);
>  
> 


-- 
Florian
