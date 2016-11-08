From: Hisashi T Fujinaka <htodd@twofifty.com>
Subject: Re: [Intel-wired-lan] [PATCH] igb: use igb_adapter->io_addr instead
 of e1000_hw->hw_addr
Date: Tue, 8 Nov 2016 09:16:48 -0800 (PST)
Message-ID: <alpine.NEB.2.20.17.1611080910530.6177@chris.i8u.org>
References: <1478588780-24480-1-git-send-email-caoj.fnst@cn.fujitsu.com> <20161108164214.GF31855@calimero.vinschen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: Cao jin <caoj.fnst@cn.fujitsu.com>, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org, linux-kernel@vger.kernel.org,
        izumi.taku@jp.fujitsu.com
To: Corinna Vinschen <vinschen@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161108164214.GF31855@calimero.vinschen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 8 Nov 2016, Corinna Vinschen wrote:

> On Nov  8 15:06, Cao jin wrote:
>> When running as guest, under certain condition, it will oops as following.
>> writel() in igb_configure_tx_ring() results in oops, because hw->hw_addr
>> is NULL. While other register access won't oops kernel because they use
>> wr32/rd32 which have a defense against NULL pointer.
>>
>>     [  141.225449] pcieport 0000:00:1c.0: AER: Multiple Uncorrected (Fatal)
>>     error received: id=0101
>>     [  141.225523] igb 0000:01:00.1: PCIe Bus Error:
>>     severity=Uncorrected (Fatal), type=Unaccessible,
>>     id=0101(Unregistered Agent ID)
>>     [  141.299442] igb 0000:01:00.1: broadcast error_detected message
>>     [  141.300539] igb 0000:01:00.0 enp1s0f0: PCIe link lost, device now
>>     detached
>>     [  141.351019] igb 0000:01:00.1 enp1s0f1: PCIe link lost, device now
>>     detached
>>     [  143.465904] pcieport 0000:00:1c.0: Root Port link has been reset
>>     [  143.465994] igb 0000:01:00.1: broadcast slot_reset message
>>     [  143.466039] igb 0000:01:00.0: enabling device (0000 -> 0002)
>>     [  144.389078] igb 0000:01:00.1: enabling device (0000 -> 0002)
>>     [  145.312078] igb 0000:01:00.1: broadcast resume message
>>     [  145.322211] BUG: unable to handle kernel paging request at
>>     0000000000003818
>>     [  145.361275] IP: [<ffffffffa02fd38d>]
>>     igb_configure_tx_ring+0x14d/0x280 [igb]
>>     [  145.400048] PGD 0
>>     [  145.438007] Oops: 0002 [#1] SMP
>>
>> A similiar issue & solution could be found at:
>>     http://patchwork.ozlabs.org/patch/689592/
>>
>> Signed-off-by: Cao jin <caoj.fnst@cn.fujitsu.com>
>> ---
>>  drivers/net/ethernet/intel/igb/igb_main.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
>> index edc9a6a..3f240ac 100644
>> --- a/drivers/net/ethernet/intel/igb/igb_main.c
>> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
>> @@ -3390,7 +3390,7 @@ void igb_configure_tx_ring(struct igb_adapter *adapter,
>>  	     tdba & 0x00000000ffffffffULL);
>>  	wr32(E1000_TDBAH(reg_idx), tdba >> 32);
>>
>> -	ring->tail = hw->hw_addr + E1000_TDT(reg_idx);
>> +	ring->tail = adapter->io_addr + E1000_TDT(reg_idx);
>>  	wr32(E1000_TDH(reg_idx), 0);
>>  	writel(0, ring->tail);
>>
>> @@ -3729,7 +3729,7 @@ void igb_configure_rx_ring(struct igb_adapter *adapter,
>>  	     ring->count * sizeof(union e1000_adv_rx_desc));
>>
>>  	/* initialize head and tail */
>> -	ring->tail = hw->hw_addr + E1000_RDT(reg_idx);
>> +	ring->tail = adapter->io_addr + E1000_RDT(reg_idx);
>>  	wr32(E1000_RDH(reg_idx), 0);
>>  	writel(0, ring->tail);
>>
>> --
>> 2.1.0
>
> Incidentally we're just looking for a solution to that problem too.
> Do three patches to fix the same problem at rougly the same time already
> qualify as freak accident?
>
> FTR, I attached my current patch, which I was planning to submit after
> some external testing.
>
> However, all three patches have one thing in common:  They workaround
> a somewhat dubious resetting of the hardware address to NULL in case
> reading from a register failed.
>
> That makes me wonder if setting the hardware address to NULL in
> rd32/igb_rd32 is really such a good idea.  It's performed in a function
> which return value is *never* tested for validity in the calling
> functions and leads to subsequent crashes since no tests for hw_addr ==
> NULL are performed.
>
> Maybe commit 22a8b2915 should be reconsidered?  Isn't there some more
> graceful way to handle the "surprise removal"?

Answering this from my home account because, well, work is Outlook.

"Reconsidering" would be great. In fact, revert if if you'd like. I'm
uncertain that the surprise removal code actually works the way I
thought previously and I think I took a lot of it out of my local code.

Unfortuantely I don't have any equipment that I can use to reproduce
surprise removal any longer so that means I wouldn't be able to test
anything. I have to defer to you or Cao Jin.

-- 
Hisashi T Fujinaka - htodd@twofifty.com (todd.fujinaka@intel.com)
