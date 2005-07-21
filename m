From: P@draigBrady.com
Subject: Re: Re: drop counts
Date: Thu, 21 Jul 2005 14:36:41 +0100
Message-ID: <42DFA4E9.5060602@draigBrady.com>
References: <42DCDCAF.1060005@draigBrady.com> <42DCF0F7.6000704@draigBrady.com> <Pine.WNT.4.63.0507201505370.1936@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050303090308000802020600"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: jesse.brandeburg@intel.com
In-Reply-To: <Pine.WNT.4.63.0507201505370.1936@jbrandeb-desk.amr.corp.intel.com>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050303090308000802020600
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by corvil.com id j6LDafAQ065855

Jesse Brandeburg wrote:
>=20
> dropped: rnbc does not mean dropped, see above.  mpc means dropped.
>=20
> fifo: mpc means the fifo overflowed, and the packet was dropped (the=20
> only time we drop).
>=20
> missed: this should also be mpc because it shows we missed the packet.

Wow, thanks! So there we were reporting drops prior
to 2.6.12 when there possibly were none!
I've confirmed with a traffic generator here that
rnbc does not include packets actually dropped.
It's interesting that at about 1Mpps sustained for 10s,
mpc was 548,888, while rnbc was 4,331,730 suggesting
that the nic was trying to DMA to the buffer at a
higher rate than the packet receive rate.

Anway recapping...

2.6.11 stats were mapped like:

packets =3D gprc
dropped =3D rnbc
fifo =3D mpc
missed =3D mpc

In 2.6.12 this changed to:

packets =3D gprc
dropped =3D mpc
fifo =3D mpc
missed =3D mpc

> now, its debatable if we should be reporting the same stat 3 times, but=
=20
> i still think it is correct, and its how our hardware maps stats and th=
e=20
> best we can overlay onto linux's definitions as we interpret them.

I think there still is a problem. Notice that /proc/net/dev
reports rx_dropped + rx_missed_errors for the drop column,
and so will be double counting drops currently.
Therefore I think we should be doing:

packets =3D gprc
dropped =3D 0
fifo =3D rnbc
missed =3D mpc

I'm putting rnbc in fifo as it's not accumulated into
anything else in the kernel. Also it's good to have
it reported as one can see when there is pressure on
the e1000 driver buffer. This is useful for tuning its size
to protect against drops and latency.

thanks,
P=E1draig.

--------------050303090308000802020600
Content-Type: application/x-texinfo;
 name="e1000-drops.diff"
Content-Disposition: inline;
 filename="e1000-drops.diff"
Content-Transfer-Encoding: 7bit

--- e1000_main.c	2005-05-17 21:31:44.000000000 +0000
+++ e1000_main_drops.c	2005-07-21 13:27:36.000000000 +0000
@@ -2639,11 +2639,10 @@
 		adapter->stats.crcerrs + adapter->stats.algnerrc +
 		adapter->stats.rlec + adapter->stats.mpc + 
 		adapter->stats.cexterr;
-	adapter->net_stats.rx_dropped = adapter->stats.mpc;
 	adapter->net_stats.rx_length_errors = adapter->stats.rlec;
 	adapter->net_stats.rx_crc_errors = adapter->stats.crcerrs;
 	adapter->net_stats.rx_frame_errors = adapter->stats.algnerrc;
-	adapter->net_stats.rx_fifo_errors = adapter->stats.mpc;
+	adapter->net_stats.rx_fifo_errors = adapter->stats.rnbc;
 	adapter->net_stats.rx_missed_errors = adapter->stats.mpc;
 
 	/* Tx Errors */

--------------050303090308000802020600--


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
