From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH] ucc_geth: Fix half-duplex operation for non-MII/RMII
	interfaces
Date: Thu, 25 Jun 2009 11:02:36 +0400
Message-ID: <20090625070236.GA27711@oksana.dev.rtsoft.ru>
References: <20090624174557.GA31479@oksana.dev.rtsoft.ru> <4A4306F2.3070909@mvista.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: David Miller <davem@davemloft.net>,
	Kumar Gala <galak@kernel.crashing.org>,
	Li Yang <leoli@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: Mark Huth <mhuth@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:7234 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751726AbZFYHDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 03:03:42 -0400
Content-Disposition: inline
In-Reply-To: <4A4306F2.3070909@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 24, 2009 at 10:11:14PM -0700, Mark Huth wrote:
> Anton Vorontsov wrote:
>> Currently the half-duplex operation seems to not work reliably for
>> RGMII/GMII PHY interfaces. It takes about 10 minutes to boot NFS
>> rootfs using 10/half link, following symptoms were observed:
>>
>>   ucc_geth: QE UCC Gigabit Ethernet Controller
>>   ucc_geth: UCC1 at 0xe0082000 (irq = 32)
>>   [...]
>>   Sending DHCP and RARP requests .
>>   PHY: mdio@e0082120:07 - Link is Up - 10/Half
>>   ., OK
> So why does the phy think this is a half-duplex network?

Because it's physical media now in half-duplex. At least that's
what PHY detects.

[...]
>>        tx-late-collsion: 604
>>        tx-aborted-frames: 604
> The above two counters are the actual errors from a half-duplex ethernet  
> configuration.  The size of the collision domain is limited so that the  
> collisions from one end will reach the other end within the minimum  
> frame length wire time.  Thus the collision will be detected within the  
> first 64 bytes of the frame.  A late collision indicates a  
> mis-configured network. The fact that everything seems to work when the  
> MAC is placed into full-duplex mode hints that the network is really a  
> full-duplex network.

No, it's half. Can be configured so on both sides, with or
without auto-negotiation. The "10/half" message comes from a
PHY layer, the PHY layer reports human readable values of
PHY's LPA/BMSR registers, not MAC's configuration.

Of course, it could be that the root cause of the problems
I observe is weird NIC on my host. Well, then QA team should
have used the same broken NIC on their hosts. :-)

I can easily test it by interconnecting two targets though.

> Otherwise, if the network is really half-duplex, then presence of a  
> full-duplex node will result in the other nodes seeing CRC/framing  
> errors on receive, and possibly also late collisions, as the full-duplex  
> node does not observe the CS or the CD( carrier sense and collision  
> detect) part of CSMA/CD, because it doesn't care.
>
> Putting a node in full-duplex will always make the nasty collision  
> related errors go away, but it may not be a proper diagnosis of the 
> problem.

>>        tx-frames-ok: 4967
>>        tx-256-511-frames: 3
>>        tx-512-1023-frames: 79
>>        tx-1024-1518-frames: 71
>>        rx-256-511-frames: 37
>>        rx-512-1023-frames: 73
>>        rx-1024-1518-frames: 5243
>>
>> According to current QEIWRM (Rev. 2 5/2009), FDX bit can be 0 for
>> RGMII(10/100) modes, while MPC8568ERM (Rev. C 02/2007) spec says
>> that cleared FDX bit is permitted for MII/RMII modes only.
>>
>> The symptoms above were seen on MPC8569E-MDS boards, so QEIWRM is
>> clearly wrong, and this patch completely cures the problems above.
>
> Not so fast - RGMII and GMII refer to the interface between the MAC and  
> the PHY.

Correct.

> While Gigabit physical links will always be full-duplex, phys  
> that detect lower operational modes will indicate half-duplex where  
> needed, and putting the MAC into full-duplex will make other nodes see  
> errors.

D'oh!

[1358634.636147] eth1: Transmit error, Tx status register 82.
[1358634.636150] Probably a duplex mismatch.  See Documentation/networking/vortex.txt

It's on a host side.

> As Andy indicated later, it may be necessary to alter the interface  
> definition in those cases, depending on the particular hardware. Forcing 
> full-duplex does not seem to be a general solution.

Definitely. Though I'm out of ideas if it's NOT host-side issue.

Thanks!

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
