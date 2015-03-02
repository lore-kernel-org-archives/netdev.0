From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 2/4] net: add IPv4 routing FIB support for switchdev
Date: Mon, 2 Mar 2015 14:28:55 -0800
Message-ID: <CAE4R7bAwC5QvteamkHs+J609DTM=jqNQeKLmEWResF0RLAD8WQ@mail.gmail.com>
References: <1425288555-22598-1-git-send-email-sfeldma@gmail.com>
	<1425288555-22598-3-git-send-email-sfeldma@gmail.com>
	<20150302.132015.1646795699731313510.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f50.google.com ([209.85.216.50]:39817 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880AbbCBW2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 17:28:55 -0500
Received: by mail-qa0-f50.google.com with SMTP id f12so25440365qad.9
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 14:28:55 -0800 (PST)
In-Reply-To: <20150302.132015.1646795699731313510.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 2, 2015 at 10:20 AM, David Miller <davem@davemloft.net> wrote:
> From: sfeldma@gmail.com
> Date: Mon,  2 Mar 2015 01:29:13 -0800
>
>> +     dev = netdev_switch_get_by_fib_dev(fi->fib_dev);
>  ...
>> +     dev = netdev_switch_get_by_fib_dev(fi->fib_dev);
>
> I really should get rid of the fib_dev define, it's always trouble.
>
> Routes can have multiple next hops, and when that is the case you
> cannot offload them to hardware in your initial implementation here.
>
> Next hops need to be iterated upon, and that currently can't be
> modelled with your abstration right now.

This gets into the issue of how to solve the case of a route with
nexthops devs not belonging to the same offload device.  So I think
you're right, and probably what we should do in the model for a first
pass is scan all the route's nh devs and make sure the devs have the
same switch_id before calling into the driver.  We have everything to
do this; I think I was punting on ECMP for this first pass to get
something out for L3, even if it was single-path.

I can revisit this for v3, but keep rocker single-path, or I can do
all for v3 and add the ECMP support to rocker.  I'm inclined to do the
former, so we can take this one step at a time.

> I also don't see you testing properly for
> net->ipv4.fib_has_custom_rules,
>
> Oh, I see, that happens in patch #4.  Please make that logic present
> from the very beginning.

Ok, I'll shuffle things around for v3.

> If you see a multi-nexthop route, for this initial implementation,
> you will need to uninstall all routes from the hardware.

I don't follow that?  In this initial implementation, rocker rejects
ECMP routes, returning -EOPNTOSUPP, but the route is still installed
in the kernel.  I'm not seeing why we'd need to uninstall from hw all
the single-path routes.

-scott
