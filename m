From: Donald Becker <becker@scyld.com>
Subject: Re: 3c59x 2.4.18 userspace seeing UDP packets with bad checksum?
Date: Tue, 30 Jul 2002 09:57:12 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0207300947190.1266-100000@beohost.scyld.com>
References: <200207301331.RAA03211@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: bert hubert <ahu@ds9a.nl>, <netdev@oss.sgi.com>, <akpm@zip.com.au>,
   <jgarzik@mandrakesoft.com>
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200207301331.RAA03211@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

On Tue, 30 Jul 2002 kuznet@ms2.inr.ac.ru wrote:

> Subject: Re: 3c59x 2.4.18 userspace seeing UDP packets with bad checksum?
> 
> > Regarding Andi's message, isn't it so that recvfrom() may return but in that
> > case returns -1 and sets errno to EAGAIN?
> 
> It should if we calculated this checksum. But 3com pretends to do this
> in hardware. :-)

I've verified that (at least some) 3Com cards don't just fake the
checksum test.  They pass on packets with invalid checksums, but don't
indicate that the checksum is correct.  The driver code for this is

	int csum_bits = rx_status & 0xee000000;
	if (csum_bits &&
		(csum_bits == (IPChksumValid | TCPChksumValid) ||
		 csum_bits == (IPChksumValid | UDPChksumValid))) {
		skb->ip_summed = CHECKSUM_UNNECESSARY;

Note that this relies on the kernel to make the final decision that the
checksum is invalid.

[[ This is the correct semantics: the driver might indicate that a protocol
   level checksum is correct, but it should not discard packets based
   on its (necessarily limited) understanding of higher level protocols. 
]]


-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Second Generation Beowulf Clusters
Annapolis MD 21403			410-990-9993
