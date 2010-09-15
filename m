From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH RESEND 1/3] netfilter: xtables: inclusion of xt_condition
Date: Wed, 15 Sep 2010 22:39:24 +0200
Message-ID: <4C912EFC.9070406@trash.net>
References: <1282034213-1829-1-git-send-email-luciano.coelho@nokia.com> <1282034213-1829-2-git-send-email-luciano.coelho@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	jengelh@medozas.de, sameo@linux.intel.com, janne.ylalehto@nokia.com
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59069 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753683Ab0IOUj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 16:39:29 -0400
In-Reply-To: <1282034213-1829-2-git-send-email-luciano.coelho@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 17.08.2010 10:36, schrieb Luciano Coelho:
> diff --git a/net/netfilter/xt_condition.c b/net/netfilter/xt_condition.c
> new file mode 100644
> index 0000000..a78d832
> --- /dev/null
> +++ b/net/netfilter/xt_condition.c
> @@ -0,0 +1,265 @@
> +/*
> + *	"condition" match extension for Xtables
> + *
> + *	Description: This module allows firewall rules to match using
> + *	condition variables available through procfs.
> + *
> + *	Authors:
> + *	Stephane Ouellette <ouellettes [at] videotron ca>, 2002-10-22
> + *	Massimiliano Hofer <max [at] nucleus it>, 2006-05-15
> + *
> + *	This program is free software; you can redistribute it and/or modify it
> + *	under the terms of the GNU General Public License; either version 2
> + *	or 3 of the License, as published by the Free Software Foundation.
> + */
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +#include <linux/kernel.h>
> +#include <linux/list.h>
> +#include <linux/module.h>
> +#include <linux/proc_fs.h>
> +#include <linux/spinlock.h>
> +#include <linux/string.h>
> +#include <linux/version.h>
> +#include <linux/netfilter/x_tables.h>
> +#include <linux/netfilter/xt_condition.h>
> +#include <net/netns/generic.h>
> +#include <asm/uaccess.h>
> +
> +/* Defaults, these can be overridden on the module command-line. */
> +static unsigned int condition_list_perms = S_IRUGO | S_IWUSR;
> +static unsigned int condition_uid_perms = 0;
> +static unsigned int condition_gid_perms = 0;

I'm not sure whether we already discussed this, but this isn't
useful if namespaces are used since the IDs aren't global.

> +
> +MODULE_AUTHOR("Stephane Ouellette <ouellettes@videotron.ca>");
> +MODULE_AUTHOR("Massimiliano Hofer <max@nucleus.it>");
> +MODULE_AUTHOR("Jan Engelhardt <jengelh@medozas.de>");
> +MODULE_DESCRIPTION("Allows rules to match against condition variables");
> +MODULE_LICENSE("GPL");
> +module_param(condition_list_perms, uint, S_IRUSR | S_IWUSR);
> +MODULE_PARM_DESC(condition_list_perms, "default permissions on /proc/net/nf_condition/* files");
> +module_param(condition_uid_perms, uint, S_IRUSR | S_IWUSR);
> +MODULE_PARM_DESC(condition_uid_perms, "default user owner of /proc/net/nf_condition/* files");
> +module_param(condition_gid_perms, uint, S_IRUSR | S_IWUSR);
> +MODULE_PARM_DESC(condition_gid_perms, "default group owner of /proc/net/nf_condition/* files");
> +MODULE_ALIAS("ipt_condition");
> +MODULE_ALIAS("ip6t_condition");
> +

> +/* proc_lock is a user context only semaphore used for write access */
> +/*           to the conditions' list.                               */
> +static DEFINE_MUTEX(proc_lock);

Why is this called proc_lock, as the comment states it protects
the condition variable list? The comment is also misleading since
this is a mutex and not a semaphore. I'd suggest list_mutex or
condition_mutex.

> +static int condition_proc_read(char __user *buffer, char **start, off_t offset,
> +			       int length, int *eof, void *data)
> +{
> +	const struct condition_variable *var = data;
> +
> +	buffer[0] = var->enabled ? '1' : '0';
> +	buffer[1] = '\n';

This is a user buffer, you need copy_to_user(). Also please run
sparse against your code to check for similar errors.

> +	if (length >= 2)
> +		*eof = true;
> +	return 2;
> +}
