From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 2/5] mlx5: Add support for UDP tunnel segmentation
 with outer checksum offload
Date: Fri, 29 Apr 2016 12:36:23 -0700
Message-ID: <CAKgT0UemjkzHNHvsp5wb4-OcJB0r3tksKKOVpx5tkRAOB2=ipw@mail.gmail.com>
References: <20160419185949.11723.50506.stgit@ahduyck-xeon-server>
	<20160419190603.11723.31623.stgit@ahduyck-xeon-server>
	<CALzJLG-8enmxxvjbVbcygVgM0VhX7Eo=6B=2pZF5jQzN9L9YEg@mail.gmail.com>
	<CAKgT0Uc5poLcTzkeA_8fi2jQeF08zbtj3+obTG1q0ha+ESZRCQ@mail.gmail.com>
	<800B6BE4-251F-4AA5-92FC-3A9393E7981E@mellanox.com>
	<CAKgT0UfsB+CbsCjerxDYkWgdGN01vmf4=VJRLEarFO4_nf-pow@mail.gmail.com>
	<49111DBA-CDD6-4D19-9D2D-D6E29675A28F@mellanox.com>
	<CAKgT0UeGJY0kntN6KeXmqZEY3k=uND4RXY+RG94q0Da2Tt2rWg@mail.gmail.com>
	<CALzJLG8yme_8a+aH+2VT8atq0wrEK208K1HB-iSQUtDipAyPXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Matthew Finlay <Matt@mellanox.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Bruce W Allan <bruce.w.allan@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Michael Chan <mchan@broadcom.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:35839 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751979AbcD2TgY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 15:36:24 -0400
Received: by mail-io0-f180.google.com with SMTP id d62so117773790iof.2
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 12:36:23 -0700 (PDT)
In-Reply-To: <CALzJLG8yme_8a+aH+2VT8atq0wrEK208K1HB-iSQUtDipAyPXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 29, 2016 at 12:27 PM, Saeed Mahameed
<saeedm@dev.mellanox.co.il> wrote:
> On Fri, Apr 29, 2016 at 4:59 AM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On Thu, Apr 28, 2016 at 6:18 PM, Matthew Finlay <Matt@mellanox.com> wrote:
>>>
>>>
>>>
>>>
>>>
>>>>>
>>>>> The mlx5 hardware requires the outer UDP checksum is not set when offloading encapsulated packets.
>>>>
>>>>The Intel documentation said the same thing.  That was due to the fact
>>>>that the hardware didn't computer the outer UDP header checksum.  I
>>>>suspect the Mellanox hardware has the same issue.  Also I have tested
>>>>on a ConnectX-4 board with the latest firmware and what I am seeing is
>>>>that with my patches applied the outer checksum is being correctly
>>>>applied for segmentation offloads.
>>>>
>>>>My thought is that that the hardware appears to ignore the UDP
>>>>checksum so if it is non-zero you cannot guarantee the checksum would
>>>>be correct on the last frame if it is a different size than the rest
>>>>of the segments.  In the case of these patches that issue has been
>>>>resolved as I have precomputed the UDP checksum for the outer UDP
>>>>header and all of the segments will be the same length so there should
>>>>be no variation in the UDP checksum of the outer header.  Unless you
>>>>can tell my exactly the reason why we cannot provide the outer UDP
>>>>checksum I would assume that the reason is due to the fact that the
>>>>hardware doesn't compute it so you cannot handle a fragment on the end
>>>>which is resolved already via GSO_PARTIAL.
>>>
>>> I will check internally and verify there are no unforeseen issues with setting the outer UDP checksum in this scenario.
>>
>> Thanks.  Any idea how long it should be.  I know I was getting a
>> auto-reply about people being out until May 1st due to a holiday so I
>> am just wondering if we should have Dave drop this patch set and I
>> submit a v2 when you can get me the feedback next week, or if we run
>> with the patches as-is for now and be prepared to revert if anything
>> should come up.
>>
>
> Alex,
>
> I reviewed your patches and other than  the claim about mlx4,
> everything seems to be ok.
> I took the liberty to apply your patches and play around with them
> only on mlx5 for now,
> It seems that it works and HW do correctly calculate the IPv6 outer
> UDP sum as illustrated in the log from the tcpdump on the receiver
> [1], I also noticed that the GSO also works on the xmitter and the HW
> ignores the outer sum as expected.
>
> Matt, I think you still need to do the homework and see if we didn't
> miss anything here, but theoretically and practically what Alex did
> here should work.
> Tariq will also check what went wrong with mlx4 outer ipv6 support,
> but this shouldn't block this series.
>
> Side notes:
> - Alex, you will need to rebase the series, it didn't apply smoothly.
> - BTW mlx5 on RX side will provide csum complete and not csum unnecessary.
>
> Saeed.
>
> [1]
> 21:28:15.474287 e4:1d:2d:5c:f2:e8 > e4:1d:2d:5c:f2:d4, ethertype IPv6
> (0x86dd), length 1514: (hlim 64, next-header UDP (17) payload length:
> 1460) 2001::37:4.58006 > 2001::36:4.4789: [udp sum ok] VXLAN, flags
> [I] (0x08), vni 46
> 66:cb:6e:a4:31:4e > b6:bf:9b:61:31:62, ethertype IPv4 (0x0800), length
> 1444: (tos 0x0, ttl 64, id 64920, offset 0, flags [DF], proto TCP (6),
> length 1430)
>     56.0.37.4.53614 > 56.0.36.4.commplex-link: Flags [.], cksum 0xd6cc
> (correct), seq 1911713070:1911714448, ack 1, win 218, options
> [nop,nop,TS val 183853011 ecr 183840106], length 1378


Thanks.  I'll probably resubmit next week after your latest set of 12
patches gets applied.

- Alex
