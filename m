From: Don Dutile <ddutile@redhat.com>
Subject: Re: [PATCH 6/7] PCI: Make sure VF's driver get attached after PF's
Date: Wed, 22 May 2013 17:40:49 -0400
Message-ID: <519D3B61.5030700@redhat.com>
References: <1368498506-25857-1-git-send-email-yinghai@kernel.org> <1368498506-25857-7-git-send-email-yinghai@kernel.org> <51925FB0.4080504@intel.com> <CAE9FiQXYQEAZ=0sG6+2OdffBqfLS9MpoN1xviRR9aDbxPxcKxQ@mail.gmail.com> <5192946F.1050700@intel.com> <CAE9FiQVGGHB_amKw0-DfDifpTnRGPbxA+q3WY5F-O3x-sx386A@mail.gmail.com> <5192AEF4.1070905@intel.com> <519BE778.9040800@redhat.com> <20130521214912.GA21713@redhat.com> <519BEEA4.2030804@gmail.com> <20130521221117.GB803@redhat.com> <519BF594.1020607@gmail.com> <CAJZOPZKsp2_Fr3xY0NZfz5QDLn-=2fn+kL0w55EihuUgDZWEiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Yinghai Lu <yinghai@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Gu Zheng <guz.fnst@cn.fujitsu.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CAJZOPZKsp2_Fr3xY0NZfz5QDLn-=2fn+kL0w55EihuUgDZWEiw@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/22/2013 04:16 PM, Or Gerlitz wrote:
> On Wed, May 22, 2013 at 1:30 AM, Alexander Duyck
> <alexander.duyck@gmail.com>  wrote:
>> On 05/21/2013 03:11 PM, Michael S. Tsirkin wrote:
>>> On Tue, May 21, 2013 at 03:01:08PM -0700, Alexander Duyck wrote:
>>>> On 05/21/2013 02:49 PM, Michael S. Tsirkin wrote:
>>>>> On Tue, May 21, 2013 at 05:30:32PM -0400, Don Dutile wrote:
>>>>>> On 05/14/2013 05:39 PM, Alexander Duyck wrote:
>>>>>>> On 05/14/2013 12:59 PM, Yinghai Lu wrote:
>>>>>>>> On Tue, May 14, 2013 at 12:45 PM, Alexander Duyck
>>>>>>>> <alexander.h.duyck@intel.com>   wrote:
>>>>>>>>> On 05/14/2013 11:44 AM, Yinghai Lu wrote:
>>>>>>>>>> On Tue, May 14, 2013 at 9:00 AM, Alexander Duyck
>>>>>>>>>> <alexander.h.duyck@intel.com>   wrote:
>>>>>>>>>>> I'm sorry, but what is the point of this patch?  With device assignment
>>>>>>>>>>> it is always possible to have VFs loaded and the PF driver unloaded
>>>>>>>>>>> since you cannot remove the VFs if they are assigned to a VM.
>>>>>>>>>> unload PF driver will not call pci_disable_sriov?
>>>>>>>>> You cannot call pci_disable_sriov because you will panic all of the
>>>>>>>>> guests that have devices assigned.
>>>>>>>> ixgbe_remove did call pci_disable_sriov...
>>>>>>>>
>>>>>>>> for guest panic, that is another problem.
>>>>>>>> just like you pci passthrough with real pci device and hotremove the
>>>>>>>> card in host.
>>>>>>>>
>>>>>>>> ...
>>>>>>>
>>>>>>> I suggest you take another look.  In ixgbe_disable_sriov, which is the
>>>>>>> function that is called we do a check for assigned VFs.  If they are
>>>>>>> assigned then we do not call pci_disable_sriov.
>>>>>>>
>>>>>>>>
>>>>>>>>> So how does your patch actually fix this problem?  It seems like it is
>>>>>>>>> just avoiding it.
>>>>>>>> yes, until the first one is done.
>>>>>>>
>>>>>>> Avoiding the issue doesn't fix the underlying problem and instead you
>>>>>>> are likely just introducing more bugs as a result.
>>>>>>>
>>>>>>>>>  From what I can tell your problem is originating in pci_call_probe.  I
>>>>>>>>> believe it is calling work_on_cpu and that doesn't seem correct since
>>>>>>>>> the work should be taking place on a CPU already local to the PF. You
>>>>>>>>> might want to look there to see why you are trying to schedule work on a
>>>>>>>>> CPU which should be perfectly fine for you to already be doing your work on.
>>>>>>>> it always try to go with local cpu with same pxm.
>>>>>>>
>>>>>>> The problem is we really shouldn't be calling work_for_cpu in this case
>>>>>>> since we are already on the correct CPU.  What probably should be
>>>>>>> happening is that pci_call_probe should be doing a check to see if the
>>>>>>> current CPU is already contained within the device node map and if so
>>>>>>> just call local_pci_probe directly.  That way you can avoid deadlocking
>>>>>>> the system by trying to flush the CPU queue of the CPU you are currently on.
>>>>>>>
>>>>>> That's the patch that Michael Tsirkin posted for a fix,
>>>>>> but it was noted that if you have the case where the _same_ driver is used for vf&  pf,
>>>>>> other deadlocks may occur.
>>>>>> It would work in the case of ixgbe/ixgbevf, but not for something like
>>>>>> the Mellanox pf/vf driver (which is the same).
>>>>>>
>>>>>
>>>>> I think our conclusion was this is a false positive for Mellanox.
>>>>> If not, we need to understand what the deadlock is better.
>>>>>
>>>>
>>>> As I understand the issue, the problem is not a deadlock for Mellanox
>>>> (At least with either your patch or mine applied), the issue is that the
>>>> PF is not ready to handle VFs when pci_enable_sriov is called due to
>>>> some firmware issues.
>
>
>>> I haven't seen Mellanox guys say anything like this on the list. Pointers?
>>> All I saw is some lockdep warnings and Tejun says they are bogus ...
>>
>> Actually the patch I submitted is at:
>> https://patchwork.kernel.org/patch/2568881/
>>
>> It was in response to:
>> https://patchwork.kernel.org/patch/2562471/
>>
>> Basically the patch I was responding to was supposed to address both the
>> lockdep issue and a problem with mlx4 not being able to support the VFs
>> when pci_enable_sriov is called.  Yinghai had specifically called out
>> the work_on_cpu lockdep issue that you also submitted a patch for.
>>
>> As per the feedback from Yinghai it seems like my patch does resolve the
>> lockdep issue that was seen.  The other half of the issue was what we
>> have been discussing with Or in regards to delaying VF driver init via
>> something like -EPROBE_DEFER instead of trying to split up
>> pci_enable_sriov and VF probe.
>
>
> Hi Alex, all, so to clarify:
>
> 1. currently due to current firmware limitation we must call
> pci_enable_sriov before the
> PF ends its initialization sequence done in the PCI probe callback, hence
>
> 2. we can't move to the new sysfs API for enabling SRIOV
>
> 3. as of 3.9-rc1 we see these nested brobes, bisected that to be as of
> commit 90888ac01d059e38ffe77a2291d44cafa9016fb "driver core: fix
> possible missing of device probe". But we didn't reach into consensus
> with the author that this wasn't possible before the commit, nor this
> is something that needs to be avoided, see
> http://marc.info/?t=136249697200007&r=1&w=2
>
> 4. I am not sure if/how we can modify the PF code to support the case
> where VFs are probed and start thier initialization sequence before
> the PF is done with its initialization
>
> 5. etc
>
> all in all, we will look into returning  -EPROBE_DEFER from the VF
> when they identify the problematic situation -- so for how much time
> this is deferred? or if this isn't time based what the logical
> condition which once met the VF probe is attempted again?
>
ah, sounds device specific.... i.e., it goes back to PF probe....

So, I'm assuming some sort of init/info-xchg is done btwn VF & PF
and has to be done to some level before PF can continue it's pci-probe
operation.  In that case, has the VF & PF done sufficient init/info-xchg
on 1st call, that the PF can continue, and then queue up a sriov-enable
at the end of PF probe ?

>
> Or.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
