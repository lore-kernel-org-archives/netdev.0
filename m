From: Nikolay Borisov <kernel@kyup.com>
Subject: ipv6 not bringing up due to qdisc_tx_is_noop failing
Date: Wed, 16 Mar 2016 17:29:46 +0200
Message-ID: <56E97BEA.4070004@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	SiteGround Operations <operations@siteground.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:34042 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935110AbcCPP3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 11:29:50 -0400
Received: by mail-wm0-f45.google.com with SMTP id p65so195337119wmp.1
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 08:29:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

I've been chasing a rather strange problem and I saw you were the person
that authored most of the code involved so I'm addresing you, but will
be happy to receive assistance from any one feeling knowledgeable enough
on the issue.

Basically I have an infiniband card on which I want to run ipv6 to this
effect I load modules ib_qib (the infiniband card is qlogic QLE7342) and
then I load module ib_ipoib and I get :
IPv6: ADDRCONF(NETDEV_UP): ib0: link is not ready

even though for example ibping and all that works. This happens because
the check if (!addrconf_qdisc_ok(dev)) in addrconf_notify fails, since
the dev's txq ->qdisc points to noop_qdisc.

Now, here is what happens :

1. When the ib_ipoib module is loaded
register_netdevice->dev_init_scheduler is called which sets the device's
qdisc to noop_qdisc

2. Then via a netlink message the device is being activate, which calls
into dev_activate->attach_one_default_qdisc which attaches the newly
created default qdisc to the dev->sleeping_qdisc member

3. The addrconf_notify is invoked which fails the check since the
netdev_queue's qdisk member was never updated (just the sleeping_qdisc)
to anything different than the initial state (which is noop_qdisc).

I have stack traces which do show this sequence of events, so my
questions now are:

1. What's the difference between netdev_queue->qdisc and
netdev_queue->qdisc_sleeping. Git blaming indicates those member haves
existed even before the git history was started.

2. Shouldn't the netdev_queue->qdisc also be updated during
attach_one_default_qdisc?


Regards,
Nikolay
