From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH] gianfar: Fix half-duplex operation for non-MII/RMII
	interfaces
Date: Thu, 25 Jun 2009 01:10:38 +0400
Message-ID: <20090624211038.GA29555@oksana.dev.rtsoft.ru>
References: <20090624182734.GA14306@oksana.dev.rtsoft.ru> <ED58F994-6BDC-4496-8445-EA1D984F1379@freescale.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: David Miller <davem@davemloft.net>,
	Kumar Gala <galak@kernel.crashing.org>,
	Li Yang <leoli@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:6193 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752158AbZFXVLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 17:11:44 -0400
Content-Disposition: inline
In-Reply-To: <ED58F994-6BDC-4496-8445-EA1D984F1379@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 24, 2009 at 03:18:59PM -0500, Andy Fleming wrote:
>
> On Jun 24, 2009, at 1:27 PM, Anton Vorontsov wrote:
>
>> It appears that gianfar driver has the same problem[1] that I
>> just fixed for ucc_geth.
>>
>> NFS boot using 10/half link takes about 10 minutes to complete:
>>
>
>>
>> The symptoms were observed on MPC8379E-RDB boards (eTSEC). Although
>> I didn't find where documentation forbids clearing Full Duplex bit
>> for non-MII/RMII modes, it's pretty distinct that the bit should be
>> set.
>>
>> It's no wonder though, QE Ethernet and TSEC are pretty similar.
>
>> -			if (!(phydev->duplex))
>> -				tempval &= ~(MACCFG2_FULL_DUPLEX);
>> +			if (!phydev->duplex &&
>> +					(phyi == PHY_INTERFACE_MODE_MII ||
>> +					 phyi == PHY_INTERFACE_MODE_RMII))
>
>
> Hmm....have you tested this on a GMII interface?

Nope, only RGMII.

>  *Technically*, full  
> duplex is required for GMII, as GMII is used only for gigabit.  However, 
> we've been treating the GMII interface type as an indicator that the PHY 
> *has* a GMII connection to the NIC.  When gianfar detects the speed is 
> 10/100 it switches to the compatible MII interface via this code, just 
> below:
>
>                         case 100:
>                         case 10:
>                                 tempval =
>                                     ((tempval & ~(MACCFG2_IF)) |  
> MACCFG2_MII);
>
>
> My concern is that you will be detecting the GMII interface, and  
> disallowing half-duplex, despite the fact that the interface is actually 
> running at 10 or 100 Mbit.

Very interesting, though I'm not sure I'm completely following. :-)

Are you saying that I should do this instead:

	if (!phydev->duplex &&
			(phyi == PHY_INTERFACE_MODE_MII ||
			 phyi == PHY_INTERFACE_MODE_RMII ||
			 (phyi == PHY_INTERFACE_MODE_GMII &&
			  phydev->speed < 1000)))
		tempval &= ~MACCFG2_FULL_DUPLEX;
	else
		tempval |= MACCFG2_FULL_DUPLEX;

i.e. we detected GMII interface initially, but it downgraded
to MII since speed is < 1000, thus we can set half-duplex in MAC?

Thanks,

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
