From: Michal Soltys <soltys@ziu.info>
Subject: vlan aware bridge doesn't propagate mac changes to vlans on top of it
Date: Tue, 6 Sep 2016 23:59:19 +0200
Message-ID: <d8cc158b-8b3b-17eb-91cc-7a46d7fc011e@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:34660 "EHLO drutsystem.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755264AbcIFV71 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Sep 2016 17:59:27 -0400
Received: from [10.0.0.2] (89-65-85-89.dynamic.chello.pl [89.65.85.89])
        (Authenticated sender: nozo)
        by drutsystem.com (Postfix) with ESMTPA id 3114FD22E9
        for <netdev@vger.kernel.org>; Tue,  6 Sep 2016 23:59:19 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consider following scenario:

- create vlan aware bridge (say br0)
- setup br0's vlans, e.g.

bridge vlan add dev br0 vid 10 self

This will add necessary fdb entries directing appropriate traffic to the
bridge itself.

- create appropriate vlan interfaces on top of it, for example:

ip li add link br0 name br0.10 type vlan id 10
ip add add 10.0.0.1/8 dev br0.10 ....

This will add vlan devices on top of br0 and *inherit br0's mac address*.

- now after all of the above is done

ip li set eth0 master br0

This will attach interface eth0 to the bridge. With this being the first
interface attached, br0 will take it's mac address as its own. Any
further changes to br0's ports may cause the same, with the lowest mac
address of some port becoming br0's mac.

This will update fdb entries as well, but all vlan interfaces on top of
br0 (e.g. br0.10) will be using old mac address from the time when vlan
was created.

The side effect of it is that any traffic addressed to such interface
will be flooded to all ports (and br0 itself).

The only workaround I found is to either manually update mac addresses
with 'ip' or recreate vlans (bridge fdb refused to update relevant entries).

But if br0's mac changes due to some port changes - shouldn't it be
somehow propagated automatically to vlans created on top of it ?
