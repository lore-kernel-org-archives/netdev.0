From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Wed, 1 Oct 2014 16:06:19 -0700
Message-ID: <CA+mtBx9=+fGjwJCKpTW5EifmavC6VGnbuJdkc5tqzeEHz+5twA@mail.gmail.com>
References: <1411962607-27878-1-git-send-email-therbert@google.com>
	<CAJ3xEMi-TRXevenx87UM7JnKqRQQATW4MBjbz8JdnQE9gk3KZw@mail.gmail.com>
	<CA+mtBx8r05=qs2J58LFq56762tFB7wF4Dsr3C5TC9w5qQP5jGw@mail.gmail.com>
	<CAJ3xEMhf6b75TQDFqEPMSXCpL9ToWG1q0OMPtrEuHNSm=-PSwQ@mail.gmail.com>
	<CA+mtBx_6HcZh5Ys1FJFBXkZ2bWX1gP6bTcjY7gbR6RG_TOy50Q@mail.gmail.com>
	<CAJ3xEMi0biCWTNtLOJ=0HWZYjOWi6pN2bw2=EWajp6XnpoyVRw@mail.gmail.com>
	<CA+mtBx-sP6g9hXAYGfHKCPYkCtjgCFM0srueh1uhoNnC2ACr1g@mail.gmail.com>
	<CAJ3xEMhc-97+3ZDwqXzX2N+=voO4QvJ5_YXn3sp8r8E9YyqotQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:63787 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751525AbaJAXGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 19:06:20 -0400
Received: by mail-ig0-f171.google.com with SMTP id h15so282029igd.10
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 16:06:19 -0700 (PDT)
In-Reply-To: <CAJ3xEMhc-97+3ZDwqXzX2N+=voO4QvJ5_YXn3sp8r8E9YyqotQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 1, 2014 at 1:58 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Tue, Sep 30, 2014 at 6:34 PM, Tom Herbert <therbert@google.com> wrote:
>> On Tue, Sep 30, 2014 at 7:30 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>> On Tue, Sep 30, 2014 at 12:38 AM, Tom Herbert <therbert@google.com> wrote:
>>>> On Mon, Sep 29, 2014 at 2:10 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>>>> On Mon, Sep 29, 2014 at 11:53 PM, Tom Herbert <therbert@google.com> wrote:
>>>>>> On Mon, Sep 29, 2014 at 12:59 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>>>>>> On Mon, Sep 29, 2014 at 6:50 AM, Tom Herbert <therbert@google.com> wrote:
>
>>> I'm not sure how exactly this (inner protocol being Ethernet and inner
>>> header lengths)
>>> is going to work to differentiate between VXLAN and NVGRE (or @ least
>>> the GRE-ing done by OVS on guest Ethernet frames).
>
>> GSO processing for VXLAN and NVGRE should be identical. They both have
>> a four byte header that needs to be copied per packet and both only
>> carry Ethernet frames.
>
> I know and indeed in the mlx4 case, the HW (ConnectX3-pro NIC) that
> supports VXLAN offloads also supports NVGRE, but generally speaking, I
> can't commit for other vendors HW/driver which support VXLAN today.
>
>
>> This would be equivalent to adding more protocol specific GSO feature
>> bits. I still don't see how this will scale. The number of protocols
>> that we might want to encapsulate over UDP is vast-- even before FOU
>> adding possibility of encapsulating any IP protocol in UDP. And, as
>> already pointed out, devices might have other arbitrary limitations
>> such as length of inner headers that wouldn't easily be represented in features.
>
>
>> Also, this does not benefit the stack or drivers that already support
>> generic SKB_GSO_UDP_TUNNEL mechanism.
>
> But again, we have 4-5 drivers that are
>
> 1. upstream
> 2. support GSO offloading under VXLAN
> 3. advertize GSO_UDP_TUNNEL
>
> As a starting point to stabilize the system (3.18 which has FOU and
> friends, merge window coming up while we are @ LPC) we can
>
> 1. add GSO_UDP_VXLAN_TUNNEL type
>
> 2. ask each maintainer to decide if they want to advertize the generic tunnel
> or only the vxlan specific one
>
> 3. color udp tunneled skb's with the tunnel type being vxlan or something else
>
> have today's code that decides if to do SW GSO or HW GSO choose according
> to the skb color and the driver posted value.
>
Solution #4: apply this patch and implement the check functions as
needed in those 4 or 5 drivers. If a device can only do VXLAN/NVGRE
then I believe the check function is something like:

bool mydev_gso_check(struct sk_buff *skb, struct net_device *dev)
{
        if ((skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL) &&
            ((skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
              skb->protocol != htons(ETH_P_TEB) ||
              skb_inner_mac_header(skb) - skb_transport_header(skb) != 12)
                return false;

        return true;
}

>> Would any other driver maintainers like to chime in on this?
>
> Alex? John?
