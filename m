From: Mark Huth <mhuth@mvista.com>
Subject: Re: [PATCH] ucc_geth: Fix half-duplex operation for non-MII/RMII
 interfaces
Date: Wed, 24 Jun 2009 22:11:14 -0700
Message-ID: <4A4306F2.3070909@mvista.com>
References: <20090624174557.GA31479@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Kumar Gala <galak@kernel.crashing.org>,
	Li Yang <leoli@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:16609 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbZFYFLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 01:11:18 -0400
In-Reply-To: <20090624174557.GA31479@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Vorontsov wrote:
> Currently the half-duplex operation seems to not work reliably for
> RGMII/GMII PHY interfaces. It takes about 10 minutes to boot NFS
> rootfs using 10/half link, following symptoms were observed:
> 
>   ucc_geth: QE UCC Gigabit Ethernet Controller
>   ucc_geth: UCC1 at 0xe0082000 (irq = 32)
>   [...]
>   Sending DHCP and RARP requests .
>   PHY: mdio@e0082120:07 - Link is Up - 10/Half
>   ., OK
So why does the phy think this is a half-duplex network?
>   [...]
>   Looking up port of RPC 100003/2 on 10.0.0.2
>   Looking up port of RPC 100005/1 on 10.0.0.2
>   VFS: Mounted root (nfs filesystem) readonly on device 0:13.
>   Freeing unused kernel memory: 204k init
>   eth0: no IPv6 routers present
>   nfs: server 10.0.0.2 not responding, still trying
>   nfs: server 10.0.0.2 not responding, still trying
>   nfs: server 10.0.0.2 not responding, still trying
>   nfs: server 10.0.0.2 OK
>   nfs: server 10.0.0.2 OK
>   nfs: server 10.0.0.2 not responding, still trying
>   [... few minutes of OK/not responding flood ...]
> 
> The statistic shows that there are indeed some errors:
> 
>   # ethtool -S eth0 | grep -v ": 0"
>   NIC statistics:
>        tx-64-frames: 42
>        tx-65-127-frames: 9
>        tx-128-255-frames: 4768
>        rx-64-frames: 41
>        rx-65-127-frames: 260
>        rx-128-255-frames: 2679
>        tx-bytes-ok: 859634
>        tx-multicast-frames: 5
>        tx-broadcast-frames: 7
>        rx-frames: 8333
>        rx-bytes-ok: 8039364
>        rx-bytes-all: 8039364
>        stats-counter-mask: 4294901760
>        tx-single-collision: 324
>        tx-multiple-collision: 47
>        tx-late-collsion: 604
>        tx-aborted-frames: 604
The above two counters are the actual errors from a half-duplex ethernet 
configuration.  The size of the collision domain is limited so that the 
collisions from one end will reach the other end within the minimum 
frame length wire time.  Thus the collision will be detected within the 
first 64 bytes of the frame.  A late collision indicates a 
mis-configured network. The fact that everything seems to work when the 
MAC is placed into full-duplex mode hints that the network is really a 
full-duplex network.

Otherwise, if the network is really half-duplex, then presence of a 
full-duplex node will result in the other nodes seeing CRC/framing 
errors on receive, and possibly also late collisions, as the full-duplex 
node does not observe the CS or the CD( carrier sense and collision 
detect) part of CSMA/CD, because it doesn't care.

Putting a node in full-duplex will always make the nasty collision 
related errors go away, but it may not be a proper diagnosis of the problem.
>        tx-frames-ok: 4967
>        tx-256-511-frames: 3
>        tx-512-1023-frames: 79
>        tx-1024-1518-frames: 71
>        rx-256-511-frames: 37
>        rx-512-1023-frames: 73
>        rx-1024-1518-frames: 5243
> 
> According to current QEIWRM (Rev. 2 5/2009), FDX bit can be 0 for
> RGMII(10/100) modes, while MPC8568ERM (Rev. C 02/2007) spec says
> that cleared FDX bit is permitted for MII/RMII modes only.
> 
> The symptoms above were seen on MPC8569E-MDS boards, so QEIWRM is
> clearly wrong, and this patch completely cures the problems above.

Not so fast - RGMII and GMII refer to the interface between the MAC and 
the PHY.  While Gigabit physical links will always be full-duplex, phys 
that detect lower operational modes will indicate half-duplex where 
needed, and putting the MAC into full-duplex will make other nodes see 
errors.

As Andy indicated later, it may be necessary to alter the interface 
definition in those cases, depending on the particular hardware. 
Forcing full-duplex does not seem to be a general solution.

Mark Huth
MontaVista Software
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> ---
>  drivers/net/ucc_geth.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> index 464df03..e618cf2 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -1469,12 +1469,16 @@ static void adjust_link(struct net_device *dev)
>  	if (phydev->link) {
>  		u32 tempval = in_be32(&ug_regs->maccfg2);
>  		u32 upsmr = in_be32(&uf_regs->upsmr);
> +		phy_interface_t phyi = ugeth->phy_interface;
> +
>  		/* Now we make sure that we can be in full duplex mode.
>  		 * If not, we operate in half-duplex mode. */
>  		if (phydev->duplex != ugeth->oldduplex) {
>  			new_state = 1;
> -			if (!(phydev->duplex))
> -				tempval &= ~(MACCFG2_FDX);
> +			if (!phydev->duplex &&
> +					(phyi == PHY_INTERFACE_MODE_MII ||
> +					 phyi == PHY_INTERFACE_MODE_RMII))
> +				tempval &= ~MACCFG2_FDX;
>  			else
>  				tempval |= MACCFG2_FDX;
>  			ugeth->oldduplex = phydev->duplex;

