From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Re: ip_no_pmtu_disc and UDP
Date: Mon, 26 Oct 2015 15:00:48 -0700
Message-ID: <CAK3+h2y3AiN7byuw2ihBohbu+TmOs2ursBvvsL5rwd32MYDGYA@mail.gmail.com>
References: <CAK3+h2wFfh+HE78kHoWwgc9vyTCLWM90C4RQ=uTRk8551-jQ7A@mail.gmail.com>
	<1445639662.2872263.418778169.006CB827@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:34845 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814AbbJZWAu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 18:00:50 -0400
Received: by lbbes7 with SMTP id es7so50557961lbb.2
        for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 15:00:48 -0700 (PDT)
In-Reply-To: <1445639662.2872263.418778169.006CB827@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the UDP packet size is about 768, here is how packet path  like:

client <----------------------------------------router<-------------------------------------------------->server
(eth0 mtu 1500 ip 10.3.72.69)     (eth0 mtu 1500 ip 10.3.72.1,
          (eth0 mtu 1500 ip 10.2.72.99)
                                                      eth1.1102 mtu
567 ip 10.2.72.139)


UDP client test script:

#!/usr/bin/perl

use strict;
use warnings;
use IO::Socket::INET;

my $socket = IO::Socket::INET->new(
                                      PeerPort  => 9999,
                                      PeerAddr  => '10.2.72.99',
                                      Proto     => 'udp',
                                      )
                                  or die "Can't bind : $@\n";



$| = 1;

my $data = "012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670123456701234567";

$socket->send($data);


sleep(10);

$socket->close();

so I am hoping if I echo 0, 1, 2, 3 respectively to
/proc/sys/net/ipv4/ip_no_pmtu_disc, I am expected to see DF bit
set/unset from the client and should have shown me on the router eth0
interface tcpdump, but instead, DF bit never set on the client. am I
misunderstanding something?


for example:

 two concurrent tcpdump on router eth0 (mtu 1500) and eth1.1102 (mtu
576) interface:

1 #tcpdump -nn -i eth0 -v udp and host 10.3.72.69 &

14:51:11.946143 IP (tos 0x0, ttl 64, id 7193, offset 0, flags [none],
proto UDP (17), length 796)
    10.3.72.69.43748 > 10.2.72.99.9999: UDP, length 768


2# tcpdump -nn -i eth1.1102 -v udp and host 10.3.72.69 &

14:51:11.946164 IP (tos 0x0, ttl 63, id 7193, offset 0, flags [+],
proto UDP (17), length 572)
14:51:11.946176 IP (tos 0x0, ttl 63, id 7193, offset 552, flags
[none], proto UDP (17), length 244)
    10.3.72.69.43748 > 10.2.72.99.9999: UDP, length 768
    10.3.72.69 > 10.2.72.99: udp

as you can see, the router was fragmenting the UDP packet and not
sending icmp frag needed message, one reason I can think of is  the DF
bit is not set on the original UDP packet.

client is on kernel 4.3.0-rc7+, router is on kernel  3.13.0-rc3

On Fri, Oct 23, 2015 at 3:34 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hello,
>
> On Fri, Oct 23, 2015, at 18:45, Vincent Li wrote:
>> It looks ip_no_pmtu_disc setting does not affect UDP IP packet DF bit
>> setting, is that intended behavior? echo 0, 1, 2, 3 respectively to
>> ip_no_pmtu_disc, UDP IP packet always have DF bit cleared, unless use
>> IP_PMTUDISC_DO on IP_MTU_DISCOVER as ip man page says.
>
> Which size do the UDP packets have and what is your MTU? inet_create
> also creates udp sockets and thus the setting does have effect.
>
>>
>> in inet_create, seems to prove that.
>>
>>        if (net->ipv4.sysctl_ip_no_pmtu_disc)
>>                 inet->pmtudisc = IP_PMTUDISC_DONT;
>>         else
>>                 inet->pmtudisc = IP_PMTUDISC_WANT;
>>
>> so I am wondering why UDP is excluded by ip_no_pmtu_disc, why in
>> inet_create, not assign each individual ip_no_pmtu_disc setting to
>> inet->pmtudisc but only check true and assign IP_PMTUDISC_DONT or
>> IP_PMTUDISC_WANT only.
>
> ip_no_pmtu_disc sysctl != IP_MTU_DISCOVER setsockopt. Also we cannot
> change this as it would disrupt communication easily relying on this
> established behavior.
>
> See Documentation/ip-sysctl.txt:
>
> ip_no_pmtu_disc - INTEGER
>         Disable Path MTU Discovery. If enabled in mode 1 and a
>         fragmentation-required ICMP is received, the PMTU to this
>         destination will be set to min_pmtu (see below). You will need
>         to raise min_pmtu to the smallest interface MTU on your system
>         manually if you want to avoid locally generated fragments.
>
>         In mode 2 incoming Path MTU Discovery messages will be
>         discarded. Outgoing frames are handled the same as in mode 1,
>         implicitly setting IP_PMTUDISC_DONT on every created socket.
>
>         Mode 3 is a hardend pmtu discover mode. The kernel will only
>         accept fragmentation-needed errors if the underlying protocol
>         can verify them besides a plain socket lookup. Current
>         protocols for which pmtu events will be honored are TCP, SCTP
>         and DCCP as they verify e.g. the sequence number or the
>         association. This mode should not be enabled globally but is
>         only intended to secure e.g. name servers in namespaces where
>         TCP path mtu must still work but path MTU information of other
>         protocols should be discarded. If enabled globally this mode
>         could break other protocols.
>
>         Possible values: 0-3
>         Default: FALSE
>
> Bye,
> Hannes
