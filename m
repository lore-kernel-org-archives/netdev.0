From: "Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>
Subject: RE: 2.6.22: ERROR: "__ucmpdi2" [drivers/net/s2io.ko] undefined!
Date: Thu, 21 Jun 2007 05:55:13 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7701C190FF@nekter>
References: <20070619204110.GA21384@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	"Leonid Grossman" <Leonid.Grossman@neterion.com>,
	"Rastapur Santosh" <santosh.rastapur@neterion.com>,
	"Ramkrishna Vepa" <ram.vepa@neterion.com>,
	"Sriram Rapuru" <Sriram.Rapuru@neterion.com>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
To: "Olaf Hering" <olaf@aepfle.de>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:53776 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750716AbXFUJzR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 05:55:17 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070619204110.GA21384@aepfle.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

We will include this fix in next set of patch submission. Thanks for the
fix.

Thanks,
~Siva 
-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Olaf Hering
Sent: Wednesday, June 20, 2007 2:11 AM
To: Stephen Hemminger
Cc: linux-kernel@vger.kernel.org; netdev@vger.kernel.org
Subject: Re: 2.6.22: ERROR: "__ucmpdi2" [drivers/net/s2io.ko] undefined!

On Tue, Jun 19, Stephen Hemminger wrote:

> On Tue, 19 Jun 2007 21:02:53 +0200
> Olaf Hering <olaf@aepfle.de> wrote:
> 
> > 
> > What happend to __ucmpdi2 from David Woodhouse?
> > google has a few hits about stuff like this on 32bit powerpc with
gcc 4.1.2:
> > 
> > ERROR: "__ucmpdi2" [drivers/net/s2io.ko] undefined!
> > 
> > using the drivers/net/s2io* files from 2.6.21 with 2.6.22-rc5 fixes 
> > the compile.
> > 
> > 25805dcf9d83098cf5492117ad2669cd14cc9b24 adds two u64 >>= 48 
> > followed by a switch statement (line 2889 and 6816).
> 
> Probably the "switch(err) {" needs a cast to a smaller type (like u8).

This change removes the calls to __ucmpdi2.

---
 drivers/net/s2io.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -2868,6 +2868,7 @@ static void tx_intr_handler(struct fifo_
 	struct tx_curr_get_info get_info, put_info;
 	struct sk_buff *skb;
 	struct TxD *txdlp;
+	u8 err_mask;
 
 	get_info = fifo_data->tx_curr_get_info;
 	memcpy(&put_info, &fifo_data->tx_curr_put_info,
sizeof(put_info)); @@ -2886,8 +2887,8 @@ static void
tx_intr_handler(struct fifo_
 			}
 
 			/* update t_code statistics */
-			err >>= 48;
-			switch(err) {
+			err_mask = err >> 48;
+			switch(err_mask) {
 				case 2:
 
nic->mac_control.stats_info->sw_stat.
 
tx_buf_abort_cnt++;
@@ -6805,6 +6806,7 @@ static int rx_osm_handler(struct ring_in
 	u16 l3_csum, l4_csum;
 	unsigned long long err = rxdp->Control_1 & RXD_T_CODE;
 	struct lro *lro;
+	u8 err_mask;
 
 	skb->dev = dev;
 
@@ -6813,8 +6815,8 @@ static int rx_osm_handler(struct ring_in
 		if (err & 0x1) {
 
sp->mac_control.stats_info->sw_stat.parity_err_cnt++;
 		}
-		err >>= 48;
-		switch(err) {
+		err_mask = err >> 48;
+		switch(err_mask) {
 			case 1:
 				sp->mac_control.stats_info->sw_stat.
 				rx_parity_err_cnt++;
@@ -6867,9 +6869,9 @@ static int rx_osm_handler(struct ring_in
 		* Note that in this case, since checksum will be
incorrect,
 		* stack will validate the same.
 		*/
-		if (err != 0x5) {
-			DBG_PRINT(ERR_DBG, "%s: Rx error Value:
0x%llx\n",
-				dev->name, err);
+		if (err_mask != 0x5) {
+			DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%x\n",
+				dev->name, err_mask);
 			sp->stats.rx_crc_errors++;
 			sp->mac_control.stats_info->sw_stat.mem_freed 
 				+= skb->truesize;
-
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
