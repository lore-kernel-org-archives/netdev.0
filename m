From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [Intel-wired-lan] [PATCH] igb: add more checks for disconnected
 adapter
Date: Tue, 06 Oct 2015 17:50:29 -0400
Message-ID: <56144225.2010308@redhat.com>
References: <1442855488-27453-1-git-send-email-jarod@redhat.com> <56007D34.1070306@gmail.com> <5600D5A2.70403@redhat.com> <5600E55B.1070406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5600E55B.1070406@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexander Duyck wrote:
> On 09/21/2015 09:14 PM, Jarod Wilson wrote:
>> Alexander Duyck wrote:
>>> On 09/21/2015 10:11 AM, Jarod Wilson wrote:
>>>> Some pci changes upcoming in 4.3 seem to cause additional disconnects,
>>>> which can happen at unfortuitous times for igb, leading to issues
>>>> such as
>>>> this, where the disconnect happened just before
>>>> igb_configure_tx_ring():
>>>>
...
>>>> Note: this is a follow-up patch in addition to the previously submitted
>>>> "igb: don't unmap NULL hw_addr"
>>>>
>>>> drivers/net/ethernet/intel/igb/igb_main.c | 15 +++++++++++++--
>>>> 1 file changed, 13 insertions(+), 2 deletions(-)
>>>>
>>>> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
>>>> b/drivers/net/ethernet/intel/igb/igb_main.c
>>>> index 6369f9e..7060edf 100644
>>>> --- a/drivers/net/ethernet/intel/igb/igb_main.c
>>>> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
>>>> @@ -952,6 +952,11 @@ static int igb_request_msix(struct igb_adapter
>>>> *adapter)
>>>> if (err)
>>>> goto err_out;
>>>>
>>>> + if (E1000_REMOVED(hw->hw_addr)) {
>>>> + err = -EIO;
>>>> + goto err_free;
>>>> + }
>>>> +
>>>> for (i = 0; i < adapter->num_q_vectors; i++) {
>>>> struct igb_q_vector *q_vector = adapter->q_vector[i];
>>>>
>>>
>>>
>>> Instead of using E1000_REMOVED we should just replace the
>>> adapter->hw.hw_addr in the setup of the itr_register with
>>> adapter->io_addr like you did for Rx/Tx below.
>>
>> I just tried that, and it reliably blows up horrifically, wedging the
>> machine to the point where all I could get was a screen shot with my
>> phone thus far, when we jump from igb_request_msix() to
>> igb_configure_msix() to igb_assign_vector() and finally to
>> igb_write_ivar(), at least as best as I can tell from what I was able to
>> see in the trace remnants still on-screen.
>
> Take a look at array_rd32, that is buggy and doesn't match up with the
> rd32 implementation. If you fix that then the blow-up should go away.
>
> You shouldn't need to worry about itr_register since it will only get
> triggered if the interrupt can be enabled and that shouldn't be able to
> happen if the device is not present.
...
>> Just switching to adapter->io_addr everywhere seems to not work as noted
>> above. :\ Note that I'm also chasing this from the other end with the
>> author of the pci patches that seem to have triggered this, so the real
>> bug might be over in pci-land, but hardening against explosions in igb
>> still seems like a worthwhile effort here.
>
> I am pretty sure array_rd32 is the problem. If you fix that then I
> suspect you should quit seeing any further issues.

Okay, I've reworked array_rd32 a bit to call igb_rd32 as well, and with 
that and some other minor tweaks, nothing blowing up. The hardware still 
doesn't work when hotplugged, due to disappearing off the pci bus 
temporarily, but I think that's a pci hotplug issue, not igb's fault. 
Things seem to behave just fine if the device is connected at boot. 
Updated patch forthcoming for dissection...

-- 
Jarod Wilson
jarod@redhat.com
