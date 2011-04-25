From: Dominik Kaspar <dokaspar.ietf@gmail.com>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Mon, 25 Apr 2011 16:35:17 +0200
Message-ID: <BANLkTi=xns1Gdjyt-SX3yDETSQfO23rXXg@mail.gmail.com>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
	<1303730701.2747.110.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Carsten Wolff <carsten@wolffcarsten.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:46239 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758278Ab1DYOfS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 10:35:18 -0400
Received: by iyb14 with SMTP id 14so1864705iyb.19
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 07:35:17 -0700 (PDT)
In-Reply-To: <1303730701.2747.110.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric and Carsten,

Thanks a lot for your quick replies. I don't have a tcpdump of this
experiment, but here is the tcp_probe log that the plot is based on
(I'll run a new test using tcpdump if you think that's more useful):

http://home.simula.no/~kaspar/static/mptcp-emu-wlan-hspa-00.log

I have also noticed what Carsten mentions, the tcp_reordering value is
essential for this whole behavior. When I start an experiment and
increase sysctl.net.ipv4.tcp_reordering during the running connection,
the TCP throughput immediately jumps close to the aggregate of both
paths. Without intervention, as in this experiment, tcp_reordering
starts out as 3 and then makes small oscillations between 3 and 12 for
more than 2 minutes. At about second 141, TCP somehow finds a new
highest reordering value (23) and at the same time, the throughput
jumps up "to the next level". The value of 23 is then used all the way
until second 603, when the reordering value becomes 32 and the
throughput again jumps up a level.

I understand that tp->reordering is increased when reordering is
detected, but what causes tp->reordering to sometimes be decreased
back to 3? Also, why does a decrease back to 3 not make the whole
procedure start all over again? For example, at second 1013.64,
tp->reordering falls from 127 down to 3. A second later (1014.93) it
then suddenly increases from 3 up to 32 without considering any
numbers in between. Why it is now suddenly so fast? At the very
beginning, it took 600 seconds to grow from 3 to 32 and afterward it
just takes a second...?

=46or the experiments, all default TCP options were used, meaning that
SACK, DSACK, Timestamps, were all enabled. Not sure how to turn on/off
TSO... so that is probably enabled, too. Path emulation is done with
tc/netem at the receiver interfaces (eth1, eth2) with this script:

http://home.simula.no/~kaspar/static/netem.sh

Greetings,
Dominik


On Mon, Apr 25, 2011 at 1:25 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le lundi 25 avril 2011 =E0 12:37 +0200, Dominik Kaspar a =E9crit :
>> Hello,
>>
>> Knowing how critical packet reordering is for standard TCP, I am
>> currently testing how robust Linux TCP is when packets are forwarded
>> over multiple paths (with different bandwidth and RTT). Since Linux
>> TCP adapts its "dupAck threshold" to an estimated level of packet
>> reordering, I expect it to be much more robust than a standard TCP
>> that strictly follows the RFCs. Indeed, as you can see in the
>> following plot, my experiments show a step-wise adaptation of Linux
>> TCP to heavy reordering. After many minutes, Linux TCP finally reach=
es
>> a data throughput close to the perfect aggregated data rate of two
>> paths (emulated with characteristics similar to IEEE 802.11b (WLAN)
>> and a 3G link (HSPA)):
>>
>> http://home.simula.no/~kaspar/static/mptcp-emu-wlan-hspa-00.png
>>
>> Does anyone have clues what's going on here? Why does the aggregated
>> throughput increase in steps? And what could be the reason it takes
>> minutes to adapt to the full capacity, when in other cases, Linux TC=
P
>> adapts much faster (for example if the bandwidth of both paths are
>> equal). I would highly appreciate some advice from the netdev
>> community.
>>
>> Implementation details:
>> This multipath TCP experiment ran between a sending machine with a
>> single Ethernet interface (eth0) and a client with two Ethernet
>> interfaces (eth1, eth2). The machines are connected through a switch
>> and tc/netem is used to emulate the bandwidth and RTT of both paths.
>> TCP connections are established using iperf between eth0 and eth1 (t=
he
>> primary path). At the sender, an iptables' NFQUEUE is used to "spoof=
"
>> the destination IP address of outgoing packets and force some to
>> travel to eth2 instead of eth1 (the secondary path). This multipath
>> scheduling happens in proportion to the emulated bandwidths, so if t=
he
>> paths are set to 500 and 1000 KB/s, then packets are distributed in =
a
>> 1:2 ratio. At the client, iptables' RAWDNAT is used to translate the
>> spoofed IP addresses back to their original, so that all packets end
>> up at eth1, although a portion actually travelled to eth2. ACKs are
>> not scheduled over multiple paths, but always travel back on the
>> primary path. TCP does not notice anything of the multipath
>> forwarding, except the side-effect of packet reordering, which can b=
e
>> huge if the path RTTs are set very differently.
>>
>
> Hi Dominik
>
> Implementation details of the tc/netem stages are important to fully
> understand how TCP stack can react.
>
> Is TSO active at sender side for example ?
>
> Your results show that only some exceptional events make bandwidth
> really change.
>
> A tcpdump/pcap of ~10.000 first packets would be nice to provide (not=
 on
> mailing list, but on your web site)
