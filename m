From: Gertjan van Wingerde <gwingerde@gmail.com>
Subject: Re: [PATCH wireless-next] rt2x00: Use more current logging styles,
 shrink object size
Date: Fri, 19 Apr 2013 11:45:44 +0200
Message-ID: <CAL1gcdOMtbzxCVLNvDK_CD-M+_SdAeL3Sja9khO9+G2bNOCz1g@mail.gmail.com>
References: <1366360406.3901.10.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ivo van Doorn <IvDoorn@gmail.com>,
	Helmut Schaa <helmut.schaa@googlemail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	rt2x00 Users List <users@rt2x00.serialmonkey.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366360406.3901.10.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

On Fri, Apr 19, 2013 at 10:33 AM, Joe Perches <joe@perches.com> wrote:
> Reduce object size ~2% using more current logging styles.
>
> Neaten and simplify logging macros.
> Use wiphy_<level> where appropriate.
> Coalesce formats.
>
> Convert ERROR/WARNING/INFO macros and uses to rt2x00_<level>
> Convert EEPROM to rt2x00_eeprom_dbg
> Convert PROBE_ERROR to rt2x00_probe_err
>
> $ size drivers/net/wireless/rt2x00/built-in.o*
>    text    data     bss     dec     hex filename
>  245537   71696   69584  386817   5e701 drivers/net/wireless/rt2x00/built-in.o.new
>  240609   70096   68944  379649   5cb01 drivers/net/wireless/rt2x00/built-in.o.new.no_dyn_debug
>  240609   70096   68944  379649   5cb01 drivers/net/wireless/rt2x00/built-in.o.new.no_rt2x00_debug
>  249198   70096   70352  389646   5f20e drivers/net/wireless/rt2x00/built-in.o.old
>  249198   70096   70352  389646   5f20e drivers/net/wireless/rt2x00/built-in.o.old.no_dyn_debug
>  244222   70096   69712  384030   5dc1e drivers/net/wireless/rt2x00/built-in.o.old.no_rt2x00_debug
>
> Signed-off-by: Joe Perches <joe@perches.com>

Thanks for doing this. I have some observations below, though.

> diff --git a/drivers/net/wireless/rt2x00/rt2x00.h b/drivers/net/wireless/rt2x00/rt2x00.h
> index 0d02d16..249d416 100644
> --- a/drivers/net/wireless/rt2x00/rt2x00.h
> +++ b/drivers/net/wireless/rt2x00/rt2x00.h
> @@ -54,47 +54,40 @@
>  #define DRV_VERSION    "2.3.0"
>  #define DRV_PROJECT    "http://rt2x00.serialmonkey.com"
>
> -/*
> - * Debug definitions.
> - * Debug output has to be enabled during compile time.
> +/* Utility printing macros */
> +#define rt2x00_err(dev, fmt, ...)                                      \
> +       wiphy_err((dev)->hw->wiphy, "%s: Error - " fmt,                 \
> +                 __func__, ##__VA_ARGS__)
> +#define rt2x00_warn(dev, fmt, ...)                                     \
> +       wiphy_err((dev)->hw->wiphy, "%s: Warning - " fmt,               \
> +                 __func__, ##__VA_ARGS__)

Shouldn't this use wiphy_warn instead of wiphy_err?

> +#define rt2x00_info(dev, fmt, ...)                                     \
> +       wiphy_err((dev)->hw->wiphy, "%s: Info - " fmt,                  \
> +                 __func__, ##__VA_ARGS__)

Shouldn't this use wiphy_info instead of wiphy_err?

> +
> +/* The special rt2x00_probe_err message form is used
> + * when the rt2x00_dev is not yet initialized.
>   */
> -#define DEBUG_PRINTK_MSG(__dev, __kernlvl, __lvl, __msg, __args...)    \
> -       printk(__kernlvl "%s -> %s: %s - " __msg,                       \
> -              wiphy_name((__dev)->hw->wiphy), __func__, __lvl, ##__args)
> -
> -#define DEBUG_PRINTK_PROBE(__kernlvl, __lvl, __msg, __args...) \
> -       printk(__kernlvl "%s -> %s: %s - " __msg,               \
> -              KBUILD_MODNAME, __func__, __lvl, ##__args)
> +#define rt2x00_probe_err(fmt, ...)                                     \
> +       printk(KERN_ERR KBUILD_MODNAME ": %s: Error - " fmt,            \
> +              __func__, ##__VA_ARGS__)
>
> +/* Debug definitions.
> + * Debug output has to be enabled during compile time.
> + */
>  #ifdef CONFIG_RT2X00_DEBUG
> -#define DEBUG_PRINTK(__dev, __kernlvl, __lvl, __msg, __args...)        \
> -       DEBUG_PRINTK_MSG(__dev, __kernlvl, __lvl, __msg, ##__args)
> -#else
> -#define DEBUG_PRINTK(__dev, __kernlvl, __lvl, __msg, __args...)        \
> -       do { } while (0)
> +#define DEBUG
>  #endif /* CONFIG_RT2X00_DEBUG */
>
>  /*
>   * Various debug levels.
> - * The debug levels PANIC and ERROR both indicate serious problems,
> - * for this reason they should never be ignored.
> - * The special ERROR_PROBE message is for messages that are generated
> - * when the rt2x00_dev is not yet initialized.
>   */
> -#define PANIC(__dev, __msg, __args...) \
> -       DEBUG_PRINTK_MSG(__dev, KERN_CRIT, "Panic", __msg, ##__args)
> -#define ERROR(__dev, __msg, __args...) \
> -       DEBUG_PRINTK_MSG(__dev, KERN_ERR, "Error", __msg, ##__args)
> -#define ERROR_PROBE(__msg, __args...) \
> -       DEBUG_PRINTK_PROBE(KERN_ERR, "Error", __msg, ##__args)
> -#define WARNING(__dev, __msg, __args...) \
> -       DEBUG_PRINTK_MSG(__dev, KERN_WARNING, "Warning", __msg, ##__args)
> -#define INFO(__dev, __msg, __args...) \
> -       DEBUG_PRINTK_MSG(__dev, KERN_INFO, "Info", __msg, ##__args)
> -#define DEBUG(__dev, __msg, __args...) \
> -       DEBUG_PRINTK(__dev, KERN_DEBUG, "Debug", __msg, ##__args)
> -#define EEPROM(__dev, __msg, __args...) \
> -       DEBUG_PRINTK(__dev, KERN_DEBUG, "EEPROM recovery", __msg, ##__args)
> +#define rt2x00_dbg(dev, fmt, ...)                                      \
> +       wiphy_dbg((dev)->hw->wiphy, "%s: Debug - " fmt,                 \
> +                 __func__, ##__VA_ARGS__)
> +#define rt2x00_eeprom_dbg(dev, fmt, ...)                               \
> +       wiphy_dbg((dev)->hw->wiphy, "%s: %s - " fmt,                    \
> +                 __func__, "EEPROM recovery", ##__VA_ARGS__)
>

Why do you give the "EEPROM recovery" string as extra argument instead
of embedding it in the format string, like you do in the rt2x00_dbg
macro for the "Debug" string?


Also, please put all rt2x00_<level> next to each other, instead of
scattering them around with the "#define DEBUG" in between them.

---
Gertjan
