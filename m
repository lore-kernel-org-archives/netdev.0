From: Indrek Peri <Indrek.Peri@Ericsson.com>
Subject: NCM driver improvments
Date: Mon, 11 Apr 2011 13:42:15 +0200
Message-ID: <4DA2E917.9050006@Ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: <alexey.orishko@stericsson.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:42822 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772Ab1DKLlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 07:41:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all

I have some ideas what could improve NCM driver. This is just for
open discussion. 

* Timer

Current NCM driver introduces timer for sending collected packets.
Driver keeps track of actual point of sending with member tx_timer_pending
which is a counter. This counter is decreased in timeout function and
timer is restarted if counter is bigger than 0. So, currently timeouts
are static.

One idea would be to reduce of amount of timeouts in system to replace
tx_timer_pending counter with varing timer divider. For example, divider
can be from 100 to 1000 (in scales).

 ctx->tx_timer.expires = jiffies + ((HZ + 999) / tmr_divider);

Scale can be calculated form packets and their data sizes collected.
For example, if there is only one TCP download session then TX collects
many small ACKs into buffer. In this case, for example, tmr_divider is 
100 and when timer expires packets will be send out. This avoids system
timeouts.

Another idea is to try to remove timer at all if traffic is low. Every
packet will be send over in one NCM frame. This reduces RTT time for
packet.


* Locks in timeout
        
        spin_lock(&ctx->mtx);
        if (ctx->tx_timer_pending != 0) {
                ctx->tx_timer_pending--;
                restart = 1;
        } else {
                restart = 0;
        }
        spin_unlock(&ctx->mtx);

        if (restart) {
                spin_lock(&ctx->mtx);
                cdc_ncm_tx_timeout_start(ctx);
                spin_unlock(&ctx->mtx);
        } else if (ctx->netdev != NULL) {
                usbnet_start_xmit(NULL, ctx->netdev);
        }

Timer divider would reduce locking because cdc_ncm_fill_tx_frame
function keeps the lock until to the end of function.
Timeout would mean then call to send.

* reset_resume

In cdc_ncm_driver struct is function:

        .reset_resume = usbnet_resume,

I think that this is good to add.

* usbnet_tx_timeout

I have seen slow path warnings in kernel and call to usbnet_tx_timeout 
with NCM driver. There is FIXME in usbnet and may be there is a need for 
reset function inside NCM because NCM driver collects data? 

BR, Indrek Peri
