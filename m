From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next 05/19] ixgbe: Add support for UDP-encapsulated tx
 checksum offload
Date: Wed, 2 Sep 2015 15:34:56 -0700
Message-ID: <CALx6S35uxQiEQmYAcYjPGOmb9HfmDC9Z91E95UPNZn9xEPYkug@mail.gmail.com>
References: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1441156443-33381-6-git-send-email-jeffrey.t.kirsher@intel.com>
	<CALx6S34-mUvQyUQNcVC+o+NeUxWEsCG2GS=Eq++eGqoh=kv8kg@mail.gmail.com>
	<F63CFE64-29E1-484B-B19B-269FAAA9C54B@intel.com>
	<CALx6S36T4tzB5aq3bbKq4DMEumvC4q2YhGscn19se0mGXGe5cQ@mail.gmail.com>
	<CAJ3xEMhLyP-S3EMC9L-utr-YMZmbZiE54cxMZT0pTGwHhqweew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Rustad, Mark D" <mark.d.rustad@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:33432 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754070AbbIBWe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 18:34:57 -0400
Received: by igbkq10 with SMTP id kq10so1292061igb.0
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 15:34:56 -0700 (PDT)
In-Reply-To: <CAJ3xEMhLyP-S3EMC9L-utr-YMZmbZiE54cxMZT0pTGwHhqweew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 2, 2015 at 2:07 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Wed, Sep 2, 2015 at 8:38 PM, Tom Herbert <tom@herbertland.com> wrote:
>> On Wed, Sep 2, 2015 at 9:46 AM, Rustad, Mark D <mark.d.rustad@intel.com> wrote:
>
>>> Note: NETIF_F_HW_CSUM is a superset of NETIF_F_IP_CSUM + NETIF_F_IPV6_CSUM.
>>> It means that device can fill TCP/UDP-like checksum anywhere in the packets
>>> whatever headers there might be.
>
>>> The device can't do whatever, wherever. There is always a limit to the offset to the inner headers that can be handled, for instance.
>
>> If the device does NETIF_F_HW_CSUM then inner/outer headers are
>> irrelevant at least in the non-GSO case. All the device needs to do is
>> compute the checksum from start and write the answer at the given
>> offset. No protocol awareness needed in the device, no need to parse
>> headers on transmit.
>
> Tom, could you elaborate a little further on the
> semantics/requirements for devices supporting NETIF_F_HW_CSUM,
> specifically, AFAIU this isn't a TX equivalent of supporting checksum
> complete on RX, right? when you say "write the answer at the given
> offset" what non-common answers are you expecting devices to produce?
> how the kernel is hinting to the device on the nature on the expected
> answer beyond the offset?
>
NETIF_F_HW_CSUM indicates that the device/driver is will to implement
CHECKSUM_PARTIAL on out for the general case. CHECKSUM_PARTIAL is
described in skbuff.h as:

The device is required to checksum the packet as seen by hard_start_xmit()
from skb->csum_start up to the end, and to record/write the checksum at
offset skb->csum_start + skb->csum_offset.

For instance, if we want to offload an inner checksum the stack would
set csum_start to the offset of the the inner transport packet and
csum_offset to the relative offset of the checksum field. The stack
takes care of priming the checksum field with the not of pseudo header
if the transport protocol needs that.

Tom


> Or.
