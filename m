From: David Ahern <dsahern@gmail.com>
Subject: RFH: problems with adjacency graph
Date: Mon, 10 Oct 2016 20:18:52 -0600
Message-ID: <7e8a1f21-3227-e27b-7bb7-42fbf49c38ed@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>, vfalico@gmail.com,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:33817 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753106AbcJKCTF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2016 22:19:05 -0400
Received: by mail-pa0-f67.google.com with SMTP id r9so565431paz.1
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2016 19:18:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri / Veaceslav:

As author's of the adjacency tracking code in dev.c I am hoping you can help with suggested patches for a couple of problems. The start point needs to include commit 93409033ae65 which resolved a different problem from what I am seeing now.

At the moment I have 2 cases both for this topology:
        +--------+
        |  myvrf |
        +--------+
          |    |
          |  +---------+
          |  | macvlan |
          |  +---------+
          |    |
      +----------+
      |  bridge  |
      +----------+
          |
      +--------+
      | bond0  |
      +--------+
          |
      +--------+
      |  eth3  |
      +--------+


Base set of commands for both cases:

ip link add bond1 type bond
ip link set bond1 up
ip link set eth3 down
ip link set eth3 master bond1
ip link set eth3 up

ip link add bridge type bridge
ip link set bridge up
ip link add macvlan link bridge type macvlan
ip link set macvlan up

ip link add myvrf type vrf table 1234
ip link set myvrf up

ip link set bridge master myvrf


############################################################
# case 1

ip link set macvlan master myvrf
ip link set bond1 master bridge

ip link delete myvrf

dmesg has a splat triggered in __netdev_adjacent_dev_remove() where you currently see the BUG(). If you convert that to a WARN_ON (which it should be, no need to panic on the remove path) it will show you 4 missing adjacencies: eth3 - myvrf, mvrf - eth3, bond1 - myvrf and myvrf - bond1. All of those are because the dev_link function does not link macvlan lower devices to myvrf when it is enslaved. (Enable the debugging to see that those messages are missing.)



############################################################
# case 2

This case just flips the ordering of the enslavements:

ip link set bond1 master bridge
ip link set macvlan master myvrf

Then run:
ip link delete bond1
ip link delete myvrf

The last command hangs because myvrf has a reference that has not been released. If you do not have commit 93409033ae65 the delete of bond1 hangs for the same reason. For this case, the debug messages show that the macvlan lower devices (eth3 and bond1) are connected to myvrf on the enslavement, but the link delete the path only removes one of them hence the unreleased refcnt on myvrf.


In the end it seems that the code for the dependency graph is not making the complete mesh which causes problems on the tear down. I have attempted a few changes that so far fix 1 problem and uncover a different one. Hence the request for help from the author's of this code.

It seems like the complete mesh is not really needed, but cscope shows spectrum, ixgbe and bonding all using the for_each upper and lower device macros.

Suggestions?

David
