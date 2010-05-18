From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: dev_get_valid_name buggy with hash collision
Date: Tue, 18 May 2010 15:29:37 +0300
Message-ID: <201005181529.37420.opurdila@ixiacom.com>
References: <4BF26926.4070507@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:10690 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751964Ab0ERM3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 08:29:40 -0400
In-Reply-To: <4BF26926.4070507@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 18 May 2010 13:17:10 you wrote:

> the commit:
> 
> commit d90310243fd750240755e217c5faa13e24f41536
> Author: Octavian Purdila <opurdila@ixiacom.com>
> Date:   Wed Nov 18 02:36:59 2009 +0000
> 
>      net: device name allocation cleanups
> 
> introduced a bug when there is a hash collision making impossible to
> rename a device with eth%d
<snip>

Hi Daniel,

Thanks for the detailed explanation ! 

> 
> IMO, the bug is to pass the 'dev->name' parameter to __dev_alloc_name
> directly instead of a temporary name.

I agree.

> 
> The patch in attachment fix the problem but I am not sure we shouldn't
> go further and do more cleanup around this bug, so you may consider it
> as a RFC more than a fix. If it is acceptable, I will send it as a patch
> against net-2.6.
> 

The patch looks good to me, just one doubt here:

>--- net-2.6.orig/net/core/dev.c
>+++ net-2.6/net/core/dev.c
>@@ -936,18 +936,22 @@ int dev_alloc_name(struct net_device *de
> }
> EXPORT_SYMBOL(dev_alloc_name);
> 
>-static int dev_get_valid_name(struct net *net, const char *name, char *buf,
>-                             bool fmt)
>+static int dev_get_valid_name(struct net_device *dev, const char *name, bool 
fmt)
> {
>+       struct net *net;
>+
>+       BUG_ON(!dev_net(dev));
>+       net = dev_net(dev);
>+
>        if (!dev_valid_name(name))
>                return -EINVAL;
> 
>        if (fmt && strchr(name, '%'))
>-               return __dev_alloc_name(net, name, buf);
>+               return dev_alloc_name(dev, name);
>        else if (__dev_get_by_name(net, name))
>                return -EEXIST;
>-       else if (buf != name)
>-               strlcpy(buf, name, IFNAMSIZ);
>+       else if (strncmp(dev->name, name, IFNAMSIZ))
>+                strlcpy(dev->name, name, IFNAMSIZ);
> 

Why do the strncmp, can't we preserve the (buf != name) condition?

Thanks,
tavi
