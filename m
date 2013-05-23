From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH 6/7] PCI: Make sure VF's driver get attached after PF's
Date: Thu, 23 May 2013 09:43:16 +0300
Message-ID: <CAJZOPZJE_uS5HpE7rMsen9eFVZBaVWqYBrO3SyPO0j3pob6maA@mail.gmail.com>
References: <1368498506-25857-1-git-send-email-yinghai@kernel.org>
	<1368498506-25857-7-git-send-email-yinghai@kernel.org>
	<51925FB0.4080504@intel.com>
	<CAE9FiQXYQEAZ=0sG6+2OdffBqfLS9MpoN1xviRR9aDbxPxcKxQ@mail.gmail.com>
	<5192946F.1050700@intel.com>
	<CAE9FiQVGGHB_amKw0-DfDifpTnRGPbxA+q3WY5F-O3x-sx386A@mail.gmail.com>
	<5192AEF4.1070905@intel.com>
	<519BE778.9040800@redhat.com>
	<20130521214912.GA21713@redhat.com>
	<519BEEA4.2030804@gmail.com>
	<20130521221117.GB803@redhat.com>
	<519BF594.1020607@gmail.com>
	<CAJZOPZKsp2_Fr3xY0NZfz5QDLn-=2fn+kL0w55EihuUgDZWEiw@mail.gmail.com>
	<519D3B61.5030700@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
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
To: Don Dutile <ddutile@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <519D3B61.5030700@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 23, 2013 at 12:40 AM, Don Dutile <ddutile@redhat.com> wrote:
> On 05/22/2013 04:16 PM, Or Gerlitz wrote:
[...]
>> Hi Alex, all, so to clarify:
>>
>> 1. currently due to current firmware limitation we must call pci_enable_sriov before the
>> PF ends its initialization sequence done in the PCI probe callback, hence
>>
>> 2. we can't move to the new sysfs API for enabling SRIOV
>>
>> 3. as of 3.9-rc1 we see these nested brobes, bisected that to be as of
>> commit 90888ac01d059e38ffe77a2291d44cafa9016fb "driver core: fix
>> possible missing of device probe". But we didn't reach into consensus
>> with the author that this wasn't possible before the commit, nor this
>> is something that needs to be avoided, see
>> http://marc.info/?t=136249697200007&r=1&w=2
>>
>> 4. I am not sure if/how we can modify the PF code to support the case
>> where VFs are probed and start thier initialization sequence before
>> the PF is done with its initialization
>>
>> 5. etc
>>
>> all in all, we will look into returning  -EPROBE_DEFER from the VF
>> when they identify the problematic situation -- so for how much time
>> this is deferred? or if this isn't time based what the logical
>> condition which once met the VF probe is attempted again?
>>
> ah, sounds device specific.... i.e., it goes back to PF probe....
>
> So, I'm assuming some sort of init/info-xchg is done btwn VF & PF
> and has to be done to some level before PF can continue it's pci-probe
> operation.  In that case, has the VF & PF done sufficient init/info-xchg
> on 1st call, that the PF can continue, and then queue up a sriov-enable
> at the end of PF probe ?

not exactly (sorry if repeating myself) -- currently we must call
pci_enable_sriov
before the PF ends its initialization sequence done in its probe
function. As soon as
pci_enable_sriov is called, VFs are started to get probed and they
detect that the PF has
not done its initialization and hence the VF init/info-xchng can't be
done. As to your question,
we can't allow for VFs to start their probing before the PF did
sriov-enable b/c of the that very same limitation.

Summing up my recollection of the the 2-3 related thread that were around lately

1. when the VF see they can't probe, we will return  -EPROBE_DEFER -
this will fix the mlx4 specific issue

2. once the limitation is removed, mlx4 will implement the sysfs
method so doing sriov-enable will be decoupled from PF probing

3. since nested probing is more general, still need to see if/which of
Michael/Tejun/Alex patch needs to go in

makes sense?

Or.
