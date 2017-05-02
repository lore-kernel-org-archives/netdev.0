From: gfree.wind@foxmail.com
Subject: [PATCH net v4 00/12] Fix possbile memleaks when fail to register_netdevice
Date: Tue,  2 May 2017 13:58:42 +0800
Message-ID: <cover.1493699451.git.gfree.wind@foxmail.com>
Cc: Gao Feng <gfree.wind@foxmail.com>
To: davem@davemloft.net, jiri@resnulli.us, mareklindner@neomailbox.ch,
        sw@simonwunderlich.de, a@unstable.cc, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg65.qq.com ([103.7.28.233]:36285 "EHLO smtpbg65.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750854AbdEBF7T (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 01:59:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@foxmail.com>

These following drivers allocate kinds of resources in its ndo_init
func, free some of them or all in the destructor func. Then there is
one memleak that some errors happen after register_netdevice invokes
the ndo_init callback. Because only the ndo_uninit callback is invoked
in the error handler of register_netdevice, but destructor not.

In my original approach, I tried to free the resources in the newlink
func when fail to register_netdevice, like destructor did except not
free the net_dev. This method is not good when destructor is changed,
and the memleak could be not fixed when there is no newlink callback.

Now create one new func used to free the resources in the destructor,
and the ndo_uninit func also could invokes it when fail to register
the net_device by comparing the dev->reg_state with NETREG_UNINITIALIZED.
If there is no existing ndo_uninit, just add one.

This solution doesn't only make sure free all resources in any case,
but also follows the original desgin that some resources could be kept
until the destructor executes normally after register the device
successfully.

Gao Feng (12):
  driver: dummy: Fix one possbile memleak when fail to
    register_netdevice
  driver: ifb: Fix one possbile memleak when fail to register_netdevice
  driver: loopback: Fix one possbile memleak when fail to
    register_netdevice
  driver: team: Fix one possbile memleak when fail to register_netdevice
  driver: veth: Fix one possbile memleak when fail to register_netdevice
  net: ip6_gre: Fix one possbile memleak when fail to register_netdevice
  ip6_tunnel: Fix one possbile memleak when fail to register_netdevice
  net: ip6_vti: Fix one possbile memleak when fail to register_netdevice
  net: ip_tunnel: Fix one possbile memleak when fail to
    register_netdevice
  net: sit: Fix one possbile memleak when fail to register_netdevice
  net: vlan: Fix one possbile memleak when fail to register_netdevice
  net: batman-adv: Fix one possbile memleak when fail to
    register_netdevice

 drivers/net/dummy.c             | 14 +++++++++++---
 drivers/net/ifb.c               | 33 +++++++++++++++++++++++----------
 drivers/net/loopback.c          | 15 ++++++++++++++-
 drivers/net/team/team.c         | 15 ++++++++++++---
 drivers/net/veth.c              | 15 ++++++++++++++-
 net/8021q/vlan_dev.c            | 17 +++++++++++++----
 net/batman-adv/soft-interface.c | 18 +++++++++++++++---
 net/ipv4/ip_tunnel.c            | 11 ++++++++++-
 net/ipv6/ip6_gre.c              | 17 +++++++++++++----
 net/ipv6/ip6_tunnel.c           | 11 ++++++++++-
 net/ipv6/ip6_vti.c              | 11 ++++++++++-
 net/ipv6/sit.c                  | 17 +++++++++++++----
 12 files changed, 158 insertions(+), 36 deletions(-)
