From: Ahmed Amamou <ahmed@gandi.net>
Subject: [PATCH RFC v2 00/21] TRILL implementation
Date: Tue,  1 Sep 2015 17:42:55 +0200
Message-ID: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: William Dauchy <william@gandi.net>, Ahmed Amamou <ahmed@gandi.net>,
	=?UTF-8?q?Fran=C3=A7ois=20Cachereul?= <f.cachereul@alphalink.fr>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:40553 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752761AbbIAPxm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 11:53:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We have been working on a TRILL implementation in the Linux kernel for =
some
time now. We have sent a first RFC a year ago (already!) and we are bac=
k
with a second version; this time we will try to update more quicly acco=
rding
to the comments.
The code has been pushed here https://github.com/Gandi/ktrill.git in th=
e devel
branch (be careful this branch is constantly rebased!)
Attached a series of patch as a second request for comment. The code is
not perfect and probably still lacks of improvements.
It's a second request of comment in order to get some feedbacks. This c=
ode has been
tested for some time now.

These patch tries to implement TRILL protocol RFC 6325.
As a first implementation, some RFC details are still not implemented.

In order to test these patches please follow the instruction:
download quagga (userland) from here https://github.com/Gandi/quagga.gi=
t
compile it using these options

=2E/bootstrap.sh && ./configure --localstatedir=3D/var/run/quagga \
--enable-isisd --enable-trilld --enable-trilld-monitoring --disable-ipv=
6 \
--disable-ospfd --disable-ospfclient --disable-ripd --disable-babeld \
--disable-bgpd && make && make install

start zebra and trilld
$ zebra -f $ZEBRA_CONF -P 2121 -u quagga -d
$ trilld -f $TRILLD_CONF -P 2021 -u quagga -d

Configuration sample can be found here
https://github.com/Gandi/quagga/blob/dev_trill/zebra/zebra.conf.sample
and here https://github.com/Gandi/quagga/blob/dev_trill/isisd/trilld.co=
nf.sample

=46inally you need to correctly configure bridge port
=46or access port (native frames)
echo 4 > /sys/class/net/<INTERFACE>/brport/trill_state
=46or trunk port (trill frame and control frames)
echo 8 > /sys/class/net/<INTERFACE>/brport/trill_state
more detail can be found here: https://github.com/Gandi/ktrill/wiki
NB: for port state github version has different flags as we did not tak=
e
into consideration all port flag when implementing it

---
Changes in V2:
- rebase on v4.2 tag
- replace genl netlink by rtnetlink
- each port will either have TRILL or bridge packet handler
  deponding on bridge status in version 0 all port used to
  have a unique handler that fallback to bridge handler if
  trill is not enabled
- remove usesless locks
- remove all format errors
- handle TRILL packets within packet split process


Ahmed Amamou (19):
  net: rbridge: add trill frame description
  net: rbridge: add RBridge structure
  net: rbridge: add CONFIG_TRILL
  net: rbridge: adapt Bridge structure
  net: rbridge: enable/disable TRILL capability
  net: rbridge: add sysfs for trill_state
  net: rbridge: get Rbridge nickname from daemon
  net: rbridge: add elected dtroot
  net: rbridge: add rbr_node management function
  net: rbridge: clean up rbr_node on rbridge stop
  net: rbridge: update node table
  net: rbridge: add basic trill frame handling function
  net: rbridge: update forwarding database
  net: rbridge: add test on trill flag before flood
  net: rbridge: add encapsulation process
  net: rbridge: add receive function
  net: rbridge: add rbr_fwd
  net: rbridge: add rbr_multidest_fwd
  net: rbridge: replace net_port rx_handler

=46ran=C3=A7ois Cachereul (1):
  net: rbridge: add layer 2 IS-IS Ethertype

William Dauchy (1):
  net: handle packet split for trill

 include/linux/etherdevice.h   |  17 +
 include/net/if_trill.h        |  88 ++++++
 include/uapi/linux/if_ether.h |   2 +
 include/uapi/linux/if_link.h  |   6 +
 net/bridge/Kconfig            |   8 +
 net/bridge/Makefile           |   2 +
 net/bridge/br_fdb.c           |  41 +++
 net/bridge/br_forward.c       |  37 ++-
 net/bridge/br_if.c            |   7 +-
 net/bridge/br_netlink.c       |  10 +-
 net/bridge/br_private.h       |  53 ++++
 net/bridge/br_sysfs_br.c      |  38 +++
 net/bridge/br_sysfs_if.c      |  26 ++
 net/bridge/rbr.c              | 718 ++++++++++++++++++++++++++++++++++=
++++++++
 net/bridge/rbr_private.h      |  85 +++++
 net/bridge/rbr_rtnetlink.c    |  93 ++++++
 net/core/flow_dissector.c     |  31 ++
 17 files changed, 1259 insertions(+), 3 deletions(-)
 create mode 100644 include/net/if_trill.h
 create mode 100644 net/bridge/rbr.c
 create mode 100644 net/bridge/rbr_private.h
 create mode 100644 net/bridge/rbr_rtnetlink.c

--=20
2.1.4
