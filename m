From: zhou zhengwu <zhouzhengwu@huawei.com>
Subject: [BUG] LACP state machine will find nothing and do nothing when link
 is single passing
Date: Thu, 16 Feb 2017 17:20:38 +0800
Message-ID: <fcacaf54-5f4e-fd6e-d00c-9de7e74d26f4@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:58513 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752969AbdBPJUr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 04:20:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

[1]Problem description:
    ServerA [bond] ----------- [bond] ServerB
    I have two servers which connected with bonding interfaces LACP 
enabled. Two bonding interfaces are configured like following:
    insmod ./bonding.ko mode=4 lacp_rate=1 all_slaves_active=1
    echo +trunk1 > /sys/class/net/bonding_masters
    echo +eth0 > /sys/class/net/trunk1/bonding/slaves
    echo +eth1 > /sys/class/net/trunk1/bonding/slaves

    Firstly, it works well.
    Then, one port (for example, eth0) in serverB failed, it can just 
send but not receive packets, however it still is UP.
    Result:
    In serverB, lcap is work well.
    While In serverA, eth0 connecting with eth0 in serverB is in the 
same lacp aggregator with eth1 and traffic is still sent through it.

[2]From the lacp implementation, we can see:
    In above condition, eth0 in server A will receive lacpdu which show 
that AD_STATE_SYNCHRONIZATION is unset in actor_state to indicate there 
is something wrong in eth0 of server B. However, our implementation of 
lacp will just check the port parameters and not check the port state.
If the peer port state changes, local lacp state machine will not find 
which will cause the lacp state machine works wrong.
