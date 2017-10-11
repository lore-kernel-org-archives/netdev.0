From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] veth: tweak creation of veth device
Date: Wed, 11 Oct 2017 15:17:06 -0700 (PDT)
Message-ID: <20171011.151706.1844884518098480593.davem@davemloft.net>
References: <1507666124-8780-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org
To: mrv@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37964 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750848AbdJKWRH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 18:17:07 -0400
In-Reply-To: <1507666124-8780-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Mashak <mrv@mojatatu.com>
Date: Tue, 10 Oct 2017 16:08:44 -0400

> When creating veth pair, at first rtnl_new_link() creates veth_dev, i.e.
> one end of the veth pipe, but not registers it; then veth_newlink() gets
> invoked, where peer dev is created _and_ registered, followed by veth_dev
> registration, which may fail if peer information, that is VETH_INFO_PEER
> attribute, has not been provided and the kernel will allocate unique veth
> name.
> 
> So, we should ask the kernel to allocate unique name for veth_dev only
> when peer info is not available.
> 
> Example:
> 
> % ip link dev veth0 type veth
> RTNETLINK answers: File exists
> 
> After fix:
> % ip link dev veth0 type veth
> % ip link show dev veth0
> 5: veth0@veth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
>     link/ether f6:ef:8b:96:f4:ec brd ff:ff:ff:ff:ff:ff
> %
> 
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>

I'm not so sure about this.

If we specify an explicit tb[IFLA_NAME], we shouldn't completely ignore that
request from the user just because they didn't give any peer information.

I see what happens in this case, the peer gets 'veth0' and then since
the user asked for 'veth0' for the non-peer it conflicts.

Well, too bad.  The user must work to orchestrate things such that
this doesn't happen.  That means either providing the IFLA_NAME for
both the peer and the non-peer, or specifying neither.

I'm not applying this, sorry.
