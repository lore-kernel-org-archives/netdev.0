From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v4 1/2] qed: Add infrastructure for PTP support.
Date: Sun, 12 Feb 2017 20:50:27 +0100
Message-ID: <20170212195027.GA2696@localhost.localdomain>
References: <1486536194-30872-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1486536194-30872-2-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170211085810.GA4006@localhost.localdomain>
 <20170211111638.GA6564@localhost.localdomain>
 <BL2PR07MB2306C87FF3E79B221675F5848D460@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20170212140202.GA1702@localhost.localdomain>
 <BL2PR07MB2306751ABE3FC347E40302B18D460@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:32869 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751103AbdBLTum (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 14:50:42 -0500
Received: by mail-wm0-f68.google.com with SMTP id v77so15655133wmv.0
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 11:50:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <BL2PR07MB2306751ABE3FC347E40302B18D460@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 12, 2017 at 03:07:34PM +0000, Mintz, Yuval wrote:
> Your algorithm ignores the HW limitation. Consider (ppb == 1): 
> your logic would output N == 7, *M == 7000000000,
>    Which has perfect accuracy [N / *M is 1 / 10^9].
> But the solution for
>    'period' * 16 + 8 == 7 * 10^9
> isn't a whole number, so this result doesn't really reflect the actual
> approximation error since we couldn't configure it to HW.

Ok, so change my code to read:

		/*truncate to HW resolution*/
		reg = (m - 8) / 16;
		m = reg * 16 + 8;

Your HW will happyly accept the value of 'reg', right?

> The original would return val == 1, period == 62499999; While this
> does have some error [val / (period * 16 + 8) is slightly bigger
> than 1 / 10^9, error at 18[?] digit after dot], it's the best we can
> configure for the HW.

That is *not* the best you can do:

Perfect:  1 / 1000000000 = .000000001
Yours:    1 / 999999992  = .000000001000000008
Mine*:    7 / 6999999992 = .00000000100000000114

[ * revised with the above change ]

Not a huge difference, but yours is not "the best we can".

Let's try another:

ppb = 40831

Perfect:  40831 / 1000000000 = .000040831
Yours:    4 / 97960          = .00004083299305839118
Mine:     5 / 122456         = .00004083099235643823

See the difference?

Please, try the two algorithms and plot the RMS error over the
interval ppb = 1 ... 100000.  The result may surprise you.

> No. In an ideal world, I would have liked optimizing everything.
> But in this world if I do find time to spend on optimizations 
> I rather do that for the stuff that matters. I.e., datapath.

As the PTP maintainer, I look after about the PTP drivers.  They
should be as good as we can make them (even when the HW is a broken as
yours is).  That is why I bothered to review and to spend time
thinking about your problem.  I especially care about having good
examples in the tree, since this stuff will inevitably get copied by
new driver authors.  It is wonderful that your data path is so very
optimized, but that is no excuse for poor PTP code.

Thanks,
Richard
