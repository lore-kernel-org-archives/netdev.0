From: bert hubert <ahu@ds9a.nl>
Subject: Re: (udp-en/decap broken in 2.6.8-rc2?) Re: ipsec, nat-t, iproute2?
Date: Sat, 31 Jul 2004 13:20:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040731112048.GA27893@outpost.ds9a.nl>
References: <20040731083456.GA24761@outpost.ds9a.nl> <E1Bqr9r-0004av-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1Bqr9r-0004av-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jul 31, 2004 at 08:32:07PM +1000, Herbert Xu wrote:

> > encapsulated packets reach userspace?
> 
> No.

socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) = 3
setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
bind(3, {sa_family=AF_INET, sin_port=htons(4500),
	sin_addr=inet_addr("10.0.0.3")}, 16) = 0

setsockopt(3, SOL_UDP, 100, [1], 4)     = 0
read(3, "\0\0\206\305\0\0\f\311\27\263\3379\313z\377T\310\6\25\217"..., 1024) = 104

I do see packets coming in on 2.6.8-rc2 and tethereal verifies that the
packets at least appear to be ESP:

Internet Protocol, Src Addr: 192.168.1.4 (192.168.1.4), Dst Addr: 10.0.0.3
(10.0.0.3)
    Version: 4
    Header length: 20 bytes
    Differentiated Services Field: 0x00 (DSCP 0x00: Default; ECN: 0x00)
        0000 00.. = Differentiated Services Codepoint: Default (0x00)
        .... ..0. = ECN-Capable Transport (ECT): 0
        .... ...0 = ECN-CE: 0
    Total Length: 132
    Identification: 0x00f0 (240)
    Flags: 0x04 (Don't Fragment)
        0... = Reserved bit: Not set
        .1.. = Don't fragment: Set
        ..0. = More fragments: Not set
    Fragment offset: 0
    Time to live: 64
    Protocol: UDP (0x11)
    Header checksum: 0x6dca (correct)
    Source: 192.168.1.4 (192.168.1.4)
    Destination: 10.0.0.3 (10.0.0.3)
User Datagram Protocol, Src Port: 4500 (4500), Dst Port: 4500 (4500)
    Source port: 4500 (4500)
    Destination port: 4500 (4500)
    Length: 112
    Checksum: 0x0000 (none)
UDP Encapsulation of IPsec Packets
Encapsulating Security Payload
    SPI: 0x000086c5
    Sequence: 4116
    Data (96 bytes)

I'm trying to reverse engineer the code out there but can't find other
things I need to do to get this to work - right now the kernel does not see
the ESP packets, but passes them to userspace. I have this SA in place on
the receiving end:

192.168.1.4[4500] 10.0.0.3[4500] 
	esp-udp mode=transport spi=34501(0x000086c5) reqid=0(0x00000000)
	E: aes-cbc  31323334 35363738 39303132 31323334 35363738 39303132
	seq=0x00000000 replay=0 flags=0x00000000 state=mature 
	created: Jul 31 13:12:09 2004	current: Jul 31 13:12:13 2004
	diff: 4(s)	hard: 0(s)	soft: 0(s)
	last:                     	hard: 0(s)	soft: 0(s)
	current: 0(bytes)	hard: 0(bytes)	soft: 0(bytes)
	allocated: 0	hard: 0	soft: 0
	sadb_seq=0 pid=595 refcnt=0

Note how the SPI matches with what tethereal sees.

And this policy on 10.0.0.3.

192.168.1.4[any] 10.0.0.3[any] icmp
	in ipsec
	esp/transport//require
	created: Jul 31 13:14:22 2004  lastused:                     
	lifetime: 0(s) validtime: 0(s)
	spid=16 seq=0 pid=659
	refcnt=1

Any further ideas? 


-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
