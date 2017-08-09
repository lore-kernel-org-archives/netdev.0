From: William Tu <u9012063@gmail.com>
Subject: [PATCH net-next] gre: introduce native tunnel support for ERSPAN
Date: Wed,  9 Aug 2017 13:22:36 -0700
Message-ID: <1502310157-7827-1-git-send-email-u9012063@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:34339 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751958AbdHIUXe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 16:23:34 -0400
Received: by mail-wm0-f48.google.com with SMTP id t138so16342243wmt.1
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 13:23:33 -0700 (PDT)
Received: from sc9-mailhost3.vmware.com ([208.91.1.34])
        by smtp.gmail.com with ESMTPSA id s3sm2459787edb.28.2017.08.09.13.23.30
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Aug 2017 13:23:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch adds ERSPAN type II tunnel support.  The implementation
is based on the draft at [1].  One of the purposes is for Linux
box to be able to receive ERSPAN monitoring traffic sent from
the Cisco switch, by creating a ERSPAN tunnel device.
In addition, the patch also adds ERSPAN TX, so traffic can 
also be encapsulated into ERSPAN and sent out.

The implementation reuses tunnel key as ERSPAN session ID, and 
field 'erspan' as ERSPAN Index fields:
./ip link add dev ers11 type erspan seq key 100 erspan 123 \
                        local 172.16.1.200 remote 172.16.1.100

[1] https://tools.ietf.org/html/draft-foschiano-erspan-01

The change to the iproute2 will be submitted in a separate patch.
I use the following script to create end-to-end ERSPAN tunnel test.

#!/bin/bash
# In the namespace NS0, create veth0 and erspan00
# Out of the namespace, create veth1 and erspan11
# Ping in and out of namespace using ERSPAN protocol 

# Namespace0:
# - erspan00 
# IP: 10.1.1.100
# local 192.16.1.100 remote 192.16.1.200
# - veth0
# IP: 172.16.1.100

# Out of namespace:
# - erspan11 
# IP: 10.1.1.200
# local 172.16.1.200 remote 172.16.1.100
# - veth1
# IP: 172.16.1.200

set -ex
TYPE=erspan
DEV_NS=erspan00
DEV=erspan11

cleanup() {
        set +ex
        ip netns del ns0 
        ip link del erspan11
        ip link del veth1
}

trap cleanup 0 2 3 9 

ip netns add ns0 
ip link add veth0 type veth peer name veth1
ip link set veth0 netns ns0
ip netns exec ns0 ip addr add 172.16.1.100/24 dev veth0
ip netns exec ns0 ip link set dev veth0 up

# Tunnel
ip netns exec ns0 ip link add dev $DEV_NS type $TYPE \
	key 1 seq local 172.16.1.100 remote 172.16.1.200 erspan 123 
ip netns exec ns0 ip addr add dev $DEV_NS 10.1.1.100/24
ip netns exec ns0 ip link set dev $DEV_NS up

# Linux
ip link set dev veth1 up
ip addr add dev veth1 172.16.1.200/24
ip link add dev $DEV type $TYPE seq key 1 \
	local 172.16.1.200 remote 172.16.1.100 erspan 123

ip addr add dev $DEV 10.1.1.200/24
ip link set dev $DEV up

# Ping from NS0
ip netns exec ns0 ping -c 3 10.1.1.200
ping -c 3 10.1.1.100
exit 0
# End

Thanks a lot!

William Tu (1):
  gre: introduce native tunnel support for ERSPAN

 include/net/ip_tunnels.h       |   3 +
 include/uapi/linux/if_ether.h  |   1 +
 include/uapi/linux/if_tunnel.h |   1 +
 net/ipv4/ip_gre.c              | 248 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 253 insertions(+)

-- 
2.7.4
