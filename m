From: Stefan Assmann <sassmann@kpanic.de>
Subject: Re: [net-next] igb: assume MSI-X interrupts during initialization
Date: Wed, 10 Feb 2016 11:26:52 +0100
Message-ID: <56BB106C.40106@kpanic.de>
References: <1442493970-20073-1-git-send-email-sassmann@kpanic.de>
 <56B5131D.1070505@redhat.com> <56B52C7C.3000500@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: Laine Stump <laine@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from app1a.xlhost.de ([84.200.252.161]:38754 "EHLO app1a.xlhost.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757704AbcBJK07 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 05:26:59 -0500
In-Reply-To: <56B52C7C.3000500@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06.02.2016 00:13, Stefan Assmann wrote:
> On 02/05/2016 10:24 PM, Laine Stump wrote:
>> Stefan,
>>
>> I have an AMD 990FX system with an Intel 82576 card that could not
>> successfully boot with any kernel starting somewhere prior to 4.2, but
>> does boot properly in 4.4+. After a lot of time bisecting, I found that
>> this patch, when applied to kernel 4.3.0, solves the problem (applying
>> to 4.2.0 has no effect, so there's some other patch/patches in the
>> interim that were also part of the fix).
>>
>> Since I don't know the details of proposing this patch for 4.3 stable,
>> would it be possible for you to do that?
>>
>> Thanks!
> 
> Hi Laine,
> 
> I took a quick look at 4.3 and the patch you mention should be
> sufficient. For 4.2 I'll have to take a closer look. I'm currently
> traveling but going to get back to you early next week.
> 
> I'd like double check things before taking any action.

I've tried to reproduce your issue on several systems, mostly Intel
though, without success running 4.2 or 4.3. As I know you mostly care
for 4.3 (current fedora) I'd suggest to queue commit

cbfe360a1541a32e9e28f8f8ac925d2b7979d767 igb: assume MSI-X interrupts
during initialization

to 4.3-stable as it's a follow-up fix to

ceee3450b3a85db05a107d54fbea031c77d30401 igb: make sure SR-IOV init uses
the right number of queues

Dave, if you agree with that please queue the patch for 4.3-stable.
Thanks!

  Stefan


> 
> Thanks!
> 
>    Stefan
> 
>> The full saga of my problem and investigaton is here:
>>
>> https://www.mail-archive.com/iommu@lists.linux-foundation.org/msg10687.html
>>
>>
>> On 09/17/2015 08:46 AM, Stefan Assmann wrote:
>>> In igb_sw_init() the sequence of calls was changed from
>>> igb_init_queue_configuration()
>>> igb_init_interrupt_scheme()
>>> igb_probe_vfs()
>>> to
>>> igb_probe_vfs()
>>> igb_init_queue_configuration()
>>> igb_init_interrupt_scheme()
>>>
>>> This results in adapter->flags not having the IGB_FLAG_HAS_MSIX bit set
>>> during igb_probe_vfs()->igb_enable_sriov(). Therefore SR-IOV does not
>>> get enabled properly and we run into a NULL pointer if the max_vfs
>>> module parameter is specified (adapter->vf_data does not get allocated,
>>> crash on accessing the structure).
>>>
>>> [    7.419348] BUG: unable to handle kernel NULL pointer dereference
>>> at 0000000000000048
>>> [    7.419367] IP: [<ffffffffa02161c6>] igb_reset+0xe6/0x5d0 [igb]
>>> [    7.419370] PGD 0
>>> [    7.419373] Oops: 0002 [#1] SMP
>>> [    7.419381] Modules linked in: ahci(+) libahci igb(+) i40e(+) vxlan
>>> ip6_udp_tunnel udp_tunnel megaraid_sas(+) ixgbe(+) mdio
>>> [    7.419385] CPU: 0 PID: 4 Comm: kworker/0:0 Not tainted 4.2.0+ #153
>>> [    7.419387] Hardware name: Dell Inc. PowerEdge R720/0C4Y3R, BIOS
>>> 1.6.0 03/07/2013
>>> [...]
>>> [    7.419431] Call Trace:
>>> [    7.419442]  [<ffffffffa0217236>] igb_probe+0x8b6/0x1340 [igb]
>>> [    7.419447]  [<ffffffff814c7f15>] local_pci_probe+0x45/0xa0
>>>
>>> Prevent this by setting the IGB_FLAG_HAS_MSIX bit before calling
>>> igb_probe_vfs(). The real interrupt capabilities will be checked during
>>> igb_init_interrupt_scheme() so this is safe to do.
>>>
>>> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
>>> ---
>>>   drivers/net/ethernet/intel/igb/igb_main.c | 3 +++
>>>   1 file changed, 3 insertions(+)
>>>
>>> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
>>> b/drivers/net/ethernet/intel/igb/igb_main.c
>>> index e174fbb..ba019fc 100644
>>> --- a/drivers/net/ethernet/intel/igb/igb_main.c
>>> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
>>> @@ -2986,6 +2986,9 @@ static int igb_sw_init(struct igb_adapter *adapter)
>>>       }
>>>   #endif /* CONFIG_PCI_IOV */
>>>
>>> +    /* Assume MSI-X interrupts, will be checked during IRQ allocation */
>>> +    adapter->flags |= IGB_FLAG_HAS_MSIX;
>>> +
>>>       igb_probe_vfs(adapter);
>>>
>>>       igb_init_queue_configuration(adapter);
>>>
>>
> 
