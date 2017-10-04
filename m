From: =?ISO-8859-15?Q?J=F6rg_Willmann?= <joe@clnt.de>
Subject: etsec2 attached to sgmii phy
Date: Wed, 4 Oct 2017 07:50:14 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1710040742090.31757@brian.int1.clnt.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="8323329-1480875405-1507096214=:31757"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay09.ispgateway.de ([134.119.228.117]:45304 "EHLO
        smtprelay09.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751266AbdJDGHj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 02:07:39 -0400
Received: from [46.237.200.88] (helo=brian.int1.clnt.de)
        by smtprelay09.ispgateway.de with esmtpsa (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128)
        (Exim 4.89)
        (envelope-from <joe@clnt.de>)
        id 1dzcZT-00037E-1S
        for netdev@vger.kernel.org; Wed, 04 Oct 2017 07:50:15 +0200
Received: from localhost ([127.0.0.1])
        by brian.int1.clnt.de with esmtp (Exim 4.86_2)
        (envelope-from <joe@clnt.de>)
        id 1dzcZS-0008Rh-Lx
        for netdev@vger.kernel.org; Wed, 04 Oct 2017 07:50:14 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--8323329-1480875405-1507096214=:31757
Content-Type: text/plain; format=flowed; charset=ISO-8859-7
Content-Transfer-Encoding: 8BIT

Hi,

we use a QorIQ P1011 connected via SGMII to a switch (Marvell 88E6352). 
Currently we still use a really old linux kernel (2.6.33) successfully.

For configuration of the MDIO Bus attached to the corresponding eTSEC/TBI 
Phy we use the following settings in the device tree:

                         mdio@25000 {
                                    #address-cells = <0x1>;
                                    #size-cells = <0x0>;
                                    compatible = "fsl,etsec2-tbi";
                                    reg = <0x25000 0x1000 0xb1030 0x4>;

                                    tbi-phy@11 {
                                                reg = <0x11>;
                                                device_type = "tbi-phy";
                                                linux,phandle = <0x5>;
                                                phandle = <0x5>;
                                    };
                         };

First resource in the mdio config is the base address of the MDIO bus, the 
second resource defines the address of TBIPA.

Doing tests with a newer kernel (4.4.71)  I was faced with problems 
communicating with the TBIPHY.

Debugging this I found out that TBIPA is no longer parameterized correctly 
and I found out why:

In commit afae5ad78b342f401c28b0bb1adb3cd494cb125a initialization of TIBPA 
has been changed:

In former versions in get_gfar_tbipa(...) for compatible "etsec2-tbi" the 
second resource of the reg entry has been used. But now only first resource 
is mapped and get_etsec_tbipa(...) which is now responsible to return the 
proper address does not (and has no way due to missing *np as function 
argument) do so but returns the first resource (which is the base 
address of mdio controller).

What do you think would be the correct way to solve this issue? Re-add *np 
to the get_*_tba() functions to be able to return the proper address?

Thank¢s for reading,
Best regards,

Joerg


--8323329-1480875405-1507096214=:31757--
