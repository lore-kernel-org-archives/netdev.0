From: Alpt <alpt@freaknet.org>
Subject: [PATCH bridge-2.6.11] bridge hub_enabled option
Date: Sun, 27 Mar 2005 10:19:03 +0200
Message-ID: <20050327081903.GA18714@nihil>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============68897805549549174=="
Cc: bridge@lists.osdl.org
Return-path: <bridge-bounces@lists.osdl.org>
To: netdev@oss.sgi.com
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.osdl.org>
List-Help: <mailto:bridge-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=subscribe>
Sender: bridge-bounces@lists.osdl.org
Errors-To: bridge-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org


--===============68897805549549174==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="z6Eq5LdranGa6ru8"
Content-Disposition: inline


--z6Eq5LdranGa6ru8
Content-Type: multipart/mixed; boundary="9amGYk9869ThD9tj"
Content-Disposition: inline


--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Bridge hub_enabled patch:
this patch adds the hub_enabled option for bridge.

By default the hub_enabled flag is set to 1. In this case nothing changes, =
the
bridge, as usually, acts as a hub and flood_forward the input pkts to all i=
ts
ports. When hun_enabled is set to 0, the bridge stops to flood_forward the =
input
traffic and takes only the pkts sent to it.
Disabling the hub option is useful to join multiple interfaces into a uniqu=
e virtual
one, thus becomes possible to have easily an ad-hoc network topology using =
multiple
interfaces.=20

For example:


	A(eth0) --- (eth1)B(eth0) --- (eth1)C
		       BRIDGE
		       NO HUB
		        br0
A and C must not be directly connected, and B must have only one interface,=
 in
this case br0.
This scenario is possible only disabling the hub behavior of the bridge.

To clarify, this topology is the same of having:

	A(wlan0)\	     /(wlan0)C
		 \	    /
		  \	   /
		    (wlan0)
		      B
A and C don't see each other.


Maybe the hub_enabled option may be useful for something else ^_-

The patch is simple and stupid, and it seems to work.

It can be found also here:
http://freaknet.org/alpt/src/bridge-hub/bridge-2.6.11-hub.patch

The patch to update the bridge-utils is here:
http://freaknet.org/alpt/src/bridge-hub/bridge-utils-1.0.6-hub.patch

Here attached there is only the patch for the net/bridge code.

Best Regards

PS: I'm resending this mail because after 7 hours I don't see it in the ml.
--=20
:wq!
"I don't know nothing" The One Who reached the Thinking Matter   '.'

[ Alpt --- Freaknet Medialab ]
[ GPG Key ID 441CF0EE ]
[ Key fingerprint =3D 8B02 26E8 831A 7BB9 81A9  5277 BFF8 037E 441C F0EE ]

--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="bridge-2.6.11-hub.patch"
Content-Transfer-Encoding: quoted-printable

diff -ru a-2.6.11/include/linux/if_bridge.h b-2.6.11/include/linux/if_bridg=
e.h
--- a-2.6.11/include/linux/if_bridge.h	2005-03-26 21:14:05.000000000 +0100
+++ b-2.6.11/include/linux/if_bridge.h	2005-03-25 23:57:19.000000000 +0100
@@ -44,6 +44,7 @@
 #define BRCTL_SET_PORT_PRIORITY 16
 #define BRCTL_SET_PATH_COST 17
 #define BRCTL_GET_FDB_ENTRIES 18
+#define BRCTL_SET_BRIDGE_HUB_STATE 19
=20
 #define BR_STATE_DISABLED 0
 #define BR_STATE_LISTENING 1
@@ -65,6 +66,7 @@
 	__u8 topology_change;
 	__u8 topology_change_detected;
 	__u8 root_port;
+	__u8 hub_enabled;
 	__u8 stp_enabled;
 	__u32 ageing_time;
 	__u32 gc_interval;
diff -ru a-2.6.11/net/bridge/br_if.c b-2.6.11/net/bridge/br_if.c
--- a-2.6.11/net/bridge/br_if.c	2005-03-26 21:14:05.000000000 +0100
+++ b-2.6.11/net/bridge/br_if.c	2005-03-25 23:56:56.000000000 +0100
@@ -155,6 +155,8 @@
 	br->bridge_id.prio[1] =3D 0x00;
 	memset(br->bridge_id.addr, 0, ETH_ALEN);
=20
+	br->hub_enabled =3D 1;
+=09
 	br->stp_enabled =3D 0;
 	br->designated_root =3D br->bridge_id;
 	br->root_path_cost =3D 0;
diff -ru a-2.6.11/net/bridge/br_input.c b-2.6.11/net/bridge/br_input.c
--- a-2.6.11/net/bridge/br_input.c	2005-03-26 21:14:05.000000000 +0100
+++ b-2.6.11/net/bridge/br_input.c	2005-03-26 22:08:38.000000000 +0100
@@ -80,12 +80,13 @@
 		goto out;
 	}
=20
-	if (dst !=3D NULL) {
+	if (dst !=3D NULL && br->hub_enabled) {
 		br_forward(dst->dst, skb);
 		goto out;
 	}
=20
-	br_flood_forward(br, skb, 0);
+	if(br->hub_enabled)
+		br_flood_forward(br, skb, 0);
=20
 out:
 	return 0;
diff -ru a-2.6.11/net/bridge/br_ioctl.c b-2.6.11/net/bridge/br_ioctl.c
--- a-2.6.11/net/bridge/br_ioctl.c	2005-03-26 21:14:05.000000000 +0100
+++ b-2.6.11/net/bridge/br_ioctl.c	2005-03-25 23:56:56.000000000 +0100
@@ -135,6 +135,7 @@
 		b.topology_change =3D br->topology_change;
 		b.topology_change_detected =3D br->topology_change_detected;
 		b.root_port =3D br->root_port;
+		b.hub_enabled =3D br->hub_enabled;
 		b.stp_enabled =3D br->stp_enabled;
 		b.ageing_time =3D jiffies_to_clock_t(br->ageing_time);
 		b.hello_timer_value =3D br_timer_value(&br->hello_timer);
@@ -247,6 +248,13 @@
 		return 0;
 	}
=20
+	case BRCTL_SET_BRIDGE_HUB_STATE:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
+		br->hub_enabled =3D args[1]?1:0;
+		return 0;
+
 	case BRCTL_SET_BRIDGE_STP_STATE:
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
diff -ru a-2.6.11/net/bridge/br_private.h b-2.6.11/net/bridge/br_private.h
--- a-2.6.11/net/bridge/br_private.h	2005-03-26 21:14:05.000000000 +0100
+++ b-2.6.11/net/bridge/br_private.h	2005-03-25 23:56:56.000000000 +0100
@@ -93,6 +93,8 @@
 	struct hlist_head		hash[BR_HASH_SIZE];
 	struct list_head		age_list;
=20
+	unsigned char			hub_enabled;
+=09
 	/* STP */
 	bridge_id			designated_root;
 	bridge_id			bridge_id;
diff -ru a-2.6.11/net/bridge/br_sysfs_br.c b-2.6.11/net/bridge/br_sysfs_br.c
--- a-2.6.11/net/bridge/br_sysfs_br.c	2005-03-26 21:14:05.000000000 +0100
+++ b-2.6.11/net/bridge/br_sysfs_br.c	2005-03-25 23:56:56.000000000 +0100
@@ -136,6 +136,28 @@
=20
 static CLASS_DEVICE_ATTR(ageing_time, S_IRUGO | S_IWUSR, show_ageing_time,
 			 store_ageing_time);
+
+static ssize_t show_hub_state(struct class_device *cd, char *buf)
+{
+	struct net_bridge *br =3D to_bridge(cd);
+	return sprintf(buf, "%d\n", br->hub_enabled);
+}
+
+static void set_hub_state(struct net_bridge *br, unsigned long val)
+{
+	br->hub_enabled =3D val;
+}
+
+static ssize_t store_hub_state(struct class_device *cd,
+			       const char *buf, size_t len)
+{
+	return store_bridge_parm(cd, buf, len, set_hub_state);
+}
+
+static CLASS_DEVICE_ATTR(hub_state, S_IRUGO | S_IWUSR, show_hub_state,
+			 store_hub_state);
+
+
 static ssize_t show_stp_state(struct class_device *cd, char *buf)
 {
 	struct net_bridge *br =3D to_bridge(cd);
@@ -246,6 +268,7 @@
 	&class_device_attr_hello_time.attr,
 	&class_device_attr_max_age.attr,
 	&class_device_attr_ageing_time.attr,
+	&class_device_attr_hub_state.attr,
 	&class_device_attr_stp_state.attr,
 	&class_device_attr_priority.attr,
 	&class_device_attr_bridge_id.attr,

--9amGYk9869ThD9tj--

--z6Eq5LdranGa6ru8
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFCRmx2v/gDfkQc8O4RAtQRAKDNfsqItVPixFmhybp0+nQtxGD4QQCgrwGW
zkwwi/CTjeDRCBkRv16qdaQ=
=hIh0
-----END PGP SIGNATURE-----

--z6Eq5LdranGa6ru8--

--===============68897805549549174==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/bridge

--===============68897805549549174==--
