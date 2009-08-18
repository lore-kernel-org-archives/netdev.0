From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for	vbus_driver
 objects
Date: Tue, 18 Aug 2009 14:15:57 +0300
Message-ID: <4A8A8D6D.9040909@redhat.com>
References: <20090817142506.GB3602@elte.hu> <4A8971A8.2040102@gmail.com> <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com> <20090818095313.GC13878@redhat.com> <4A8A7BB9.2020906@redhat.com> <20090818100945.GD13878@redhat.com> <4A8A7EE5.6090209@redhat.com> <20090818102840.GF13878@redhat.com> <4A8A8631.1040006@redhat.com> <20090818110708.GG13878@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45803 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758805AbZHRLQS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2009 07:16:18 -0400
In-Reply-To: <20090818110708.GG13878@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/18/2009 02:07 PM, Michael S. Tsirkin wrote:
> On Tue, Aug 18, 2009 at 01:45:05PM +0300, Avi Kivity wrote:
>    
>> On 08/18/2009 01:28 PM, Michael S. Tsirkin wrote:
>>      
>>>        
>>>> Suppose a nested guest has two devices.  One a virtual device backed by
>>>> its host (our guest), and one a virtual device backed by us (the real
>>>> host), and assigned by the guest to the nested guest.  If both devices
>>>> use hypercalls, there is no way to distinguish between them.
>>>>
>>>>          
>>> Not sure I understand. What I had in mind is that devices would have to
>>> either use different hypercalls and map hypercall to address during
>>> setup, or pass address with each hypercall.  We get the hypercall,
>>> translate the address as if it was pio access, and know the destination?
>>>
>>>        
>> There are no different hypercalls.  There's just one hypercall
>> instruction, and there's no standard on how it's used.  If a nested call
>> issues a hypercall instruction, you have no idea if it's calling a
>> Hyper-V hypercall or a vbus/virtio kick.
>>      
> userspace will know which it is, because hypercall capability
> in the device has been activated, and can tell kernel, using
> something similar to iosignalfd. No?
>    

The host kernel sees a hypercall vmexit.  How does it know if it's a 
nested-guest-to-guest hypercall or a nested-guest-to-host hypercall?  
The two are equally valid at the same time.


>> You could have a protocol where you register the hypercall instruction's
>> address with its recipient, but it quickly becomes a tangled mess.
>>      
> I really thought we could pass the io address in register as an input
> parameter. Is there a way to do this in a secure manner?
>
> Hmm. Doesn't kvm use hypercalls now? How does this work with nesting?
> For example, in this code in arch/x86/kvm/x86.c:
>
>          switch (nr) {
>          case KVM_HC_VAPIC_POLL_IRQ:
>                  ret = 0;
>                  break;
>          case KVM_HC_MMU_OP:
>                  r = kvm_pv_mmu_op(vcpu, a0, hc_gpa(vcpu, a1, a2),&ret);
>                  break;
>          default:
>                  ret = -KVM_ENOSYS;
>                  break;
>          }
>
> how do we know that it's the guest and not the nested guest performing
> the hypercall?
>    

The host knows whether the guest or nested guest are running.  If the 
guest is running, it's a guest-to-host hypercall.  If the nested guest 
is running, it's a nested-guest-to-guest hypercall.  We don't have 
nested-guest-to-host hypercalls (and couldn't unless we get agreement on 
a protocol from all hypervisor vendors).

-- 
error compiling committee.c: too many arguments to function

