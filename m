From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Mon, 22 May 2017 23:09:27 +0200
Message-ID: <20170522210927.GR29447@lunn.ch>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
 <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
 <66de55da-7a5c-68b8-50d5-cab313ec0d6f@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zefir Kurtisi <zefir.kurtisi@neratec.com>, netdev@vger.kernel.org,
        f.fainelli@gmail.com, David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, jhugo@codeaurora.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40354 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935737AbdEVVJa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 17:09:30 -0400
Content-Disposition: inline
In-Reply-To: <66de55da-7a5c-68b8-50d5-cab313ec0d6f@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 22, 2017 at 03:12:03PM -0500, Timur Tabi wrote:
> On 10/24/2016 05:40 AM, Zefir Kurtisi wrote:
> > This commit adds a wrapper function for at8031
> > that in case of operating in SGMII mode double
> > checks SGMII link state when generic aneg_done()
> > succeeds. It prints a warning on failure but
> > intentionally does not try to recover from this
> > state. As a result, if you ever see a warning
> > '803x_aneg_done: SGMII link is not ok' you will
> > end up having an Ethernet link up but won't get
> > any data through. This should not happen, if it
> > does, please contact the module maintainer.
> 
> I'm getting bitten by this one again.  We're now have several systems that
> are reporting the link failure ("803x_aneg_done: SGMII link is not ok"), and
> the interface comes up but is not functional.  I believe this is expected.
> 
> The problem, however, is not because of the link failure.  Instead, the
> problem is this:
> 
> > +	/* check if the SGMII link is OK. */
> > +	if (!(phy_read(phydev, AT803X_PSSR) & AT803X_PSSR_MR_AN_COMPLETE)) {
> > +		pr_warn("803x_aneg_done: SGMII link is not ok\n");
> > +		aneg_done = 0;
> 
> Returning zero is what breaks the interface.  If I comment-out this last
> line, so that at803x_aneg_done() returns BMSR_ANEGCOMPLETE instead, then
> everything works.

Are you using interrupts? Or polling?

If polling, it should come back again 1 second later and see if
auto-neg has completed. Hopefully the SGMII side comes up eventually.

If you are using interrupts, you need another interrupt when the SGMII
side comes up, otherwise i think the state machine is stuck waiting.

     Andrew
