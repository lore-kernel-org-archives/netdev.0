From: Joe Perches <joe@perches.com>
Subject: Re: [net-next v2 11/16] i40e: remove chatty log messages
Date: Fri, 20 Dec 2013 09:59:20 -0800
Message-ID: <1387562360.2353.51.camel@joe-AO722>
References: <1387557965-13241-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1387557965-13241-12-git-send-email-jeffrey.t.kirsher@intel.com>
	 <52B489ED.3010704@cogentembedded.com>
	 <AAEA33E297BCAC4B9BB20A7C2DF0AB8D654E34C9@FMSMSX113.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0208.hostedemail.com ([216.40.44.208]:40885 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751838Ab3LTR7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 12:59:23 -0500
In-Reply-To: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D654E34C9@FMSMSX113.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-20 at 17:40 +0000, Williams, Mitch A wrote:
> > -----Original Message-----
> > From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com]
[]
> > > diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c
[]
> > > @@ -2988,21 +2988,11 @@ static int i40e_vsi_control_tx(struct i40e_vsi
> > *vsi, bool enable)
> > >   		} while (j-- && ((tx_reg >> I40E_QTX_ENA_QENA_REQ_SHIFT)
> > >   			       ^ (tx_reg >> I40E_QTX_ENA_QENA_STAT_SHIFT)) & 1);
> > >
> > > -		if (enable) {
> > > -			/* is STAT set ? */
> > > -			if ((tx_reg & I40E_QTX_ENA_QENA_STAT_MASK)) {
> > > -				dev_info(&pf->pdev->dev,
> > > -					 "Tx %d already enabled\n", i);
> > > +		/* Skip if the queue is already in the requested state */
> > > +		if (enable && (tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
> > >   				continue;
> > 
> >     This line seems over-indented now.
> > 
> > > -			}
> > > -		} else {
> > > -			/* is !STAT set ? */
> > > -			if (!(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK)) {
> > > -				dev_info(&pf->pdev->dev,
> > > -					 "Tx %d already disabled\n", i);
> > > +		if (!enable && !(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
> > >   				continue;
> > 
> >     This one too.
[]
> Sergei, if you look at the source instead of the patch, you'll see
> that these are correct. The whole thing is inside a for loop, so it
> should properly be indented two tabs.

I looked at the source.
Both continue statements _are_ overly indented.
4 tabs should be 3.

Also, this code is inconsistent and might be
nicer using the same form:

		/* Skip if the queue is already in the requested state */
		if (enable && (tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
			continue;
		if (!enable && !(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
			continue;

[...]

		/* wait for the change to finish */
		for (j = 0; j < 10; j++) {
			tx_reg = rd32(hw, I40E_QTX_ENA(pf_q));
			if (enable) {
				if ((tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
					break;
			} else {
				if (!(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
					break;
			}

Perhaps the first form should be like the second

	if (enable) {
		if (tx_reg & I40E_QTX_ENA_QENA_STAT_MASK)
			continue;
	} else {
		if (!(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
			continue;
	}

or maybe both should be

	bool mask = tx_reg & I40E_QTX_ENA_QENA_STAT_MASK;
	if (enable ^ mask)
