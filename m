From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [tcpdump-workers] [PATCH net 1/2] net: dev_queue_xmit_nit: fix
 skb->vlan_tci field value
Date: Fri, 11 Jan 2013 09:46:19 +0100
Message-ID: <50EFD15B.4050307@redhat.com>
References: <CAOUgPvRGQ4XQ-HCFzwKi5rFFfC1fJcicH8DxH0pUjAvgxfi7cw@mail.gmail.com> <CAOxq_8MXCvGpq4Q0UfxSbWMDNTusrK710fQ11qgfXKWS+zpoZQ@mail.gmail.com> <1357712850.27446.28.camel@edumazet-glaptop> <CAOxq_8P=yOYGhhJ2_YJT3ya32k7UNjX6d6Qpz+oVfD4d56sJfQ@mail.gmail.com> <CAOxq_8P4PLKXn9FOAWyq4zYH5+Yt7DT1mrU2OSQujGCOjBJZYg@mail.gmail.com> <1357761063.27446.60.camel@edumazet-glaptop> <32117.1357868869@sandelman.ca> <CAOUgPvSpMmsLpiwmnxwFx9p+B=KOG5VqjNvu_+54hLcBPNK4Cg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Richardson <mcr@sandelman.ca>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ani Sinha <ani@aristanetworks.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	edumazet <edumazet@google.com>,
	tcpdump-workers <tcpdump-workers@lists.tcpdump.org>
To: Paul Pearce <pearce@cs.berkeley.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52744 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753043Ab3AKIqd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 03:46:33 -0500
In-Reply-To: <CAOUgPvSpMmsLpiwmnxwFx9p+B=KOG5VqjNvu_+54hLcBPNK4Cg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/11/2013 03:37 AM, Paul Pearce wrote:
>>> My opinion as a kernel developer is that the network tap is here to have
>>> a copy of the exact frame given to the _device_.

Agreed.

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
>
> The msg from that commit reads in part:
>> Vlan untagging happens early in __netif_receive_skb so the rest of
>> code (ptype_all handlers, rx_handlers) see the skb like it was
>> untagged by hw.
>
> His confusion (which I share) is why it's acceptable to have this
> behavior of removing headers and setting skb->vlan_tci (regardless of
> hardware acceleration) on the RX path but not also set skb->vlan_tci
> on the TX path.
>
> Indepdent of proposed userspace or PACKET_AUXDATA solutions,
> clarification on the RX skb->vlan_tci behavior would be appreciated.
>
> My knowledge of this code is quite limited so it's entirely possible
> I'm off base here. If so please tell me.

While we're at the topic, though it's slightly unrelated this particular
problem, but related to capturing VLANs and ``what's seen on the wire'',
since it was mentioned.

For different NICs/drivers you might get different default behaviours, and
mostly it's the case (I assume, correct me if I'm wrong) that libpcap has
to ``un-untag'' the VLAN headers in user space, doing a memmove(3) for each
stripped VLAN packet in order to ``fix'' this.

Because of this hack, I even got a report of a user recently, that in
Wireshark, he saw a QinQ header, although it should just have been one
VLAN encapsulation (AR8131 driver with ethtool -K eth0 rxvlan off) as he
saw with netsniff-ng (no memmove(3) done there). (I didn't further follow
or verify this report though.)
