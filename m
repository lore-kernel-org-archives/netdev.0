From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: e1000 speed/duplex error
Date: Wed, 02 Aug 2006 08:02:09 -0700
Message-ID: <44D0BE71.9080205@intel.com>
References: <1301563340.20060801141827@mail.ru> <9929d2390608010420t60bd44d7o4e522c6edc0a677e@mail.gmail.com> <793732866.20060801153230@mail.ru> <9929d2390608010445w4fd81b64g310ae90a423e1a7d@mail.gmail.com> <911206621.20060801162006@mail.ru> <9929d2390608010534x54324569ja70b1fcbdc23c097@mail.gmail.com> <44CF66AD.1030901@intel.com> <168330902.20060802113402@mail.ru> <9929d2390608020043y75b487c4ge5a02e7a6c96cb9b@mail.gmail.com> <1556642230.20060802123908@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Auke Kok <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7563 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S1751167AbWHBPDo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 11:03:44 -0400
To: a1 <a1k@mail.ru>
In-Reply-To: <1556642230.20060802123908@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

a1 wrote:
> JK> I agree.  Although ethtool does not have that functionality as of yet.
> JK>  Feel free to provide a patch to the ethtool maintainer (Jeff Garzik)
> JK> if you would like.  I will put it on my plate of things to do, but I
> JK> will admit that it is near the bottom of the list of items to get done
> JK> for me.  Feel free to ping me once in awhile to remind me.
> 
> Ethtool already have support for that, but e1000 driver doesn't treat
> all values passed from ethtool correctly.
> 
> For example, if I run ethtool with the following parameters:
> ethtool -s eth0 speed 100 duplex full autoneg on
> 
> parameters filled by ethtool looks like:
> 
> ecmd->autoneg = AUTONEG_ENABLE;
> ecmd->advertising = ADVERTISED_100baseT_Full;
> 
> but then they passed to the driver, driver fills the structure passed
> to the hw layer with all possible advertise values.

>         if (ecmd->autoneg == AUTONEG_ENABLE) {
>                 hw->autoneg = 1;
>                 if (hw->media_type == e1000_media_type_fiber)
>                         hw->autoneg_advertised = ADVERTISED_1000baseT_Full |
>                                      ADVERTISED_FIBRE |
>                                      ADVERTISED_Autoneg;
>                 else
> --->                    hw->autoneg_advertised = ADVERTISED_10baseT_Half |
>                                                   ADVERTISED_10baseT_Full |
>                                                   ADVERTISED_100baseT_Half |
>                                                   ADVERTISED_100baseT_Full |
>                                                   ADVERTISED_1000baseT_Full|
>                                                   ADVERTISED_Autoneg |
>                                                   ADVERTISED_TP;
>                 ecmd->advertising = hw->autoneg_advertised;
>         } else

> If you change it that way everything works like I thought
> 
> --- e1000_ethtool.c.orig        Mon Jun 26 14:13:26 2006
> +++ e1000_ethtool.c     Wed Aug 02 12:35:36 2006
> @@ -225,13 +225,7 @@
>                                      ADVERTISED_FIBRE |
>                                      ADVERTISED_Autoneg;
>                 else
> -                       hw->autoneg_advertised = ADVERTISED_10baseT_Half |
> -                                                 ADVERTISED_10baseT_Full |
> -                                                 ADVERTISED_100baseT_Half |
> -                                                 ADVERTISED_100baseT_Full |
> -                                                 ADVERTISED_1000baseT_Full|
> -                                                 ADVERTISED_Autoneg |
> -                                                 ADVERTISED_TP;
> +                       hw->autoneg_advertised = ecmd->advertising;

Don't you mean this? :

+                       hw->autoneg_advertised = ecmd->advertising |
+                                                ADVERTISED_Autoneg |
+                                                ADVERTISED_TP;

and we'd also have to do this for fibre...

 >
>                 ecmd->advertising = hw->autoneg_advertised;
>         } else
>                 if (e1000_set_spd_dplx(adapter, ecmd->speed + ecmd->duplex))


but that's not really what you want: the way ethtool works currently only 
allows you to pass *one* speed/duplex tuple and autonegotiate with that, or 
all (by omitting any speed/duplex tuple).

ethtool needs some code that allows you to specify "autonegotiate 10_half or 
100_full or 1000_full" (3 tuples, but not implying 100_half or 10_full). This 
is something mii-tool was able to do but this functionality never made it into 
ethtool AFAIK :)

This is the most useful case for everyone, you can omit advertising gig link 
if you only have 100mbit switches and speed up link times that way etc.

Auke
