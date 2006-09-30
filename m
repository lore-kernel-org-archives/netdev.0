From: James Morris <jmorris@namei.org>
Subject: Re: Is TCP over IPsec broken in 2.6.18?
Date: Sat, 30 Sep 2006 01:06:57 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609300037460.12011@d.namei>
References: <Pine.LNX.4.64.0609241029410.14827@d.namei>
 <E1GRdnS-0003kd-00@gondolin.me.apana.org.au> <20060925103836.GA13966@2ka.mipt.ru>
 <20060925112754.GA18228@gondor.apana.org.au> <20060925120519.GA19010@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:3725 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750906AbWI3FG7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Sep 2006 01:06:59 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060925120519.GA19010@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've just seen something similar and can recreate it with static keying 
via setkey.

The symptom was that ping was only working in one direction, and I 
quintuple-checked the configs and that they have the same kernels etc., 
then ran a bunch of tcpdumps on each and and a router in the middle with 
various protocols.

Some protocols work (ssh) but others (ftp) doesn't.  Also verified the 
problem via simple telnet to these ports.

In one case, the ftp server receives a SYN from the client over ipsec just 
fine but the synack goes out in cleartext (also verified the server is in 
SYN_RECV), and the client drops these.

tcpdump on intermediate router:

[ SYN packet from client, ESP encapsulated as expected ]

IP (tos 0x10, ttl  63, id 4588, offset 0, flags [DF], proto: ESP (50), 
length: 104) 10.1.2.2 > 10.1.3.2: ESP(spi=0x00055555,seq=0x4), length 84

[ SYNACK from server, in the clear, not expected ]

IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto: TCP (6), length: 
60) 10.1.3.2.ftp > 10.1.2.2.53123: S, cksum 0x314c (correct), 
2413701424:2413701424(0) ack 2343803769 win 11844 <mss 
3960,sackOK,timestamp 1018642 690836,nop,wscale 9>

Again note that another protocol such as SSH works as expected.


Connecting from the other side, it looks fine:

IP (tos 0x10, ttl  64, id 33701, offset 0, flags [DF], proto: ESP (50), 
length: 104) 10.1.3.2 > 10.1.2.2: ESP(spi=0x00066666,seq=0x1), length 84

IP (tos 0x0, ttl  63, id 0, offset 0, flags [DF], proto: ESP (50), length: 
104) 10.1.2.2 > 10.1.3.2: ESP(spi=0x00055555,seq=0x1), length 84



Another odd thing I noticed was a ping client in the non-working direction 
segfaulted under strace (once).

These are both x86 machines running the kernel:
2.6.18-1.2699.fc6  (note that this has xen patches but is running bare 
metal).

I ran tcpdump for the above ftp and ssh cases to see if there was anything 
different about the packets (e.g. TOS or TCP opts) but found nothing -- it 
all looks fine, as well as using nc to make sure they're selecting source 
ports of a similar value etc.

Will try with an upstream kernel and see what happens.

-- 
James Morris
<jmorris@namei.org>
