From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next 02/10] udp: Expand UDP tunnel common APIs
Date: Tue, 22 Jul 2014 14:16:11 -0700
Message-ID: <CA+mtBx9RUe7a2hYsRjHbS3E+TzGOQ4Q8wLZp+-TDHQkV+L5c1Q@mail.gmail.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
	<1406024393-6778-3-git-send-email-azhou@nicira.com>
	<CA+mtBx9M_BpjT-_Egng+jFxmqJzdC2Npg0ufE2ZSAb9Lhw8hxg@mail.gmail.com>
	<CACzMAJ+uW0rYQxxmi4GouGF64bbr0VDCsdrBymypWLxCaHQSrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:35034 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752457AbaGVVQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 17:16:12 -0400
Received: by mail-ig0-f171.google.com with SMTP id l13so4508821iga.4
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 14:16:12 -0700 (PDT)
In-Reply-To: <CACzMAJ+uW0rYQxxmi4GouGF64bbr0VDCsdrBymypWLxCaHQSrA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 22, 2014 at 2:02 PM, Andy Zhou <azhou@nicira.com> wrote:
> On Tue, Jul 22, 2014 at 12:52 PM, Tom Herbert <therbert@google.com> wrote:
>>
>>
>> On Tue, Jul 22, 2014 at 3:19 AM, Andy Zhou <azhou@nicira.com> wrote:
>>> Added create_udp_tunnel_socket(), packet receive and transmit,  and
>>> other related common functions for UDP tunnels.
>>>
>>> Per net open UDP tunnel ports are tracked in this common layer to
>>> prevent sharing of a single port with more than one UDP tunnel.
>>>
>> bind should already prevent this. I don't really see a need to track udp
>> encap ports separately.
>
> When a new network device driver is activated, does it need to get a list
> of currently open UDP tunnel ports to configure its offloads?
>
If that's needed it should be driven by the UDP offload registration
mechanisms, not from UDP tunnel code. It's very conceivable that we
will have UDP offloads that don't correspond to UDP tunnels in the
kernel--QUIC comes to mind.

>>> --- a/include/net/udp_tunnel.h
>>> +++ b/include/net/udp_tunnel.h
>>> @@ -1,7 +1,10 @@
>>>  #ifndef __NET_UDP_TUNNEL_H
>>>  #define __NET_UDP_TUNNEL_H
>>>
>>> -#define UDP_TUNNEL_TYPE_VXLAN 0x01
>>> +#include <net/ip_tunnels.h>
>>> +
>>> +#define UDP_TUNNEL_TYPE_VXLAN  0x01
>>> +#define UDP_TUNNEL_TYPE_GENEVE 0x02
>>>
>> Why do we need to define these? Caller should know what type of port is
>> being opened and provide appropriate encap_rcv.
>
> Assume udp tunnel layer needs to keep track of open ports, should it
> also keep track of the protocol associated with the port?
>
For what purpose? Other than for offloads and rcv_encap functions that
provide the service function anyway, what need is there for UDP layer
to know about this. More to the point, if I add a module to the kernel
with a new flavor of UDP tunneling, I shouldn't have to touch any core
code for things to work correctly. So by this line of thinking,
neither the terms VXLAN nor GENEVE should appear in any common code.

>>> +
>>> +/* Calls the ndo_add_tunnel_port of the caller in order to
>>> + * supply the listening VXLAN udp ports. Callers are expected
>>> + * to implement the ndo_add_tunnle_port.
>>> + */
>> Seems a little presumptuous that we're doing VXLAN specific things in what
>> should be common and generic code...
>>
> You are right. Cut-and-past error. It should read "UDP tunnel ports"
> instead. I will fix it.

Given my arguments above, I'm not sure that ndo_add_tunnel_port is the
right interface either.
