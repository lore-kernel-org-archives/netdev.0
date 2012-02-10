From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into hardware
Date: Thu, 09 Feb 2012 20:14:52 -0800
Message-ID: <4F3499BC.8020609@intel.com>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>  <20120208203627.035c6b0e@nehalam.linuxnetplumber.net>  <4F34042F.6090806@intel.com>  <20120209094047.3ea7aa56@nehalam.linuxnetplumber.net>  <4F3407F7.9000202@intel.com> <1328821894.2089.3.camel@mojatatu> <4F347D96.2020806@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38567 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754786Ab2BJEO6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Feb 2012 23:14:58 -0500
In-Reply-To: <4F347D96.2020806@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/9/2012 6:14 PM, John Fastabend wrote:
> On 2/9/2012 1:11 PM, jamal wrote:
>> On Thu, 2012-02-09 at 09:52 -0800, John Fastabend wrote:
>>
>>>>> By netlink_notifier do you mean adding a notifier_block and using atomic_notifier_call_chain()
>>>>> probably in rtnl_notify()? Then drivers could register with the notifier chain with
>>>>> atomic_notifier_chain_register() and receive the events correctly. Or did I miss
>>>>> some notifier chain that already exists?
>>>>
>>>> Yes. that is what I mean. The callbacks you need may or may not already be present.
>>
>> I'll go one step further.
>> This stuff shouldnt be in the kernel at all. 
>> The disadvantage is you need a user space app to update the hardware.
>> i.e, the same mechanism should be usable for either a switch embedded
>> in a NIC or a standalone hardware switch (with/out the s/ware bridge 
>> presence)
>>
>> cheers,
>> jamal
>>
> 
> Hi Jamal,
> 
> The user space app in this case would listen for FDB updates to the SW
> bridge and then mirror them at the embedded NIC. In this case it seems
> easier to just add a notifier chain and let the kernel keep these in
> sync. Otherwise we need a daemon in user space to replicate these.
> 
> On the other hand if you could make the same RTM_NEWNEIGH, RTM_DELNEIGH,
> and RTM_GETNEIGH work for the bridge, embedded bridge, and macvlan you
> would have one common interface to drive these. But the bridge already
> has this protocol/msgtype so that would require either some demux or
> new protocol/msgtype pairs to be created. 
> 
> Let me think on it. I'm tempted by the simplicity of adding notifier
> hooks though.
> 
> .John
> 

Actually because the bridge is adding/removing fdb entries dynamically
maybe its best this gets done in kernel. Here's the example case,


  ----------                 ---------
  | ethx.y |  <---- E        | veth0 |  <--- A
  ----------                 ---------
      |                           |
      |                           |
      |                           |
      |                     --------------
      |                     |  SW Bridge | <--- B
      |                     --------------
      |                           |
      |                           |
      |                      ---------
      |                      | eth0  |     <--- C
      |                      ---------
      |                           |
   -----------------------------------
   |        embedded switch          |     <--- D
   -----------------------------------
                   |
                   |
                   G

With the flow by letters above hope this is not too difficult to follow.

(A) veth0 a virtual device transmits packet destined for ethx.y
(B) SW bridge receives frames and updates FDB flooding to C
(C) eth0 the PF in this case sends the frame to the HW backed by the
    embedded bridge
(D) The HW embedded switch has a static entry for ethx.y and forwards
    the frame to the VF or if its a broadcast frame also floods it to
    the wire and ethx.y
(E) ethx.y receives the frame and generates a response to the dest mac of
    veth0

Now here is the potential issue,

(G) The frame transmitted from ethx.y with the destination address of
    veth0 but the embedded switch is not a learning switch. If the FDB
    update is done in user space its possible (likely?) that the FDB
    entry for veth0 has not been added to the embedded switch yet. Now
    we either have to flood the frame which is not horrible but not
    ideal or worse if the embedded switch does not support flooding send
    it to the wire and veth0 never receives it. If the SW bridge pushes
    the FDB update down into the embedded switch the address is for
    sure in the embedded switches forwarding tables and the switching
    works as expected.

So to handle this case correctly its probably best IMHO to use a notifier
hook. Having a RTM_GETNEIGH for the embedded switch implemented though
would be nice for dumping the FDB of the embedded switch and SET/DEL
could be used to configure the FDB when its not being driven by the SW
switch. Of course we should try to be minimalists here.

.John
