From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01/18] flag parameters: helper function
Date: Mon, 5 May 2008 18:51:03 -0700
Message-ID: <20080505185103.b9299541.akpm@linux-foundation.org>
References: <200805050342.m453gkY4029814@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davidel@xmailserver.org, mtk.manpages@gmail.com,
	torvalds@linux-foundation.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59353 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754331AbYEFBvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 21:51:25 -0400
In-Reply-To: <200805050342.m453gkY4029814@devserv.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 4 May 2008 23:42:46 -0400 Ulrich Drepper <drepper@redhat.com> wrote:

> In the following patches we have to map one set of flags to another one
> in numerous locations.  This patch provides a generic implementation for
> this.  It is basically the code Davide Libenzi suggested on 4/27/08.
> 
> I haven't checked whether this functionality can be applied to any existing
> code.
> 
> 
>  include/linux/flagsremap.h |   15 +++++++++++++++
>  lib/Makefile               |    2 +-
>  lib/flagsremap.c           |   17 +++++++++++++++++
>  3 files changed, 33 insertions(+), 1 deletion(-)
> 
> 
> Signed-off-by: Ulrich Drepper <drepper@redhat.com>
> 
> diff --git a/include/linux/flagsremap.h b/include/linux/flagsremap.h
> new file mode 100644
> index 0000000..6ea0ee3
> --- /dev/null
> +++ b/include/linux/flagsremap.h
> @@ -0,0 +1,15 @@
> +/*
> + * Generic flag remapping functionality.
> + */
> +#ifndef _LINUX_FLAPREMAP_H
> +#define _LINUX_FLAGREMAP_H
> +
> +struct flags_rmap {
> +	int f;
> +	int of;
> +};

In kernel world, the abbreviation "rmap" means "reverse mapping".  I think
"flags_remapping" would be a better identifier here.

> +extern int flags_remap(const struct flags_rmap *m, int n,
> +		       int f, int *rf);
> +
> +#endif /* _LINUX_FLAGREMAP_H */
> diff --git a/lib/Makefile b/lib/Makefile
> index 74b0cfb..ab861ad 100644
> --- a/lib/Makefile
> +++ b/lib/Makefile
> @@ -6,7 +6,7 @@ lib-y := ctype.o string.o vsprintf.o cmdline.o \
>  	 rbtree.o radix-tree.o dump_stack.o \
>  	 idr.o int_sqrt.o extable.o prio_tree.o \
>  	 sha1.o irq_regs.o reciprocal_div.o argv_split.o \
> -	 proportions.o prio_heap.o ratelimit.o
> +	 proportions.o prio_heap.o ratelimit.o flagsremap.o
>  
>  lib-$(CONFIG_MMU) += ioremap.o
>  lib-$(CONFIG_SMP) += cpumask.o
> diff --git a/lib/flagsremap.c b/lib/flagsremap.c
> new file mode 100644
> index 0000000..7dbe8f5
> --- /dev/null
> +++ b/lib/flagsremap.c
> @@ -0,0 +1,17 @@
> +/*
> + * Implement generic flag remapping.
> + */
> +#include <linux/flagsremap.h>
> +
> +
> +int flags_remap(const struct flags_rmap *m, int n,
> +		int f, int *rf)
> +{
> +	int i;
> +	for (i = 0, *rf = 0; f && i < n; i++, m++)
> +		if (f & m->f) {
> +			*rf |= m->of;
> +			f &= ~m->f;
> +		}
> +	return f;
> +}

hm, that looks expensive.  The compiler will need to generate a deref of m
and rf multiple times around the loop.  Copying them into locals does
improve that a lot.

I'm only on [1/18] so I don't know how often this code gets executed.  If
it's "on each open" then ouch, perhaps it might even be worth investigating a
table-based implementation.

Also: sorry, but ugh-at-the-naming.  We don't *gain* anything from having
idenitifers called f, of, m, n and rf.  And we lose quite a lot in
readability and understandability.  It would be much nicer to invest a
little bit more typing-time here, IMO.
