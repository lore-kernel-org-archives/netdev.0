From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 0/3] net: remove dsa.h from netdevice.h
Date: Wed, 7 Oct 2015 12:27:10 -0400
Message-ID: <20151007162710.GA11487@ketchup.mtl.sfl>
References: <1444168467-10293-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <56146A74.8050807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, Andrew Lunn <andrew@lunn.ch>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56146A74.8050807@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian, All,

On Oct. Tuesday 06 (41) 05:42 PM, Florian Fainelli wrote:
> On 06/10/15 14:54, Vivien Didelot wrote:
> > In order to push switchdev objects down to DSA drivers, I need to i=
nclude
> > switchdev.h in dsa.h. But compilation fails because of a circular d=
ependency
> > issue, since dsa.h is also included in linux/netdevice.h.
>=20
> Just for the record, what does this circular dependency looks like? L=
ast
> I tried something in that front, I ended-up forward declaring the
> 'switchdev_obj' structure, but that was weeks ago before the whole
> restructuring, so could be pointless now.

My next work is to push the switchdev callback for FDB dump down to the
DSA drivers. It works if I forward declare all these in net/dsa.h:

 * struct switchdev_obj
 * struct switchdev_obj_port_fdb
 * typedef int switchdev_obj_dump_cb_t(struct switchdev_obj *obj);

Then will come the VLAN ops, etc. It doesn't feel like the way to go.

Below is how these dependency errors look like. There are two issues
this patchset fixes. First, here's what happens you just add:

    #include <net/switchdev.h>

in include/net/dsa.h:

[...]

In file included from include/net/dsa.h:22:0,
                 from include/linux/netdevice.h:44,
                 from include/linux/icmpv6.h:12,
                 from include/linux/ipv6.h:71,
                 from include/net/ipv6.h:16,
                 from include/linux/sunrpc/clnt.h:27,
                 from include/linux/nfs_fs.h:30,
                 from init/do_mounts.c:32:
include/net/switchdev.h:52:30: error: field =E2=80=98ppid=E2=80=99 has =
incomplete type
   struct netdev_phys_item_id ppid; /* PORT_PARENT_ID */
                              ^
include/net/switchdev.h:185:14: warning: =E2=80=98struct nlmsghdr=E2=80=
=99 declared inside parameter list [enabled by default]
       struct nlmsghdr *nlh, u16 flags);
              ^
include/net/switchdev.h:185:14: warning: its scope is only this definit=
ion or declaration, which is probably not what you want [enabled by def=
ault]
include/net/switchdev.h:187:14: warning: =E2=80=98struct nlmsghdr=E2=80=
=99 declared inside parameter list [enabled by default]
       struct nlmsghdr *nlh, u16 flags);
              ^
include/net/switchdev.h:195:7: warning: =E2=80=98struct nlattr=E2=80=99=
 declared inside parameter list [enabled by default]
       u16 vid, u16 nlm_flags);
       ^
include/net/switchdev.h:195:7: warning: =E2=80=98struct ndmsg=E2=80=99 =
declared inside parameter list [enabled by default]
include/net/switchdev.h:198:7: warning: =E2=80=98struct nlattr=E2=80=99=
 declared inside parameter list [enabled by default]
       u16 vid);
       ^
include/net/switchdev.h:198:7: warning: =E2=80=98struct ndmsg=E2=80=99 =
declared inside parameter list [enabled by default]
include/net/switchdev.h:201:15: warning: =E2=80=98struct netlink_callba=
ck=E2=80=99 declared inside parameter list [enabled by default]
        struct net_device *filter_dev, int idx);
               ^

[...]

Removing the dsa.h include from linux/netdevice.h gets rid of these
warnings, but then, the DSA code complains with the following:

[...]

net/dsa/slave.c: In function =E2=80=98dsa_slave_phy_read=E2=80=99:
net/dsa/slave.c:29:8: error: dereferencing pointer to incomplete type
  if (ds->phys_mii_mask & (1 << addr))
        ^

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
net/dsa/slave.c:214:9: error: dereferencing pointer to incomplete type
  if (!ds->drv->vlan_getnext || !vid_begin)
         ^

[...]

net/dsa/slave.c:1190:7: error: =E2=80=98DSA_TAG_PROTO_EDSA=E2=80=99 und=
eclared (first use in this function)
  case DSA_TAG_PROTO_EDSA:
       ^
net/dsa/slave.c:1219:4: error: dereferencing pointer to incomplete type
  ds->ports[port] =3D slave_dev;
    ^
net/dsa/slave.c:1225:5: error: dereferencing pointer to incomplete type
   ds->ports[port] =3D NULL;
     ^
net/dsa/slave.c: In function =E2=80=98dsa_slave_get_iflink=E2=80=99:
net/dsa/slave.c:64:1: warning: control reaches end of non-void function=
 [-Wreturn-type]
 }
 ^
cc1: some warnings being treated as errors
scripts/Makefile.build:258: recipe for target 'net/dsa/slave.o' failed
make[3]: *** [net/dsa/slave.o] Error 1
scripts/Makefile.build:403: recipe for target 'net/dsa' failed
make[2]: *** [net/dsa] Error 2

[...]

=46inally, adding:

    #include <net/dsa.h>

in net/dsa/dsa_priv.h fixes these errors.

Does the patchset makes sense?

Best,
-v
