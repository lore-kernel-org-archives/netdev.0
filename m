From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next] tg3: Prevent system hang during repeated
 EEH errors.
Date: Mon, 17 Jun 2013 11:59:12 -0700
Message-ID: <1371495552.5012.9.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1371244506-18969-1-git-send-email-nsujir@broadcom.com>
 <20130617182811.GA12442@d2.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: "Nithin Nayak Sujir" <nsujir@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: "Benjamin Poirier" <benjamin.poirier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1800 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752039Ab3FQS7V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jun 2013 14:59:21 -0400
In-Reply-To: <20130617182811.GA12442@d2.synalogic.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-17 at 14:28 -0400, Benjamin Poirier wrote: 
> On 2013/06/14 14:15, Nithin Nayak Sujir wrote:
> [...]
> > @@ -17796,6 +17799,10 @@ static pci_ers_result_t tg3_io_slot_reset(struct pci_dev *pdev)
> >  	rc = PCI_ERS_RESULT_RECOVERED;
> >  
> >  done:
> > +	if (rc != PCI_ERS_RESULT_RECOVERED && netif_running(netdev)) {
> > +		tg3_napi_enable(tp);
> > +		dev_close(netdev);
> > +	}
> >  	rtnl_unlock();
> >  
> >  	return rc;
> > @@ -17826,6 +17833,8 @@ static void tg3_io_resume(struct pci_dev *pdev)
> >  	if (err) {
> >  		tg3_full_unlock(tp);
> >  		netdev_err(netdev, "Cannot restart hardware after reset.\n");
> > +		tg3_napi_enable(tp);
> > +		dev_close(netdev);
> >  		goto done;
> >  	}
> 
> Are these two hunks needed?
> 1) These functions do not call tg3_netif_stop() or tg3_napi_disable()
> 2) an error in tg3_io_resume() does not trigger device removal in
> handle_eeh_events(). In fact the ->resume callback has no return value.
> 

The normal sequence is:

error_detected(), slot_reset(), resume()

In error_detected(), chip will be shutdown and NAPI will be disabled if
netif_running state is true.  When everything works correctly, the chip
will be re-enabled in resume() and NAPI re-enabled.  If we run into any
error in this sequence, the sequence will not complete normally.  In
this case, if netif_running state is true, we know that the NAPI state
has been disabled earlier in error_detected(), and we need to properly
close the device.
