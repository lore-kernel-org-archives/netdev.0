From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] netfilter: do not hold dev in ipt_CLUSTERIP
Date: Mon, 19 Jun 2017 19:08:37 +0200
Message-ID: <20170619170837.GA4763@salvia>
References: <cc6ebc3f8784d8d537737a1e18b443a2e0c7313a.1495271286.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>,
        netfilter-devel@vger.kernel.org, davem@davemloft.net, fw@strlen.de
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55252 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750913AbdFSRIm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Jun 2017 13:08:42 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 95D1E2E7848
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 19:08:31 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 855B38F48
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 19:08:31 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 56BB21850F
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 19:08:29 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <cc6ebc3f8784d8d537737a1e18b443a2e0c7313a.1495271286.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 20, 2017 at 05:08:06PM +0800, Xin Long wrote:
> It's a terrible thing to hold dev in iptables target. When the dev is
> being removed, unregister_netdevice has to wait for the dev to become
> free. dmesg will keep logging the err:
> 
>   kernel:unregister_netdevice: waiting for veth0_in to become free. \
>   Usage count = 1
> 
> until iptables rules with this target are removed manually.
> 
> The worse thing is when deleting a netns, a virtual nic will be deleted
> instead of reset to init_net in default_device_ops exit/exit_batch. As
> it is earlier than to flush the iptables rules in iptable_filter_net_ops
> exit, unregister_netdevice will block to wait for the nic to become free.
> 
> As unregister_netdevice is actually waiting for iptables rules flushing
> while iptables rules have to be flushed after unregister_netdevice. This
> 'dead lock' will cause unregister_netdevice to block there forever. As
> the netns is not available to operate at that moment, iptables rules can
> not even be flushed manually either.
> 
> The reproducer can be:
> 
>   # ip netns add test
>   # ip link add veth0_in type veth peer name veth0_out
>   # ip link set veth0_in netns test
>   # ip netns exec test ip link set lo up
>   # ip netns exec test ip link set veth0_in up
>   # ip netns exec test iptables -I INPUT -d 1.2.3.4 -i veth0_in -j \
>     CLUSTERIP --new --clustermac 89:d4:47:eb:9a:fa --total-nodes 3 \
>     --local-node 1 --hashmode sourceip-sourceport
>   # ip netns del test
> 
> This issue can be triggered by all virtual nics with ipt_CLUSTERIP.
> 
> This patch is to fix it by not holding dev in ipt_CLUSTERIP, but only
> save dev->ifindex instead of dev. When removing the mc from the dev,
> it will get dev by c->ifindex through dev_get_by_index.
> 
> Note that it doesn't save dev->name but dev->ifindex, as a dev->name
> can be changed, it will confuse ipt_CLUSTERIP.

Applied to nf-next.

This problem has been there since day 1, and it's a large patch, so I
prefer we follow nf-next path.

Thanks!
