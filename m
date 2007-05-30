From: "Laurent Chavey" <chavey@google.com>
Subject: Re: bond_compute_features() does not handle devices with different CSUM
Date: Tue, 29 May 2007 19:47:09 -0700
Message-ID: <97949e3e0705291947j7fa5cd3fy5afe7f5eb898252c@mail.gmail.com>
References: <97949e3e0705291741t4c485d38ud48b06e6d07e31bc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:34733 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbXE3CrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2007 22:47:14 -0400
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id l4U2lCWm032081
	for <netdev@vger.kernel.org>; Wed, 30 May 2007 03:47:12 +0100
Received: from ug-out-1314.google.com (ugcm2.prod.google.com [10.66.114.2])
	by spaceape11.eur.corp.google.com with ESMTP id l4U2lAkR029686
	for <netdev@vger.kernel.org>; Wed, 30 May 2007 03:47:10 +0100
Received: by ug-out-1314.google.com with SMTP id m2so86536ugc
        for <netdev@vger.kernel.org>; Tue, 29 May 2007 19:47:10 -0700 (PDT)
In-Reply-To: <97949e3e0705291741t4c485d38ud48b06e6d07e31bc@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

proposed change.

--- 2.6.20/drivers/net/bonding/bond_main.c      2007-05-29
19:43:39.010565000 -0700
+++ 2.6.20.fix/drivers/net/bonding/bond_main.c  2007-05-29
19:46:12.376980000 -0700
@@ -1227,7 +1227,14 @@
        int i;

        bond_for_each_slave(bond, slave, i) {
-               features &= (slave->dev->features & BOND_INTERSECT_FEATURES);
+               /* NETIF_F_HW_CSUM includes support for NET_IF_IP_CSUM
+                * as such when looking for the intersection we need to
+                * add it to the device supported features
+                */
+               unsigned long dev_features = slave->dev->features;
+               if (slave->dev->features & NETIF_F_HW_CSUM)
+                       dev_features |= NETIF_F_IP_CSUM;
+               features &= (features & BOND_INTERSECT_FEATURES);
                if (slave->dev->hard_header_len > max_hard_header_len)
                        max_hard_header_len = slave->dev->hard_header_len;
        }



On 5/29/07, Laurent Chavey <chavey@google.com> wrote:
> kernel version <= 2.6.20.1
> file drivers/net/bonding/bonding_main.c
> function bond_compute_features()
>
> -----------
>   Given a system with two different NIC. One driver sets
>         dev->features |=  NETIF_F_HW_CSUM
>   the other driver sets
>         dev->features |=  NETIF_F_IP_CSUM
>
>   when enslaving the 2 device above, bond_compute_features()
>   does not set the intersection of the 2 CSUM
>   features (should be NETIF_F_IP_CSUM)
> -----------
>
>    should the bond features in the case above include NETIF_F_IP_CSUM
>
