From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH 6/6] [IPROUTE2]: Change the rate table calc of transmit
	cost to use upper bound value
Date: Wed, 12 Sep 2007 12:14:57 +0200
Message-ID: <1189592097.26927.27.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:36431 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964940AbXILKPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 06:15:30 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 2e3edbef7913ac43899c8258ee59d9032778cee1
Author: Jesper Dangaard Brouer <hawk@comx.dk>
Date:   Wed Sep 5 15:24:51 2007 +0200

    [IPROUTE2]: Change the rate table calc of transmit cost to use upper bound value.
    
    Patrick McHardy, Cite: 'its better to overestimate than underestimate
    to stay in control of the queue'.
    
    Illustrating the rate table array:
     Legend description
       rtab[x]   : Array index x of rtab[x]
       xmit_sz   : Transmit size contained in rtab[x] (normally transmit time)
       maps[a-b] : Packet sizes from a to b, will map into rtab[x]
    
    Current/old rate table mapping (cell_log:3):
     rtab[0]:=xmit_sz:0  maps[0-7]
     rtab[1]:=xmit_sz:8  maps[8-15]
     rtab[2]:=xmit_sz:16 maps[16-23]
     rtab[3]:=xmit_sz:24 maps[24-31]
     rtab[4]:=xmit_sz:32 maps[32-39]
     rtab[5]:=xmit_sz:40 maps[40-47]
     rtab[6]:=xmit_sz:48 maps[48-55]
    
    New rate table mapping, with kernel cell_align support.
     rtab[0]:=xmit_sz:8  maps[0-8]
     rtab[1]:=xmit_sz:16 maps[9-16]
     rtab[2]:=xmit_sz:24 maps[17-24]
     rtab[3]:=xmit_sz:32 maps[25-32]
     rtab[4]:=xmit_sz:40 maps[33-40]
     rtab[5]:=xmit_sz:48 maps[41-48]
     rtab[6]:=xmit_sz:56 maps[49-56]
    
    New TC util on a kernel WITHOUT support for cell_align
     rtab[0]:=xmit_sz:8 maps[0-7]
     rtab[1]:=xmit_sz:16 maps[8-15]
     rtab[2]:=xmit_sz:24 maps[16-23]
     rtab[3]:=xmit_sz:32 maps[24-31]
     rtab[4]:=xmit_sz:40 maps[32-39]
     rtab[5]:=xmit_sz:48 maps[40-47]
     rtab[6]:=xmit_sz:56 maps[48-55]
    
    Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>

diff --git a/tc/tc_core.c b/tc/tc_core.c
index c713a18..752b07c 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -84,11 +84,12 @@ int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab, int cell_log, unsigned mt
 			cell_log++;
 	}
 	for (i=0; i<256; i++) {
-		unsigned sz = (i<<cell_log);
+		unsigned sz = ((i+1)<<cell_log);
 		if (sz < mpu)
 			sz = mpu;
 		rtab[i] = tc_calc_xmittime(bps, sz);
 	}
+	r->cell_align=-1; // Due to the sz calc
 	r->cell_log=cell_log;
 	return cell_log;
 }

