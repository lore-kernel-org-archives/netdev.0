From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 2/3] remove irq_sem from e1000
Date: Mon, 09 Apr 2007 16:34:01 -0400
Message-ID: <461AA339.3040503@redhat.com>
References: <20070220.pBx.84771300@egw.corp.redhat.com> <461A7DD8.5040402@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, jacliburn@bellsouth.net, john.ronciak@intel.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54778 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964989AbXDIUeU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Apr 2007 16:34:20 -0400
In-Reply-To: <461A7DD8.5040402@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Chris Snook wrote:
>> From: Chris Snook <csnook@redhat.com>
>>
>> Remove unnecessary irq_sem accounting from e1000.  Tested with no 
>> problems.
> 
> 
> the major problem with this is that one of the e1000 parts (82547) still 
> requires the irq_sem. I doubt that you tested that card specifically. 
> I'm still not convinced that this patch is therefore a good idea. the 
> patch for ixgb is another thing, but for e1000 we definately want to 
> keep the irq_sem around until we get some definitive testing on all 
> adapters.
> 
> So, this patch will stay under suspicion a bit longer. Same for the ixgb 
> version.
> 
> Auke

Requires?  I acknowledge that the code is used in a special codepath for 
those cards, but it appears to be used in the same unnecessary way it is 
used everywhere else.

My testing was limited to an onboard NIC on a fairly old box I don't 
have access to anymore, as well as the e1000-derived atl1 driver.  My 
primary justification is code inspection.  The code just doesn't do 
anything productive.

	-- Chris

>>
>> Signed-off-by: Chris Snook <csnook@redhat.com>
>> -- 
>> diff -urp linux-2.6.20-git14.orig/drivers/net/e1000/e1000.h
>> linux-2.6.20-git14/drivers/net/e1000/e1000.h
>> --- linux-2.6.20-git14.orig/drivers/net/e1000/e1000.h    2007-02-19
>> 14:32:15.000000000 -0500
>> +++ linux-2.6.20-git14/drivers/net/e1000/e1000.h    2007-02-19 
>> 15:07:37.000000000
>> -0500
>> @@ -252,7 +252,6 @@ struct e1000_adapter {
>>  #ifdef CONFIG_E1000_NAPI
>>      spinlock_t tx_queue_lock;
>>  #endif
>> -    atomic_t irq_sem;
>>      unsigned int total_tx_bytes;
>>      unsigned int total_tx_packets;
>>      unsigned int total_rx_bytes;
>> diff -urp linux-2.6.20-git14.orig/drivers/net/e1000/e1000_main.c
>> linux-2.6.20-git14/drivers/net/e1000/e1000_main.c
>> --- linux-2.6.20-git14.orig/drivers/net/e1000/e1000_main.c    2007-02-19
>> 14:32:15.000000000 -0500
>> +++ linux-2.6.20-git14/drivers/net/e1000/e1000_main.c    2007-02-19
>> 15:09:28.000000000 -0500
>> @@ -349,7 +349,6 @@ static void e1000_free_irq(struct e1000_
>>  static void
>>  e1000_irq_disable(struct e1000_adapter *adapter)
>>  {
>> -    atomic_inc(&adapter->irq_sem);
>>      E1000_WRITE_REG(&adapter->hw, IMC, ~0);
>>      E1000_WRITE_FLUSH(&adapter->hw);
>>      synchronize_irq(adapter->pdev->irq);
>> @@ -363,10 +362,8 @@ e1000_irq_disable(struct e1000_adapter *
>>  static void
>>  e1000_irq_enable(struct e1000_adapter *adapter)
>>  {
>> -    if (likely(atomic_dec_and_test(&adapter->irq_sem))) {
>> -        E1000_WRITE_REG(&adapter->hw, IMS, IMS_ENABLE_MASK);
>> -        E1000_WRITE_FLUSH(&adapter->hw);
>> -    }
>> +    E1000_WRITE_REG(&adapter->hw, IMS, IMS_ENABLE_MASK);
>> +    E1000_WRITE_FLUSH(&adapter->hw);
>>  }
>>
>>  static void
>> @@ -1336,7 +1333,6 @@ e1000_sw_init(struct e1000_adapter *adap
>>      spin_lock_init(&adapter->tx_queue_lock);
>>  #endif
>>
>> -    atomic_set(&adapter->irq_sem, 1);
>>      spin_lock_init(&adapter->stats_lock);
>>
>>      set_bit(__E1000_DOWN, &adapter->flags);
>> @@ -3758,11 +3754,6 @@ e1000_intr_msi(int irq, void *data)
>>  #endif
>>      uint32_t icr = E1000_READ_REG(hw, ICR);
>>
>> -#ifdef CONFIG_E1000_NAPI
>> -    /* read ICR disables interrupts using IAM, so keep up with our
>> -     * enable/disable accounting */
>> -    atomic_inc(&adapter->irq_sem);
>> -#endif
>>      if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
>>          hw->get_link_status = 1;
>>          /* 80003ES2LAN workaround-- For packet buffer work-around on
>> @@ -3832,13 +3823,6 @@ e1000_intr(int irq, void *data)
>>      if (unlikely(hw->mac_type >= e1000_82571 &&
>>                   !(icr & E1000_ICR_INT_ASSERTED)))
>>          return IRQ_NONE;
>> -
>> -    /* Interrupt Auto-Mask...upon reading ICR,
>> -     * interrupts are masked.  No need for the
>> -     * IMC write, but it does mean we should
>> -     * account for it ASAP. */
>> -    if (likely(hw->mac_type >= e1000_82571))
>> -        atomic_inc(&adapter->irq_sem);
>>  #endif
>>
>>      if (unlikely(icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC))) {
>> @@ -3862,7 +3846,6 @@ e1000_intr(int irq, void *data)
>>  #ifdef CONFIG_E1000_NAPI
>>      if (unlikely(hw->mac_type < e1000_82571)) {
>>          /* disable interrupts, without the synchronize_irq bit */
>> -        atomic_inc(&adapter->irq_sem);
>>          E1000_WRITE_REG(hw, IMC, ~0);
>>          E1000_WRITE_FLUSH(hw);
>>      }
>> @@ -3888,7 +3871,6 @@ e1000_intr(int irq, void *data)
>>       * de-assertion state.
>>       */
>>      if (hw->mac_type == e1000_82547 || hw->mac_type == 
>> e1000_82547_rev_2) {
>> -        atomic_inc(&adapter->irq_sem);
>>          E1000_WRITE_REG(hw, IMC, ~0);
>>      }
>>
>> -
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

