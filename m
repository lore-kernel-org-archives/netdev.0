From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 1/3] netdev: introduce new NETIF_F_HW_SWITCH_OFFLOAD feature
 flag for switch device offloads
Date: Sat, 06 Dec 2014 10:59:11 -0800
Message-ID: <548351FF.1070703@cumulusnetworks.com>
References: <1417746401-8140-2-git-send-email-roopa@cumulusnetworks.com> <20141205224320.GA22992@casper.infradead.org> <5482B44F.2050509@cumulusnetworks.com> <20141206101425.GA15999@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	vyasevic@redhat.com, f.fainelli@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:43023 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751283AbaLFS7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Dec 2014 13:59:17 -0500
In-Reply-To: <20141206101425.GA15999@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/6/14, 2:14 AM, Thomas Graf wrote:
> On 12/05/14 at 11:46pm, Roopa Prabhu wrote:
>> On 12/5/14, 2:43 PM, Thomas Graf wrote:
>>> On 12/04/14 at 06:26pm, roopa@cumulusnetworks.com wrote:
>>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>>
>>>> This is a generic high level feature flag for all switch asic features today.
>>>>
>>>> switch drivers set this flag on switch ports. Logical devices like
>>>> bridge, bonds, vxlans can inherit this flag from their slaves/ports.
>>>>
>>>> I had to use SWITCH in the name to avoid ambiguity with other feature
>>>> flags. But, since i have been harping about not calling it 'switch',
>>>> I am welcome to any suggestions :)
>>>>
>>>> An alternative to using a feature flag is to use a IFF_HW_OFFLOAD
>>>> in net_device_flags.
>>> What does this flag indicate specifically? What driver would
>>> implement ndo_bridge_setlink() but not set this flag?
>>>
>>> I think it should be clearly documented when this flag is to bet set.
>> I mentioned it as an alternative because it was there in my RFC patch. There
>> is no code for it yet.
>> And I will get rid of the comment in v2.
> Sorry, I was referring to NETIF_F_HW_SWITCH_OFFLOAD.
Ah, ok.

> I do not
> understand the scope of this bit/flag yet.
> Can you give examples
> when to set this bit? At what point would the existing ixgbe FDB
> offload set this bit? Is there a case when ndo_bridge_setlink()
> is implemented but this bit is not set?
The switch asic drivers will set this flag on the switch ports. This 
flag will be used when you want to offload
kernel networking to hardware or in other words accelerate  the 
corresponding kernel network function.
  In the context of current patches it is the bridge driver. A kernel 
bridge that has any of these switch asic ports
  as bridge ports can inherit this flag and use this flag on the ports to
call the switch driver ndo ops to offload state to hw and thus hw 
accelerate the bridging function.

The existing l2 offload flags, example the hwmode and self flags used 
for nic drivers bridge/l2 offload,
does not help switch asic hardware completely. AFAICT, those are used 
today to manage the bridge in nic hw directly.
They don't involve the bridge driver.

And the most important thing is they require the user to specify this 
additional flag to offload.


In my proposal,
- The flag/bit helps switch asic drivers to indicate that they 
accelerate the kernel networking objects/functions
- The user does not have to specify a new flag to do so. A bridge 
created with switch asic ports will thus be accelerated if the switch 
driver supports it.
- The user can continue to directly manage l2 in nics (ixgbe) using the 
existing hwmode/self flags
- And it also does not stop users from using the 'self' flag to talk to 
the switch asic driver directly
- And involving the bridge driver makes sure the add/del notifications 
to user space go out after both kernel and hardware are programmed

Regarding ixgbe driver setting this flag: For the current vepa and veb 
modes I don't see a need for it.
But if there is a use case in the future to indicate hw accelerating the 
bridge driver, ixgbe driver can set this flag
