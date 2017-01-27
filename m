From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: loopback device reference count leakage
Date: Thu, 26 Jan 2017 17:01:38 -0800
Message-ID: <CAM_iQpWJmXnsZ4D870aEZ+HL3pfaZU3HyunyxnhG9=EHS0Tcdg@mail.gmail.com>
References: <BY1PR17MB0101922AF9444B40E31B3B3CA1750@BY1PR17MB0101.namprd17.prod.outlook.com>
 <CAM_iQpXQ5MyL_KYNctZuZLv_w-ai3pmXKswOLXYeEYmVBdQqJA@mail.gmail.com> <CO2PR17MB01050D56F6EE3C8D54B00CAAA1770@CO2PR17MB0105.namprd17.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Kaiwen Xu <kevin@kevxu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35648 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750749AbdA0BDN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 20:03:13 -0500
Received: by mail-wm0-f65.google.com with SMTP id d140so54671762wmd.2
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 17:02:00 -0800 (PST)
In-Reply-To: <CO2PR17MB01050D56F6EE3C8D54B00CAAA1770@CO2PR17MB0105.namprd17.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 26, 2017 at 2:51 PM, Kaiwen Xu <kevin@kevxu.net> wrote:
> Hi Cong,
>
> I tested out your patch, it does seem to be preventing the issue from
> happening. Here are the dev_put/dev_hold() calls with your patch
> applied.

Good. Now we narrow down the bug to those dst's referring loopback_dev.


> However, what confuses me is that when the issue didn't occur, there
> were always multiple dst_ifdown() calls at the end continuously holding
> and releasing the loopback device reference count (sometimes it will be
> looping for about a minute), until the last dst_destroy() happens. E.g.
>
> Jan 11 16:14:59 <hostname> kernel: [ 2033.429563] lo: dev_hold 2 dst_ifdown
> Jan 11 16:14:59 <hostname> kernel: [ 2033.429565] lo: dev_put 2 dst_ifdown
> Jan 11 16:15:00 <hostname> kernel: [ 2034.453484] lo: dev_hold 2 dst_ifdown
> Jan 11 16:15:00 <hostname> kernel: [ 2034.453487] lo: dev_put 2 dst_ifdown
>
> (this continues...)
>
> Jan 11 16:15:01 <hostname> kernel: [ 2035.129452] lo: dev_put 1 dst_destroy
>
> And when the issue did occur, the last dst_destroy() call never occurs.

Yeah, I noticed that too. So we have two cases here:

1) If these dst's (referring to loopback_dev) really need to stay in
GC for a long
time, then we should really just releasing loopback references as what my patch
does.

2) If they don't not, that is, if they are supposed to be GC'ed soon
in this case,
then we should investigate why they are still there.

2) seems more likely than 1), because at the point when loopback device is
being unregistered, the whole network namespace is being gone, all other
devices are already gone, no one should a take reference to this netns,
therefore no one should take a reference to any dst referring to any device
in it too, even though the dst GC is global.

I'd suggest to you add some debugging printk's to the dst refcount functions,
or maybe just inside dst_gc_task(). I think the last dst referring to
the loopback
dev is still being referred at that point, which prevents GC from destroying it.

Meanwhile, if it would be also helpful if you can share how you managed to
reproduce this reliably, I saw this bug in our data center before but never
know how to reproduce it.

Thanks!
