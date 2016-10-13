From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 00/11] net: Fix netdev adjacency tracking
Date: Thu, 13 Oct 2016 09:34:24 +0200
Message-ID: <20161013073424.GB1816@nanopsycho.orion>
References: <1476305519-28833-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net,
        dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, linux-rdma@vger.kernel.org,
        j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:35277 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750926AbcJMHe3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 03:34:29 -0400
Received: by mail-lf0-f66.google.com with SMTP id x79so11208401lff.2
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 00:34:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1476305519-28833-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 12, 2016 at 10:51:48PM CEST, dsa@cumulusnetworks.com wrote:
>The netdev adjacency tracking is failing to create proper dependencies
>for some topologies. For example this topology
>
>        +--------+
>        |  myvrf |
>        +--------+
>          |    |
>          |  +---------+
>          |  | macvlan |
>          |  +---------+
>          |    |
>      +----------+
>      |  bridge  |
>      +----------+
>          |
>      +--------+
>      | bond0  |
>      +--------+
>          |
>      +--------+
>      |  eth3  |
>      +--------+
>
>hits 1 of 2 problems depending on the order of enslavement. The base set of
>commands for both cases:
>
>    ip link add bond1 type bond
>    ip link set bond1 up
>    ip link set eth3 down
>    ip link set eth3 master bond1
>    ip link set eth3 up
>
>    ip link add bridge type bridge
>    ip link set bridge up
>    ip link add macvlan link bridge type macvlan
>    ip link set macvlan up
>
>    ip link add myvrf type vrf table 1234
>    ip link set myvrf up
>
>    ip link set bridge master myvrf
>
>Case 1 enslave macvlan to the vrf before enslaving the bond to the bridge:
>
>    ip link set macvlan master myvrf
>    ip link set bond1 master bridge
>
>Attempts to delete the VRF:
>    ip link delete myvrf
>
>trigger the BUG in __netdev_adjacent_dev_remove:
>
>[  587.405260] tried to remove device eth3 from myvrf
>[  587.407269] ------------[ cut here ]------------
>[  587.408918] kernel BUG at /home/dsa/kernel.git/net/core/dev.c:5661!
>[  587.411113] invalid opcode: 0000 [#1] SMP
>[  587.412454] Modules linked in: macvlan bridge stp llc bonding vrf
>[  587.414765] CPU: 0 PID: 726 Comm: ip Not tainted 4.8.0+ #109
>[  587.416766] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
>[  587.420241] task: ffff88013ab6eec0 task.stack: ffffc90000628000
>[  587.422163] RIP: 0010:[<ffffffff813cef03>]  [<ffffffff813cef03>] __netdev_adjacent_dev_remove+0x40/0x12c
>...
>[  587.446053] Call Trace:
>[  587.446424]  [<ffffffff813d1542>] __netdev_adjacent_dev_unlink+0x20/0x3c
>[  587.447390]  [<ffffffff813d16a3>] netdev_upper_dev_unlink+0xfa/0x15e
>[  587.448297]  [<ffffffffa00003a3>] vrf_del_slave+0x13/0x2a [vrf]
>[  587.449153]  [<ffffffffa00004a4>] vrf_dev_uninit+0xea/0x114 [vrf]
>[  587.450036]  [<ffffffff813d19b0>] rollback_registered_many+0x22b/0x2da
>[  587.450974]  [<ffffffff813d1aac>] unregister_netdevice_many+0x17/0x48
>[  587.451903]  [<ffffffff813de444>] rtnl_delete_link+0x3c/0x43
>[  587.452719]  [<ffffffff813dedcd>] rtnl_dellink+0x180/0x194
>
>When the BUG is converted to a WARN_ON it shows 4 missing adjacencies:
>  eth3 - myvrf, mvrf - eth3, bond1 - myvrf and myvrf - bond1
>
>All of those are because the __netdev_upper_dev_link function does not
>properly link macvlan lower devices to myvrf when it is enslaved.
>
>The second case just flips the ordering of the enslavements:
>    ip link set bond1 master bridge
>    ip link set macvlan master myvrf
>
>Then run:
>    ip link delete bond1
>    ip link delete myvrf
>
>The vrf delete command hangs because myvrf has a reference that has not
>been released. In this case the removal code does not account for 2 paths 
>between eth3 and myvrf - one from bridge to vrf and the other through the
>macvlan.
>
>Rather than try to maintain a linked list of all upper and lower devices
>per netdevice, only track the direct neighbors. The remaining stack can
>be determined by recursively walking the neighbors.

Although I didn't like the "all-list" idea when Veaceslav pushed it
because it looked to me like a big hammer, it turned out to be very handy
and quick for traversing neighbours. Why it cannot be fixed?

The walks with possibly hundreds of function calls instead of a single
list traverse worries me.
