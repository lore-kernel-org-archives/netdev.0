From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: ixgbe: SR-IOV, macvlan filter on VFs
Date: Thu, 14 Aug 2014 07:47:29 -0700
Message-ID: <53ECCC01.4050400@gmail.com>
References: <53ECA5C9.2020904@univ-nantes.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yoann Juet <yoann.juet@univ-nantes.fr>
To: Yoann Juet <veilletechno-irts@univ-nantes.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:42425 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754827AbaHNOrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 10:47:45 -0400
Received: by mail-oa0-f52.google.com with SMTP id o6so1066130oag.11
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 07:47:45 -0700 (PDT)
In-Reply-To: <53ECA5C9.2020904@univ-nantes.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/2014 05:04 AM, Yoann Juet wrote:
> Hi all,
>
> We are trying to make VRRP with VMAC address work on VMs using SR-IOV.
> The well known Keepalived VRRP framework implements such a feature with
> a macvlan device per physical interface. In our setup, this means we get
> a new macvlan device per VF. To make it partially work, we first have to
> disable the ixgbe anti-spoofing feature on the PFs that are involved:
>
> ip link set dev <ethX> vf <x> spoofchk off
>
> Now, VIPs' Virtual Mac Address are known from clients (arp answers are
> transmitted). But this is not enough ; VIPs are still not reachable from
> clients as they are attached to a macvlan device. Each time a VMAC is
> set on a macvlan device, we get the following messages:
>
> [674943.437989] ixgbe 0000:04:00.0 eth2: VF 0 requested MACVLAN filter
> but is administratively denied
> [674943.458875] ixgbe 0000:04:00.0 eth2: VF 1 requested MACVLAN filter
> but is administratively denied
>
> Looks like macvlan on VF only works for outbound traffic from VMs.
> Inbound traffic is filtered. Is there a solution to disable macvlan
> filtering on a VF basis ?
>
> Thanks,
> Best Regards,
>
> --

hmm this should work I think.

Did you set the VF mac address at some point with,

	ip link set dev DEVICE vf NUM mac ADDR

If not this how did you setup the virtual functions? Manually via
sriov_numvfs? Or via libvirt or other library. Basically there is a
check in the driver to see if the MAC was set via the physical function
and in this case the driver doesn't allow the VF to add/remove any
MAC addresses on the rx filters.

In the ixgbe driver if ixgbe_ndo_set_vf_mac is ever called it sets
the pf_set_mac bit (this is the check) and denies any further mac
updates. This function gets called when ever a netlink IFLA_VF_MAC
attribute is setup. This is what is invoked by the above 'ip link'
command.


Thanks,
John

-- 
John Fastabend         Intel Corporation
