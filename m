From: Sven Anders <anders@anduras.de>
Subject: Re: Possible bug in bonding driver (with VLAN in ALB mode)
Date: Mon, 27 Oct 2008 14:38:20 +0100
Message-ID: <4905C44C.8000302@anduras.de>
References: <48FE0EEB.7050503@anduras.de> <1830.1224612755@death.nxdomain.ibm.com> <48FE51C5.2010800@anduras.de> <4231.1224629540@death.nxdomain.ibm.com> <48FF3A05.1010408@anduras.de> <23022.1224702799@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA1C63D52C3D48DB74E4105DA"
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metropolitan.anduras.de ([80.237.200.159]:36787 "EHLO
	metropolitan.anduras.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752432AbYJ0Ni3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 09:38:29 -0400
In-Reply-To: <23022.1224702799@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA1C63D52C3D48DB74E4105DA
Content-Type: multipart/mixed;
 boundary="------------070207030903050605040701"

This is a multi-part message in MIME format.
--------------070207030903050605040701
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Jay Vosburgh schrieb:

> 	Can you give this a try?  This patch just checks for VLAN-ness
> and extracts the real device if so, then does the usual "is it bonding"=

> stuff to the real device.
>=20
> [...]

Ok, this worked as expected. I think you can submit the patch.

So:  Signed-off-by: Sven Anders <anders@anduras.de>

>> What troubles me is, that nobody since the addition of VLAN support
>> to bonding in 2004 had this problem before. Did this (ever) work in
>> one older version of the bonding driver?
>=20
> 	I suspect not; I don't recall checking the load balancing
> performance of this kind of configuration (all VLANs over balance-alb).=


Ok.
I wrote a patch to show the current status of the load-balancing in ALB m=
ode,
which helped me a lot identifing the problem.
I attached a version of it to this mail.

Moreover I see two additional problem:

1. If I want to use bonding on 10GBit ethernet cards, the counters
   will most likely overflow, because 10 seconds rebalancing interval
   is too long. But reducing it to 3 or 4 seconds may not be a real
   solution. Maybe we should use 64 Bit counters here?!

2. Is this right, that there is no IPv6 support f=FCr RLB?
   I'm not really sure, but we only have the following entries
   in the RLB structure:

	struct rlb_client_info {
	        __be32 ip_src;          /* the server IP address */
        	__be32 ip_dst;          /* the client IP address */
		[...]
	}

   And the function "rlb_update_entry_from_arp()" for updating the info
   by the received arp packages, only supports IPv4 (see struct arp_pkt
   too!)

Any comments welcome...

Cheers
 Sven
--=20
 Sven Anders <anders@anduras.de>                 () Ascii Ribbon Campaign=

                                                 /\ Support plain text e-=
mail
 ANDURAS service solutions AG
 Innstra=DFe 71 - 94036 Passau - Germany
 Web: www.anduras.de - Tel: +49 (0)851-4 90 50-0 - Fax: +49 (0)851-4 90 5=
0-55

Rechtsform: Aktiengesellschaft - Sitz: Passau - Amtsgericht Passau HRB 60=
32
Mitglieder des Vorstands: Sven Anders, Marcus Junker
Vorsitzender des Aufsichtsrats: Mark Peters

--------------070207030903050605040701
Content-Type: text/x-diff;
 name="bonding-status-output.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
 filename="bonding-status-output.patch"

Signed-off-by: Sven Anders <anders@anduras.de>

diff -ru linux-2.6.28rc2/drivers/net/bonding/bond_alb.c linux-2.6.28rc2-n=
ew/drivers/net/bonding/bond_alb.c
--- linux-2.6.28rc2/drivers/net/bonding/bond_alb.c	2008-10-16 13:05:38.00=
0000000 +0200
+++ linux-2.6.28rc2-new/drivers/net/bonding/bond_alb.c	2008-10-27 14:07:3=
8.000000000 +0100
@@ -26,6 +26,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/pkt_sched.h>
+#include <linux/seq_file.h>
 #include <linux/spinlock.h>
 #include <linux/slab.h>
 #include <linux/timer.h>
@@ -1772,3 +1773,88 @@
 	}
 }
=20
+void bond_alb_info_show(struct seq_file *seq)
+{
+	struct bonding *bond =3D seq->private;
+	struct alb_bond_info *bond_info =3D &(BOND_ALB_INFO(bond));
+	struct rlb_client_info *rclient_info;
+	struct tlb_client_info *tclient_info;
+	struct slave *slave;
+	u32 index;
+	int i;
+	DECLARE_MAC_BUF(mac);
+
+	seq_puts(seq, "\nALB info\n");
+	seq_puts(seq, "\n Receive Load Balancing table:\n");
+	seq_puts(seq, "  Index Slave    Assigned Client-MAC"
+		      "         Server -> Client\n");
+
+	_lock_rx_hashtbl(bond);
+
+	index =3D bond_info->rx_hashtbl_head;
+	for (; index !=3D RLB_NULL_INDEX; index =3D rclient_info->next) {
+		rclient_info =3D &(bond_info->rx_hashtbl[index]);
+		if (rclient_info) {
+			seq_printf(seq,	"%6u: %-8s %6s   %-17s  ",
+				   index,
+				   (rclient_info->slave &&
+				   rclient_info->slave->dev &&
+				   rclient_info->slave->dev->name ?
+				   rclient_info->slave->dev->name : "(none)"),
+				   (rclient_info->assigned ? "yes" : "no"),
+				   print_mac(mac, rclient_info->mac_dst));
+
+			/* Implemented as separate outputs to
+			   support IPv6 in the future (if it's supported) */
+			seq_printf(seq,	NIPQUAD_FMT " -> ",
+				   NIPQUAD(rclient_info->ip_src));
+			seq_printf(seq,	NIPQUAD_FMT "\n",
+				   NIPQUAD(rclient_info->ip_dst));
+		}
+	}
+
+	_unlock_rx_hashtbl(bond);
+
+	seq_puts(seq, "\n Transmit Load Balancing table:\n");
+	seq_printf(seq,	"  Unbalanced load: %u\n"
+			"  Rebalance interval: %u seconds\n\n",
+			bond_info->unbalanced_load,
+			BOND_TLB_REBALANCE_INTERVAL);
+
+	_lock_tx_hashtbl(bond);
+
+	/* Process each slave */
+	bond_for_each_slave(bond, slave, i) {
+
+		if (slave) {
+			seq_puts(seq, "  Slave    Used  Speed    Duplex"
+				      "  Current load\n");
+			seq_printf(seq, "  %-8s %3s   %-8u %4s      %10u\n",
+				   (slave->dev->name ?
+				    slave->dev->name : "none"),
+				   (SLAVE_IS_OK(slave) ? "yes" : "no"),
+				   slave->speed,
+				   (slave->duplex ? "full" : "half"),
+				   SLAVE_TLB_INFO(slave).load);
+
+			seq_puts(seq, "           Index    TX Bytes      "
+				      "Load history\n");
+
+			index =3D SLAVE_TLB_INFO(slave).head;
+			for (; index !=3D TLB_NULL_INDEX;
+			     index =3D tclient_info->next) {
+				tclient_info =3D &(bond_info->tx_hashtbl[index]);
+				if (tclient_info)
+					seq_printf(seq,	"            "
+						   "%3u:  %10u"
+						   "        %10u\n",
+						   index,
+						   tclient_info->tx_bytes,
+						   tclient_info->load_history);
+			}
+			seq_puts(seq, "\n");
+		}
+	}
+
+	_unlock_tx_hashtbl(bond);
+}
diff -ru linux-2.6.28rc2/drivers/net/bonding/bond_alb.h linux-2.6.28rc2-n=
ew/drivers/net/bonding/bond_alb.h
--- linux-2.6.28rc2/drivers/net/bonding/bond_alb.h	2008-06-09 11:37:33.00=
0000000 +0200
+++ linux-2.6.28rc2-new/drivers/net/bonding/bond_alb.h	2008-10-27 13:56:0=
0.000000000 +0100
@@ -128,5 +128,6 @@
 void bond_alb_monitor(struct work_struct *);
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr);
 void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id);
+void bond_alb_info_show(struct seq_file *seq);
 #endif /* __BOND_ALB_H__ */
=20
diff -ru linux-2.6.28rc2/drivers/net/bonding/bond_main.c linux-2.6.28rc2-=
new/drivers/net/bonding/bond_main.c
--- linux-2.6.28rc2/drivers/net/bonding/bond_main.c	2008-10-25 19:13:44.0=
00000000 +0200
+++ linux-2.6.28rc2-new/drivers/net/bonding/bond_main.c	2008-10-27 14:08:=
25.000000000 +0100
@@ -3308,7 +3308,8 @@
 			seq_printf(seq, "\tPartner Mac Address: %s\n",
 				   print_mac(mac, ad_info.partner_system));
 		}
-	}
+	} else if (bond->params.mode =3D=3D BOND_MODE_ALB)
+		bond_alb_info_show(seq);
 }
=20
 static void bond_info_show_slave(struct seq_file *seq, const struct slav=
e *slave)

--------------070207030903050605040701
Content-Type: text/x-vcard; charset=utf-8;
 name="anders.vcf"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="anders.vcf"

begin:vcard
fn:Sven Anders
n:Anders;Sven
org:ANDURAS AG;Research and Development
adr;quoted-printable:;;Innstra=3DC3=3D9Fe 71;Passau;Bavaria;94036;Germany=

email;internet:anders@anduras.de
title:Dipl. Inf.
tel;work:++49 (0)851 / 490 50 -0
tel;fax:++49 (0)851 / 590 50 - 55
x-mozilla-html:FALSE
url:http://www.anduras.de
version:2.1
end:vcard


--------------070207030903050605040701--

--------------enigA1C63D52C3D48DB74E4105DA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFJBcRO5lKZ7Feg4EcRAu8eAJ9tSBI5LYZirfqQn00NAeRpBH7wrACgn2mA
Qp3u8Lb8I+XxLkWLZQFbwaw=
=TMpg
-----END PGP SIGNATURE-----

--------------enigA1C63D52C3D48DB74E4105DA--
