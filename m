From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Subject: Re: veths often slow to come up
Date: Wed, 5 Aug 2015 12:23:59 -0300
Message-ID: <20150805152358.GE10686@indiana.gru.redhat.com>
References: <D1E67FCC.3FA19%Shaun.Crampton@metaswitch.com>
 <CAM_iQpV6ZjKWmy8ou6xM=fP8gfE19cS9r=YT4P2xW7rBJwAyZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Shaun Crampton <Shaun.Crampton@metaswitch.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAM_iQpV6ZjKWmy8ou6xM=fP8gfE19cS9r=YT4P2xW7rBJwAyZA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 04, 2015 at 08:26:28PM -0700, Cong Wang wrote:
> (Cc'ing netdev for network issues)
>=20
> On Tue, Aug 4, 2015 at 6:42 AM, Shaun Crampton
> <Shaun.Crampton@metaswitch.com> wrote:
> > Please CC me on any responses, thanks.
> >
> > Setting both ends of a veth to be oper UP completes very quickly bu=
t I
> > find that pings only start flowing over the veth after about a seco=
nd.
> > This seems to correlate with the NO-CARRIER flag being set or the
> > interface being in "state UNKNOWN" or "state DOWN=C2=B2 for about a=
 second
> > (demo script below).
> >
> > If I run the script repeatedly then sometimes it completes very qui=
ckly on
> > subsequent runs as if there=C2=B9s a hot cache somewhere.
> >
> > Could this be a bug or is there a configuration to speed this up?  =
Seems
> > odd that it=C2=B9s almost exactly 1s on the first run.
> >
> > Seen on these kernels:
> > * 3.13.0-57-generic #95-Ubuntu SMP Fri Jun 19 09:28:15 UTC 2015 x86=
_64
> > x86_64 x86_64 GNU/Linux
> > * 4.0.9-coreos #2 SMP Thu Jul 30 01:07:55 UTC 2015 x86_64 Intel(R) =
Xeon(R)
> > CPU @ 2.50GHz GenuineIntel GNU/Linux
> >
> > Regards,
> >
> > -Shaun
> >

Take a look at linkwatch_urgent_event at net/core/link_watch.c, and all=
 of
link_watch.c in general. That's where the 1s delay comes from. It's des=
igned to
prevent link message storms.

In particular, look at commit 294cc44b7e48a6e7732499eebcf409b231460d8e,=
 which
added the urgent event.

I suspect this was designed to workaround buggy drivers/hardware, not t=
o help
userspace handle thousands of virtual devices being created and destroy=
ed all
the time.

Maybe virtual devices should be whitelisted here? Maybe the patch below=
 is
stupid, because drivers may abuse it, and drivers are buggy, otherwise =
linkwatch
would not be needed in the first place.

Regards.
Cascardo.

> >
> > Running my test script below (Assumes veth0/1 do not already exist)=
:
> >
> > $ sudo ./veth-test.sh
> > Time to create veth:
> >
> > real    0m0.019s
> > user    0m0.002s
> > sys     0m0.010s
> >
> > Time to wait for carrier:
> >
> > real    0m1.005s
> > user    0m0.007s
> > sys     0m0.123s
> >
> >
> >
> > # veth-test.sh
> >
> > #!/bin/bash
> > function create_veth {
> >   ip link add type veth
> >   ip link set veth0 up
> >   ip link set veth1 up
> > }
> > function wait_for_carrier {
> >   while ! ip link show | grep -qE 'veth[01]';
> >   do
> >     sleep 0.05
> >   done
> >   while ip link show | grep -E 'veth[01]=C2=B9 | \
> >         grep -Eq 'NO-CARRIER|state DOWN|state UNKNOWN';
> >   do
> >     sleep 0.05
> >   done
> > }
> > echo "Time to create veth:"
> > time create_veth
> > echo
> > echo "Time to wait for carrier:"
> > time wait_for_carrier
> > ip link del veth0
---
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 343592c..91123a8 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -306,6 +306,7 @@ static void veth_setup(struct net_device *dev)
=20
 	dev->priv_flags &=3D ~IFF_TX_SKB_SHARING;
 	dev->priv_flags |=3D IFF_LIVE_ADDR_CHANGE;
+	dev->priv_flags |=3D IFF_LINKWATCH_URGENT;
=20
 	dev->netdev_ops =3D &veth_netdev_ops;
 	dev->ethtool_ops =3D &veth_ethtool_ops;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 607b5f4..138f5e9 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1262,6 +1262,7 @@ struct net_device_ops {
  * @IFF_LIVE_ADDR_CHANGE: device supports hardware address
  *	change when it's running
  * @IFF_MACVLAN: Macvlan device
+ * @IFF_LINKWATCH_URGENT: device does not flood with link updates
  */
 enum netdev_priv_flags {
 	IFF_802_1Q_VLAN			=3D 1<<0,
@@ -1289,6 +1290,7 @@ enum netdev_priv_flags {
 	IFF_XMIT_DST_RELEASE_PERM	=3D 1<<22,
 	IFF_IPVLAN_MASTER		=3D 1<<23,
 	IFF_IPVLAN_SLAVE		=3D 1<<24,
+	IFF_LINKWATCH_URGENT		=3D 1<<25,
 };
=20
 #define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
diff --git a/net/core/link_watch.c b/net/core/link_watch.c
index 9828616..e2957a0 100644
--- a/net/core/link_watch.c
+++ b/net/core/link_watch.c
@@ -95,6 +95,9 @@ static bool linkwatch_urgent_event(struct net_device =
*dev)
 	if (dev->priv_flags & IFF_TEAM_PORT)
 		return true;
=20
+	if (dev->priv_flags & IFF_LINKWATCH_URGENT)
+		return true;
+
 	return netif_carrier_ok(dev) &&	qdisc_tx_changing(dev);
 }
---=20
