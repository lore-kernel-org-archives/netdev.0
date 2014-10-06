From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Mon, 6 Oct 2014 14:51:49 -0700
Message-ID: <CAEP_g=_vY8gE1h8sKPfXeQSGH52z87usgVHyL49NC_A0UD241g@mail.gmail.com>
References: <1411962607-27878-1-git-send-email-therbert@google.com>
 <CAJ3xEMi-TRXevenx87UM7JnKqRQQATW4MBjbz8JdnQE9gk3KZw@mail.gmail.com>
 <CA+mtBx8r05=qs2J58LFq56762tFB7wF4Dsr3C5TC9w5qQP5jGw@mail.gmail.com>
 <CAJ3xEMhf6b75TQDFqEPMSXCpL9ToWG1q0OMPtrEuHNSm=-PSwQ@mail.gmail.com>
 <CA+mtBx_6HcZh5Ys1FJFBXkZ2bWX1gP6bTcjY7gbR6RG_TOy50Q@mail.gmail.com>
 <CAJ3xEMi0biCWTNtLOJ=0HWZYjOWi6pN2bw2=EWajp6XnpoyVRw@mail.gmail.com>
 <CA+mtBx-sP6g9hXAYGfHKCPYkCtjgCFM0srueh1uhoNnC2ACr1g@mail.gmail.com>
 <CAJ3xEMhc-97+3ZDwqXzX2N+=voO4QvJ5_YXn3sp8r8E9YyqotQ@mail.gmail.com>
 <CA+mtBx9=+fGjwJCKpTW5EifmavC6VGnbuJdkc5tqzeEHz+5twA@mail.gmail.com>
 <CAJ3xEMhzxfP3Sqp=_QSQehd2j2s=Gr3B1iO2S--OcoT7VC94nQ@mail.gmail.com> <CA+mtBx8-w74f_f9JEfpwH9=Mjr_zaJJAYCMMdYAWdCy-51pzqg@mail.gmail.com>
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
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:38482 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752338AbaJFVwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 17:52:12 -0400
Received: by mail-qa0-f54.google.com with SMTP id i13so4186714qae.13
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 14:52:11 -0700 (PDT)
In-Reply-To: <CA+mtBx8-w74f_f9JEfpwH9=Mjr_zaJJAYCMMdYAWdCy-51pzqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 5, 2014 at 11:49 AM, Tom Herbert <therbert@google.com> wrote:
> On Sun, Oct 5, 2014 at 7:04 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>> On Thu, Oct 2, 2014 at 2:06 AM, Tom Herbert <therbert@google.com> wrote:
>>> On Wed, Oct 1, 2014 at 1:58 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>>> On Tue, Sep 30, 2014 at 6:34 PM, Tom Herbert <therbert@google.com> wrote:
>>>>> On Tue, Sep 30, 2014 at 7:30 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>> [...]
>>> Solution #4: apply this patch and implement the check functions as
>>> needed in those 4 or 5 drivers. If a device can only do VXLAN/NVGRE
>>> then I believe the check function is something like:
>>>
>>> bool mydev_gso_check(struct sk_buff *skb, struct net_device *dev)
>>> {
>>>         if ((skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL) &&
>>>             ((skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
>>>               skb->protocol != htons(ETH_P_TEB) ||
>>>               skb_inner_mac_header(skb) - skb_transport_header(skb) != 12)
>>>                 return false;
>>>
>>>         return true;
>>> }
>>
>> Yep, such helper can can be basically made to work and let the 4-5
>> drivers that can
>> do GSO offloading for vxlan but not for any FOU/GUE packets signal
>> that to the stack.
>>
>> Re the 12 constant, you were referring to the udp+vxlan headers? it's 8+8
>>
>> Also, we need a way for drivers that can support VXLAN or NVGRE but
>> not concurrently
>> on the same port @ the same time to only let vxlan packet to pass
>> successfully through the helper.
>>
> Or, there should be no difference in GSO processing between VXLAN and
> NVGRE. Can you explain why you feel you need to differentiate them for
> GSO?

There is a difference in the processing that needs to happen for VXLAN
and GRE, even on transmit: at a minimum, the length field in the UDP
header needs to be updated for VXLAN. These are already broken out in
the stack between GRE and UDP tunnels anyways though.
