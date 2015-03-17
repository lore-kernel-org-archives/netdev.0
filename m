From: Jesse Gross <jesse@nicira.com>
Subject: Re: Hardware support for foo over UDP?
Date: Tue, 17 Mar 2015 12:08:46 -0700
Message-ID: <CAEP_g=-WnC5yKm_dGsA9aj-6ZZEwoFs2YBMg28xpZzftAmh3fQ@mail.gmail.com>
References: <CALx6S36bovfh_-oFo+PMag0Asato3qyAFdizteAFm9g4=YwFTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog132.obsmtp.com ([74.125.149.250]:36039 "HELO
	na3sys009aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753016AbbCQTJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 15:09:08 -0400
Received: by mail-lb0-f175.google.com with SMTP id ds1so14024779lbc.3
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 12:09:07 -0700 (PDT)
In-Reply-To: <CALx6S36bovfh_-oFo+PMag0Asato3qyAFdizteAFm9g4=YwFTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 16, 2015 at 9:52 AM, Tom Herbert <tom@herbertland.com> wrote:
> RSS is mostly solved by enabling RSS for UDP. IMO this should be
> enabled by default in NICs that support it as the historical counter
> argument is that this cause OOO for fragmented UDP packets seems to be
> a lesser concern.

I agree with this. Given that UDP is used for load balancing in
ECMP/LAG there doesn't seem to be much benefit to not using at the
host if any possible packet reordering has already occurred in the
network.

> TX-csum and RX-csum are made generic through NETIF_HW_CSUM and
> CHECKSUM_UNNECESSARY; we've known this for a long time ;-). These will
> work well to offload encapsulated transport checksums.  UDP
> encapsulation also allows the opportunity to enable UDP checksum.
> We're actually leveraging that to get good performance on legacy HW
> using checksum-unnecessary conversion and remote checksum offload in
> GUE and VXLAN. It does raise the possibility that someone may want to
> explore HW offload of more than one checksum in a packet on transmit.

Things like remote checksum offload are nice when they can be used but
are really more of a short term solution. Since it both requires
changes to the protocol and can't be easily be computed by some types
of devices, we'll still ultimately want the NIC to compute the
checksum.

I do know that people are planning on introducing NICs that can
compute multiple checksums, although I don't believe that any are
available yet.

> For LSO (TSO), the stack already demonstrates a generic solution for
> segmentation with UDP encapsulation in GSO (__skb_udp_tunnel_segment).
> Note that this code does not need to know the encapsulation protocol
> or parse the packet to do GSO. As long we don't have any fields in the
> encapsulation headers that need to be modified per segment, the bits
> between the UDP header and the encapsulated L2/L3 header are just
> copied per segment.

I am happy with how this turned out as well.

> LRO is the hardest offload to make generic, a device will need to
> parse encapsulation which will also mean that the device needs to know
> the port to encapsulation protocol mapping. I don't know if we can
> find a better answer here but it might be worth some consideration.

I have thought about this in the past and I also don't know of any
better solution (and it also roughly mirrors what we have in
software). I think this bit of protocol-awareness has minimal impact
on the stack since the operation that is being performed across
protocols is the same, it's just giving a hint as to which parser
should be used by the NIC.
