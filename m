From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH net v2] L2TP:Adjust intf MTU,factor underlay L3,overlay L2
Date: Tue, 11 Oct 2016 08:47:45 +0100
Message-ID: <52890af4-38d6-6aa7-a9e0-69be60fe89fa@katalix.com>
References: <alpine.DEB.2.11.1609221341500.6975@duvvury30.eng.vyatta.net>
 <57ED30D7.6000009@katalix.com>
 <alpine.DEB.2.11.1609291913070.8509@duvvury48.eng.vyatta.net>
 <1cec5be4-0719-0dca-d3c6-8c794c867672@katalix.com>
 <alpine.DEB.2.11.1610031954330.2198@duvvury48.eng.vyatta.net>
 <149288c4-a352-ae30-ad3a-91d1edfa4bce@katalix.com>
 <CAGeBGG7AS1JZYHC6T5_H6vY4wfptUtPzO=+kdCcUzJGXA0m6_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: kleptog@svana.org, netdev@vger.kernel.org, davem@redhat.com,
        linux-kernel@vger.kernel.org, nprachan@brocade.com,
        Robert Shearman <rshearma@brocade.com>, dfawcus@brocade.com,
        stephen@networkplumber.org, acme@redhat.com, lboccass@brocade.com,
        bhong@brocade.com
To: R Parameswaran <parameswaran.r7@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGeBGG7AS1JZYHC6T5_H6vY4wfptUtPzO=+kdCcUzJGXA0m6_A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/10/16 02:54, R Parameswaran wrote:
>
>
> Hi James,
>
> Please see inline:
>
> On Tue, Oct 4, 2016 at 12:53 AM, James Chapman <jchapman@katalix.com
> <mailto:jchapman@katalix.com>> wrote:
>
>     On 04/10/16 04:12, R. Parameswaran wrote:
>     >
>     > Hi James,
>     >
>     > Please see inline, thanks for the reply:
>     >
>     > On Sat, 1 Oct 2016, James Chapman wrote:
>     >
>     >> On 30/09/16 03:39, R. Parameswaran wrote:
>     >>>>> + /* Adjust MTU, factor overhead - underlay L3 hdr, overlay
>     L2 hdr*/
>     >>>>> + if (tunnel->sock->sk_family == AF_INET)
>     >>>>> +         overhead += (ETH_HLEN + sizeof(struct iphdr));
>     >>>>> + else if (tunnel->sock->sk_family == AF_INET6)
>     >>>>> +         overhead += (ETH_HLEN + sizeof(struct ipv6hdr));
>     >>>> What about options in the IP header? If certain options are
>     set on the
>     >>>> socket, the IP header may be larger.
>     >>>>
>     >>> Thanks for the reply - It looks like IP options can only be
>     >>> enabled through setsockopt on an application's socket (if
>     there's any
>     >>> other way to turn on IP options, please let me know - didn't
>     see any
>     >>> sysctl setting for transmit). This scenario would come
>     >>> into picture when an application opens a raw IP or UDP socket
>     such that it
>     >>> routes into the L2TP logical interface.
>     >> No. An L2TP daemon (userspace) will open a socket for each
>     tunnel that
>     >> it creates. Control and data packets use the same socket, which
>     is the
>     >> socket used by this code. It may set any options on its
>     sockets. L2TP
>     >> tunnel sockets can be created either by an L2TP daemon (managed
>     tunnels)
>     >> or by ip l2tp commands (unmanaged tunnels).
>     >>
>     > One Q I have is whether it would be sufficient to solve this for the
>     > common case (i.e no IP options) and have an expectation that the
>     > administrator will explicitly provision the mtu using the 'ip
>     link ...
>     > mtu'  command when dealing with infrequent occurences like IP
>     options?
>     >
>     > But looking at the code, it looks to be possible to pick up whether
>     > options are enabled and how long the options are, from the
>     ip_options struct
>     > embedded in the tunnel socket. If you want me to, I can repost
>     the patch
>     > with this change (will need a few days) - please let me know if
>     this is
>     > what you had in mind.
>     >
>     >
>     Yes, that's what I had in mind. But my preference would be that this
>     would be a new function in the ip core, for use by any encap protocol,
>     where appropriate.
>
> Discussed this with Nachi (nprachan), we were thinking of a new
> function in ip_sockglue.c which would take the tunnel socket as
> parameter, derive the underlay device MTU and compute the underlay L3
> overhead (IPv4/IPv6 header, UDP header if it is a UDP socket, and IP
> option length if the ip_options struct exists in the socket). The
> function would be agnostic to the tunnel type (although we could
> provision tunnel-type and encap type as parameters). Callers would
> call it to figure out the cumulative underlay L3 overhead and the
> underlay MTU, and then use these numbers in the MTU calculation for
> their specific tunnel type. Let me know if that is different from what
> you had in mind, and/or if you have any suggestions on which file to
> place this in. I'll try and have this re-posted  by the end of this
> week or by early next week.
>

I think keep it simple. A function to return the size of the IP header
associated with any IP socket, not necessarily a tunnel socket. Don't
mix in any MTU derivation logic or UDP header size etc.

Post code early as an RFC. You're more likely to get review feedback
from others.
