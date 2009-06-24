From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] gianfar: Fix half-duplex operation for non-MII/RMII
	interfaces
Date: Wed, 24 Jun 2009 15:18:59 -0500
Message-ID: <ED58F994-6BDC-4496-8445-EA1D984F1379@freescale.com>
References: <20090624182734.GA14306@oksana.dev.rtsoft.ru>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Li Yang <leoli@freescale.com>, David Miller <davem@davemloft.net>
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20090624182734.GA14306@oksana.dev.rtsoft.ru>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org


On Jun 24, 2009, at 1:27 PM, Anton Vorontsov wrote:

> It appears that gianfar driver has the same problem[1] that I
> just fixed for ucc_geth.
>
> NFS boot using 10/half link takes about 10 minutes to complete:
>

>
> The symptoms were observed on MPC8379E-RDB boards (eTSEC). Although
> I didn't find where documentation forbids clearing Full Duplex bit
> for non-MII/RMII modes, it's pretty distinct that the bit should be
> set.
>
> It's no wonder though, QE Ethernet and TSEC are pretty similar.

> -			if (!(phydev->duplex))
> -				tempval &= ~(MACCFG2_FULL_DUPLEX);
> +			if (!phydev->duplex &&
> +					(phyi == PHY_INTERFACE_MODE_MII ||
> +					 phyi == PHY_INTERFACE_MODE_RMII))


Hmm....have you tested this on a GMII interface?  *Technically*, full  
duplex is required for GMII, as GMII is used only for gigabit.   
However, we've been treating the GMII interface type as an indicator  
that the PHY *has* a GMII connection to the NIC.  When gianfar detects  
the speed is 10/100 it switches to the compatible MII interface via  
this code, just below:

                         case 100:
                         case 10:
                                 tempval =
                                     ((tempval & ~(MACCFG2_IF)) |  
MACCFG2_MII);


My concern is that you will be detecting the GMII interface, and  
disallowing half-duplex, despite the fact that the interface is  
actually running at 10 or 100 Mbit.

Andy
