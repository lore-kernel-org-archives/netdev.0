From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [0/3] mc_filter on big-endian arch
Date: Mon, 7 Jun 2004 13:48:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040607114832.GA32569@k3.hellgate.ch>
References: <20040606165322.GA13247@k3.hellgate.ch> <1086575392.4731.9.camel@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Dillow <dave@thedillows.org>
Content-Disposition: inline
In-Reply-To: <1086575392.4731.9.camel@ori.thedillows.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 06 Jun 2004 22:29:52 -0400, David Dillow wrote:
> I think typhoon's OK -- I calculate the filter on the host, and then do
> a cpu_to_le32() on the final values, since the processor on the NIC is
> in little-endian mode.
> 
> However, I've never tested it. I'll be happy to do so, if someone will
> point me to appropriate code -- I've got an Ultra5 as well, so I can
> test both big and little endian machines. Otherwise, I'll test it when I
> get around to writing something, or someone reports a bug. :)

Warning: This is a very basic functionality test using standard Linux
tools. Some existing multicast problems are detected by this (if you
screw up the endianness of the filter hash, you will know :-)). Others
are not.

Multicast Driver Testing Quick How-To
=====================================

Make sure the host you are testing replies to broadcasts:

target# cat /proc/sys/net/ipv4/icmp_echo_ignore_all
0
target# cat /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
0

Our test packets need to go to the target host, so either have a
route or use ping "-r -I <ifname>" option:
tester# route add -net 224.0.0.0 netmask 240.0.0.0 eth0

Since every multicast capable host interface joins 224.0.0.1, you
can already ping your target:

tester# ping -r -I eth0 -t 1 -c 2 224.0.0.1

Your target host should answer this (so may your tester, depending on
your setup).

We haven't joined the next group yet, so there should be no answer:

tester# ping -r -I eth0 -t 1 -c 2 224.1.1.1

Use packet sniffer to confirm that target is not seeing the request
(use -p option for tcpdump or tethereal to prevent promiscuous mode)

Now join the group:
target# ip maddr add 01:00:5e:01:01:01 dev eth0

tester# ping -r -I eth0 -t 1 -c 2 224.1.1.1

Use packet sniffer to confirm that target is seeing the request now.
