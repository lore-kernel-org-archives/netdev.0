From: Alex Duyck <aduyck@mirantis.com>
Subject: Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable outer Tx checksum by default
Date: Fri, 19 Feb 2016 15:10:29 -0800
Message-ID: <CAMt9YRrOxCmJbrftixdJTXZcySZ_mARqCT6C=4-Nqv_ZJKnTwA@mail.gmail.com>
References: <20160219191806.15687.37621.stgit@localhost.localdomain>
	<CAEh+42jHjEqjEyN3-OopZK2hAowh4LGKSgZWgSe9+W1zdezpZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f44.google.com ([209.85.213.44]:36805 "EHLO
	mail-vk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1428813AbcBSXKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 18:10:31 -0500
Received: by mail-vk0-f44.google.com with SMTP id c3so87960989vkb.3
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 15:10:30 -0800 (PST)
In-Reply-To: <CAEh+42jHjEqjEyN3-OopZK2hAowh4LGKSgZWgSe9+W1zdezpZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 19, 2016 at 1:53 PM, Jesse Gross <jesse@kernel.org> wrote:
> On Fri, Feb 19, 2016 at 11:26 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
>> This patch series makes it so that we enable the outer Tx checksum for IPv4
>> tunnels by default.  This makes the behavior consistent with how we were
>> handling this for IPv6.  In addition I have updated the internal flags for
>> these tunnels so that we use a ZERO_CSUM_TX flag for IPv4 which should
>> match up will with the ZERO_CSUM6_TX flag which was already in use for
>> IPv6.
>>
>> For most network devices this should be a net gain in terms of performance
>> as having the outer header checksum present allows for devices to report
>> CHECKSUM_UNNECESSARY which we can then convert to CHECKSUM_COMPLETE in order
>> to determine if the inner header checksum is valid.
>>
>> Below is some data I collected with ixgbe with an X540 that demonstrates
>> this.  I located two PFs connected back to back in two different name
>> spaces and then setup a pair of tunnels on each, one with checksum enabled
>> and one without.
>>
>> Recv   Send    Send                          Utilization
>> Socket Socket  Message  Elapsed              Send
>> Size   Size    Size     Time     Throughput  local
>> bytes  bytes   bytes    secs.    10^6bits/s  % S
>>
>> noudpcsum:
>>  87380  16384  16384    30.00      8898.67   12.80
>> udpcsum:
>>  87380  16384  16384    30.00      9088.47   5.69
>>
>> The one spot where this may cause a performance regression is if the
>> environment contains devices that can parse the inner headers and a device
>> supports NETIF_F_GSO_UDP_TUNNEL but not NETIF_F_GSO_UDP_TUNNEL_CSUM.  In
>> the case of such a device we have to fall back to using GSO to segment the
>> tunnel instead of TSO and as a result we may take a performance hit as seen
>> below with i40e.
>
> Do you have any numbers from 40G links? Obviously, at 10G the links
> are basically saturated and while I can see a difference in the
> utilization rate, I suspect that the change will be much more apparent
> at higher speeds.

Unfortunately I don't have any true 40G links to test with.  The
closest I can get is to run PF to VF on an i40e.  Running that I have
seen the numbers go from about 20Gb/s to 15Gb/s with almost all the
difference being related to the fact that we are having to
allocate/free more skbs and make more trips through the
i40e_lan_xmit_frame function resulting in more descriptors.

> I'm concerned about the drop in performance for devices that currently
> support offloads (almost none of which expose
> NETIF_F_GSO_UDP_TUNNEL_CSUM as a feature). Presumably the people that
> care most about tunnel performance are the ones that already have
> these NICs and will be the most impacted by the drop.

The problem is being able to transmit fast is kind of pointless if the
receiving end cannot handle it.  We hadn't gotten around to really
getting the Rx checksum bits working until the 3.18 kernel which I
don't suspect many people are running so at this point messing with
the TSO bits isn't really making much of a difference.  Then on top of
that most devices have certain limitations on how many ports they can
handle and such.  I know the i40e is supposed to support something
like 10 port numbers, but the fm10k and ixgbe are limited to one port
as I recall.  So this whole thing is already really brittle as it is.
My goal with this change is to make the behavior more consistent
across the board.

> My hope is that we can continue to use TSO on devices that only
> support NETIF_F_GSO_UDP_TUNNEL. The main problem is that the UDP
> length field may vary across segments. However, in practice this is
> the only on the final segment and only in cases where the total length
> is not a multiple of the MSS. If we could detect cases where those
> conditions are met, we could continue to use TSO with the UDP checksum
> field pre-populated. A possible step even further would be to break
> off the final segment into a separate packet to make things conform if
> necessary. This would avoid a performance regression and I think make
> this more palatable to a lot of people.

I think Tom and I had discussed this possibility a bit at netconf.
The GSO logic is something I planned on looking at over the next
several weeks as I suspect there is probably room for improvement
there.

>> I also haven't investigated the effect this will have on OVS.  However I
>> suspect the impact should be minimal as the worst case scenario should be
>> that Tx checksumming will become enabled by default which should be
>> consistent with the existing behavior for IPv6.
>
> I don't think that it should cause any problems.

Good to hear.

Do you know if OVS has some way to control the VXLAN configuration so
that it could disable Tx checksums?  If so that would probably be a
good way to address the 40G issues assuming someone is running an
environment hat had nothing but NICs that can support the TSO and Rx
checksum on inner headers.
