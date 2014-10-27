From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net 1/2] drivers/net: Disable UFO through virtio
Date: Mon, 27 Oct 2014 04:22:28 +0000
Message-ID: <1414383748.16849.21.camel@decadent.org.uk>
References: <1414383425.16849.18.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7837656918908280367=="
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	virtualization@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1414383425.16849.18.camel@decadent.org.uk>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--===============7837656918908280367==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-gzUstCdgZu7hJCgs+TD1"


--=-gzUstCdgZu7hJCgs+TD1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

IPv6 does not allow fragmentation by routers, so there is no
fragmentation ID in the fixed header.  UFO for IPv6 requires the ID to
be passed separately, but there is no provision for this in the virtio
net protocol.

Until recently our software implementation of UFO/IPv6 generated a new
ID, but this was a bug.  Now we will use ID=3D0 for any UFO/IPv6 packet
passed through a tap, which is even worse.

Unfortunately there is no distinction between UFO/IPv4 and v6
features, so disable UFO on taps and virtio_net completely until we
have a proper solution.

We cannot depend on VM managers respecting the tap feature flags, so
keep accepting UFO packets but log a warning the first time we do
this.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Fixes: 916e4cf46d02 ("ipv6: reuse ip6_frag_id from ip6_ufo_append_data")
---
I hoped that turning off the UFO feature completely would work, but when
I used libvirt and QEMU on Debian stable I found they still advertised
UFO to the guest.

Ben.

 drivers/net/macvtap.c    | 13 +++++--------
 drivers/net/tun.c        | 18 ++++++++++--------
 drivers/net/virtio_net.c | 23 +++++++++++++----------
 3 files changed, 28 insertions(+), 26 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 65e2892..2aeaa61 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -65,7 +65,7 @@ static struct cdev macvtap_cdev;
 static const struct proto_ops macvtap_socket_ops;
=20
 #define TUN_OFFLOADS (NETIF_F_HW_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
-		      NETIF_F_TSO6 | NETIF_F_UFO)
+		      NETIF_F_TSO6)
 #define RX_OFFLOADS (NETIF_F_GRO | NETIF_F_LRO)
 #define TAP_FEATURES (NETIF_F_GSO | NETIF_F_SG)
=20
@@ -569,6 +569,8 @@ static int macvtap_skb_from_vnet_hdr(struct sk_buff *sk=
b,
 			gso_type =3D SKB_GSO_TCPV6;
 			break;
 		case VIRTIO_NET_HDR_GSO_UDP:
+			pr_warn_once("macvtap: %s: using disabled UFO feature; please fix this =
program\n",
+				     current->comm);
 			gso_type =3D SKB_GSO_UDP;
 			break;
 		default:
@@ -614,8 +616,6 @@ static void macvtap_skb_to_vnet_hdr(const struct sk_buf=
f *skb,
 			vnet_hdr->gso_type =3D VIRTIO_NET_HDR_GSO_TCPV4;
 		else if (sinfo->gso_type & SKB_GSO_TCPV6)
 			vnet_hdr->gso_type =3D VIRTIO_NET_HDR_GSO_TCPV6;
-		else if (sinfo->gso_type & SKB_GSO_UDP)
-			vnet_hdr->gso_type =3D VIRTIO_NET_HDR_GSO_UDP;
 		else
 			BUG();
 		if (sinfo->gso_type & SKB_GSO_TCP_ECN)
@@ -950,9 +950,6 @@ static int set_offload(struct macvtap_queue *q, unsigne=
d long arg)
 			if (arg & TUN_F_TSO6)
 				feature_mask |=3D NETIF_F_TSO6;
 		}
-
-		if (arg & TUN_F_UFO)
-			feature_mask |=3D NETIF_F_UFO;
 	}
=20
 	/* tun/tap driver inverts the usage for TSO offloads, where
@@ -963,7 +960,7 @@ static int set_offload(struct macvtap_queue *q, unsigne=
d long arg)
 	 * When user space turns off TSO, we turn off GSO/LRO so that
 	 * user-space will not receive TSO frames.
 	 */
-	if (feature_mask & (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_UFO))
+	if (feature_mask & (NETIF_F_TSO | NETIF_F_TSO6))
 		features |=3D RX_OFFLOADS;
 	else
 		features &=3D ~RX_OFFLOADS;
@@ -1064,7 +1061,7 @@ static long macvtap_ioctl(struct file *file, unsigned=
 int cmd,
 	case TUNSETOFFLOAD:
 		/* let the user check for future flags */
 		if (arg & ~(TUN_F_CSUM | TUN_F_TSO4 | TUN_F_TSO6 |
-			    TUN_F_TSO_ECN | TUN_F_UFO))
+			    TUN_F_TSO_ECN))
 			return -EINVAL;
=20
 		rtnl_lock();
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 186ce54..e8b949a 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -174,7 +174,7 @@ struct tun_struct {
 	struct net_device	*dev;
 	netdev_features_t	set_features;
 #define TUN_USER_FEATURES (NETIF_F_HW_CSUM|NETIF_F_TSO_ECN|NETIF_F_TSO| \
-			  NETIF_F_TSO6|NETIF_F_UFO)
+			  NETIF_F_TSO6)
=20
 	int			vnet_hdr_sz;
 	int			sndbuf;
@@ -1149,8 +1149,17 @@ static ssize_t tun_get_user(struct tun_struct *tun, =
struct tun_file *tfile,
 			skb_shinfo(skb)->gso_type =3D SKB_GSO_TCPV6;
 			break;
 		case VIRTIO_NET_HDR_GSO_UDP:
+		{
+			static bool warned;
+			if (!warned) {
+				warned =3D true;
+				netdev_warn(tun->dev,
+					    "%s: using disabled UFO feature; please fix this program\n",
+					    current->comm);
+			}
 			skb_shinfo(skb)->gso_type =3D SKB_GSO_UDP;
 			break;
+		}
 		default:
 			tun->dev->stats.rx_frame_errors++;
 			kfree_skb(skb);
@@ -1251,8 +1260,6 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 				gso.gso_type =3D VIRTIO_NET_HDR_GSO_TCPV4;
 			else if (sinfo->gso_type & SKB_GSO_TCPV6)
 				gso.gso_type =3D VIRTIO_NET_HDR_GSO_TCPV6;
-			else if (sinfo->gso_type & SKB_GSO_UDP)
-				gso.gso_type =3D VIRTIO_NET_HDR_GSO_UDP;
 			else {
 				pr_err("unexpected GSO type: "
 				       "0x%x, gso_size %d, hdr_len %d\n",
@@ -1762,11 +1769,6 @@ static int set_offload(struct tun_struct *tun, unsig=
ned long arg)
 				features |=3D NETIF_F_TSO6;
 			arg &=3D ~(TUN_F_TSO4|TUN_F_TSO6);
 		}
-
-		if (arg & TUN_F_UFO) {
-			features |=3D NETIF_F_UFO;
-			arg &=3D ~TUN_F_UFO;
-		}
 	}
=20
 	/* This gives the user a way to test for new features in future by
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index d75256bd..e9e269d 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -491,8 +491,16 @@ static void receive_buf(struct receive_queue *rq, void=
 *buf, unsigned int len)
 			skb_shinfo(skb)->gso_type =3D SKB_GSO_TCPV4;
 			break;
 		case VIRTIO_NET_HDR_GSO_UDP:
+		{
+			static bool warned;
+			if (!warned) {
+				warned =3D true;
+				netdev_warn(dev,
+					    "host using disabled UFO feature; please fix it\n");
+			}
 			skb_shinfo(skb)->gso_type =3D SKB_GSO_UDP;
 			break;
+		}
 		case VIRTIO_NET_HDR_GSO_TCPV6:
 			skb_shinfo(skb)->gso_type =3D SKB_GSO_TCPV6;
 			break;
@@ -881,8 +889,6 @@ static int xmit_skb(struct send_queue *sq, struct sk_bu=
ff *skb)
 			hdr->hdr.gso_type =3D VIRTIO_NET_HDR_GSO_TCPV4;
 		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
 			hdr->hdr.gso_type =3D VIRTIO_NET_HDR_GSO_TCPV6;
-		else if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP)
-			hdr->hdr.gso_type =3D VIRTIO_NET_HDR_GSO_UDP;
 		else
 			BUG();
 		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCP_ECN)
@@ -1705,7 +1711,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 			dev->features |=3D NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
=20
 		if (virtio_has_feature(vdev, VIRTIO_NET_F_GSO)) {
-			dev->hw_features |=3D NETIF_F_TSO | NETIF_F_UFO
+			dev->hw_features |=3D NETIF_F_TSO
 				| NETIF_F_TSO_ECN | NETIF_F_TSO6;
 		}
 		/* Individual feature bits: what can host handle? */
@@ -1715,11 +1721,9 @@ static int virtnet_probe(struct virtio_device *vdev)
 			dev->hw_features |=3D NETIF_F_TSO6;
 		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_ECN))
 			dev->hw_features |=3D NETIF_F_TSO_ECN;
-		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_UFO))
-			dev->hw_features |=3D NETIF_F_UFO;
=20
 		if (gso)
-			dev->features |=3D dev->hw_features & (NETIF_F_ALL_TSO|NETIF_F_UFO);
+			dev->features |=3D dev->hw_features & NETIF_F_ALL_TSO;
 		/* (!csum && gso) case will be fixed by register_netdev() */
 	}
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_CSUM))
@@ -1757,8 +1761,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 	/* If we can receive ANY GSO packets, we must allocate large ones. */
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4) ||
 	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO6) ||
-	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_ECN) ||
-	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_UFO))
+	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_ECN))
 		vi->big_packets =3D true;
=20
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
@@ -1952,9 +1955,9 @@ static struct virtio_device_id id_table[] =3D {
 static unsigned int features[] =3D {
 	VIRTIO_NET_F_CSUM, VIRTIO_NET_F_GUEST_CSUM,
 	VIRTIO_NET_F_GSO, VIRTIO_NET_F_MAC,
-	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6,
+	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_TSO6,
 	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6,
-	VIRTIO_NET_F_GUEST_ECN, VIRTIO_NET_F_GUEST_UFO,
+	VIRTIO_NET_F_GUEST_ECN,
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
 	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
 	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ,


--=20
Ben Hutchings
Theory and practice are closer in theory than in practice.
                                - John Levine, moderator of comp.compilers

--=-gzUstCdgZu7hJCgs+TD1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVE3Iiee/yOyVhhEJAQpAyg/9EDvaZcCLGWP44HJ/4NLtXDaACYAFNvPJ
hiseLk/gzRkX3Yda/WThTBMVtj+2OGneE0bYCb/zr/egRyyPyNA3mI59pSS1WYf1
cgJifZ60M1Oez4IMbPTYp6ox+9lTv9FIH2dFF2kebQyxBUw7BoSdRi50Bn4ln7j+
jDtI0qmzjngjB5vnu1HF7jCH7vPKz/vcYPvEuZnYnpFsBkOtIag85T+0ha55mXe/
RfES6LwAY8KaC3qpxWTsUbgs2+oC+QKXEIqhOAQkXPYhPduMpiOCaUGeczUP210q
xcyq2Xe9EY9cq3Y35FJNUH0rMy5+Cj7a49w5HydsxVZV08yx7vLFW84ghZoBWBmV
yYD3VbDs2vdo7dRxO4E5qXTidxHBAOdoMlAi3mdpVurYYdReFgm4AvEU8F3DmiN7
LHtG2ty9W+RM58X59Z0yjC+C27qgDYbEk/tbVlFOLvHBNH9h0tMkFcjAyEwbLnKq
jnrqn6XcEemSqz2rgBUaCp+kzNzWtY4G/IhH2e7zD0PHNjeLo2nkHxhRH14p6fKk
Q7YssZxY+b7V7fiUtGz1CcWT1kdyglbzjGI5OJ+Kj5pAmdw5sQM22zU/F9CaTFuQ
m4er5zKj7+6tWRs5upG1NcfqUkGrw4NnLdGzEikXV6Dt6cg6SrzmWJsc4SRQXHyT
jGSfaZqmBuc=
=Zj6O
-----END PGP SIGNATURE-----

--=-gzUstCdgZu7hJCgs+TD1--

--===============7837656918908280367==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============7837656918908280367==--
