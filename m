From: Robin Humble <rjh@cita.utoronto.ca>
Subject: [RFC] e1000 performance patch
Date: Wed, 26 Apr 2006 18:13:53 -0400
Message-ID: <20060426221353.GA22143@lemming.cita.utoronto.ca>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="J2SCkAp4GZ/dPZZf"
Return-path: <netdev-owner@vger.kernel.org>
Received: from quail.cita.utoronto.ca ([128.100.76.6]:49347 "EHLO
	quail.cita.utoronto.ca") by vger.kernel.org with ESMTP
	id S964901AbWDZWOa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 18:14:30 -0400
Received: from cita.utoronto.ca (lemming.cita.utoronto.ca [128.100.76.53])
	by quail.cita.utoronto.ca (8.13.1/8.13.1) with ESMTP id k3QMDr2p017276
	for <netdev@vger.kernel.org>; Wed, 26 Apr 2006 18:13:53 -0400
Received: from lemming.cita.utoronto.ca (localhost [127.0.0.1])
	by cita.utoronto.ca (8.13.6/8.12.8) with ESMTP id k3QMDrbs025495
	for <netdev@vger.kernel.org>; Wed, 26 Apr 2006 18:13:53 -0400
Received: (from rjh@localhost)
	by lemming.cita.utoronto.ca (8.13.6/8.13.6/Submit) id k3QMDrLU025494
	for netdev@vger.kernel.org; Wed, 26 Apr 2006 18:13:53 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


[I sent this to the e1000-devel folks, and they suggested netdev might
 have opinions too. the below text has changed a little bit to reflect
 feedback from Auke Kok]

attached is a small patch for e1000 that dynamically changes Interrupt
Throttle Rate for best performance - both latency and bandwidth.
it makes e1000 look really good on netpipe with a ~28 us latency and
890 Mbit/s bandwidth.

the basic idea is that high InterruptThrottleRate (~200k) is best for
small messages, whilst low ITR (~15k) is best for large messages.
leaving the ITR high for large messages burns outrageous amounts of cpu,
and any less than ~15k ITR is bad for bandwidth.

so this patch creates a new "performance dynamic" mode
  InterruptThrottleRate=2   (2,2 for dual NICS)
which changes the ITR on the fly. the patch is based on the existing
"dynamic" mode (ITR=1) which seems to be optimised for low cpu usage
with little concern for performance.

hopefully the thresholds chosen for ITR changeovers will be ok on other
people's hardware too, but I really have no idea how universal it'll be.
we've been running it for a few months on our cluster and it appears stable.

10M 20M 100M as thresholds for changing between the 200k 90k 30 15k ITRs
were set pretty much by eye - by doing a bunch of netpipe runs and
trying to minimise cpu usage (ITR) for a target latency/bandwidth.

I've done an analysis of performance on this page:
  http://www.cita.utoronto.ca/mediawiki/index.php/E1000_performance_patch
our hardware details are there too.
there's also a link to another analysis of how the patch affects routing
performance and cpu usage (surprisingly better).

despite the netpipe improvements, I haven't seen much in the way of real
world code differences (either +ve or -ve) from a regular 15k ITR. I've
seen an improvement in one code, and a slight degradation (~1%) in HPL
(top500.org benchmark). it should probably make the most difference for
codes that consistantly send small (< 1k) messages.

one possible improvement would be if the watchdog routine was called
more than once every 2 seconds - that would allow the ITR to adapt more
often.
ideally (I think) for traffic with mixed packet sizes the ITR would be
adapted 100's of times a second, but I'm not sure how practical that is.

cheers,
robin

--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="rjh-performance-e1000-7.0.33.patch"

diff -ru e1000-7.0.33/src/e1000_main.c e1000-7.0.33-rjh-performance/src/e1000_main.c
--- e1000-7.0.33/src/e1000_main.c	2006-02-03 16:53:41.000000000 -0500
+++ e1000-7.0.33-rjh-performance/src/e1000_main.c	2006-04-01 21:44:21.000000000 -0500
@@ -1732,7 +1732,7 @@
 
 	if (hw->mac_type >= e1000_82540) {
 		E1000_WRITE_REG(hw, RADV, adapter->rx_abs_int_delay);
-		if (adapter->itr > 1)
+		if (adapter->itr > 2)
 			E1000_WRITE_REG(hw, ITR,
 				1000000000 / (adapter->itr * 256));
 	}
@@ -2394,17 +2394,30 @@
 		}
 	}
 
-	/* Dynamic mode for Interrupt Throttle Rate (ITR) */
-	if (adapter->hw.mac_type >= e1000_82540 && adapter->itr == 1) {
-		/* Symmetric Tx/Rx gets a reduced ITR=2000; Total
-		 * asymmetrical Tx or Rx gets ITR=8000; everyone
-		 * else is between 2000-8000. */
-		uint32_t goc = (adapter->gotcl + adapter->gorcl) / 10000;
-		uint32_t dif = (adapter->gotcl > adapter->gorcl ?
-			adapter->gotcl - adapter->gorcl :
-			adapter->gorcl - adapter->gotcl) / 10000;
-		uint32_t itr = goc > 0 ? (dif * 6000 / goc + 2000) : 8000;
-		E1000_WRITE_REG(&adapter->hw, ITR, 1000000000 / (itr * 256));
+	/* Dynamic modes for Interrupt Throttle Rate (ITR) */
+	if (adapter->hw.mac_type >= e1000_82540) {
+		if (adapter->itr == 1) {
+			/* Symmetric Tx/Rx gets a reduced ITR=2000; Total
+			 * asymmetrical Tx or Rx gets ITR=8000; everyone
+			 * else is between 2000-8000. */
+			uint32_t goc = (adapter->gotcl + adapter->gorcl) / 10000;
+			uint32_t dif = (adapter->gotcl > adapter->gorcl ?
+				adapter->gotcl - adapter->gorcl :
+				adapter->gorcl - adapter->gotcl) / 10000;
+			uint32_t itr = goc > 0 ? (dif * 6000 / goc + 2000) : 8000;
+			E1000_WRITE_REG(&adapter->hw, ITR, 1000000000 / (itr * 256));
+		}
+		else if (adapter->itr == 2) {  /* low latency, high bandwidth, moderate cpu usage */
+			/* range from high itr at low cl, to low itr at high cl
+			 *   < 10M      =>  large itr
+			 * 10M to 20M   =>  90k itr
+                         * 20M to 100M  =>  30k itr
+			 *   > 100M     =>  15k itr    */
+			uint32_t goc = max(adapter->gotcl, adapter->gorcl) / 1000000;
+			uint32_t itr = goc > 10 ? (goc > 20 ? (goc > 100 ? 15000: 30000): 90000): 200000;
+			/* DPRINTK(PROBE, INFO, "e1000 ITR %d - [tr]cl min/ave/max %dm / %dm/ %dm\n", itr, min(adapter->gotcl, adapter->gorcl) / 1000000, (adapter->gotcl + adapter->gorcl) / 2000000, max(adapter->gotcl, adapter->gorcl) / 1000000 ); */
+			E1000_WRITE_REG(&adapter->hw, ITR, 1000000000 / (itr * 256));
+		}
 	}
 
 	/* Cause software interrupt to ensure rx ring is cleaned */
diff -ru e1000-7.0.33/src/e1000_param.c e1000-7.0.33-rjh-performance/src/e1000_param.c
--- e1000-7.0.33/src/e1000_param.c	2006-02-03 16:53:41.000000000 -0500
+++ e1000-7.0.33-rjh-performance/src/e1000_param.c	2006-03-29 21:42:00.000000000 -0500
@@ -538,6 +538,10 @@
 				DPRINTK(PROBE, INFO, "%s set to dynamic mode\n",
 					opt.name);
 				break;
+			case 2:
+				DPRINTK(PROBE, INFO, "%s set to performance dynamic mode\n",
+					opt.name);
+				break;
 			default:
 				e1000_validate_option(&adapter->itr, &opt,
 					adapter);

--J2SCkAp4GZ/dPZZf--
