From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Tue, 08 May 2007 19:17:16 +0200
Message-ID: <m3lkfz5j6r.fsf@maximus.localdomain>
References: <m3abwhcy74.fsf@maximus.localdomain>
	<m3vef5biob.fsf@maximus.localdomain>
	<5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk>
	<m3hcqoa772.fsf@maximus.localdomain>
	<86D26EBE-5899-468F-9C79-23E83E0DE04B@cam.ac.uk>
	<m33b289zku.fsf@maximus.localdomain>
	<m3zm4g3yed.fsf_-_@maximus.localdomain>
	<20070508113735.GB32055@xi.wantstofly.org>
	<m3fy6775fz.fsf@maximus.localdomain>
	<20070508145340.GD387@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael-Luke Jones <mlj28@cam.ac.uk>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Russell King <rmk@arm.linux.org.uk>,
	ARM Linux Mailing List
	<linux-arm-kernel@lists.arm.linux.org.uk>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S966677AbXEHRRW@vger.kernel.org>
In-Reply-To: <20070508145340.GD387@xi.wantstofly.org> (Lennert Buytenhek's message of "Tue, 8 May 2007 16:53:40 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennert Buytenhek <buytenh@wantstofly.org> writes:

> The board support code knows such things as that the "front ethernet
> port" on the board is connected to the CPU's MII port number #2, but
> the board support code does _not_ know that MII port number #2
> corresponds to "ixp4xx hardware queue #5."

Sure. And I don't want it to know.

It has to pick up any available queue for RX, that is. If the
board code knows it uses ETH connected to NPE-B and NPE-C, and
HSS-0 connected (obviously) to NPE-A, and it wants some crypto
functions etc., it can pick a queue which normally belongs to
HSS-1. If the code knows the board has both HSS and only NPE-B
Ethernet, it can use one of NPE-C Ethernet's queues. It's that
simple.

The Ethernet (and HSS etc.) driver knows it has to use queue 24 for
NPE-B Ethernet's TX and 27 for TX and so on, this is fixed in the
firmware so I don't let the board code mess with that. The
Ethernet RX queue is different, we can just make something up and
tell NPE about that.

That's BTW the same thing you would want to do with SRAM - except
that the SRAM allocator is technically possible, while making
queue assignments needs knowledge about the hardware.

> If Intel puts out a firmware update next month, and your ethernet
> driver is modified to take advantage of the new features in that
> firmware and starts depending on the newer version of that firmware,
> we will have to modify every ixp4xx board support file in case the
> firmware update modifies the ixp4xx queue numbers in use.

Nope, we just modify Ethernet driver:
drivers/net/arm/ixp4xx_eth.c:
#define TX_QUEUE(plat)          (NPE_ID(port) + 23)
#define RXFREE_QUEUE(plat)      (NPE_ID(port) + 26)
#define TXDONE_QUEUE            31

> The
> mapping from hardware ports (MII port #0, MII port #6, HSS port
> #42, whatever) to ixp4xx hardware queue numbers (0-63) should _not_
> be put in every single ixp4xx board support file.

I've never considered doing that :-)

drivers/net/wan/ixp4xx_hss.c:
/* Queue IDs */
#define HSS0_CHL_RXTRIG_QUEUE   12      /* orig size = 32 dwords */
#define HSS0_PKT_RX_QUEUE       13      /* orig size = 32 dwords */
#define HSS0_PKT_TX0_QUEUE      14      /* orig size = 16 dwords */
#define HSS0_PKT_TX1_QUEUE      15
#define HSS0_PKT_TX2_QUEUE      16
#define HSS0_PKT_TX3_QUEUE      17
#define HSS0_PKT_RXFREE0_QUEUE  18      /* orig size = 16 dwords */
#define HSS0_PKT_RXFREE1_QUEUE  19
#define HSS0_PKT_RXFREE2_QUEUE  20
#define HSS0_PKT_RXFREE3_QUEUE  21
#define HSS0_PKT_TXDONE_QUEUE   22      /* orig size = 64 dwords */

#define HSS1_CHL_RXTRIG_QUEUE   10
#define HSS1_PKT_RX_QUEUE       0
#define HSS1_PKT_TX0_QUEUE      5
#define HSS1_PKT_TX1_QUEUE      6
#define HSS1_PKT_TX2_QUEUE      7
#define HSS1_PKT_TX3_QUEUE      8
#define HSS1_PKT_RXFREE0_QUEUE  1
#define HSS1_PKT_RXFREE1_QUEUE  2
#define HSS1_PKT_RXFREE2_QUEUE  3
#define HSS1_PKT_RXFREE3_QUEUE  4
#define HSS1_PKT_TXDONE_QUEUE   9

>> Without them the code in question is hardly readable,
>
> You can read Polish, how can you complain about code readability. :-))

Well, you may have the point, but I also care about others :-)
-- 
Krzysztof Halasa
