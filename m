From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2] drivers/net/cxgb3/cxgb3_main.c: prevent reading
 uninitialized stack memory
Date: Thu, 16 Sep 2010 11:54:23 -0400
Message-ID: <20100916155423.GA14318@home.goodmis.org>
References: <1284586992.6275.93.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: divy@chelsio.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, security@kernel.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.123]:44740 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754944Ab0IPPy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 11:54:26 -0400
Content-Disposition: inline
In-Reply-To: <1284586992.6275.93.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 15, 2010 at 05:43:12PM -0400, Dan Rosenberg wrote:
> Fixed formatting (tabs and line breaks).
> 
> The CHELSIO_GET_QSET_NUM device ioctl allows unprivileged users to read
> 4 bytes of uninitialized stack memory, because the "addr" member of the
> ch_reg struct declared on the stack in cxgb_extension_ioctl() is not
> altered or zeroed before being copied back to the user.  This patch
> takes care of it.
> 
> Signed-off-by: Dan Rosenberg <dan.j.rosenberg@gmail.com>
> 
> --- linux-2.6.35.4.orig/drivers/net/cxgb3/cxgb3_main.c	2010-08-26 19:47:12.000000000 -0400
> +++ linux-2.6.35.4/drivers/net/cxgb3/cxgb3_main.c	2010-09-14 21:24:34.369511115 -0400
> @@ -2296,6 +2296,8 @@ static int cxgb_extension_ioctl(struct n
>  	case CHELSIO_GET_QSET_NUM:{
>  		struct ch_reg edata;
>  
> +		memset(&edata, 0, sizeof(struct ch_reg));
> +
>  		edata.cmd = CHELSIO_GET_QSET_NUM;
>  		edata.val = pi->nqsets;

This is a pretty expensive way to fix it. either...

+		edata.addr = 0;

    or:

-		struct ch_reg edata;
+		struct ch_reg edata = {
+			.cmd = CHELSIO_GET_QSET_NUM,
+			.val = pi->nqsets
+		};

-  		edata.cmd = CHELSIO_GET_QSET_NUM;
-  		edata.val = pi->nqsets;

If you are worried that the struct ch_reg may grow someday.

-- Steve

>  		if (copy_to_user(useraddr, &edata, sizeof(edata)))
> 
> 
