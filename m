From: Don Dutile <ddutile@redhat.com>
Subject: Re: [PATCH 6/7] PCI: Make sure VF's driver get attached after PF's
Date: Tue, 21 May 2013 17:31:48 -0400
Message-ID: <519BE7C4.3050306@redhat.com>
References: <1368498506-25857-1-git-send-email-yinghai@kernel.org> <1368498506-25857-7-git-send-email-yinghai@kernel.org> <51925FB0.4080504@intel.com> <CAE9FiQXYQEAZ=0sG6+2OdffBqfLS9MpoN1xviRR9aDbxPxcKxQ@mail.gmail.com> <5192946F.1050700@intel.com> <CAE9FiQVGGHB_amKw0-DfDifpTnRGPbxA+q3WY5F-O3x-sx386A@mail.gmail.com> <5192AEF4.1070905@intel.com> <519BE778.9040800@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yinghai Lu <yinghai@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Gu Zheng <guz.fnst@cn.fujitsu.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <519BE778.9040800@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/21/2013 05:30 PM, Don Dutile wrote:
> On 05/14/2013 05:39 PM, Alexander Duyck wrote:
>> On 05/14/2013 12:59 PM, Yinghai Lu wrote:
>>> On Tue, May 14, 2013 at 12:45 PM, Alexander Duyck
>>> <alexander.h.duyck@intel.com> wrote:
>>>> On 05/14/2013 11:44 AM, Yinghai Lu wrote:
>>>>> On Tue, May 14, 2013 at 9:00 AM, Alexander Duyck
>>>>> <alexander.h.duyck@intel.com> wrote:
>>>>>> I'm sorry, but what is the point of this patch? With device assignment
>>>>>> it is always possible to have VFs loaded and the PF driver unloaded
>>>>>> since you cannot remove the VFs if they are assigned to a VM.
>>>>> unload PF driver will not call pci_disable_sriov?
>>>> You cannot call pci_disable_sriov because you will panic all of the
>>>> guests that have devices assigned.
>>> ixgbe_remove did call pci_disable_sriov...
>>>
>>> for guest panic, that is another problem.
>>> just like you pci passthrough with real pci device and hotremove the
>>> card in host.
>>>
>>> ...
>>
>> I suggest you take another look. In ixgbe_disable_sriov, which is the
>> function that is called we do a check for assigned VFs. If they are
>> assigned then we do not call pci_disable_sriov.
>>
>>>
>>>> So how does your patch actually fix this problem? It seems like it is
>>>> just avoiding it.
>>> yes, until the first one is done.
>>
>> Avoiding the issue doesn't fix the underlying problem and instead you
>> are likely just introducing more bugs as a result.
>>
>>>> From what I can tell your problem is originating in pci_call_probe. I
>>>> believe it is calling work_on_cpu and that doesn't seem correct since
>>>> the work should be taking place on a CPU already local to the PF. You
>>>> might want to look there to see why you are trying to schedule work on a
>>>> CPU which should be perfectly fine for you to already be doing your work on.
>>> it always try to go with local cpu with same pxm.
>>
>> The problem is we really shouldn't be calling work_for_cpu in this case
>> since we are already on the correct CPU. What probably should be
>> happening is that pci_call_probe should be doing a check to see if the
>> current CPU is already contained within the device node map and if so
>> just call local_pci_probe directly. That way you can avoid deadlocking
>> the system by trying to flush the CPU queue of the CPU you are currently on.
>>
> That's the patch that Michael Tsirkin posted for a fix,
> but it was noted that if you have the case where the _same_ driver is used for vf & pf,
> other deadlocks may occur.
> It would work in the case of ixgbe/ixgbevf, but not for something like
> the Mellanox pf/vf driver (which is the same).
>
apologies; here's the thread the discussed the issue:
https://patchwork.kernel.org/patch/2458681/

>>
>> Alex
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at http://vger.kernel.org/majordomo-info.html
>
