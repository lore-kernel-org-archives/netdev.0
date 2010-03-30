From: James Chapman <jchapman@katalix.com>
Subject: [PATCH v3 00/12] l2tp: Introduce L2TPv3 support
Date: Tue, 30 Mar 2010 17:17:25 +0100
Message-ID: <20100330161725.9628.69994.stgit@bert.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:49324 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751409Ab0C3QRM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Mar 2010 12:17:12 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.katalix.com (Postfix) with ESMTP id 591C8A620AC
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 17:17:31 +0100 (BST)
Received: from mail.katalix.com ([127.0.0.1])
	by localhost (mail.katalix.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id A9LBoX8eRxZd for <netdev@vger.kernel.org>;
	Tue, 30 Mar 2010 17:17:25 +0100 (BST)
Received: from bert.katalix.com (localhost.localdomain [127.0.0.1])
	by mail.katalix.com (Postfix) with ESMTP id A96F0A62087
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 17:17:25 +0100 (BST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds L2TPv3 support. It splits the existing pppol2tp
driver to separate its L2TP and PPP parts, then adds new L2TPv3
functionality. The patches implement a new socket family for L2TPv3 IP
encapsulation, expose virtual netdevices for each L2TPv3 ethernet
pseudowire and add a netlink interface.

The following drivers are provided:-

l2tp_core    - L2TP driver core. Always required.
l2tp_ppp     - L2TP PPP (PPPoL2TP). L2TPv2 and L2TPv3.
l2tp_eth     - L2TPv3 ethernet pseudowire.
l2tp_ip      - L2TPv3 IP encapsulation.
l2tp_netlink - L2TPv3 netlink API.

The combination of l2tp_core and l2tp_ppp provides
backwards-compatible L2TPv2 pppol2tp functionality. Userspace L2TPv2
applications using the existing pppol2tp driver should not need to
change.

The implementation is as I described in a previous posting to netdev,
archived at
http://marc.info/?l=linux-netdev&m=120845482320143&w=4. Unfortunately,
splitting the existing pppol2tp driver into l2tp_core and l2tp_ppp
makes the changes difficult to review. The split is needed to separate
PPP from L2TP, since in L2TPv3, protocols other than PPP can be
carried. I have organised the patches so that the split is done first,
with new features added in separate patches.

Relevant RFCs are:-
- http://www.ietf.org/rfc/rfc3931.txt (L2TPv3)
- http://www.ietf.org/rfc/rfc4719.txt (L2TPv3 ethernet pseudowire)

A patchset is available to iproute2 which adds a number of commands
for unmanaged L2TPv3 tunnels. This will be submitted separately.

TODO:-
- Add IP pseudowires. These carry only IP frames (no L2 header).
- Add VLAN pseudowires.
- Add L2TP tunnel switching.
- Add ATM pseudowires - RFC3355 and RFC4454.

Signed-off-by: James Chapman <jchapman@katalix.com>
Reviewed-by: Randy Dunlap <randy.dunlap@oracle.com>

---

Changelog:-

v3 (this version)

- Use hash_32() instead of hash_long() for better efficiency on 64-bit
  archs (Eric Dumazet)

- Add missing setting of sk->sk_no_check for the case when creating
  kernel socket for the unmanaged tunnel case. (Eric Dumazet)

- Fix a dev_put leak for the case when user creates an ethernet
  pseudowire with a specific device name and a device with that name
  already exists. (Eric Dumazet)

- Use dev_forward_skb() in receive path of l2tp_eth driver.

v2 (29-mar-2010)

- Fix compile error when CONFIG_COMPAT is defined. Since l2tp_ip is
  not a UDP socket, use compat_ip_[gs]etsockopt directly instead of
  config_udp_[gs]etsockopt. (David Miller)

- Fix whitespace issues found by
  git apply --check --whitespace=error-all (David Miller)

James Chapman (12):
      l2tp: Relocate pppol2tp driver to new net/l2tp directory
      l2tp: Split pppol2tp patch into separate l2tp and ppp parts
      ppp: Add ppp_dev_name() exported function
      l2tp: Add ppp device name to L2TP ppp session data
      l2tp: Add L2TPv3 protocol support
      l2tp: Update PPP-over-L2TP driver to work over L2TPv3
      l2tp: Add L2TPv3 IP encapsulation (no UDP) support
      netlink: Export genl_lock() API for use by modules
      l2tp: Add netlink control API for L2TP
      l2tp: Add L2TP ethernet pseudowire support
      l2tp: Add support for static unmanaged L2TPv3 tunnels
      l2tp: Update documentation



 Documentation/networking/l2tp.txt |  233 +++
 drivers/net/Kconfig               |    7 
 drivers/net/Makefile              |    2 
 drivers/net/ppp_generic.c         |   19 
 drivers/net/pppol2tp.c            | 2680 -------------------------------------
 include/linux/genetlink.h         |    8 
 include/linux/if_pppol2tp.h       |   16 
 include/linux/if_pppox.h          |    9 
 include/linux/l2tp.h              |  164 ++
 include/linux/ppp_channel.h       |    3 
 net/Kconfig                       |    1 
 net/Makefile                      |    1 
 net/l2tp/Kconfig                  |   94 +
 net/l2tp/Makefile                 |   11 
 net/l2tp/l2tp_core.c              | 2016 ++++++++++++++++++++++++++++
 net/l2tp/l2tp_core.h              |  306 ++++
 net/l2tp/l2tp_eth.c               |  371 +++++
 net/l2tp/l2tp_ip.c                |  679 +++++++++
 net/l2tp/l2tp_netlink.c           |  844 ++++++++++++
 net/l2tp/l2tp_ppp.c               | 1602 ++++++++++++++++++++++
 net/netlink/genetlink.c           |    6 
 21 files changed, 6348 insertions(+), 2724 deletions(-)
 delete mode 100644 drivers/net/pppol2tp.c
 create mode 100644 include/linux/l2tp.h
 create mode 100644 net/l2tp/Kconfig
 create mode 100644 net/l2tp/Makefile
 create mode 100644 net/l2tp/l2tp_core.c
 create mode 100644 net/l2tp/l2tp_core.h
 create mode 100644 net/l2tp/l2tp_eth.c
 create mode 100644 net/l2tp/l2tp_ip.c
 create mode 100644 net/l2tp/l2tp_netlink.c
 create mode 100644 net/l2tp/l2tp_ppp.c



