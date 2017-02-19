From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next 11/13] net: ethernet: aquantia: Refactoring
 buffers copying.
Date: Sun, 19 Feb 2017 11:36:51 +0100
Message-ID: <f286ae3c-bd91-559e-1e6a-68f261af3541@gmx.de>
References: <cover.1487187192.git.pavel.belous@aquantia.com>
 <de4d3c34fac8c7bbbb614f776ca1255fd6aa03a6.1487187192.git.pavel.belous@aquantia.com>
 <4262ef98-4ba5-3f1a-5b72-208be51bdd6f@gmx.de>
 <063D6719AE5E284EB5DD2968C1650D6DCFE68133@AcuExch.aculab.com>
 <trinity-c726d458-78f5-41bf-8d00-ac6d55a03c35-1487260948543@3capp-gmx-bs24>
 <063D6719AE5E284EB5DD2968C1650D6DCFE6842A@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Pavel Belous <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:59482 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751382AbdBSKhR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 19 Feb 2017 05:37:17 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFE6842A@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 16.02.2017 17:37, David Laight wrote:
> From: Lino Sanfilippo
>> Sent: 16 February 2017 16:02
> ...
>> I was referring to the copy of tx descriptors, not the frames/fragments itself.
>> I wrote "tx buffers" because in this driver a descriptor is represented as
>>  a struct "aq_ring_buff_s". I cannot see a reason why this descriptor copy
>>  should be necessary.
> 
> Not unless the descriptor memory is on the card.
> 
> Actually it might be worse than that.
> The transmit descriptor probably has an 'owner' bit.
> The write of the word containing that bit must be last and
> preceded by the appropriate barrier (probably dma_wmb()).
> Another barrier is needed before the 'doorbell' io write that kicks
> the hardware.
> 

After taking a look at the concerning code parts, I can say that there is
at least no barrier to ensure dma flush before the doorbell.
What about the patch below to fix this?

Regards,
Lino

Subject: [PATCH] net: aquantia: add memory barrier before tx descriptors are
 passed to the hardware

Add a memory barrier to ensure that tx descriptors are written completely
before the descriptors are passed to the hardware.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Suggested-by: David Laight <David.Laight@ACULAB.COM>
---
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_llh.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_llh.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_llh.c
index 3de651a..c3d73e7 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_llh.c
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_llh.c
@@ -526,6 +526,8 @@ void reg_tx_dma_desc_base_addressmswset(struct aq_hw_s *aq_hw,
 void reg_tx_dma_desc_tail_ptr_set(struct aq_hw_s *aq_hw,
 				  u32 tx_dma_desc_tail_ptr, u32 descriptor)
 {
+	/* make sure writes to dma descriptors are completed */
+	wmb();
 	aq_hw_write_reg(aq_hw, tx_dma_desc_tail_ptr_adr(descriptor),
 			tx_dma_desc_tail_ptr);
 }
-- 
2.7.4
