From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/6] net: dsa: push switchdev prepare phase in FDB ops
Date: Wed,  7 Oct 2015 19:48:25 -0400
Message-ID: <1444261711-1829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset pushes the switchdev prepare phase for the FDB add and de=
l
operations down to the DSA drivers. Currently only mv88e6xxx is affecte=
d.

Since the dump requires a bit of refactoring in the driver, it'll come =
in a
future patchset.

The first 3 patches removes the dsa.h include from linux/netdevice.h, w=
hich
broke the inclusion of switchdev.h in dsa.h.

The last 3 patches add port_fdb_prepare and change port_fdb_add and
port_fdb_del to use the switchdev FDB object structure.

To be more specific about the include dependency issue, here's a snippe=
t of
what happens currently if you include switchdev.h in dsa.h:

[...]
    include/net/switchdev.h:52:30: error: field =E2=80=98ppid=E2=80=99 =
has incomplete type
       struct netdev_phys_item_id ppid; /* PORT_PARENT_ID */
                                  ^
    include/net/switchdev.h:185:14: warning: =E2=80=98struct nlmsghdr=E2=
=80=99 declared inside parameter list [enabled by default]
           struct nlmsghdr *nlh, u16 flags);
                  ^
    include/net/switchdev.h:195:7: warning: =E2=80=98struct ndmsg=E2=80=
=99 declared inside parameter list [enabled by default]
    include/net/switchdev.h:198:7: warning: =E2=80=98struct nlattr=E2=80=
=99 declared inside parameter list [enabled by default]
           u16 vid);
           ^
    include/net/switchdev.h:201:15: warning: =E2=80=98struct netlink_ca=
llback=E2=80=99 declared inside parameter list [enabled by default]
            struct net_device *filter_dev, int idx);
                   ^
[...]

Removing the dsa.h include from linux/netdevice.h gets rid of these err=
ors but
then the DSA code complains if you don't include it in dsa_priv.h:

[...]
net/dsa/slave.c: In function =E2=80=98dsa_slave_set_mac_address=E2=80=99=
:
net/dsa/slave.c:178:39: error: dereferencing pointer to incomplete type
  struct net_device *master =3D p->parent->dst->master_netdev;
                                       ^
In file included from include/linux/list.h:8:0,
                 from net/dsa/slave.c:11:
net/dsa/slave.c: In function =E2=80=98dsa_bridge_check_vlan_range=E2=80=
=99:
net/dsa/slave.c:209:26: error: =E2=80=98DSA_MAX_PORTS=E2=80=99 undeclar=
ed (first use in this function)
  DECLARE_BITMAP(members, DSA_MAX_PORTS);
                          ^
net/dsa/slave.c:209:26: note: each undeclared identifier is reported on=
ly once for each function it appears in
  DECLARE_BITMAP(members, DSA_MAX_PORTS);
                          ^
include/linux/kernel.h:67:30: note: in definition of macro =E2=80=98DIV=
_ROUND_UP=E2=80=99
 #define DIV_ROUND_UP(n,d) (((n) + (d) - 1) / (d))
                              ^
include/linux/types.h:10:21: note: in expansion of macro =E2=80=98BITS_=
TO_LONGS=E2=80=99
  unsigned long name[BITS_TO_LONGS(bits)]
                     ^
net/dsa/slave.c:209:2: note: in expansion of macro =E2=80=98DECLARE_BIT=
MAP=E2=80=99
  DECLARE_BITMAP(members, DSA_MAX_PORTS);
  ^
net/dsa/slave.c:1190:7: error: =E2=80=98DSA_TAG_PROTO_EDSA=E2=80=99 und=
eclared (first use in this function)
  case DSA_TAG_PROTO_EDSA:
       ^
net/dsa/slave.c: In function =E2=80=98dsa_slave_get_iflink=E2=80=99:
net/dsa/slave.c:64:1: warning: control reaches end of non-void function=
 [-Wreturn-type]
 }
 ^
[...]


Thanks,
-v

Vivien Didelot (6):
  net: dsa: add uses_hw_tag
  net: dsa: include dsa.h in dsa_priv.h
  net: remove dsa.h include from linux/netdevice.h
  net: dsa: add port_fdb_prepare
  net: dsa: push prepare phase in port_fdb_add
  net: dsa: use switchdev obj in port_fdb_del

 drivers/net/dsa/mv88e6171.c |  1 +
 drivers/net/dsa/mv88e6352.c |  1 +
 drivers/net/dsa/mv88e6xxx.c | 23 +++++++++++++++++------
 drivers/net/dsa/mv88e6xxx.h |  8 ++++++--
 include/linux/netdevice.h   |  9 ++++++---
 include/net/dsa.h           | 14 +++++++-------
 net/dsa/dsa.c               |  1 +
 net/dsa/dsa_priv.h          |  1 +
 net/dsa/slave.c             | 11 +++++++----
 9 files changed, 47 insertions(+), 22 deletions(-)

--=20
2.6.0
