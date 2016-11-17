From: "Neftin, Sasha" <sasha.neftin@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH v2] e1000e: free IRQ regardless of
 __E1000_DOWN
Date: Thu, 17 Nov 2016 15:31:21 +0200
Message-ID: <baeeb0a1-a454-6c81-59e9-3cec79a524a7@intel.com>
References: <1478727681-16505-1-git-send-email-tbaicar@codeaurora.org>
 <42e53bc2-0361-e7b7-1093-4e095aa56955@intel.com>
 <dff136c7-cb6a-8a61-d311-01959bac16b9@codeaurora.org>
 <3914adae-91b2-7b74-02bc-579b3e32d143@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: "Baicar, Tyler" <tbaicar@codeaurora.org>,
        jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        okaya@codeaurora.org, timur@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3914adae-91b2-7b74-02bc-579b3e32d143@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/13/2016 10:34 AM, Neftin, Sasha wrote:
> On 11/11/2016 12:35 AM, Baicar, Tyler wrote:
>> Hello Sasha,
>>
>> On 11/9/2016 11:19 PM, Neftin, Sasha wrote:
>>> On 11/9/2016 11:41 PM, Tyler Baicar wrote:
>>>> Move IRQ free code so that it will happen regardless of the
>>>> __E1000_DOWN bit. Currently the e1000e driver only releases its IRQ
>>>> if the __E1000_DOWN bit is cleared. This is not sufficient because
>>>> it is possible for __E1000_DOWN to be set without releasing the IRQ.
>>>> In such a situation, we will hit a kernel bug later in e1000_remove
>>>> because the IRQ still has action since it was never freed. A
>>>> secondary bus reset can cause this case to happen.
>>>>
>>>> Signed-off-by: Tyler Baicar <tbaicar@codeaurora.org>
>>>> ---
>>>>   drivers/net/ethernet/intel/e1000e/netdev.c | 3 ++-
>>>>   1 file changed, 2 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c
>>>> b/drivers/net/ethernet/intel/e1000e/netdev.c
>>>> index 7017281..36cfcb0 100644
>>>> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
>>>> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
>>>> @@ -4679,12 +4679,13 @@ int e1000e_close(struct net_device *netdev)
>>>>         if (!test_bit(__E1000_DOWN, &adapter->state)) {
>>>>           e1000e_down(adapter, true);
>>>> -        e1000_free_irq(adapter);
>>>>             /* Link status message must follow this format */
>>>>           pr_info("%s NIC Link is Down\n", adapter->netdev->name);
>>>>       }               
>>>>   +    e1000_free_irq(adapter);
>>>> +
>>>>       napi_disable(&adapter->napi);
>>>>         e1000e_free_tx_resources(adapter->tx_ring);
>>>>
>>> I would like not recommend insert this change. This change related
>>> driver state machine, we afraid from lot of synchronization problem and
>>> issues.
>>> We need keep e1000_free_irq in loop and check for 'test_bit' ready.
>>
>> What do you mean here? There is no loop. If __E1000_DOWN is set then we
>> will never free the IRQ.
>>
>>> Another point, does before execute secondary bus reset your SW back up
>>> pcie configuration space as properly?
>>
>> After a secondary bus reset, the link needs to recover and go back to a
>> working state after 1 second.
>>
>> From the callstack, the issue is happening while removing the endpoint
>> from the system, before applying the secondary bus reset.
>>
>> The order of events is
>> 1. remove the drivers
>> 2. cause a secondary bus reset
>> 3. wait 1 second
> Actually, this is too much, usually link up in less than 100ms.You can
> check Data Link Layer indication.
>> 4. recover the link
>>
>> callstack:
>> free_msi_irqs+0x6c/0x1a8
>> pci_disable_msi+0xb0/0x148
>> e1000e_reset_interrupt_capability+0x60/0x78
>> e1000_remove+0xc8/0x180
>> pci_device_remove+0x48/0x118
>> __device_release_driver+0x80/0x108
>> device_release_driver+0x2c/0x40
>> pci_stop_bus_device+0xa0/0xb0
>> pci_stop_bus_device+0x3c/0xb0
>> pci_stop_root_bus+0x54/0x80
>> acpi_pci_root_remove+0x28/0x64
>> acpi_bus_trim+0x6c/0xa4
>> acpi_device_hotplug+0x19c/0x3f4
>> acpi_hotplug_work_fn+0x28/0x3c
>> process_one_work+0x150/0x460
>> worker_thread+0x50/0x4b8
>> kthread+0xd4/0xe8
>> ret_from_fork+0x10/0x50
>>
>> Thanks,
>> Tyler
>>
> Hello Tyler,
> Okay, we need consult more about this suggestion.
> May I ask what is setup you run? Is there NIC or on board LAN? I would
> like try reproduce this issue in our lab's too.
> Also, is same issue observed with same scenario and others NIC's too?
> Sasha
> _______________________________________________
> Intel-wired-lan mailing list
> Intel-wired-lan@lists.osuosl.org
> http://lists.osuosl.org/mailman/listinfo/intel-wired-lan
> 
Hello Tyler,
I see some in consistent implementation of __*_close methods in our
drivers. Do you have any igb NIC to check if same problem persist there?
Thanks,
Sasha
