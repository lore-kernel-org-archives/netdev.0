From: Lance Richardson <lrichard@redhat.com>
Subject: Re: [PATCH net] vxlan: eliminate cached dst leak
Date: Wed, 31 May 2017 11:48:19 -0400 (EDT)
Message-ID: <417842781.17409724.1496245699953.JavaMail.zimbra@redhat.com>
References: <20170529172557.7065-1-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: pabeni@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51536 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750898AbdEaPsW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 11:48:22 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6F5064E4D0
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 15:48:22 +0000 (UTC)
In-Reply-To: <20170529172557.7065-1-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: "Lance Richardson" <lrichard@redhat.com>
> To: netdev@vger.kernel.org, pabeni@redhat.com
> Sent: Monday, 29 May, 2017 1:25:57 PM
> Subject: [PATCH net] vxlan: eliminate cached dst leak
> 
> After commit 0c1d70af924b ("net: use dst_cache for vxlan device"),
> cached dst entries could be leaked when more than one remote was
> present for a given vxlan_fdb entry, causing subsequent netns
> operations to block indefinitely and "unregister_netdevice: waiting
> for lo to become free." messages to appear in the kernel log.
> 
> Fix by properly releasing cached dst and freeing resources in this
> case.
> 
> Fixes: commit 0c1d70af924b ("net: use dst_cache for vxlan device")
> Signed-off-by: Lance Richardson <lrichard@redhat.com>
> ---

This problem was originally debugged and the patch tested in an OpenStack
(devstack) test environment. Here's a small(-ish) reproducer script that
was cooked up after posting:

ip netns add ns0
ip netns add ns1
ip netns add ns2

ip link add p0 type veth peer name p1
ip link add p2 type veth peer name p3
ip link add p4 type veth peer name p5

ip link add name br0 type bridge
ip link set br0 up

ip link set p0 master br0 up
ip link set p1 netns ns0

ip link set p2 master br0 up
ip link set p3 netns ns1

ip link set p4 master br0 up
ip link set p5 netns ns2

ip netns exec ns0 ip addr add "1.1.1.1/24" dev p1
ip netns exec ns0 ip link set dev p1 up

ip netns exec ns1 ip addr add "1.1.1.2/24" dev p3
ip netns exec ns1 ip link set dev p3 up

ip netns exec ns2 ip addr add "1.1.1.3/24" dev p5
ip netns exec ns2 ip link set dev p5 up

ip netns exec ns0 ip link add vxlan0 type vxlan dstport 4789 id 10 dev p1
ip netns exec ns0 ip addr add "4.1.1.1/24" dev vxlan0
ip netns exec ns0 ip link set dev vxlan0 up mtu 1450

ip netns exec ns1 ip link add vxlan1 type vxlan dstport 4789 id 10 dev p3
ip netns exec ns1 ip addr add "4.1.1.2/24" dev vxlan1
ip netns exec ns1 ip link set dev vxlan1 up mtu 1450

ip netns exec ns2 ip link add vxlan2 type vxlan dstport 4789 id 10 dev p5
ip netns exec ns2 ip addr add "4.1.1.3/24" dev vxlan2
ip netns exec ns2 ip link set dev vxlan2 up mtu 1450

# Create a vxlan default fdb entry with two remotes in the list
ip netns exec ns0 bridge fdb append to 00:00:00:00:00:00 dst 1.1.1.2 dev vxlan0
ip netns exec ns0 bridge fdb append to 00:00:00:00:00:00 dst 1.1.1.3 dev vxlan0

# Forward some packets to populate dst cache for default fdb
ip netns exec ns0 ping -c 2 4.1.1.2
ip netns exec ns0 ping -c 2 4.1.1.3

# delete one of the entries in the fdb remotes list to trigger the bug
ip netns exec ns0 bridge fdb del to 00:00:00:00:00:00 dst 1.1.1.3 dev vxlan0

ip netns del ns2
ip netns del ns1
ip netns del ns0

# If bug is triggered, kernel messages similar to this should be logged:
#
#    kernel:unregister_netdevice: waiting for lo to become free. Usage count = 1
#
# Netns commands like "ip netns add ns3" will hang indefinitely.
