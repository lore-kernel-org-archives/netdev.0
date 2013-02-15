From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [tcpdump-workers] [PATCH net 1/2] net: dev_queue_xmit_nit: fix skb->vlan_tci field value
Date: Fri, 15 Feb 2013 00:17:33 -0800
Message-ID: <87ehgi3s9u.fsf@xmission.com>
References: <CAOUgPvRGQ4XQ-HCFzwKi5rFFfC1fJcicH8DxH0pUjAvgxfi7cw@mail.gmail.com>
	<CAOxq_8MXCvGpq4Q0UfxSbWMDNTusrK710fQ11qgfXKWS+zpoZQ@mail.gmail.com>
	<1357712850.27446.28.camel@edumazet-glaptop>
	<CAOxq_8P=yOYGhhJ2_YJT3ya32k7UNjX6d6Qpz+oVfD4d56sJfQ@mail.gmail.com>
	<CAOxq_8P4PLKXn9FOAWyq4zYH5+Yt7DT1mrU2OSQujGCOjBJZYg@mail.gmail.com>
	<1357761063.27446.60.camel@edumazet-glaptop>
	<32117.1357868869@sandelman.ca>
	<CAOUgPvSpMmsLpiwmnxwFx9p+B=KOG5VqjNvu_+54hLcBPNK4Cg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michael Richardson <mcr@sandelman.ca>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ani Sinha <ani@aristanetworks.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	edumazet <edumazet@google.com>,
	tcpdump-workers <tcpdump-workers@lists.tcpdump.org>,
	dborkman <dborkman@redhat.com>
To: Paul Pearce <pearce@cs.berkeley.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:51619 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752217Ab3BOIRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 03:17:40 -0500
In-Reply-To: <CAOUgPvSpMmsLpiwmnxwFx9p+B=KOG5VqjNvu_+54hLcBPNK4Cg@mail.gmail.com>
	(Paul Pearce's message of "Thu, 10 Jan 2013 18:37:19 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Pearce <pearce@cs.berkeley.edu> writes:

>>> My opinion as a kernel developer is that the network tap is here to have
>>> a copy of the exact frame given to the _device_.
>
>> Good: as someone who spends lots of time with tcpdump doing both network
>> and protocol diagnostics, it's really important to see exactly there.
>> If that means turning off some hardware offload in order to get the
>> intact 1p header, then that may be fine for many situations.
>> (At 10G, on a live router... well...)
>
> I agree as well.
>
> But I think Ani's point was that for RX packets, as of commit
> bcc6d47903612c3861201cc3a866fb604f26b8b2, the filters are not
> getting exactly what's "on the wire." Independent of hardware
> acceleration the vlan headers are being stripped off and skb->vlan_tci
> is being set. That's was the origin of this whole mess.

The mess goes back much farther than that.  That commit just flushed
a lot of the mess out into the open, and made it apparent the kernel
had insufficient facilities for dealing with packets whose vlan
tags had been stripped and that libpcap had not been handling stripped
vlan tags.

> The msg from that commit reads in part:
>> Vlan untagging happens early in __netif_receive_skb so the rest of
>> code (ptype_all handlers, rx_handlers) see the skb like it was
>> untagged by hw.
>
> His confusion (which I share) is why it's acceptable to have this
> behavior of removing headers and setting skb->vlan_tci (regardless of
> hardware acceleration) on the RX path but not also set skb->vlan_tci
> on the TX path.

On all paths the kernel will now set a flag VLAN_TAG_PRESENT if the
vlan_tci is stripped off and used.  So there is no pressing need for a
kernel change.  recvmsg and BPF filters have all of the information they
need to figure out what is going on.  So at this point this is a libpcap
problem not a kernel problem.

On the RX path always stripping the header allowed the vlan processing
code to be simplified and some bugs to be fixed.

Just reading through the code a bit more it looks like stripping the
vlan headers on TX if the network device does not support vlan header
accelleration is a performance loss.  There are other cases besides
AF_PACKET in particular vlan_dev_hard_header that will insert the vlan
header on a packet before the packet is transmitted.

> Indepdent of proposed userspace or PACKET_AUXDATA solutions,
> clarification on the RX skb->vlan_tci behavior would be appreciated.

There are two variables now available in AUXDATA and in the BPF filters
for packets.  VLAN_TAG_PRESENT and VLAN_TAG.

Packets that have their vlan tags stripped have VLAN_TAG_PRESENT set
and the tag is available in VLAN_TAG.

> My knowledge of this code is quite limited so it's entirely possible
> I'm off base here. If so please tell me.

Eric
