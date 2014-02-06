From: Cong Wang <cwang@twopensource.com>
Subject: Re: Fw: [Bug 70071] New: Sending netconsole messages over a bridged
 network interface doesn't work anymore
Date: Wed, 5 Feb 2014 21:05:24 -0800
Message-ID: <CAHA+R7Pf1q7+xyqpwmGPToa0fTGn6dmukLvyncWwYAP-F_JvLg@mail.gmail.com>
References: <20140205141539.450095fa@samsung-9>
	<52F30863.7000206@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:57005 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704AbaBFFFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 00:05:25 -0500
Received: by mail-lb0-f174.google.com with SMTP id l4so1071948lbv.33
        for <netdev@vger.kernel.org>; Wed, 05 Feb 2014 21:05:24 -0800 (PST)
In-Reply-To: <52F30863.7000206@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 5, 2014 at 7:58 PM, Toshiaki Makita
<makita.toshiaki@lab.ntt.co.jp> wrote:
> (2014/02/06 6:15), Stephen Hemminger wrote:
>>
>>
>> Begin forwarded message:
>>
>> Date: Wed, 5 Feb 2014 04:36:03 -0800
>> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
>> To: "stephen@networkplumber.org" <stephen@networkplumber.org>
>> Subject: [Bug 70071] New: Sending netconsole messages over a bridged network interface doesn't work anymore
>
> Reverting this commit seems to fix the problem.
> 93d8bf9fb8f3 ("bridge: cleanup netpoll code")
>
> In the following code path, p->br->dev->npinfo is NULL at
> br_netpoll_enable() because __netpoll_setup() assigns ndev->npinfo after
> calling ndo_netpoll_setup().
>
>   __netpoll_setup() -> br_netpoll_setup() -> br_netpoll_enable()

Yeah, looks like we can just remove that incorrect 'if'.
Please test the following patch.

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index e4401a5..bb2b706 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -254,9 +254,6 @@ int br_netpoll_enable(struct net_bridge_port *p, gfp_t gfp)
        struct netpoll *np;
        int err;

-       if (!p->br->dev->npinfo)
-               return 0;
-
        np = kzalloc(sizeof(*p->np), gfp);
        if (!np)
                return -ENOMEM;
