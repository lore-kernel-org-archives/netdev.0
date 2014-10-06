From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Mon, 6 Oct 2014 15:33:00 -0700
Message-ID: <CAEP_g=-S2b3mev+q-qPBHeBw7jb-Y2XvbTeZPgaLgVj=c+3Bjg@mail.gmail.com>
References: <1411962607-27878-1-git-send-email-therbert@google.com>
 <CAJ3xEMi-TRXevenx87UM7JnKqRQQATW4MBjbz8JdnQE9gk3KZw@mail.gmail.com>
 <CA+mtBx8r05=qs2J58LFq56762tFB7wF4Dsr3C5TC9w5qQP5jGw@mail.gmail.com>
 <CAJ3xEMhf6b75TQDFqEPMSXCpL9ToWG1q0OMPtrEuHNSm=-PSwQ@mail.gmail.com>
 <CA+mtBx_6HcZh5Ys1FJFBXkZ2bWX1gP6bTcjY7gbR6RG_TOy50Q@mail.gmail.com>
 <CAJ3xEMi0biCWTNtLOJ=0HWZYjOWi6pN2bw2=EWajp6XnpoyVRw@mail.gmail.com>
 <CA+mtBx-sP6g9hXAYGfHKCPYkCtjgCFM0srueh1uhoNnC2ACr1g@mail.gmail.com>
 <CAJ3xEMhc-97+3ZDwqXzX2N+=voO4QvJ5_YXn3sp8r8E9YyqotQ@mail.gmail.com>
 <CA+mtBx9=+fGjwJCKpTW5EifmavC6VGnbuJdkc5tqzeEHz+5twA@mail.gmail.com>
 <CAJ3xEMhzxfP3Sqp=_QSQehd2j2s=Gr3B1iO2S--OcoT7VC94nQ@mail.gmail.com>
 <CA+mtBx8-w74f_f9JEfpwH9=Mjr_zaJJAYCMMdYAWdCy-51pzqg@mail.gmail.com>
 <CAJ3xEMgPb9BhvtifmTzy6bS9WDf3jUx6dnx4418KNTjGNPreHQ@mail.gmail.com> <CA+mtBx-AW65w7grfb7zTaDKzKQ2n_7JQuLquj1Ayopa4gdiF6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:52609 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750956AbaJFWdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 18:33:21 -0400
Received: by mail-qc0-f171.google.com with SMTP id i17so4781901qcy.30
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 15:33:20 -0700 (PDT)
In-Reply-To: <CA+mtBx-AW65w7grfb7zTaDKzKQ2n_7JQuLquj1Ayopa4gdiF6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 6, 2014 at 10:59 AM, Tom Herbert <therbert@google.com> wrote:
> On Sun, Oct 5, 2014 at 12:13 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>> On Sun, Oct 5, 2014 at 9:49 PM, Tom Herbert <therbert@google.com> wrote:
>>> On Sun, Oct 5, 2014 at 7:04 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>>> On Thu, Oct 2, 2014 at 2:06 AM, Tom Herbert <therbert@google.com> wrote:
>>>>> On Wed, Oct 1, 2014 at 1:58 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>>>>> On Tue, Sep 30, 2014 at 6:34 PM, Tom Herbert <therbert@google.com> wrote:
>>>>>>> On Tue, Sep 30, 2014 at 7:30 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>>> [...]
>>>>> Solution #4: apply this patch and implement the check functions as
>>>>> needed in those 4 or 5 drivers. If a device can only do VXLAN/NVGRE
>>>>> then I believe the check function is something like:
>>>>>
>>>>> bool mydev_gso_check(struct sk_buff *skb, struct net_device *dev)
>>>>> {
>>>>>         if ((skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL) &&
>>>>>             ((skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
>>>>>               skb->protocol != htons(ETH_P_TEB) ||
>>>>>               skb_inner_mac_header(skb) - skb_transport_header(skb) != 12)
>>>>>                 return false;
>>>>>
>>>>>         return true;
>>>>> }
>>>>
>>>> Yep, such helper can can be basically made to work and let the 4-5
>>>> drivers that can
>>>> do GSO offloading for vxlan but not for any FOU/GUE packets signal
>>>> that to the stack.
>>>>
>>>> Re the 12 constant, you were referring to the udp+vxlan headers? it's 8+8
>>>>
>>>> Also, we need a way for drivers that can support VXLAN or NVGRE but
>>>> not concurrently
>>>> on the same port @ the same time to only let vxlan packet to pass
>>>> successfully through the helper.
>>
>>> Or, there should be no difference in GSO processing between VXLAN and
>>> NVGRE. Can you explain why you feel you need to differentiate them for GSO?
>>
>>
>> RX wise, Linux tells the driver that UDP port X would be used for
>> VXLAN, right? and indeed, it's possible for some HW implementations
>> not to support RX offloading (checksum) for both VXLAN and NVGRE @ the
>> same time over the same port. But TX/GRO wise, you're probably
>> correct. The thing is that from the user POV they need solution that
>> works for both RX and TX offloading.
>
> I think from a user POV we want a solution that supports RX and TX
> offloading across the widest range of protocols. This is accomplished
> by implementing protocol agnostic mechanisms like CHECKSUM_COMPLETE
> and protocol agnostic UDP tunnel TSO like we've described. IMO, the
> fact that we have devices that implement protocol specific mechanisms
> for NVGRE and VXLAN should be considered legacy support in the stack,
> for new UDP encapsulation protocols we should not expose specifics in
> the stack in either by adding a GSO type for each protocol, nor
> ndo_add_foo_port for each protocol-- these things will not scale and
> unnecessarily complicate the core stack.

It's not clear to me that allowing devices to know what protocols are
running on what ports actually complicates the stack. The part that is
complicated is usually the types of operations that are being
offloaded (checksum, TSO, etc.). In all of these tunnel cases, the
operations are same and if you have a clean registration mechanism
then nothing in the core has to see this - only the protocol doing the
registering and the driver that is supporting it.

I have no disagreement with trying to be generic across protocols. I'm
just not convinced that it is a realistic plan. It's obvious that it
is not doable today nor will be it be in the next generation of NICs
(which are guaranteed to add support for new protocols). Furthermore,
there will be more advanced stuff coming in the future that I think
will be difficult or impossible to make protocol agnostic. Rather than
pretending that this doesn't exist or will never happen, it's better
focus on how to integrating it cleanly.
