From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC 4/9] snet: introduce snet_core.c and snet.h
Date: Mon, 04 Jan 2010 15:43:41 +0100
Message-ID: <4B41FE9D.2070708@trash.net>
References: <1262437456-24476-1-git-send-email-sam@synack.fr> <1262437456-24476-5-git-send-email-sam@synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Samir Bellabes <sam@synack.fr>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1262437456-24476-5-git-send-email-sam@synack.fr>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Samir Bellabes wrote:
> this patch introduce snet_core.c, which provides main functions to start and
> stop snet's subsystems :
> 	- snet_hooks	: LSM hooks
> 	- snet_netlink	: kernel-user communication (genetlink)
> 	- snet_event	: manages the table of protected syscalls
> 	- snet_verdict	: provides a wait queue for syscalls and manage verdicts
> 			  from userspace
> 
> Signed-off-by: Samir Bellabes <sam@synack.fr>
> ---
>  security/snet/include/snet.h |   29 ++++++++++++++++
>  security/snet/snet_core.c    |   77 ++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 106 insertions(+), 0 deletions(-)
>  create mode 100644 security/snet/include/snet.h
>  create mode 100644 security/snet/snet_core.c
> 
> diff --git a/security/snet/include/snet.h b/security/snet/include/snet.h
> new file mode 100644
> index 0000000..b664a47
> --- /dev/null
> +++ b/security/snet/include/snet.h
> @@ -0,0 +1,29 @@
> +#ifndef _SNET_H
> +#define _SNET_H
> +
> +#include "snet_hooks.h"
> +
> +#define SNET_VERSION	0x1
> +#define SNET_NAME	"snet"
> +
> +#define SNET_PRINTK(enable, fmt, arg...)			\
> +	do {							\
> +		if (enable)					\
> +			printk(KERN_INFO "%s: %s: " fmt ,	\
> +				SNET_NAME , __func__ ,		\
> +				## arg);			\
> +	} while (0)

How about using pr_debug()?

> +struct snet_event {
> +	enum snet_syscall syscall;
> +	u8 protocol;
> +} __attribute__ ((packed));

Does this really need to be packed? You're using it in a
struct snet_event_entry, which is padded anyways.

> +
> +#endif /* _SNET_H */
> diff --git a/security/snet/snet_core.c b/security/snet/snet_core.c
> new file mode 100644
> index 0000000..34b61e9
> --- /dev/null
> +++ b/security/snet/snet_core.c
> @@ -0,0 +1,77 @@
> +#include <linux/module.h>
> +#include <linux/kernel.h>
> +#include <net/genetlink.h>
> +
> +#include "snet.h"
> +#include "snet_hooks.h"
> +#include "snet_netlink.h"
> +#include "snet_event.h"
> +#include "snet_verdict.h"
> +#include "snet_utils.h"
> +
> +unsigned int event_hash_size = 16;
> +module_param(event_hash_size, uint, 0600);
> +MODULE_PARM_DESC(event_hash_size, "Set the size of the event hash table");
> +
> +unsigned int verdict_hash_size = 16;
> +module_param(verdict_hash_size, uint, 0600);
> +MODULE_PARM_DESC(verdict_hash_size, "Set the size of the verdict hash table");

I can't see anything handling size changes after initialization,
so there should probably use 0400.

> +
> +unsigned int snet_verdict_delay = 5;
> +module_param(snet_verdict_delay, uint, 0600);
> +MODULE_PARM_DESC(snet_verdict_delay, "Set the timeout for verdicts in secs");
> +
> +unsigned int snet_verdict_policy = SNET_VERDICT_GRANT;	/* permissive by default */
> +module_param(snet_verdict_policy, uint, 0600);
> +MODULE_PARM_DESC(snet_verdict_policy, "Set the default verdict");

> +
> +#ifdef CONFIG_SECURITY_SNET_DEBUG
> +unsigned int snet_debug;
> +EXPORT_SYMBOL_GPL(snet_debug);
> +module_param(snet_debug, bool, 0644);
> +MODULE_PARM_DESC(snet_debug, "Enable debug messages");
> +#endif
> +
> +void snet_core_exit(void)
> +{
> +	snet_netlink_exit();
> +	snet_event_exit();
> +	snet_hooks_exit();
> +	snet_verdict_exit();
> +	snet_dbg("stopped\n");
> +}
> +
> +static __init int snet_init(void)
> +{
> +	int ret;
> +
> +	snet_dbg("initializing: event_hash_size=%u "
> +		 "verdict_hash_size=%u verdict_delay=%usecs "
> +		 "default_policy=%s\n",
> +		 event_hash_size, verdict_hash_size, snet_verdict_delay,
> +		 snet_verdict_name(snet_verdict_policy));
> +
> +	ret = snet_event_init();
> +	if (ret < 0)
> +		goto exit;
> +
> +	ret = snet_verdict_init();
> +	if (ret < 0)
> +		goto exit;
> +
> +	ret = snet_hooks_init();
> +	if (ret < 0)
> +		goto exit;
> +
> +	snet_dbg("started\n");
> +	return 0;
> +exit:
> +	snet_core_exit();
> +	return ret;

By cleaning up only those parts that were successfully initialized,
you could avoid things like the verdict_hash check below:

> +int snet_verdict_exit(void)
> +{
> +	write_lock_bh(&verdict_hash_lock);
> +	if (verdict_hash) {
> +		__snet_verdict_flush();
> +		kfree(verdict_hash);
> +		verdict_hash = NULL;
> +	}
> +	write_unlock_bh(&verdict_hash_lock);
> +
> +	return 0;

Also the exit() functions should return void, there shouldn't
be any error conditions since there's no way to handle them.

