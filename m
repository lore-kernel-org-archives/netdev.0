From: bert hubert <ahu@ds9a.nl>
Subject: 3c59x 2.4.18 userspace seeing UDP packets with bad checksum?
Date: Tue, 30 Jul 2002 15:14:25 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020730131424.GA25238@outpost.ds9a.nl>
References: <20020730104815.GA22307@outpost.ds9a.nl> <200207301240.QAA03021@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, akpm@zip.com.au, jgarzik@mandrakesoft.com,
   becker@scyld.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200207301240.QAA03021@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

On Tue, Jul 30, 2002 at 04:40:38PM +0400, kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> > I'm under the strong impression that 2.4.18 lets userspace see packets with
> > incorrect UDP checksums.
> 
> How did you get this impression?

The hardware:

3c59x: Donald Becker and others. www.scyld.com/network/vortex.html
01:02.0: 3Com PCI 3c905C Tornado at 0xd800. Vers LK1.1.16
01:02.0 Ethernet controller: 3Com Corporation 3c905C-TX [Fast Etherlink]
(rev 78)

The packet is subtly corrupted and contains an invalid DNS label which our
nameserver tripped over (oops). It looks like a single byte error. PowerDNS
lives inside a wrapper, once every second the wrapper calls wait(), to see
if the child is well:

Jul 30 07:04:44 knife pdns-powerdns[2983]: Our pdns instance (6595) exited
after signal 11

These are the relevant packets, grouped by question/answer.

07:04:42.902162 200.171.175.165.14760 > 213.244.168.217.53:  [udp sum ok]
4170 CNAME? ifm.com.br. [|domain] (ttl 112, id 41767, len 56)

07:04:42.902198 213.244.168.217.53 > 200.171.175.165.14760:  [udp sum ok]
4170*- q: CNAME? ifm.com.br. 0/0/0 (28) (DF) (ttl 64, id 0, len 56)

==

07:04:43.147215 202.239.113.18.56146 > 213.244.168.217.53:  [udp sum ok]
32295 A? failte.powernap.org. [|domain] (ttl 241, id 11501, len 65)

07:04:43.149494 213.244.168.217.53 > 202.239.113.18.56146:  [udp sum ok]
32295*- q: A? failte.powernap.org. 1/0/0 failte.powernap.org. A 213.106.2.65
(53) (DF) (ttl 64, id 0, len 81)

==

This is the packet I mean. Note that no answers are sent out after this
one:

07:04:43.505166 61.222.31.205.62361 > 213.244.168.217.53:  [bad udp cksum
25f1!] 49 op5 [2a][|domain] (ttl 112, id 51330, len 109)

== 

07:04:43.698853 194.25.2.147.34441 > 213.244.168.217.53:  [udp sum ok] 53889
[1au] AAAA? DNS-EU1.POWERDNS.NET. . OPT  UDPsize=4096 (49) (DF) (ttl 248, id
23358, len 77)

==

07:04:43.699074 194.25.2.147.34441 > 213.244.168.217.53:  [udp sum ok] 32420
[1au] A6 ? DNS-EU1.POWERDNS.NET. . OPT  UDPsize=4096 (49) (DF) (ttl 248, id
23359, len 77)

==

Until a few seconds later when the parent respawns a new PowerDNS.

> > Is this policy?
> 
> This is impossible unless requested explicitly with SO_NO_CHECK
> or a buggy hardware incorrectly reports checksum is valid.

We don't supply SO_NO_CHECK. As the driver source mentions hardware
checksumming I've cc'd in Andrew, Donald & Jeff.

Regarding Andi's message, isn't it so that recvfrom() may return but in that
case returns -1 and sets errno to EAGAIN? I've seen that when trying to
reproduce this bug by using tcpreplay.

Anything I can do to help, let me know. I get in the order of 20 of these
corrupted packets each night from our Taiwanese friends at Hinet, and only
at night.

Netstat -s output after 81 days:

Udp:
    112974784 packets received
    10386 packets to unknown port received.
    3840 packet receive errors
    112889199 packets sent

Regards,

bert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://www.tk                              the dot in .tk
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
