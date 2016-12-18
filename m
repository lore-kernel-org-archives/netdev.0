From: Tobias Klausmann <tobias.johannes.klausmann@mni.thm.de>
Subject: Re: regression: ath_tx_edma_tasklet() Illegal idle entry in RCU
 read-side critical section
Date: Sun, 18 Dec 2016 17:17:54 +0100
Message-ID: <58b67d5b-0275-f80f-479f-78cf748b4319@mni.thm.de>
References: <23a2a3ab-974a-ed26-6afa-aafab9bb972e@gmail.com>
 <20161218155938.GP3924@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, ath9k-devel@qca.qualcomm.com,
        linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
        netdev@vger.kernel.org, nbd@nbd.name, kvalo@qca.qualcomm.com
To: paulmck@linux.vnet.ibm.com, Gabriel C <nix.or.die@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161218155938.GP3924@linux.vnet.ibm.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

A patch for this is already floating on the ML for a while now latest: 
(ath9k: do not return early to fix rcu unlocking)

Hopefully Kalle will include it in one of his upcoming pull requests.

Greetings,

Tobias


On 18.12.2016 16:59, Paul E. McKenney wrote:
> On Sun, Dec 18, 2016 at 02:52:48PM +0100, Gabriel C wrote:
>> Hello,
>>
>> while testing kernel 4.9 I run into a weird issue with the ath9k driver.
>>
>> I can boot the box in console mode and it stay up sometime but is not usable.
> Looks to me like someone forgot an rcu_read_unlock() somewhere.  Given that
> the unmatched rcu_read_lock() appears in ath_tx_edma_tasklet(), perhaps
> that is also where the missing rcu_read_unlock() is.  And sure enough,
> in the middle of this function we have the following:
>
> 		fifo_list = &txq->txq_fifo[txq->txq_tailidx];
> 		if (list_empty(fifo_list)) {
> 			ath_txq_unlock(sc, txq);
> 			return;
> 		}
>
> This will of course return while still in an RCU read-side critical
> section.  The caller cannot tell the difference between a return here
> and falling off the end of the function, so this is likely the bug.
> Or one of the bugs, anyway.  Copying the author and committer for
> their thoughts.
>
> Please try the patch at the end of this email.
>
> 							Thanx, Paul
>
>> from dmesg :
>>
>> ===============================
>> [ INFO: suspicious RCU usage. ]
>> 4.9-fw1 #1 Tainted: G          I
>> -------------------------------
>> kernel/rcu/tree.c:705 Illegal idle entry in RCU read-side critical section.!
>>
>> other info that might help us debug this:
>>
>>
>> RCU used illegally from idle CPU!
>> rcu_scheduler_active = 1, debug_locks = 1
>> RCU used illegally from extended quiescent state!
>> 1 lock held by swapper/0/0:
>>   #0:  (rcu_read_lock){......}, at: [<ffffffffa0ee0240>] ath_tx_edma_tasklet+0x0/0x460 [ath9k]
>>
>> stack backtrace:
>> CPU: 0 PID: 0 Comm: swapper/0 Tainted: G          I     4.9-fw1 #1
>> Hardware name: FUJITSU                          PRIMERGY TX200 S5             /D2709, BIOS 6.00 Rev. 1.14.2709              02/04/2013
>>   ffff88043ee03f38 ffffffff812cf0f3 ffffffff81a11540 0000000000000001
>>   ffff88043ee03f68 ffffffff810b7865 ffffffff81a55d58 ffff88043efcedc0
>>   ffff88083cb1ca00 00000000000000d1 ffff88043ee03f88 ffffffff810dbfe8
>> Call Trace:
>>   <IRQ>
>>   [<ffffffff812cf0f3>] dump_stack+0x86/0xc3
>>   [<ffffffff810b7865>] lockdep_rcu_suspicious+0xc5/0x100
>>   [<ffffffff810dbfe8>] rcu_eqs_enter_common.constprop.62+0x128/0x130
>>   [<ffffffff810ddc78>] rcu_irq_exit+0x38/0x70
>>   [<ffffffff81067ec4>] irq_exit+0x74/0xd0
>>   [<ffffffff8101e561>] do_IRQ+0x71/0x130
>>   [<ffffffff8158700c>] common_interrupt+0x8c/0x8c
>>   <EOI>
>>   [<ffffffff81472836>] ? cpuidle_enter_state+0x156/0x220
>>   [<ffffffff81472922>] cpuidle_enter+0x12/0x20
>>   [<ffffffff810ad23e>] call_cpuidle+0x1e/0x40
>>   [<ffffffff810ad46d>] cpu_startup_entry+0x11d/0x210
>>   [<ffffffff8157892c>] rest_init+0x12c/0x140
>>   [<ffffffff81d02ec3>] start_kernel+0x40f/0x41c
>>   [<ffffffff81d02120>] ? early_idt_handler_array+0x120/0x120
>>   [<ffffffff81d02299>] x86_64_start_reservations+0x2a/0x2c
>>   [<ffffffff81d02386>] x86_64_start_kernel+0xeb/0xf8
> ------------------------------------------------------------------------
>
> commit 5a16fed76936184a7ac22e466cf39bd8bb5ee65e
> Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Date:   Sun Dec 18 07:49:00 2016 -0800
>
>      drivers/ath: Add missing rcu_read_unlock() to ath_tx_edma_tasklet()
>      
>      Commit d94a461d7a7d ("ath9k: use ieee80211_tx_status_noskb where possible")
>      added rcu_read_lock() and rcu_read_unlock() around the body of
>      ath_tx_edma_tasklet(), but failed to add the needed rcu_read_unlock()
>      before a "return" in the middle of this function.  This commit therefore
>      adds the missing rcu_read_unlock().
>      
>      Reported-by: Gabriel C <nix.or.die@gmail.com>
>      Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>      Cc: Felix Fietkau <nbd@nbd.name>
>      Cc: Kalle Valo <kvalo@qca.qualcomm.com>
>      Cc: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
>      Cc: <linux-wireless@vger.kernel.org?
>      Cc: <ath9k-devel@lists.ath9k.org>
>
> diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
> index 52bfbb988611..857d5ae09a1d 100644
> --- a/drivers/net/wireless/ath/ath9k/xmit.c
> +++ b/drivers/net/wireless/ath/ath9k/xmit.c
> @@ -2787,6 +2787,7 @@ void ath_tx_edma_tasklet(struct ath_softc *sc)
>   		fifo_list = &txq->txq_fifo[txq->txq_tailidx];
>   		if (list_empty(fifo_list)) {
>   			ath_txq_unlock(sc, txq);
> +			rcu_read_unlock();
>   			return;
>   		}
>   
>
