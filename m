From: P@draigBrady.com
Subject: drop counts
Date: Tue, 19 Jul 2005 11:57:51 +0100
Message-ID: <42DCDCAF.1060005__42151.3049667285$1121771254$gmane$org@draigBrady.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050106030408090609090809"
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
        e1000-devel@lists.sourceforge.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050106030408090609090809
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id j6JB8GH9008033

I'm confused about the drop count reporting in e1000
nics (and elsewhere). On e1000 nics the on nic rx buffer
drop counts are maintained in "mpc" and the in kernel buffer drops
are maintained in "rnbc".
Note also the e1000 nic does not count mpc in its
rx_packets count (gprc).
In kernel 2.6.11 and before these were mapped to the
kernel statistics like:

packets =3D gprc
dropped =3D rnbc
fifo =3D mpc
missed =3D mpc

In 2.6.12 this changed to:

packets =3D gprc
dropped =3D mpc
fifo =3D mpc
missed =3D mpc

Both are wrong I think and
I think it should do (see attached patch):

packets =3D gprc + mpc
dropped =3D mpc + rnbc
fifo =3D rnbc
missed =3D mpc

I tried to correlate this with the tg3 driver,
but that confused me also as it seems to do:

packets =3D rx_packets
dropped =3D equiv of rnbc (maintained by driver)
fifo =3D ?
missed =3D ?
errors =3D rx_errors + rx_discards

cheers,
P=C3=A1draig.

--------------050106030408090609090809
Content-Type: application/x-texinfo;
 name="e1000-drops.diff"
Content-Disposition: inline;
 filename="e1000-drops.diff"
Content-Transfer-Encoding: 7bit

--- e1000_main.c	2005-05-17 21:31:44.000000000 +0000
+++ e1000_main_drops.c	2005-07-19 10:28:36.000000000 +0000
@@ -2626,7 +2626,7 @@
 
 	/* Fill out the OS statistics structure */
 
-	adapter->net_stats.rx_packets = adapter->stats.gprc;
+	adapter->net_stats.rx_packets = adapter->stats.gprc + adapter->stats.mpc;
 	adapter->net_stats.tx_packets = adapter->stats.gptc;
 	adapter->net_stats.rx_bytes = adapter->stats.gorcl;
 	adapter->net_stats.tx_bytes = adapter->stats.gotcl;
@@ -2638,12 +2638,12 @@
 	adapter->net_stats.rx_errors = adapter->stats.rxerrc +
 		adapter->stats.crcerrs + adapter->stats.algnerrc +
 		adapter->stats.rlec + adapter->stats.mpc + 
-		adapter->stats.cexterr;
-	adapter->net_stats.rx_dropped = adapter->stats.mpc;
+		adapter->stats.rnbc + adapter->stats.cexterr;
+	adapter->net_stats.rx_dropped = adapter->stats.mpc + adapter->stats.rnbc;
 	adapter->net_stats.rx_length_errors = adapter->stats.rlec;
 	adapter->net_stats.rx_crc_errors = adapter->stats.crcerrs;
 	adapter->net_stats.rx_frame_errors = adapter->stats.algnerrc;
-	adapter->net_stats.rx_fifo_errors = adapter->stats.mpc;
+	adapter->net_stats.rx_fifo_errors = adapter->stats.rnbc;
 	adapter->net_stats.rx_missed_errors = adapter->stats.mpc;
 
 	/* Tx Errors */

--------------050106030408090609090809--
