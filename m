From: Serhey Popovych <serhe.popovych@gmail.com>
Subject: [PATCH 0/3] dev: Fix network device ifindex allocation
Date: Fri, 16 Jun 2017 17:23:50 +0300
Message-ID: <cover.1497621810.git.serhe.popovych@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:34792 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753832AbdFPOYU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 10:24:20 -0400
Received: by mail-lf0-f66.google.com with SMTP id o28so4382765lfk.1
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 07:24:20 -0700 (PDT)
Received: from tuxracer.synapse.com ([195.238.92.77])
        by smtp.gmail.com with ESMTPSA id z10sm486566lja.6.2017.06.16.07.24.18
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 07:24:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some problems with network device ifindex handling in
the core and veth driver.

* Network device index (ifindex) is signed int, but only values > 0
  consodered to be valid. However it is possible for userspace
  to supply negative ifindex value using following command:

    # ip link add dev dummy2 index -100 up type dummy
    # ip link sh dev dummy2
    Device "dummy2" does not exist.
    # ip li sh |tail -n2
    -100: dummy2: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue \
    state UNKNOWN mode DEFAULT group default
        link/ether 7e:77:1b:49:50:de brd ff:ff:ff:ff:ff:ff

* It is possible to hit infinite loop when number of ifindex in
  some network namespace get exchausted.

	# There should be plenty of RAM to create INT_MAX netdev.
	# Hitting OOM is much likely with such huge number, but anyway.
	for ((i = 1; i <= 0x7fffffff; i++)); do
		ifname="dummy$i";
		[ ! -d "/sys/class/net/$ifname" ] || continue
		ip link add dev "$ifname" index "$i" type dummy
	done

* (minor) check for dev->ifindex being greater than zero.

Patches in this series tries to address these problems.

Serhey Popovych (3):
  dev: Prevent creating network devices with negative ifindex
  dev: Avoid infinite loop on network device index exhaustion
  veth: Set ifindex only if given and not negative

 drivers/net/veth.c |  2 +-
 net/core/dev.c     | 30 ++++++++++++++++++++++--------
 2 files changed, 23 insertions(+), 9 deletions(-)

-- 
1.8.3.1
