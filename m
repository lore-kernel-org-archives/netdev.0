From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [E1000-devel] Transmission limit
Date: Thu, 2 Dec 2004 19:23:24 +0100
Message-ID: <16815.23964.93437.411404@robur.slu.se>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	<41A73826.3000109@draigBrady.com>
	<16807.20052.569125.686158@robur.slu.se>
	<1101484740.24742.213.camel@mellia.lipar.polito.it>
	<41A76085.7000105@draigBrady.com>
	<1101499285.1079.45.camel@jzny.localdomain>
	<16811.8052.678955.795327@robur.slu.se>
	<1101821501.1043.43.camel@jzny.localdomain>
	<20041130134600.GA31515@xi.wantstofly.org>
	<1101824754.1044.126.camel@jzny.localdomain>
	<20041201001107.GE4203@xi.wantstofly.org>
	<1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net>
	<16813.58484.343629.570703@robur.slu.se>
	<1101919791.5198.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Lennert Buytenhek <buytenh@wantstofly.org>, jamal <hadi@cyberus.ca>,
        P@draigBrady.com, mellia@prezzemolo.polito.it,
        e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: sfeldma@pobox.com
In-Reply-To: <1101919791.5198.15.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello!

Below is little patch to clean skb at xmit. It's old jungle trick Jamal
and I used w. tulip. Note we can now even decrease the size of TX ring.

It can increase TX performance from 800 kpps to
  1125128pps 576Mb/sec (576065536bps) errors: 0
  1124946pps 575Mb/sec (575972352bps) errors: 0

But suffers from scheduling problems as the previous patch. Often we just get
  582108pps 298Mb/sec (298039296bps) errors: 0

When the sender CPU free (it's) skb's. we might get some "TX free affinity"
which are unrelated to irq affinity of course not 100% perfect.
 
And some of Scotts may still be used. 

--- drivers/net/e1000/e1000.h.orig	2004-12-01 13:59:36.000000000 +0100
+++ drivers/net/e1000/e1000.h	2004-12-02 20:11:31.000000000 +0100
@@ -103,7 +103,7 @@
 #define E1000_MAX_INTR 10
 
 /* TX/RX descriptor defines */
-#define E1000_DEFAULT_TXD                  256
+#define E1000_DEFAULT_TXD                  128
 #define E1000_MAX_TXD                      256
 #define E1000_MIN_TXD                       80
 #define E1000_MAX_82544_TXD               4096
--- drivers/net/e1000/e1000_main.c.orig	2004-12-01 13:59:36.000000000 +0100
+++ drivers/net/e1000/e1000_main.c	2004-12-02 20:37:40.000000000 +0100
@@ -1820,6 +1820,10 @@
  		return NETDEV_TX_LOCKED; 
  	} 
 
+
+	if( adapter->tx_ring.next_to_use - adapter->tx_ring.next_to_clean > 80 )
+		e1000_clean_tx_ring(adapter);
+
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */
 	if(E1000_DESC_UNUSED(&adapter->tx_ring) < count + 2) {


						  --ro
