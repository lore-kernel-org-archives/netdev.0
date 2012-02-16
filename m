From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH] bnx2x: tx-switching module parameter
Date: Thu, 16 Feb 2012 11:38:47 -0800
Message-ID: <4F3D5B47.6030505@intel.com>
References: <1329401112-9542-1-git-send-email-ariele@broadcom.com> <20120216094936.3449e6ef@nehalam.linuxnetplumber.net> <1329417315.30697.3.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ariel Elior <ariele@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61859 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751791Ab2BPTjE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Feb 2012 14:39:04 -0500
In-Reply-To: <1329417315.30697.3.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/16/2012 10:35 AM, Eilon Greenstein wrote:
> On Thu, 2012-02-16 at 09:49 -0800, Stephen Hemminger wrote:
>> On Thu, 16 Feb 2012 16:05:12 +0200
>> "Ariel Elior" <ariele@broadcom.com> wrote:
>>
>>> In 57712 and 578xx the tx-switching module parameter allows the user to control
>>> whether outgoing traffic can be loopbacked into the device in case there is a
>>> relevant client for the data using the same device for rx.
>>> A classic example where this is necessary is for virtualization purposes, where
>>> one vm is transmitting data to another, while both use different pci functions of
>>> the same port of the same nic.
>>>
>>> In case there is a promiscuous client in the rx (which wants to receive all
>>> data) or if the traffic is broadcast, traffic may be sent on both the loopback
>>> channel and the physical wire.
>>>
>>> The reason tx-switching is controlled by a module parameter is twofold:
>>> 1. There is a certain performance penalty for tx-switching because:
>>>    a. every packet must be compared against the receiver clients.
>>>    b. duplicated traffic being loopbacked can consume a significant portion of
>>>    the overall bandwidth, depending on the scenario.
>>> 2. Tx-switching doesn't make much sense as a per function parameter, but should
>>> rather be controlled uniformly for the  entire device. The reason is that if one
>>> interface wants to be able to send data on the loopback it is not enough to
>>> enable tx-switching for that interface, as the target interface must also
>>> register its rx classification information where the transmitting interface can
>>> find it. One would still have to use the module parameter in each VM, though.
>>>
>>> Signed-off-by: Ariel Elior <ariele@broadcom.com>
>>> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
>>
>> Module parameters are the hardware vendors friend, but the system
>> integrators nightmare. Although you think your hardware is special
>> but it isn't some other vendor will have same idea, how is user and
>> distribution supposed to control it?
> 
> Actually, module parameters require more explanations and cause more
> questions since they are unique to the device than any standard way - so
> we do prefer a standard way of doing things. In this case, we looked at
> other driver and scanned the mailing list history to see if we missed
> some discussion - but could not found anything. It is possible that for
> some HW the cost of doing this internal switching is low and therefore
> enabled by default and it is possible that some HW do not support it.
> This applies only to multi-functions (more than one PF sharing the same
> network port) devices and is usually required in VMs which are using
> physical device assignment since most multi-function environments are
> controlled by the switch which is looping back the packets.
> 

It should be relevant to any case where your doing hardware switching and
the mechanism to configure this should be independent of how you expose
multiple MAC services (mac/vlan pairs) realized as net devices in Linux.
Specifically the mechanism should work for a PF and many VFs, multiple PFs,
or queue based filtering mechanisms (Intel's VMDq).

The 82599 Intel devices support disabling loopback. This is needed to support
VEPA modes as defined in the 802.1Qbg standard which should be ratified
shortly. Typically you would expect the peer to support a hairpin forwarding
so that PF-VF, VF-VF, and PF-PF communication still works.

> But netdev is a great place to ask - are there other vendors out there
> that requires this control over internal switching? If so, we can define
> a new ethtool command. The alternative of using the ethtool private
> flags seems just as inconvenient from administrators point of view and
> also seem less appropriate since this configuration is more likely to be
> the same for all PFs on the same machine.
> 

This needs to be configurable at runtime. Because the 802.1Qbg spec defines
a protocol to learn which mode we should use and we want to be able to support
this. 'lldpad' and 'libvirt' already have some support for this. Also macvlan's
may be stacked on top of the PF and depending on the macvlan mode VEB or VEPA
you may need to configure the hardware switch to be compatible.

My thought on this is it should be a netlink command because it will be helpful
in userspace to get events when this is changed. A module parameter should be
a non-starter here because that would require any management application to start
loading and unloading modules which is a pain and bounces the link. Ethtool is
better than a modparam but I would prefer to get an event so that I can keep
lldpad (or any other app for that matter) in sync.

Thanks,
John


> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
