From: Paul Moore <pmoore@redhat.com>
Subject: Re: [RFC PATCH v2 03/18] netlabel: Initial support for the CALIPSO netlink protocol.
Date: Sun, 07 Feb 2016 14:55:58 -0500
Message-ID: <8370513.CzcpcvV7jq@sifl>
References: <1452246774-13241-4-git-send-email-huw@codeweavers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Huw Davies <huw@codeweavers.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1452246774-13241-4-git-send-email-huw@codeweavers.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, January 08, 2016 09:52:39 AM Huw Davies wrote:
> CALIPSO is a packet labelling protocol for IPv6 which is very similar
> to CIPSO.  It is specified in RFC 5570.  Much of the code is based on
> the current CIPSO code.
> 
> This adds support for adding passthrough-type CALIPSO DOIs through the
> NLBL_CALIPSO_C_ADD command.  It requires attributes:
> 
>  NLBL_CALIPSO_A_TYPE which must be CALIPSO_MAP_PASS.
>  NLBL_CALIPSO_A_DOI.
> 
> In passthrough mode the CALIPSO engine will map MLS secattr levels
> and categories directly to the packet label.
> 
> At this stage, the major difference between this and the CIPSO
> code is that IPv6 may be compiled as a module.  To allow for
> this the CALIPSO functions are registered at module init time.
> 
> Signed-off-by: Huw Davies <huw@codeweavers.com>

...

> diff --git a/include/net/calipso.h b/include/net/calipso.h
> new file mode 100644
> index 0000000..ad4d653
> --- /dev/null
> +++ b/include/net/calipso.h
> @@ -0,0 +1,79 @@
> +/*
> + * CALIPSO - Common Architecture Label IPv6 Security Option
> + *
> + * This is an implementation of the CALIPSO protocol as specified in
> + * RFC 5570.
> + *
> + * Authors: Paul Moore <paul@paul-moore.com>
> + *          Huw Davies <huw@codeweavers.com>
> + *
> + */
> +
> +/*
> + * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
> + * (c) Copyright Huw Davies <huw@codeweavers.com>, 2015
> + *
> + * This program is free software;  you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY;  without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
> + * the GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program;  if not, see <http://www.gnu.org/licenses/>.
> + *
> + */
> +
> +#ifndef _CALIPSO_H
> +#define _CALIPSO_H
> +
> +#include <linux/types.h>
> +#include <linux/rcupdate.h>
> +#include <linux/list.h>
> +#include <linux/net.h>
> +#include <linux/skbuff.h>
> +#include <net/netlabel.h>
> +#include <net/request_sock.h>
> +#include <linux/atomic.h>
> +#include <asm/unaligned.h>
> +
> +/* known doi values */
> +#define CALIPSO_DOI_UNKNOWN          0x00000000
> +
> +/* doi mapping types */
> +#define CALIPSO_MAP_UNKNOWN          0
> +#define CALIPSO_MAP_PASS             1

For (my) sanity's sake, let's use the same _MAP_PASS value as CIPSO (2).

> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> index 9f5137c..07214c7 100644
> --- a/net/ipv6/af_inet6.c
> +++ b/net/ipv6/af_inet6.c
> @@ -60,6 +60,7 @@
>  #ifdef CONFIG_IPV6_TUNNEL
>  #include <net/ip6_tunnel.h>
>  #endif
> +#include <net/calipso.h>
> 
>  #include <asm/uaccess.h>
>  #include <linux/mroute6.h>
> @@ -971,13 +972,19 @@ static int __init inet6_init(void)
>  	if (err)
>  		goto sysctl_fail;
>  #endif
> +
> +	err = calipso_init();
> +	if (err)
> +		goto calipso_fail;

It seems like the calipso_init() call should got before the sysctl init call 
in inet6_init().

> diff --git a/net/netlabel/netlabel_calipso.h
> b/net/netlabel/netlabel_calipso.h new file mode 100644
> index 0000000..01bfd37
> --- /dev/null
> +++ b/net/netlabel/netlabel_calipso.h
> @@ -0,0 +1,128 @@
> +/*
> + * NetLabel CALIPSO Support
> + *
> + * This file defines the CALIPSO functions for the NetLabel system.  The
> + * NetLabel system manages static and dynamic label mappings for network
> + * protocols such as CIPSO and RIPSO.
> + *
> + * Authors: Paul Moore <paul@paul-moore.com>
> + *          Huw Davies <huw@codeweavers.com>
> + *
> + */
> +
> +/* (c) Copyright Hewlett-Packard Development Company, L.P., 2006
> + * (c) Copyright Huw Davies <huw@codeweavers.com>, 2015
> + *
> + * This program is free software;  you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY;  without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
> + * the GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program;  if not, see <http://www.gnu.org/licenses/>.
> + *
> + */
> +
> +#ifndef _NETLABEL_CALIPSO
> +#define _NETLABEL_CALIPSO
> +
> +#include <net/netlabel.h>
> +#include <net/calipso.h>
> +
> +/* The following NetLabel payloads are supported by the CALIPSO subsystem.
> + *
> + * o ADD:
> + *   Sent by an application to add a new DOI mapping table.
> + *
> + *   Required attributes:
> + *
> + *     NLBL_CALIPSO_A_DOI
> + *     NLBL_CALIPSO_A_MTYPE
> + *
> + *   If using CALIPSO_MAP_PASS no additional attributes are required.

This patch includes descriptive comments for all the different 
NetLabel/CALIPSO payloads provided for the entire patchset, rather than this 
particular patch.  It would be preferable to add the comment blocks as you add 
support for the payloads in each patch rather than all at once.

-- 
paul moore
security @ redhat
