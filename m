From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Mon, 22 May 2017 15:12:03 -0500
Message-ID: <66de55da-7a5c-68b8-50d5-cab313ec0d6f@codeaurora.org>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
 <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com,
        David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, jhugo@codeaurora.org
To: Zefir Kurtisi <zefir.kurtisi@neratec.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:40102 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751537AbdEVUMG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 16:12:06 -0400
In-Reply-To: <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/24/2016 05:40 AM, Zefir Kurtisi wrote:
> This commit adds a wrapper function for at8031
> that in case of operating in SGMII mode double
> checks SGMII link state when generic aneg_done()
> succeeds. It prints a warning on failure but
> intentionally does not try to recover from this
> state. As a result, if you ever see a warning
> '803x_aneg_done: SGMII link is not ok' you will
> end up having an Ethernet link up but won't get
> any data through. This should not happen, if it
> does, please contact the module maintainer.

I'm getting bitten by this one again.  We're now have several systems that
are reporting the link failure ("803x_aneg_done: SGMII link is not ok"), and
the interface comes up but is not functional.  I believe this is expected.

The problem, however, is not because of the link failure.  Instead, the
problem is this:

> +	/* check if the SGMII link is OK. */
> +	if (!(phy_read(phydev, AT803X_PSSR) & AT803X_PSSR_MR_AN_COMPLETE)) {
> +		pr_warn("803x_aneg_done: SGMII link is not ok\n");
> +		aneg_done = 0;

Returning zero is what breaks the interface.  If I comment-out this last
line, so that at803x_aneg_done() returns BMSR_ANEGCOMPLETE instead, then
everything works.

The documentation for phy_aneg_done() says this:

 * Description: Return the auto-negotiation status from this @phydev
 * Returns > 0 on success or < 0 on error. 0 means that auto-negotiation
 * is still pending.

So I think there are two issues here:

1. What exactly is supposed to happen when phy_aneg_done() returns a zero?
On our system, returning a zero results in a broken link, even though there
are no errors reported.  I just can't send any packets.

2. I'm preparing a patch that adds a command-line parameter to at803x that
makes this code conditional.  If you specify the parameter ("linkcheck")
then it will check the link and return 0 on failure.  Otherwise, it will
return whether genphy_aneg_done() returns.  The question is, should it still
print the message?

What I cannot determine is whether or not the link is actually okay.  It
appears to me that the driver says the link is not ok, but in truth it
actually is, and maybe the whole at803x_aneg_done() function based on a
false premise.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
