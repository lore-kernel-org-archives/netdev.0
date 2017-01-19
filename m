From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Thu, 19 Jan 2017 10:43:48 +0100
Message-ID: <759d6323-ffac-ebe8-b197-4e1165be5673@neratec.com>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
 <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
 <e063a5fd-a1c5-e9ec-1700-21c6974a7cbe@codeaurora.org>
 <3291b7c1-7bf6-d776-adab-b89c9cd9be38@neratec.com>
 <5763c2fb-7286-15b0-091f-1abf26c0afe7@codeaurora.org>
 <b12e913d-874b-734a-4401-88315b8459dc@neratec.com>
 <7d61d23d-60f5-a77e-42ad-fccf6e8d5878@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com
To: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:38808 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751360AbdASJyi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 04:54:38 -0500
In-Reply-To: <7d61d23d-60f5-a77e-42ad-fccf6e8d5878@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/18/2017 04:02 PM, Timur Tabi wrote:
> On 01/18/2017 07:53 AM, Zefir Kurtisi wrote:
>> No, not necessarily. The SGMII link default configuration is set such that you do
>> not have to bother at all.
> 
> Does the SGMII link need to make the speed and duplex of the external link?
> 
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c#n50
> 
> 
> Here is where I can configure the SGMII link to match whatever phydev says the
> external link is.  This is code that was handed down to me.  I've never really
> understood what the purpose was.  Shouldn't I just be able to configure the SGMII
> link to 1Gbs full-duplex, regardless of what the external link is set to?
> 

This is because the SGMII link is a transparent interface to the upper layer with
no means to inform the other side of the link type in the lower layer.

It always operates at 675MHz, which with two lines gives 1.25Gbps, which at 10/8
coding gives exactly 1Gbps net data rate. If the at803x's copper side
autonegotiates to 1Gbps, the bits traversing over the SGMII match the copper side
1:1. In case the copper side autonegotiates to e.g. 100Mbps, each bit at the
copper side on the SGMII bus is replicated and sent 10x times - or 100x times in
case of 10Mbps. The MAC side of the ETH needs to be aware of how the SGMII data
has to be interpreted, and this is why you have to set the bits you are referring to.

>> That is, if in your case you see the warning popping up but the link always
>> regains connection, then it is an ignorable false positive.
> 
> Unfortunately, I can't really ignore it because genphy does this:
> 
> $ ifup eth1
> [ 1034.754276] qcom-emac QCOM8070:00 eth1: Link is Up - 1Gbps/Full - flow control
> rx/tx
> 
> But the at803x driver does this:
> 
> $ ifup eth1
> [ 1020.507728] 803x_aneg_done: SGMII link is not ok
> [ 1020.513517] qcom-emac QCOM8070:00 eth1: Link is Up - 1Gbps/Full - flow control
> rx/tx
> [ 1020.522839] qcom-emac QCOM8070:00 eth1: Link is Up - 1Gbps/Full - flow control
> rx/tx
> 
> Customers are going to complain.
> 
Yes, the double link-status message is annoying - I was referring to the other
message.

To track down who is causing the additional message, I would proceed with
following technique that helped me dig down a similar problem: since you control
the events in question and there is no risk of flooding the kernel log, in the top
of phy.c::phy_print_status() add a dump_stack() call. In the debug log ensure that
all of the traces end up in the same phydev->adjust_link() callback handler (in
your case emac_adjust_link()).

In the gianfar's handler there is an additional check whether the link really
changed before phy_print_status() is called, in emac_adjust_link() this happens
unconditionally - maybe that is the problem you are facing.

@Florian: is it safe to assume that when phydev->adjust_link() is called there was
in fact a link change (link, duplex, pause), or does the handler have to double
check for a change? I see some ETH drivers maintain a private old state instance
for that, while others don't.


Cheers,
Zefir
