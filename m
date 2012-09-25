From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inet_diag: fix panic when unload inet_diag
Date: Tue, 25 Sep 2012 08:36:51 +0200
Message-ID: <1348555011.26828.2031.camel@edumazet-glaptop>
References: <1348541310-31913-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, stephen.hemminger@vyatta.com, jengelh@inai.de,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61767 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854Ab2IYGg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 02:36:57 -0400
Received: by bkcjk13 with SMTP id jk13so1327227bkc.19
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 23:36:55 -0700 (PDT)
In-Reply-To: <1348541310-31913-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-09-25 at 10:48 +0800, Gao feng wrote:
> when inet_diag being compiled as module, inet_diag_handler_dump
> set netlink_dump_control.dump to inet_diag_dump,so if module
> inet_diag is unloaded,netlink will still try to call this function
> in netlink_dump. this will cause kernel panic.
> 
> fix this by adding a reference of inet_diag module before
> setting netlink_callback, and release this reference in
> netlink_callback.done.
> 
> Thanks for all help from Stephen,Jan and Eric.
...

>  
> @@ -1001,8 +1025,26 @@ static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
>  		{
>  			struct netlink_dump_control c = {
>  				.dump = inet_diag_dump,
> +				.done = inet_diag_done,
>  			};
> -			return netlink_dump_start(net->diag_nlsk, skb, h, &c);
> +			int err;
> +			/*
> +			 * netlink_dump will call inet_diag_dump,
> +			 * so we need a reference of THIS_MODULE.
> +			 */
> +			if (!try_module_get(THIS_MODULE))
> +				return -EPROTONOSUPPORT;
> +
> +			err = netlink_dump_start(net->diag_nlsk, skb, h, &c);
> +
> +			if ((err != -EINTR) && (err != -ENOBUFS)) {
> +				/*
> +				 * netlink_callback set failed, release the
> +				 * referenct of THIS_MODULE.
> +				 */
> +				module_put(THIS_MODULE);
> +			}
> +			return err;
>  		}
>  	}
>  

Hmm... this seems error prone...

In the future, netlink_dump_start() could be changed to return other
errors than EINTR or ENOBUFS that need the module_put()

I would change netlink_dump_start() to __netlink_dump_start() and add a
module param to it, so that this module stuff is centralized in
__netlink_dump_start()

Then, instead of calling (from inet_diag)

netlink_dump_start(net->diag_nlsk, skb, nlh, &c);

you would use :

__netlink_dump_start(net->diag_nlsk, skb, nlh, &c, THIS_MODULE);

I wonder if this fix is not needed elsewhere eventually
(net/unix/af_unix.c for example ?)
