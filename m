From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next 02/10] udp: Expand UDP tunnel common APIs
Date: Tue, 22 Jul 2014 19:16:54 -0700
Message-ID: <53CF1B16.1000009@gmail.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>	<1406024393-6778-3-git-send-email-azhou@nicira.com>	<CA+mtBx9M_BpjT-_Egng+jFxmqJzdC2Npg0ufE2ZSAb9Lhw8hxg@mail.gmail.com>	<CACzMAJ+uW0rYQxxmi4GouGF64bbr0VDCsdrBymypWLxCaHQSrA@mail.gmail.com>	<CA+mtBx9RUe7a2hYsRjHbS3E+TzGOQ4Q8wLZp+-TDHQkV+L5c1Q@mail.gmail.com>	<CAEP_g=8oQ_Yn1ZDNjoFKgwRaGvpyW+s9RfOd1utEMsNWmJmX-Q@mail.gmail.com>	<CA+mtBx830L17hr_eaRKHcA9MaE9Xs7W3pC+sYh7a=E=CVmM3QQ@mail.gmail.com>	<53CEEBFD.9020402@intel.com> <CA+mtBx-q0PV4U_jGt-N+v5Ax_uoxYeQjrvHCqmAvU_VEQtFZNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:35040 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875AbaGWCQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 22:16:56 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so663648pdj.12
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 19:16:55 -0700 (PDT)
In-Reply-To: <CA+mtBx-q0PV4U_jGt-N+v5Ax_uoxYeQjrvHCqmAvU_VEQtFZNg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2014 04:24 PM, Tom Herbert wrote:
> On Tue, Jul 22, 2014 at 3:55 PM, Alexander Duyck
> <alexander.h.duyck@intel.com> wrote:
>> On 07/22/2014 03:38 PM, Tom Herbert wrote:
>>> On Tue, Jul 22, 2014 at 2:56 PM, Jesse Gross <jesse@nicira.com> wrote:
>>>> On Tue, Jul 22, 2014 at 5:16 PM, Tom Herbert <therbert@google.com> wrote:
>>>>> On Tue, Jul 22, 2014 at 2:02 PM, Andy Zhou <azhou@nicira.com> wrote:
>>>>>> On Tue, Jul 22, 2014 at 12:52 PM, Tom Herbert <therbert@google.com> wrote:
>>>>>>>> --- a/include/net/udp_tunnel.h
>>>>>>>> +++ b/include/net/udp_tunnel.h
>>>>>>>> @@ -1,7 +1,10 @@
>>>>>>>>  #ifndef __NET_UDP_TUNNEL_H
>>>>>>>>  #define __NET_UDP_TUNNEL_H
>>>>>>>>
>>>>>>>> -#define UDP_TUNNEL_TYPE_VXLAN 0x01
>>>>>>>> +#include <net/ip_tunnels.h>
>>>>>>>> +
>>>>>>>> +#define UDP_TUNNEL_TYPE_VXLAN  0x01
>>>>>>>> +#define UDP_TUNNEL_TYPE_GENEVE 0x02
>>>>>>>>
>>>>>>> Why do we need to define these? Caller should know what type of port is
>>>>>>> being opened and provide appropriate encap_rcv.
>>>>>>
>>>>>> Assume udp tunnel layer needs to keep track of open ports, should it
>>>>>> also keep track of the protocol associated with the port?
>>>>>>
>>>>> For what purpose? Other than for offloads and rcv_encap functions that
>>>>> provide the service function anyway, what need is there for UDP layer
>>>>> to know about this. More to the point, if I add a module to the kernel
>>>>> with a new flavor of UDP tunneling, I shouldn't have to touch any core
>>>>> code for things to work correctly. So by this line of thinking,
>>>>> neither the terms VXLAN nor GENEVE should appear in any common code.
>>>>
>>>> The hardware will need to know what the header format is so that it
>>>> can parse the packets on receive. And since the NIC can't exactly call
>>>> into a function pointer like GRO can, I'm not sure that there is a
>>>> solution that doesn't involve an identifier that needs to be listed
>>>> somewhere. This is a pretty minimal impact - it doesn't actually
>>>> appear in the core code.
>>>
>>> The hardware doesn't *need* to know this, it's must be optional and
>>> should have no bearing on the software stack. Suggest to put them in
>>> their own header file. Also, as HW features these should appear in
>>> NETIF_F_* list so that we can control on a per device level rather to
>>> enable this feature (something like how NETIF_F_GSO_* was done).
>>>
>>> What about support for L2TP/UDP?
>>
>> The hardware needs some means of knowing what UDP port numbers are used
>> for VXLAN and/or GENEVE as the two formats contain subtle differences
>> that we have to be ready for on the Rx path as we have to parse out the
>> frames.
>>
>> We already have feature flags controlling the offloads, what the port
>> numbers provide is a means for us to determine what Rx packets we should
>> parse as tunnels vs standard UDP and which tunnel type we should parse
>> it as.
>>
> Which feature flags control the receive side parsing in the device?

The only real features that need the port info are Rx hash and Rx
checksum.  If those are disabled then there shouldn't be any need for
the port numbers.  I don't recall if you can disable them separately
from the non-tunnel case though.  I believe they are linked to the
standard offloads.

Thanks,

Alex
