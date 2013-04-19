From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Fri, 19 Apr 2013 13:21:27 +1000
Message-ID: <20130419132127.05ea53adec329ca794d62be7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__19_Apr_2013_13_21_27_+1000_dvd23tER/adnHB1W"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Martin =?UTF-8?B?SHVuZGViw7hsbA==?= <martin@hundeboll.net>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__19_Apr_2013_13_21_27_+1000_dvd23tER/adnHB1W
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (x86_64
allmodconfig) failed like this:

net/batman-adv/network-coding.c: In function 'batadv_nc_skb_store_sniffed_u=
nicast':
net/batman-adv/network-coding.c:1487:2: warning: passing argument 1 of 'bat=
adv_is_my_mac' from incompatible pointer type [enabled by default]
net/batman-adv/main.h:168:5: note: expected 'struct batadv_priv *' but argu=
ment is of type 'unsigned char *'
net/batman-adv/network-coding.c:1487:2: error: too few arguments to functio=
n 'batadv_is_my_mac'
net/batman-adv/main.h:168:5: note: declared here
net/batman-adv/network-coding.c: In function 'batadv_nc_skb_decode_packet':
net/batman-adv/network-coding.c:1540:2: warning: passing argument 1 of 'bat=
adv_is_my_mac' from incompatible pointer type [enabled by default]
net/batman-adv/main.h:168:5: note: expected 'struct batadv_priv *' but argu=
ment is of type 'uint8_t *'
net/batman-adv/network-coding.c:1540:2: error: too few arguments to functio=
n 'batadv_is_my_mac'
net/batman-adv/main.h:168:5: note: declared here
net/batman-adv/network-coding.c: In function 'batadv_nc_find_decoding_packe=
t':
net/batman-adv/network-coding.c:1611:2: warning: passing argument 1 of 'bat=
adv_is_my_mac' from incompatible pointer type [enabled by default]
net/batman-adv/main.h:168:5: note: expected 'struct batadv_priv *' but argu=
ment is of type 'uint8_t *'
net/batman-adv/network-coding.c:1611:2: error: too few arguments to functio=
n 'batadv_is_my_mac'
net/batman-adv/main.h:168:5: note: declared here
net/batman-adv/network-coding.c: In function 'batadv_nc_recv_coded_packet':
net/batman-adv/network-coding.c:1678:2: warning: passing argument 1 of 'bat=
adv_is_my_mac' from incompatible pointer type [enabled by default]
net/batman-adv/main.h:168:5: note: expected 'struct batadv_priv *' but argu=
ment is of type 'unsigned char *'
net/batman-adv/network-coding.c:1678:2: error: too few arguments to functio=
n 'batadv_is_my_mac'
net/batman-adv/main.h:168:5: note: declared here
net/batman-adv/network-coding.c:1679:6: warning: passing argument 1 of 'bat=
adv_is_my_mac' from incompatible pointer type [enabled by default]
net/batman-adv/main.h:168:5: note: expected 'struct batadv_priv *' but argu=
ment is of type 'uint8_t *'
net/batman-adv/network-coding.c:1679:6: error: too few arguments to functio=
n 'batadv_is_my_mac'
net/batman-adv/main.h:168:5: note: declared here
net/batman-adv/network-coding.c:1683:2: warning: passing argument 1 of 'bat=
adv_is_my_mac' from incompatible pointer type [enabled by default]
net/batman-adv/main.h:168:5: note: expected 'struct batadv_priv *' but argu=
ment is of type 'uint8_t *'
net/batman-adv/network-coding.c:1683:2: error: too few arguments to functio=
n 'batadv_is_my_mac'
net/batman-adv/main.h:168:5: note: declared here

Caused by commits 612d2b4fe0a1 ("batman-adv: network coding - save
overheard and tx packets for decoding") and 2df5278b0267 ("batman-adv:
network coding - receive coded packets and decode them") from the
net-next tree interacting with commit fe8a93b95145 ("batman-adv: make
is_my_mac() check for the current mesh only") from the net tree.

I added the following merge fix patch and can carry it as necessary:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 19 Apr 2013 13:13:25 +1000
Subject: [PATCH] batman-adv: merge fix for batadv_is_my_mac() API change

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/batman-adv/network-coding.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-codin=
g.c
index 6b9a544..382db5e 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -1484,7 +1484,7 @@ void batadv_nc_skb_store_sniffed_unicast(struct batad=
v_priv *bat_priv,
 {
 	struct ethhdr *ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
=20
-	if (batadv_is_my_mac(ethhdr->h_dest))
+	if (batadv_is_my_mac(bat_priv, ethhdr->h_dest))
 		return;
=20
 	/* Set data pointer to MAC header to mimic packets from our tx path */
@@ -1496,6 +1496,7 @@ void batadv_nc_skb_store_sniffed_unicast(struct batad=
v_priv *bat_priv,
 /**
  * batadv_nc_skb_decode_packet - decode given skb using the decode data st=
ored
  *  in nc_packet
+ * @bat_priv: the bat priv with all the soft interface information
  * @skb: unicast skb to decode
  * @nc_packet: decode data needed to decode the skb
  *
@@ -1503,7 +1504,7 @@ void batadv_nc_skb_store_sniffed_unicast(struct batad=
v_priv *bat_priv,
  * in case of an error.
  */
 static struct batadv_unicast_packet *
-batadv_nc_skb_decode_packet(struct sk_buff *skb,
+batadv_nc_skb_decode_packet(struct batadv_priv *bat_priv, struct sk_buff *=
skb,
 			    struct batadv_nc_packet *nc_packet)
 {
 	const int h_size =3D sizeof(struct batadv_unicast_packet);
@@ -1537,7 +1538,7 @@ batadv_nc_skb_decode_packet(struct sk_buff *skb,
 	/* Select the correct unicast header information based on the location
 	 * of our mac address in the coded_packet header
 	 */
-	if (batadv_is_my_mac(coded_packet_tmp.second_dest)) {
+	if (batadv_is_my_mac(bat_priv, coded_packet_tmp.second_dest)) {
 		/* If we are the second destination the packet was overheard,
 		 * so the Ethernet address must be copied to h_dest and
 		 * pkt_type changed from PACKET_OTHERHOST to PACKET_HOST
@@ -1608,7 +1609,7 @@ batadv_nc_find_decoding_packet(struct batadv_priv *ba=
t_priv,
=20
 	/* Select the correct packet id based on the location of our mac-addr */
 	dest =3D ethhdr->h_source;
-	if (!batadv_is_my_mac(coded->second_dest)) {
+	if (!batadv_is_my_mac(bat_priv, coded->second_dest)) {
 		source =3D coded->second_source;
 		packet_id =3D coded->second_crc;
 	} else {
@@ -1675,12 +1676,12 @@ static int batadv_nc_recv_coded_packet(struct sk_bu=
ff *skb,
 	ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
=20
 	/* Verify frame is destined for us */
-	if (!batadv_is_my_mac(ethhdr->h_dest) &&
-	    !batadv_is_my_mac(coded_packet->second_dest))
+	if (!batadv_is_my_mac(bat_priv, ethhdr->h_dest) &&
+	    !batadv_is_my_mac(bat_priv, coded_packet->second_dest))
 		return NET_RX_DROP;
=20
 	/* Update stat counter */
-	if (batadv_is_my_mac(coded_packet->second_dest))
+	if (batadv_is_my_mac(bat_priv, coded_packet->second_dest))
 		batadv_inc_counter(bat_priv, BATADV_CNT_NC_SNIFFED);
=20
 	nc_packet =3D batadv_nc_find_decoding_packet(bat_priv, ethhdr,
@@ -1698,7 +1699,7 @@ static int batadv_nc_recv_coded_packet(struct sk_buff=
 *skb,
 		goto free_nc_packet;
=20
 	/* Decode the packet */
-	unicast_packet =3D batadv_nc_skb_decode_packet(skb, nc_packet);
+	unicast_packet =3D batadv_nc_skb_decode_packet(bat_priv, skb, nc_packet);
 	if (!unicast_packet) {
 		batadv_inc_counter(bat_priv, BATADV_CNT_NC_DECODE_FAILED);
 		goto free_nc_packet;
--=20
1.8.1

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__19_Apr_2013_13_21_27_+1000_dvd23tER/adnHB1W
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRcLg3AAoJEECxmPOUX5FE9b4QAJ6ygjIGSpyNfMyEVpVirJEC
81TcDOI7aj91vCJznj3LClFo9+LsJcPyNzL58ZqG8N8cv/x6rQgGcWZb9pFVAYO1
qeHcVM90c3UWSMP5CTdphwJgh5EePGCzu7CqBcbcXJsRT/HC9WsrejoTIUpVU2Lw
ecokYEEiSgZrfIPmsIqrncK/+veBzxvnJnifooFLIUaNcQg/elIyeTxokUKPDLiG
11/lfDQN6HhcYe9BW/bWWBkey6xON2L3FNhM02/nIfs9mSDlBl+LcUUFXZ1mzfa1
LOdDQQNeWRp1N8DiEIEiDKKAm8D3oR6mGifGzyaSCW40WBle9VPTsWTmbs9PIct+
46/gxjkkSEwPK2KWU03pkD7G3GVO3mexBIZIQ4u2L0ccN2jbpJqWaiKpWpnthkHU
D0fiakgzMwIXhOrL/ZVYFggdMLvepcP2USLd9LiE6EzctNDH8vpdaTrlwxNyLt8t
RLEdiWBoUBzy/P6hIadHqtgJV/3P0BywyhSl3sil9KoXHr/OOv8VZbr1KYdIRWLk
vX48SKFentiCY7pzGnidbK/7UMNJXayeLIii9fKlR00gHXgRLlB32zOm/nqAWrhY
RaqvqmtfZUPWk2pOcPdj+EqD3eJL15/3z5VzwLQUazL+BShhurCJ2MwhXLKp3St+
BS3OGT/attBRaoLha4SZ
=bmzk
-----END PGP SIGNATURE-----

--Signature=_Fri__19_Apr_2013_13_21_27_+1000_dvd23tER/adnHB1W--
