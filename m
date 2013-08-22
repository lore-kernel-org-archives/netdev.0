From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/2] genl: Hold reference on correct module while
 netlink-dump.
Date: Thu, 22 Aug 2013 09:40:42 +0200
Message-ID: <1377157242.14110.21.camel@jlt4.sipsolutions.net>
References: <1377143892-20763-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:34025 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753758Ab3HVHkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 03:40:45 -0400
In-Reply-To: <1377143892-20763-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-21 at 20:58 -0700, Pravin B Shelar wrote:
> netlink dump operations take module as parameter to hold
> reference for entire netlink dump duration.
> Currently it holds ref only on genl module which is not correct
> when we use ops registered to genl from another module.
> Following patch adds module pointer to genl_ops so that netlink
> can hold ref count on it.
> 
> CC: Jesse Gross <jesse@nicira.com>
> CC: Johannes Berg <johannes.berg@intel.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  include/net/genetlink.h |   21 ++++++++++++++++++---
>  net/netlink/genetlink.c |   39 ++++++++++++++++++++++++---------------
>  2 files changed, 42 insertions(+), 18 deletions(-)
> 
> diff --git a/include/net/genetlink.h b/include/net/genetlink.h
> index 93024a4..7f57b2c 100644
> --- a/include/net/genetlink.h
> +++ b/include/net/genetlink.h
> @@ -119,13 +119,28 @@ struct genl_ops {
>  					 struct netlink_callback *cb);
>  	int		       (*done)(struct netlink_callback *cb);
>  	struct list_head	ops_list;
> +	struct module		*module;
>  };

This may be more correct than my patch, but I'm not sure it's worth
spending the memory. Is there going to be any generic netlink family
that actually puts operations into a different module than the family
itself? I doubt that.

> @@ -605,14 +610,18 @@ static int genl_family_rcv_msg(struct genl_family *family,
>  			genl_unlock();
>  			c.data = ops;
>  			c.dump = genl_lock_dumpit;
> -			if (ops->done)
> -				c.done = genl_lock_done;
> +			c.done = genl_lock_done;
> +			c.module = THIS_MODULE;

THIS_MODULE here is useless, this code is always built-in.

> +			if (!try_module_get(ops->module))
> +				return -EPROTONOSUPPORT;

Why open-code it? You can just point c.module to the ops module here as
well (because generic netlink is built-in) and save yourself the
try_module_get stuff.

johannes
