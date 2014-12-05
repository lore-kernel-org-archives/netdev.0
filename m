From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH net-next 0/4] net: allow setting congctl via routing table
Date: Fri, 5 Dec 2014 11:05:21 -0800
Message-ID: <CAA93jw5SCx32T1Z-cSeAyHFWiQsW9gp20Qoq3v=w_RO7sq=VoA@mail.gmail.com>
References: <1417793092-6263-1-git-send-email-dborkman@redhat.com>
	<CAA93jw46b5hCFPAwziyTRpTAzLdXeb4nrTEZXiEqxYWhRi49CA@mail.gmail.com>
	<1417804540.2462.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:59312 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbaLETFW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 14:05:22 -0500
Received: by mail-ob0-f169.google.com with SMTP id vb8so995947obc.28
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 11:05:21 -0800 (PST)
In-Reply-To: <1417804540.2462.4.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 5, 2014 at 10:35 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Fr, 2014-12-05 at 08:35 -0800, Dave Taht wrote:
>> On Fri, Dec 5, 2014 at 7:24 AM, Daniel Borkmann <dborkman@redhat.com=
> wrote:
>> > This is the second part of our work and allows for setting the con=
gestion
>> > control algorithm via routing table. For details, please see indiv=
idual
>> > patches.
>> >
>> > Joint work with Florian Westphal, suggested by Hannes Frederic Sow=
a.
>> >
>> > Thanks!
>> >
>> > Daniel Borkmann (4):
>> >   net: tcp: refactor reinitialization of congestion control
>> >   net: tcp: add key management to congestion control
>> >   net: tcp: add RTAX_CC_ALGO fib handling
>> >   net: tcp: add per route congestion control
>>
>>
>> Very interesting. Have you tried something other than dctcp here
>> (e.g. westwood or lp?)
>>
>> Have you considered the case where the route changes underneath
>> you from one device to another?
>
> Notice, there is no way the state of a tcp congestion control algorit=
hm
> can be converted to be used by a different one, so this would only
> affect new tcp connections via this interface.

You are missing the point. If the route changes from a path that
is DCTCP capable to one that is not, (say you fail over to a backup lin=
k)

and flows persist, bad things will happen. DCTCP, in particular, depend=
s
upon a very specific AQM configuration on all the hops in the path, wit=
hout that
it can be very aggressive.

I do think it is feasible to convert from at least some of the
core state from one tcp congestion control algorithm to another.

>> Example, here I am routing everything through eth0, where I
>> would want cubic, probably...
>>
>> root@ganesha:~/git/tinc# ip route
>> default via 172.26.16.1 dev eth0  proto babel onlink
>> 69.181.216.0/22 via 172.26.16.1 dev eth0  proto babel onlink
>> 169.254.0.0/16 dev eth0  scope link  metric 1000
>> 172.26.16.0/24 dev eth0  proto kernel  scope link  src 172.26.16.177
>> 172.26.16.1 via 172.26.16.1 dev eth0  proto babel onlink
>> 172.26.16.112 via 172.26.16.112 dev eth0  proto babel onlink
>> 172.26.17.0/24 via 172.26.16.1 dev eth0  proto babel onlink
>> 172.26.17.3 via 172.26.16.1 dev eth0  proto babel onlink
>> 172.26.17.227 via 172.26.16.1 dev eth0  proto babel onlink
>> 192.168.7.0/30 dev eth1  proto kernel  scope link  src 192.168.7.1  =
metric 1
>> 192.168.7.2 via 172.26.16.112 dev eth0  proto babel onlink
>>
>> And I pull the plug, and everything flips over to wlan0,
>> where I might want westwood (or something saner than
>> that. It might be nice to have a per-device cc default
>> algorithm...)
>
> Something like that might be possible with metrics and "via ... dev i=
f0
> metric xxx" routes, which will be cleaned up as soon as the interface
> goes down and the fallback will be to a route with a different
> congestion algorithm.

mmm... I do dynamic routing via various routing protocols, which
generally don't bother with inserting more than one metric.

While we are thinking through this, what happens with tunnels?

This route in my network switches between interfaces and routes
depending on which is best.

fde5:dfb9:df90:fff0::/64 dev vpn6  proto kernel  metric 256
fde5:dfb9:df90:fff0::/60 via fde5:dfb9:df90:fff0::1 dev vpn6  metric 10=
24


>> root@ganesha:~/git/tinc# ip route
>> default via 172.26.17.224 dev wlan0  proto babel onlink
>> 69.181.216.0/22 via 172.26.17.224 dev wlan0  proto babel onlink
>> 169.254.0.0/16 dev eth0  scope link  metric 1000
>> 172.26.16.0/24 dev eth0  proto kernel  scope link  src 172.26.16.177
>> 172.26.16.1 via 172.26.17.227 dev wlan0  proto babel onlink
>> 172.26.16.112 via 172.26.17.227 dev wlan0  proto babel onlink
>> 172.26.17.0/24 via 172.26.17.224 dev wlan0  proto babel onlink
>> 172.26.17.3 via 172.26.17.227 dev wlan0  proto babel onlink
>> 172.26.17.227 via 172.26.17.227 dev wlan0  proto babel onlink
>> 192.168.7.0/30 dev eth1  proto kernel  scope link  src 192.168.7.1  =
metric 1
>> 192.168.7.2 via 172.26.17.227 dev wlan0  proto babel onlink
>>
>
> Bye,
> Hannes
>
>



--=20
Dave T=C3=A4ht

thttp://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks
