From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: NAT stops forwarding ACKs after PMTU discovery
Date: Mon, 19 Aug 2013 01:43:18 -0700
Message-ID: <5211DAA6.1070302@fatooh.org>
References: <521061B4.1030508@fatooh.org>  <1376839467.21329.36.camel@edumazet-glaptop>  <alpine.DEB.2.00.1308182314050.25515@blackhole.kfki.hu>  <1376870425.4226.25.camel@edumazet-glaptop> <1376870592.4226.27.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from juniper.fatooh.org ([173.255.221.30]:46499 "EHLO
	juniper.fatooh.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973Ab3HSInT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 04:43:19 -0400
In-Reply-To: <1376870592.4226.27.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-08-18 17:03, Eric Dumazet wrote:
> On Sun, 2013-08-18 at 17:00 -0700, Eric Dumazet wrote:
> 
>> Code like this seems very suspect to me :
>>
>> before(sack, receiver->td_end + 1)
>>
> 
> My suggestion would be to try :
> 
> diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c

[...]

Thanks for all your suggestions--I really wasn't expecting so much on a
weekend. Here's all the data I have for tonight.


I tried the linux-next kernel, then linux-next with your patch applied.
Neither of them fix the problem, unfortunately. I have taken tcpdumps
for a working SSH and a failing SSH.

http://fatooh.org/files/tmp/linux-next-patch1.tar.bz2

[localhost]
sudo tcpdump -ni br0 -s 0 -w /tmp/local.pcap 'host 10.15.24.13 or icmp'

[router eth0]
tcpdump -ni eth0 -s 0 -w /tmp/eth0.pcap \
    'host 10.15.24.13 or (icmp and host not 69.78.33.132)'
* the exclusion here is just to remove some unrelated clutter

[router tun0]
tcpdump -ni tun0 -s 0 -w /tmp/tun0.pcap -s 0 'host 10.15.24.13 or icmp'

[remote]
tcpdump -ni eth0 -s 0 -w remote.pcap 'host 192.168.61.56'


Some notes:

1. I tested the new kernels only on the Linux router, assuming that is
where it was intended.

2. I take back what I wrote earlier about every connection that involves
PMTU discovery failed; I may have been observing this wrong. For now,
the situation is that some connections stop forwarding packets from the
remote host immediately after the retransmit, while other work fine.

3. From local.pcap, you can see that my localhost doesn't actually
transmit a large packet, yet the router's eth0 sees a large packet come
in. I think this is due to TSO, but I'm not completely sure.

4. For some reason, I cannot reproduce this when SSHing to a host at
work that is running Debian sid with 3.10-1-amd64, but I can reproduce
it when SSHing to hosts running Centos 6.4 with
2.6.32-358.6.1.el6.x86_64 (which surely has a ton of patches applied,
for whatever that's worth).

5. I have only a vague understanding of SACK; I will be reading up on
this soon. I will also look into packetdrill for reproducing the
problem, if the SSH results aren't good enough.

6. If I reduce the MTU on localhost to match the path MTU, the problem
does go away.

Thanks again for all the help,
Corey
