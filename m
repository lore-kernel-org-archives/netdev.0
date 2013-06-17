From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: [PATCH net-next] tg3: Prevent system hang during repeated EEH
 errors.
Date: Mon, 17 Jun 2013 14:56:47 -0400
Message-ID: <20130617185647.GB12442@d2.synalogic.ca>
References: <1371244506-18969-1-git-send-email-nsujir@broadcom.com>
 <20130617182811.GA12442@d2.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Michael Chan <mchan@broadcom.com>
To: Nithin Nayak Sujir <nsujir@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:36125 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751936Ab3FQS4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 14:56:51 -0400
Received: by mail-qc0-f181.google.com with SMTP id u12so1811053qcx.12
        for <netdev@vger.kernel.org>; Mon, 17 Jun 2013 11:56:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130617182811.GA12442@d2.synalogic.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/06/17 14:28, Benjamin Poirier wrote:
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

Ok, I see why this is relevant, since the slot_reset and resume
callbacks are always called after the error_detected callback.

> 2) an error in tg3_io_resume() does not trigger device removal in
> handle_eeh_events(). In fact the ->resume callback has no return value.

Nevertheless, this hunk

> > @@ -17826,6 +17833,8 @@ static void tg3_io_resume(struct pci_dev *pdev)
> >  	if (err) {
> >  		tg3_full_unlock(tp);
> >  		netdev_err(netdev, "Cannot restart hardware after reset.\n");
> > +		tg3_napi_enable(tp);
> > +		dev_close(netdev);
> >  		goto done;
> >  	}

duplicates the error handling code already in tg3_restart_hw().

> 
> >  
> > -- 
> > 1.8.1.4
> > 
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
