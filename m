From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [PATCH] qlge: Fix incorrect usage of module parameters and
	netdev msg level
Date: Thu, 18 Nov 2010 09:22:24 -0800
Message-ID: <20101118172224.GA14333@linux-ox1b.qlogic.org>
References: <1290075903-3038-1-git-send-email-sonnyrao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Milton Miller <miltonm@bga.com>,
	Linux Driver <Linux-Driver@qlogic.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sonny Rao <sonnyrao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cain.qlogic.com ([198.70.193.223]:54957 "EHLO cain.qlc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755489Ab0KRRe4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Nov 2010 12:34:56 -0500
Content-Disposition: inline
In-Reply-To: <1290075903-3038-1-git-send-email-sonnyrao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 18, 2010 at 02:25:03AM -0800, Sonny Rao wrote:
> Driver appears to be mistaking the permission field with default value
> in the case of debug and qlge_irq_type.
> 
> Driver is also passing debug as a bitmask into netif_msg_init()
> which really wants a number of bits, so fix that.
> 
> Signed-off-by: Milton Miller <miltonm@bga.com>
> Signed-off-by: Sonny Rao <sonnyrao@linux.vnet.ibm.com>
> ---
>  drivers/net/qlge/qlge_main.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
> index d9a7626..66878bb 100644
> --- a/drivers/net/qlge/qlge_main.c
> +++ b/drivers/net/qlge/qlge_main.c
> @@ -62,15 +62,15 @@ static const u32 default_msg =
>  /* NETIF_MSG_PKTDATA | */
>      NETIF_MSG_HW | NETIF_MSG_WOL | 0;
>  
> -static int debug = 0x00007fff;	/* defaults above */
> -module_param(debug, int, 0);
> +static int debug = 15;	/* defaults above */


I think what we want here is:

> +static int debug = -1;	/* defaults above */

This will correct it and maintain the current behavior.
By passing in the 0x00007ffff we were getting the passed in default
paramter from the 2nd compare in the first if statement below. If we set
debug to 15 then it looks like we would turn on all bits rather than
qlge default.

static inline u32 netif_msg_init(int debug_value, int default_msg_enable_bits)
{
        /* use default */
        if (debug_value < 0 || debug_value >= (sizeof(u32) * 8))
                return default_msg_enable_bits;
        if (debug_value == 0)   /* no output */
                return 0;
        /* set low N bits */
        return (1 << debug_value) - 1;
}

