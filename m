From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v3 0/7] switchdev: add IPv4 routing offload
Date: Wed, 4 Mar 2015 20:50:28 -0800
Message-ID: <CAE4R7bDTV38bR2Oo2nfO6gFQQBhC4avmWdYeK_2sj1bqZWQiEg@mail.gmail.com>
References: <1425425520-34017-1-git-send-email-sfeldma@gmail.com>
	<20150304.003844.1400829201582760359.davem@davemloft.net>
	<CAE4R7bDBJye388V+itU9XqFNjruf0GcbXWFydx60fghiZp+NQw@mail.gmail.com>
	<20150304.160604.2259380248170644628.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:32807 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622AbbCEEu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 23:50:28 -0500
Received: by mail-qa0-f46.google.com with SMTP id n4so37399463qaq.5
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 20:50:28 -0800 (PST)
In-Reply-To: <20150304.160604.2259380248170644628.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 4, 2015 at 1:06 PM, David Miller <davem@davemloft.net> wrote:
>
> From: Scott Feldman <sfeldma@gmail.com>
> Date: Tue, 3 Mar 2015 23:28:06 -0800
>
> > On Tue, Mar 3, 2015 at 9:38 PM, David Miller <davem@davemloft.net> wrote:
> > In v3, the setting and clearing of RTNH_F_EXTERNAL moved to the
> > driver, the implementer of the add/del ndo ops.  So RTNH_F_EXTERNAL
> > does get cleared by the driver on fib_flush_external().  We could add
> > an additional clear above the driver, just in case the driver screwed
> > up and forgot to clear it.  Driver bug in that case; not sure where to
> > draw the line.
>
> I'd rather the state bit get managed by net/ipv4/*.c rather than
> duplicate this into every driver, that's error prone and duplicates
> logic unnecessarily.

That's the way it was in v2 :(

In v3, net/ipv4/*.c doesn't know if the driver skipped installing a
route to hw.  The driver returns 0 as if it was installed. So the
driver has to mark the ones actually installed.

This is why in v2 had return code -EOPNOTSUPP for routes that are
skipped by driver.  For example, rocker currently skips ECMP routes.
It's not an err condition.

But I see driver could skip and not skip the wrong combination of
routes such that we get a prefix split, for example.  We can't trust
driver.

I don't know what to do for v4.  Bummer, we got pretty close.  My only
ideas right now involve more code to handling unwinding some routes
from hw when related route fails to install to hw.

-scott
