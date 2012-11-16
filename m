From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Thu, 15 Nov 2012 22:51:22 -0800
Message-ID: <87mwyi9h1x.fsf@xmission.com>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com>
	<3246.1351717319@obiwan.sandelman.ca>
	<CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michael Richardson <mcr@sandelman.ca>, netdev@vger.kernel.org,
	tcpdump-workers@lists.tcpdump.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: Ani Sinha <ani@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:40479 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148Ab2KPGvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 01:51:49 -0500
In-Reply-To: <CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
	(Ani Sinha's message of "Wed, 31 Oct 2012 14:50:27 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ani Sinha <ani@aristanetworks.com> writes:

> cc'ing netdev.
>
>
> On Wed, Oct 31, 2012 at 2:01 PM, Michael Richardson <mcr@sandelman.ca> wrote:
>>
>> Thanks for this email.
>>
>>>>>>> "Ani" == Ani Sinha <ani@aristanetworks.com> writes:
>>     Ani> remove "inline" from vlan_core.c functions
>>     Ani> Signed-off-by: David S. Miller <davem@davemloft.net>
>>
>>     Ani> As a result of this patch, with or without HW acceleration support in
>>     Ani> the kernel driver, the vlan tag information is pulled out from the
>>     Ani> packet and is inserted in the skb metadata. Thereafter, the vlan tag
>>     Ani> information for a 802.1q packet can be obtained my applications
>>     Ani> running in the user space by using the auxdata and cmsg
>>     Ani> structure.
>>
>> Do you think that the existance of this behaviour could be exposed in
>> sysctl, /proc/net or /sys equivalent (we still don't have /sys/net...)?
>> As a read only file that had a 0/1 in it?
>
> yes, we definitely need a run time check. Whether this could be in the
> form of a socket option or a /proc entry I don't know.

I don't see any need to add any kernel code to allow checking if vlan
tags are stripped.  Vlan headers are stripped on all kernel interfaces
today.  Vlan headers have been stripped on all but a handful of software
interfaces for 6+ years.  For all kernels if the vlan header is stripped
it is reported in the auxdata, upon packet reception.  Careful code
should also look for TP_STATUS_VLAN_VALID which allows for
distinguishing a striped vlan header of 0 from no vlan header.

The safe assumption then is that testing for vlan headers and vlan
values in bpf filters is not possible without the new bpf extentions.

It is possible to test for the presence of support of the new vlan bpf
extensions by attempting to load a filter that uses them.  As only valid
filters can be loaded, old kernels that do not support filtering of vlan
tags will fail to load the a test filter with uses them.

For old kernels that do not support the new extensions it is possible to
generate code that looks at the ethernet header and sees if the
ethertype is 0x8100 and then does things with it, but that will only
work on a small handful of software only interfaces.

Eric
