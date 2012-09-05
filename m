From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/10] net/macb: Fix a race in macb_start_xmit()
Date: Wed, 05 Sep 2012 17:30:23 -0400 (EDT)
Message-ID: <20120905.173023.2235590074897156746.davem@davemloft.net>
References: <cover.1346775479.git.nicolas.ferre@atmel.com>
 <40f02ee50a29aaec6c949432a1bcf09f4b027181.1346775479.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, patrice.vilchez@atmel.com,
 linux-kernel@vger.kernel.org, havard@skinnemoen.net, jamie@jamieiles.com,
 plagnioj@jcrosoft.com, linux-arm-kernel@lists.infradead.org
To: nicolas.ferre@atmel.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <40f02ee50a29aaec6c949432a1bcf09f4b027181.1346775479.git.nicolas.ferre@atmel.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Nicolas Ferre <nicolas.ferre@atmel.com>
Date: Wed, 5 Sep 2012 10:19:11 +0200

> From: Havard Skinnemoen <havard@skinnemoen.net>
> 
> Fix a race in macb_start_xmit() where we unconditionally set the TSTART bit.
> If an underrun just happened (we do this with interrupts disabled, so it might
> not have been handled yet), the controller starts transmitting from the first
> entry in the ring, which is usually wrong.
> Restart the controller after error handling.
> 
> Signed-off-by: Havard Skinnemoen <havard@skinnemoen.net>
> [nicolas.ferre@atmel.com: split patch in topics]
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Accumulating special case code and checks into the hot path of TX packet
processing is extremely unwise.

Instead, when you handle the TX error conditions and reset the chip you
should first ensure that there are no flows of control in the transmit
function of your driver by using the appropriate locking et al. facilities.

For example, you can quiesce the transmit path by handling the chip error
interrupt as follows:

1) Disable chip interrupt generation.

2) Schedule a workqueue so you can process the reset outside of hard
   interrupt context.

3) In the workqueue function, disable NAPI and perform a
   netif_tx_disable() to guarentee there are no threads of
   execution trying to queue up packets for TX into the driver.

4) Perform your chip reset and whatever else is necessary.

5) Re-enable NAPI and TX.

Then you don't need any special checks in your xmit method at all.
