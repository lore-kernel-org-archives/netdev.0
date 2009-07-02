From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: tg3 driver not advertising 1000mbit
Date: Thu, 2 Jul 2009 09:42:12 -0700
Message-ID: <20090702164212.GA8430@xw6200.broadcom.net>
References: <1244831838.9225.71.camel@HP1>
 <4A32CDE9.7020602@dupondje.be> <1244844106.9225.92.camel@HP1>
 <4A32D3DB.30703@dupondje.be>
 <20090624173608.GA8985@xw6200.broadcom.net>
 <4A453E8F.3000405@dupondje.be>
 <20090627022629.GA27439@xw6200.broadcom.net>
 <4A45ED40.4090408@dupondje.be>
 <20090629185038.GA29283@xw6200.broadcom.net>
 <4A49D8ED.5060109@dupondje.be>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David Christensen" <davidch@broadcom.com>
To: "Jean-Louis Dupond" <info@dupondje.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1795 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752126AbZGBQmR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jul 2009 12:42:17 -0400
In-Reply-To: <4A49D8ED.5060109@dupondje.be>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 30, 2009 at 02:20:45AM -0700, Jean-Louis Dupond wrote:
> # ethtool -i eth0
> driver: tg3
> version: 3.97
> firmware-version: 5722-v3.08, ASFIPMI v6.02
> bus-info: 0000:01:00.0
> 
> Kernel version 2.6.29.4

Rats.  I mirrored your setup here, but I still can't reproduce the
problem.  I still suspect this is a bad driver <=> firmware interaction.

Can you apply the following patch and show me the resulting syslog
entries?  The patch is just making sure the firmware request to shutdown
really goes through.


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 46a3f86..900e28b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1124,6 +1124,9 @@ static void tg3_wait_for_event_ack(struct tg3 *tp)
 			break;
 		udelay(8);
 	}
+
+	if (i == delay_cnt)
+		printk( KERN_WARNING "Firmware didn't ack driver event!\n" );
 }
 
 /* tp->lock is held. */
@@ -6330,12 +6333,16 @@ static void tg3_stop_fw(struct tg3 *tp)
 		/* Wait for RX cpu to ACK the previous event. */
 		tg3_wait_for_event_ack(tp);
 
+		printk( KERN_NOTICE "%s: Stopping firmware.\n", tp->dev->name );
+
 		tg3_write_mem(tp, NIC_SRAM_FW_CMD_MBOX, FWCMD_NICDRV_PAUSE_FW);
 
 		tg3_generate_fw_event(tp);
 
 		/* Wait for RX cpu to ACK this event. */
 		tg3_wait_for_event_ack(tp);
+
+		printk( KERN_NOTICE "%s: Operation completed.\n", tp->dev->name );
 	}
 }
 
@@ -7537,6 +7544,8 @@ static void tg3_timer(unsigned long __opaque)
 		    !(tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)) {
 			tg3_wait_for_event_ack(tp);
 
+			printk( KERN_NOTICE "%s: Sending keepalive event.\n", tp->dev->name );
+
 			tg3_write_mem(tp, NIC_SRAM_FW_CMD_MBOX,
 				      FWCMD_NICDRV_ALIVE3);
 			tg3_write_mem(tp, NIC_SRAM_FW_CMD_LEN_MBOX, 4);

