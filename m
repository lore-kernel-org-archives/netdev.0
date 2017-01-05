From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Avoid NULL pointer dereference in tg3_get_nstats()
Date: Thu, 05 Jan 2017 15:17:05 -0500 (EST)
Message-ID: <20170105.151705.2187713228201334532.davem@davemloft.net>
References: <1483625601-10552-1-git-send-email-wangyufen@huawei.com>
        <20170105.123337.2237827308340782208.davem@davemloft.net>
        <CACKFLimPkD6hxECA+ZhH+7BVmVSoJ1GfAMZyJ7S50CbhiuC0mA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangyufen@huawei.com, siva.kallam@broadcom.com,
        prashant@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49406 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753722AbdAEURI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 15:17:08 -0500
In-Reply-To: <CACKFLimPkD6hxECA+ZhH+7BVmVSoJ1GfAMZyJ7S50CbhiuC0mA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Thu, 5 Jan 2017 12:04:13 -0800

> But it looks like ndo_get_stats() can be called without rtnl lock from
> net-procfs.c.  So it is possible that we'll read tp->hw_stats after it
> has been freed.  For example, if we are reading /proc/net/dev and
> closing tg3 at the same time.  David, is not taking rtnl_lock in
> net-procfs.c by design?

Probably not, that dev_get_stats() call probably should be surrounded
by RTNL protection.

Doing a quick grep on dev_get_stats() shows other call sites, most of
which are using it to fetch slave device statistics from the get stats
method of the parent.  Which should be ok.

It appears that the vlan procfs code in net/8021q/vlanproc.c has a
similar bug as net/core/net-procfs.c

Maybe net/core/net-sysfs.c has the same issue as well, and perhaps also
net/openvswitch/vport.c:ovs_vport_get_stats().
