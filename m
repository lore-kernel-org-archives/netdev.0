From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [net-next PATCH v4 0/8] Managing the forwarding database(FDB)
Date: Thu, 03 May 2012 22:43:20 -0700
Message-ID: <4FA36C78.80509@us.ibm.com>
References: <20120415163905.14091.30491.stgit@jf-dev1-dcblab> <20120415.130637.2258594023349277277.davem@davemloft.net> <20120502150830.GA2976@redhat.com> <4FA1ACA1.2080808@intel.com> <4FA1C50C.7010405@us.ibm.com> <4FA2DEA5.6050802@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa.prabhu@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, shemminger@vyatta.com,
	bhutchings@solarflare.com, hadi@cyberus.ca,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gregory.v.rose@intel.com, krkumar2@in.ibm.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:59489 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752124Ab2EDFob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 01:44:31 -0400
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sri@us.ibm.com>;
	Thu, 3 May 2012 23:44:30 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 997E219D804A
	for <netdev@vger.kernel.org>; Thu,  3 May 2012 23:43:41 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q445hGph221998
	for <netdev@vger.kernel.org>; Thu, 3 May 2012 23:43:36 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q445h0LN004881
	for <netdev@vger.kernel.org>; Thu, 3 May 2012 23:43:01 -0600
In-Reply-To: <4FA2DEA5.6050802@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/3/2012 12:38 PM, John Fastabend wrote:
> On 5/2/2012 4:36 PM, Sridhar Samudrala wrote:
>> On 5/2/2012 2:52 PM, John Fastabend wrote:
>>> On 5/2/2012 8:08 AM, Michael S. Tsirkin wrote:
>>>> On Sun, Apr 15, 2012 at 01:06:37PM -0400, David Miller wrote:
>>>>> From: John Fastabend<john.r.fastabend@intel.com>
>>>>> Date: Sun, 15 Apr 2012 09:43:51 -0700
>>>>>
>>>>>> The following series is a submission for net-next to allow
>>>>>> embedded switches and other stacked devices other then the
>>>>>> Linux bridge to manage a forwarding database.
>>>>>>
>>>>>> Previously discussed here,
>>>>>>
>>>>>> http://lists.openwall.net/netdev/2012/03/19/26
>>>>>>
>>>>>> v4: propagate return codes correctly for ndo_dflt_Fdb_dump()
>>>>>>
>>>>>> v3: resolve the macvlan patch 8/8 to fix a dev_set_promiscuity()
>>>>>>       error and add the flags field to change and get link routines.
>>>>>>
>>>>>> v2: addressed feedback from Ben Hutchings resolving a typo in the
>>>>>>       multicast add/del routines and improving the error handling
>>>>>>       when both NTF_SELF and NTF_MASTER are set.
>>>>>>
>>>>>> I've tested this with 'br' tool published by Stephen Hemminger
>>>>>> soon to be renamed 'bridge' I believe and various traffic
>>>>>> generators mostly pktgen, ping, and netperf.
>>>>> All applied, if we need any more tweaks we can just add them
>>>>> on top of this work.
>>>>>
>>>>> Thanks John.
>>>> John, do you plan to update kvm userspace to use this interface?
>>>>
>>> No immediate plans. I would really appreciate it if you or one
>>> of the IBM developers working in this space took it on. Of course
>>> if no one steps up I guess I can eventually get at it but it will
>>> be sometime. For now I've been doing this manually with the bridge
>>> tool yet to be published.
>>>
>>>
>> Does this mean that when we add an interface to a bridge, it need not be put in promiscuous mode and
>> add/delete fdb entries dynamically?
> The net/bridge will automatically put the interface in promisc mode
> when the device is attached. We do need to add/delete fdb entries
> though to allow forwarding packets from the virtual function and
> any emulated devices e.g. tap devices on the bridge.

Consider the following scenario where we have a SR-IOV NIC with 1 PF
and 2 VFs (VF1 & VF2).
- eth0 is the PF which is attached to bridge br0 and connected to 2 VMs 
VM1 and VM2.
- eth1 is the VF1 terminated on the host and assigned to VM3 via 
macvtap0 in passthru mode.
- VF2 is directly assigned to VM4 via pci-device assignment.

  VM1      VM2         VM3           VM4
(mac1)  (mac2)     (mac3)         (mac4)
  |        |           |             |
  |        |           |             |
vnet0   vnet1         |             |
  |        |           |             |
  \        /           |             |
   \      /            |             |
     br0            macvtap0         |
      |              (mac3)          |
      |                |             |
     eth0            eth1            |
      |              (mac3)          |
      |               |              |
    ------------------------------------
   | PF              VF1           VF2  |
   |                                    |
   |                 VEB                |
   ------------------------------------

In this setup, i think when VM1 and VM2 come up, mac1 and mac2 have to 
be added to the
embedded bridge's fdb.  Once we add these 2 entries, all the 4 VMs can 
talk to each other.
Is this correct?

Now, if VM1 or VM2 wants to add secondary mac addresses, i think we need 
qemu to add a new fdb
entry when it receives add mac address command via virtio control vq.

Can we add multiple mac addresses to VFs? For example VM3 and VM4 trying 
to add a secondary mac address.

What about VMs trying to create VLANs? I think this will work on VM1 and 
VM2. However with VM3
and VM4, i think we need qemu to add vlans to the VFs when the VMs 
create them.

Thanks
Sridhar
