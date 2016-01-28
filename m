From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH] igb: Fix VLAN tag stripping on Intel i350
Date: Thu, 28 Jan 2016 13:53:23 +0100
Message-ID: <20160128125323.GA17357@calimero.vinschen.de>
References: <1453901284-32628-1-git-send-email-vinschen@redhat.com>
 <1453922722.3014.29.camel@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="i9LlY+UWpKt15+FH"
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	Corinna Vinschen <vinschen@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41331 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755124AbcA1MxZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jan 2016 07:53:25 -0500
Content-Disposition: inline
In-Reply-To: <1453922722.3014.29.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--i9LlY+UWpKt15+FH
Content-Type: multipart/mixed; boundary="sdtB3X0nJg68CQEu"
Content-Disposition: inline


--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jeff,

On Jan 27 11:25, Jeff Kirsher wrote:
> On Wed, 2016-01-27 at 14:28 +0100, Corinna Vinschen wrote:
> > Problem: When switching off VLAN offloading on an i350, the VLAN
> > interface gets unusable.=C2=A0 For testing, set up a VLAN on an i350
> > and some remote machine, e.g.:
> > [...]
> I tried applying your patch to my tree for review and validation, but
> due to patches already applied against the igb driver in my tree, your
> patch does not apply cleanly.
>=20
> Can you please update your patch to apply cleanly to my tree?
> git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
> dev-queue
>=20
> (next-queue tree and dev-queue branch)

The attached patch is against the dev-queue branch of your next-queue tree.

I retested again using an i350 as well as a 82580.  On the i350 I tested
additionally adding and removing VFs while offloading was switched on or
off, and it worked as desired.

I'm just a bit unsure about the correctness of the igb_set_vf_vlan_strip
call from igb_vf_reset.  I think it's the right thing to do since
resetting the VF requires to reevaluate the STRVLAN flag.  I'd feel
better if you could double check, though.


Thanks,
Corinna

--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="0001-igb-Fix-VLAN-tag-stripping-on-Intel-i350.patch"
Content-Transfer-Encoding: quoted-printable

=46rom ab27415c3d3be2beb978316007f84fb54d12b619 Mon Sep 17 00:00:00 2001
=46rom: Corinna Vinschen <vinschen@redhat.com>
Date: Thu, 28 Jan 2016 13:31:11 +0100
Subject: [PATCH] igb: Fix VLAN tag stripping on Intel i350

Problem: When switching off VLAN offloading on an i350, the VLAN
interface gets unusable.  For testing, set up a VLAN on an i350
and some remote machine, e.g.:

  $ ip link add link eth0 name eth0.42 type vlan id 42
  $ ip addr add 192.168.42.1/24 dev eth0.42
  $ ip link set dev eth0.42 up

Offloading is switched on by default:

  $ ethtool -k eth0 | grep vlan-offload
  rx-vlan-offload: on
  tx-vlan-offload: on

  $ ping -c 3 -I eth0.42 192.168.42.2
  [...works as usual...]

Now switch off VLAN offloading and try again:

  $ ethtool -K eth0 rxvlan off
  Actual changes:
  rx-vlan-offload: off
  tx-vlan-offload: off [requested on]
  $ ping -c 3 -I eth0.42 192.168.42.2
  PING 192.168.42.2 (192.168.42.2) from 192.168.42.1 eth0.42: 56(84) bytes =
of da
ta.

  --- 192.168.42.2 ping statistics ---
  3 packets transmitted, 0 received, 100% packet loss, time 1999ms

I can only reproduce it on an i350, the above works fine on a 82580.

While inspecting the igb source, I came across the code in igb_set_vmolr
which sets the E1000_VMOLR_STRVLAN/E1000_DVMOLR_STRVLAN flags once and
for all, and in all of the igb code there's no other place where the
STRVLAN is set or cleared.  Thus, VLAN stripping is enabled in igb
unconditionally, independently of the offloading setting.

I compared that to the latest Intel igb-5.3.3.5 driver from
http://sourceforge.net/projects/e1000/ which in fact sets and clears the
STRVLAN flag independently from igb_set_vmolr in its own function
igb_set_vf_vlan_strip, depending on the vlan settings.

So I included the STRVLAN handling from the igb-5.3.3.5 driver into our
current igb driver and tested the above scenario again.  This time ping
still works after switching off VLAN offloading.

Tested on i350, with and without addtional VFs, as well as on 82580
successfully.

Signed-off-by: Corinna Vinschen <vinschen@redhat.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 41 ++++++++++++++++++++++++---=
----
 1 file changed, 32 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethern=
et/intel/igb/igb_main.c
index 95d6042..c414e41 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3699,6 +3699,28 @@ static inline int igb_set_vf_rlpml(struct igb_adapte=
r *adapter, int size,
 	return 0;
 }
=20
+static inline void igb_set_vf_vlan_strip(struct igb_adapter *adapter,
+					 int vfn, bool enable)
+{
+	struct e1000_hw *hw =3D &adapter->hw;
+	u32 val, reg;
+
+	if (hw->mac.type < e1000_82576)
+		return;
+
+	if (hw->mac.type =3D=3D e1000_i350)
+		reg =3D E1000_DVMOLR(vfn);
+	else
+		reg =3D E1000_VMOLR(vfn);
+
+	val =3D rd32(reg);
+	if (enable)
+		val |=3D E1000_VMOLR_STRVLAN;
+	else
+		val &=3D ~(E1000_VMOLR_STRVLAN);
+	wr32(reg, val);
+}
+
 static inline void igb_set_vmolr(struct igb_adapter *adapter,
 				 int vfn, bool aupe)
 {
@@ -3712,14 +3734,6 @@ static inline void igb_set_vmolr(struct igb_adapter =
*adapter,
 		return;
=20
 	vmolr =3D rd32(E1000_VMOLR(vfn));
-	vmolr |=3D E1000_VMOLR_STRVLAN; /* Strip vlan tags */
-	if (hw->mac.type =3D=3D e1000_i350) {
-		u32 dvmolr;
-
-		dvmolr =3D rd32(E1000_DVMOLR(vfn));
-		dvmolr |=3D E1000_DVMOLR_STRVLAN;
-		wr32(E1000_DVMOLR(vfn), dvmolr);
-	}
 	if (aupe)
 		vmolr |=3D E1000_VMOLR_AUPE; /* Accept untagged packets */
 	else
@@ -6217,6 +6231,7 @@ static int igb_enable_port_vlan(struct igb_adapter *a=
dapter, int vf,
=20
 	adapter->vf_data[vf].pf_vlan =3D vlan;
 	adapter->vf_data[vf].pf_qos =3D qos;
+	igb_set_vf_vlan_strip(adapter, vf, true);
 	dev_info(&adapter->pdev->dev,
 		 "Setting VLAN %d, QOS 0x%x on VF %d\n", vlan, qos, vf);
 	if (test_bit(__IGB_DOWN, &adapter->state)) {
@@ -6244,6 +6259,7 @@ static int igb_disable_port_vlan(struct igb_adapter *=
adapter, int vf)
=20
 	adapter->vf_data[vf].pf_vlan =3D 0;
 	adapter->vf_data[vf].pf_qos =3D 0;
+	igb_set_vf_vlan_strip(adapter, vf, false);
=20
 	return 0;
 }
@@ -6264,6 +6280,7 @@ static int igb_set_vf_vlan_msg(struct igb_adapter *ad=
apter, u32 *msgbuf, u32 vf)
 {
 	int add =3D (msgbuf[0] & E1000_VT_MSGINFO_MASK) >> E1000_VT_MSGINFO_SHIFT;
 	int vid =3D (msgbuf[1] & E1000_VLVF_VLANID_MASK);
+	int ret;
=20
 	if (adapter->vf_data[vf].pf_vlan)
 		return -1;
@@ -6272,7 +6289,10 @@ static int igb_set_vf_vlan_msg(struct igb_adapter *a=
dapter, u32 *msgbuf, u32 vf)
 	if (!vid && !add)
 		return 0;
=20
-	return igb_set_vf_vlan(adapter, vid, !!add, vf);
+	ret =3D igb_set_vf_vlan(adapter, vid, !!add, vf);
+	if (!ret)
+		igb_set_vf_vlan_strip(adapter, vf, !!vid);
+	return ret;
 }
=20
 static inline void igb_vf_reset(struct igb_adapter *adapter, u32 vf)
@@ -6289,6 +6309,7 @@ static inline void igb_vf_reset(struct igb_adapter *a=
dapter, u32 vf)
 	igb_set_vmvir(adapter, vf_data->pf_vlan |
 			       (vf_data->pf_qos << VLAN_PRIO_SHIFT), vf);
 	igb_set_vmolr(adapter, vf, !vf_data->pf_vlan);
+	igb_set_vf_vlan_strip(adapter, vf, !!(vf_data->pf_vlan));
=20
 	/* reset multicast table array for vf */
 	adapter->vf_data[vf].num_vf_mc_hashes =3D 0;
@@ -7449,6 +7470,8 @@ static void igb_vlan_mode(struct net_device *netdev, =
netdev_features_t features)
 		ctrl &=3D ~E1000_CTRL_VME;
 		wr32(E1000_CTRL, ctrl);
 	}
+
+	igb_set_vf_vlan_strip(adapter, adapter->vfs_allocated_count, enable);
 }
=20
 static int igb_vlan_rx_add_vid(struct net_device *netdev,
--=20
2.5.0


--sdtB3X0nJg68CQEu--

--i9LlY+UWpKt15+FH
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWqg9DAAoJEPU2Bp2uRE+gcBIP/R5SToHP+6hxP9YMWcqyx7mK
wjDmEDI47JZJmYpgr0GTl+3/MHVSA8nl5CtlGnggTtL9g9jz51iQw0WPcYqfXuw1
goh9tIAUKb6zq7WqosANH+naTmF6u3P25BtAjOjyR54O1KnmVsW0NbXRkY2Zps2H
2ObjVgO21qylKn7U6VkqKHqadHDNjAlYFpkLg5xuC1LIOdqOPE///ElWs+pq4k1t
mndWMfYoCxF9erT6xkdemXeNIPFykYmJb6uRr5f+PpouMenqXVS4kjsHqjMC+cpO
7L4f6l9vuvCJG+ZaOGz9U4hg1f9x2ROCkzpDQ1vYZ+vydm2wxQgshOSwDQEXcBbN
bS9wwycBKSbvxv4SHSowONUQDr3sILIaIlJ4qpe8FT4Msjz0Zz1e1jLibCsqzBvB
ULohsptG3PxcgJihPPXoAiWLOW9tZGckINjtfi1JLAUgSw2EtF3Xa3bQTVognoQh
9hPGhqCjJ2VfhKdmh9W/5rvWE0Gy0X3K4v2D5mR+004aQnZRTzVK2nIzWp+6aAs1
d4h1NLuwJu3X+tXjhHVl6TSexUFP8hYtzAS/iiNddFZjGqYSDWsvoZ4HYQr8wgSY
VEYi6FO1r5ULtuJywza/yQyqVe4ZF3mEYoy1L0OS9nFiq9mrzLETbswCW+n5Qq5S
LarO1Ww+9H/c1cIgSKki
=ci4n
-----END PGP SIGNATURE-----

--i9LlY+UWpKt15+FH--
