From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] netconsole: Initialize after all core networking drivers
Date: Tue, 29 Dec 2015 14:59:49 +0100
Message-ID: <568291D5.9050008@stressinduktion.org>
References: <20151217235239.GA1444048@devbig337.prn1.facebook.com>
 <1450400894.8474.114.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151218014615.GB1715233@devbig337.prn1.facebook.com>
 <20151223230328.GA967745@devbig337.prn1.facebook.com>
 <567BC832.8090704@stressinduktion.org>
 <CAHA+R7OspurUF_tj2v59gpmG+CGHxnUMjV-6b2MHtFw4ie14xQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Calvin Owens <calvinowens@fb.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	izumi.taku@jp.fujitsu.com, John Linville <linville@tuxdriver.com>,
	David Ahern <dsa@cumulusnetworks.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel-team <kernel-team@fb.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHA+R7OspurUF_tj2v59gpmG+CGHxnUMjV-6b2MHtFw4ie14xQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29.12.2015 00:21, Cong Wang wrote:
> On Thu, Dec 24, 2015 at 2:25 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> Hi,
>>
>> On 24.12.2015 00:03, Calvin Owens wrote:
>>> This patch addresses the issue cited in 7332a13b038be05c by making vxlan
>>> actually check if ipv6 is loaded, and reverts it to module_init() so
>>> that it becomes device_initcall() when built-in, eliminating the
>>> netconsole issue.
>>>
>>> The ipv6 module is permanent, so there's no need to actually do the
>>> usual module_get/module_put dance: once we find it loaded, we can just
>>> assume that it always will be.
>>>
>>> AFAICS, nothing actually ends up calling vxlan_open() during initcalls,
>>> so in the (IPV6=y && VXLAN=y) case we can't end up there before ipv6 has
>>> initialized.
>>>
>>> Signed-off-by: Calvin Owens <calvinowens@fb.com>
>>
>> This architecture just sucks. :(
>>
>>
>> ixgbe should not have to call into vxlan but vxlan has to call to ixgbe.
>> Thus the vxlan_get_rx_port is absolutely unnecessary and should be
>> removed. This also lets ixgbe depend on vxlan which is absurd.
>>
>> Simply let vxlan_get_rx_port be called from vxlan_notifier_block on
>> NETDEV_REGISTER or NETDEV_UP events, which is already available.
>>
>> For the second vxlan_get_rx_port case, which is a
>> IXGBE_FLAG2_VXLAN_REREG_NEEDED needed event, I would suggest we also
>> push that over to the vxlan_notifier_block, maybe with a new event type
>> for the notifiers.
>>
>> After this change ixgbe would not depend on vxlan module any more.
>>
>
> Agreed with this direction, but not yet convinced with this approach.
>
> My feeling is that we should move this piece of code into core
> networking, so that both vxlan and ixgbe driver can call it without
> worrying about the dependencies. It looks like all we need here
> is a per-netns structure about family and ports for all vxlans.
> But I could overlook something here.

We actually have that already in terms of net_generic(vxlan_net_id). We 
will also need that for geneve and other offloads supported by hardware.

Your approach seems to be basically the same like mine, just in your 
proposal the driver calls to all the helper functions, while in my 
proposal the vxlan/geneve and other layers can update the offload 
settings on the hardware.

As the notifier_blocks are already available and registered, why not 
just use them?

Thanks,
Hannes
