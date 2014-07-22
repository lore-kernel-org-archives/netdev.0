From: Ethan Zhao <ethan.kernel@gmail.com>
Subject: Re: [PATCH 1/2 V3] PCI: introduce device assignment
 interface and refactory related code
Date: Tue, 22 Jul 2014 08:35:39 +0800
Message-ID: <CABawtvMe3q5mT0_XhqiQX7Rs2Cu-dO-PAF3mrhCFpkAMOUH3dw@mail.gmail.com>
References: <1405081802-419-1-git-send-email-ethan.zhao@oracle.com>
	<1405084407.4098.59.camel@ul30vt.home>
	<1405088147.4098.64.camel@ul30vt.home>
	<B5657A6538887040AD3A81F1008BEC63B020DC@avmb3.qlogic.org>
	<1405907916.4463.2.camel@ul30vt.home>
	<CABawtvO5dSENsCzzTpxhmsUOSsSJ7=Qb08W9D+eWFOiK9m536A@mail.gmail.com>
	<B5657A6538887040AD3A81F1008BEC63B025FE@avmb3.qlogic.org>
	<1405951273.4463.4.camel@ul30vt.home>
	<B5657A6538887040AD3A81F1008BEC63B0268C@avmb3.qlogic.org>
	<1405953543.4463.19.camel@ul30vt.home> <53CD970A.8020706@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	linux-pci <linux-pci@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"vaughan.cao@oracle.com" <vaughan.cao@oracle.com>,
	"jesse.brandeburg@intel.com" <jesse.brandeburg@intel.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>, Ethan Zhao <ethan.zhao@oracle.com>,
	"linux.nics@intel.com" <linux.nics@intel.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"gleb@kernel.org" <gleb@kernel.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	"bhelgaas@google.com" <bhelgaas@google.com>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>,
	netdev <netdev@vger.kernel.org>,
	"bruce.w.allan@intel.com" <bruce.w.allan@intel.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"john.ronciak@intel.com" <john.ronciak@intel.com>,
	"david.vrabel@citrix.com" <david.vrabel@citrix.com>,
	"pbonzini@redhat.c
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <53CD970A.8020706@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Jul 22, 2014 at 6:41 AM, Alexander Duyck
<alexander.h.duyck@intel.com> wrote:
> On 07/21/2014 07:39 AM, Alex Williamson wrote:
>> On Mon, 2014-07-21 at 14:11 +0000, Yuval Mintz wrote:
>>>>>>>>>>> pci_iov_assign_device(),
>>>>>>>>>>> pci_iov_deassign_device()
>>>>>>>>>>>
>>>>>>>>>>> along with the existed one
>>>>>>>>>>>
>>>>>>>>>>> pci_vfs_assigned()
>>>>>>>>>>>
>>>>>>>>>>> They construct the VFs assignment management interface,
>>>>>>>> perhaps it's the right place to add some sort of mechanism in
>>>>>>>> order to prevent module removal once one of its VFs is assigned.
>>>>>>>> [e.g., incrementing module reference count]
>>>>>>>>
>>>>>>> On what module would the reference count be increased, the PF?
>>>>>>> The entire "VF assigned" interface is a hack to work around poor
>>>>>>> architectures like legacy KVM device assignment where there's no
>>>>>>> proper device owner for the VF.  This is "fixed" by using VFIO
>>>>>>> instead and hopefully deprecating legacy KVM assignment.  Thanks,
>>>>>>
>>>>>>   To explain what Alex said, in another word, if VMs access VF via
>>>>>> VFIO driver, the owner of the device is VFIO, in this case, if you
>>>>>> unload PF driver, you still need to unload VFIO first, then unload
>>>>>> PF driver. but the PF driver knows how to notify the VFIO driver to unload.
>>>>>>   But without VFIO like driver, for example some of current code
>>>>>> will assign devcie (PF/VF) directly to KVM or XEN without driver in
>>>>>> the middle. and the PF driver doesn't know how to unbind the assignment...
>>>>>
>>>>> I thought about perhaps incrementing the reference count of the PF's
>>>>> module [i.e., the module supplying the driver for the PF] directly, so
>>>>> THAT module won't be removable as long as the VF is assigned.
>>>>>
>>>>> Although I don't know whether the module is even accessible; Can you
>>>>> derive a pointer to a module from a net_device struct?
>>>>
>>>> A VF is not necessarily a net device.  A pci_dev does have a physfn pointer
>>>> though.
>>>
>>> I stand corrected.
>>>
>>> Is there anything inherently wrong about this approach, though?
>>
>> What does incrementing the module reference on the PF driver accomplish?
>> We can still unbind the PF device from the driver.  That's what this "VF
>> used" flag is supposed to accomplish is preventing the PF from unbinding
>> from the driver while VFs are in use, but as has been noted, it's a
>> terrible hack.
>>
>
> Keep in mind there are also use cases such as what occurs in igb/ixgbe
> where the PF driver can be swapped out while the VFs are left in place.
>  Nothing explicitly says we cannot unload the PF driver while the VFs
> are assigned, we just cannot free the VFs or disable SR-IOV while they
> are assigned.

  unbind one PF from the driver but keep the VF reside in it ? the meanwhile
  not shutdown the PF ?

>
> In that scenario we just force the link down on the link state down on
> the VFs while the PF is not present.  I'm not sure how many people make
> use of the behavior but that is currently how we end up supporting it
> for igb/ixgbe.

  Roger !
>
> One approach would be to use a reference count for the SR-IOV itself.  I
> know in the case of the igb/ixgbe drivers we use the assigned number of
> VFs to determine if we can change the number of VFs allocated or not.  I
> imagine you could probably just use the assigned count as a reference
> count and if it is non-zero prevent SR-IOV from being disabled.

  I am managing to figure out a way to cut out the VFs assigned checking before
 disable SR_IOV... ...

  Maybe via composing  pseudo PCI driver for every user VF/PF assigned
to them ?
but does it work when PF swap out without touching VF as you mentioned ?

Thanks,
Ethan
>
> Thanks,
>
> Alex
>

------------------------------------------------------------------------------
Want fast and easy access to all the code in your enterprise? Index and
search up to 200,000 lines of code with a free copy of Black Duck
Code Sight - the same software that powers the world's largest code
search on Ohloh, the Black Duck Open Hub! Try it now.
http://p.sf.net/sfu/bds
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
