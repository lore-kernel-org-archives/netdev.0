From: Edward Cree <ecree@solarflare.com>
Subject: Re: RFC: Checksum offload and XDP
Date: Tue, 11 Apr 2017 16:55:38 +0100
Message-ID: <63f0f671-5b33-4895-355c-be6259b16341@solarflare.com>
References: <CALx6S357=e3414sPBnW3ajzXfkvVBiGMChx+vgbf9snpe95-aQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Tom Herbert <tom@herbertland.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from connect-us.pphosted.com ([67.231.154.164]:46343 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751564AbdDKPzv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 11:55:51 -0400
In-Reply-To: <CALx6S357=e3414sPBnW3ajzXfkvVBiGMChx+vgbf9snpe95-aQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/04/17 19:26, Tom Herbert wrote:
> Not having checksum offload in XDP is going to get more painful once
> we start seeing a lot programs doing packet modifications. One nice
> thing we do for ILA router is pre-compute the checksum delta necessary
> to maintain checksum neutral property in the packet. So that after
> doing ILA routing in XDP the checksum complete value is still valid as
> is the transport layer checksum.
>
> It's conceivable we could generalize this by having a u16 checksum
> delta returned from XDP program. If the checksum diff can be
> pre-computed in a structure for doing the translation, then there
> should be little cost other than making API a little more complex. On
> return the checksum_complete value is updated jusy by adding in the
> diff value.
>
> Tom

AIUI you're suggesting to have the user's BPF program do this calculation  and (somehow) feed the diff back to the caller.  As well as adding work
 for the XDP program writer, it also means trusting they got it right.
My suggestion was that the eBPF verifier could insert instructions around
 every write that update the diff value automagically, and not allow the
 user's program to touch it directly.
There would be some cleverness required, for instance to determine which
 byte of the checksum to add to (and thus sometimes shift the byte diff
 by 8 before adding it in) - which might require a runtime check when the
 load is indexed.  Or might not, if the verifier sees something like
 packet[ETH_HLEN + (ihl << 2)] and can deduce the low bit of the offset.
For the simple case, we would translate "write byte to packet+1" into:
	diff -= packet[1];
	write byte to packet+1;
	diff += packet[1];
Alexei, does this sound reasonable?

The counter-argument, of course, is that if the XDP program edits fields
 that are protected by an Internet checksum (which in practice usually
 means anything but the Ethernet header) and then fixes up the checksums
 itself, we will edit our diff value twice just to conclude that diff==0.
 And maybe we are willing to trust root with the ability to lie to the
 kernel about incoming packets' checksum_complete values.

-Ed
