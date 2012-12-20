From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH net-next] be2net: fix INTx ISR for interrupt behaviour
 on BE2
Date: Thu, 20 Dec 2012 21:20:46 +0000
Message-ID: <1356038446.2889.31.camel@bwh-desktop.uk.solarflarecom.com>
References: <d856540b-bacc-45e3-a7cc-49e7febafb95@CMEXHTCAS1.ad.emulex.com>
	 <1354134001.2768.11.camel@bwh-desktop.uk.solarflarecom.com>
	 <1354134328.2768.16.camel@bwh-desktop.uk.solarflarecom.com>
	 <CF9D1877D81D214CB0CA0669EFAE020C0E0C422D@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Perla, Sathya" <Sathya.Perla@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50041 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114Ab2LTVUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 16:20:49 -0500
In-Reply-To: <CF9D1877D81D214CB0CA0669EFAE020C0E0C422D@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-18 at 12:57 +0000, Perla, Sathya wrote:
> >-----Original Message-----
> >From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> 
> >On Wed, 2012-11-28 at 20:20 +0000, Ben Hutchings wrote:
> >> On Wed, 2012-11-28 at 11:20 +0530, Sathya Perla wrote:
> >> > On BE2 chip, an interrupt may be raised even when EQ is in un-armed state.
> >> > As a result be_intx()::events_get() and be_poll:events_get() can race and
> >> > notify an EQ wrongly.
> >> >
> >> > Fix this by counting events only in be_poll(). Commit 0b545a629 fixes
> >> > the same issue in the MSI-x path.
> >> >
> >> > But, on Lancer, INTx can be de-asserted only by notifying num evts. This
> >> > is not an issue as the above BE2 behavior doesn't exist/has never been
> >> > seen on Lancer.
> >> [...]
> >> > @@ -2014,15 +1996,23 @@ static int be_rx_cqs_create(struct be_adapter
> >*adapter)
> >> >
> >> >  static irqreturn_t be_intx(int irq, void *dev)
> >> >  {
> >> > -	struct be_adapter *adapter = dev;
> >> > -	int num_evts;
> >> > +	struct be_eq_obj *eqo = dev;
> >> > +	struct be_adapter *adapter = eqo->adapter;
> >> > +	int num_evts = 0;
> >> >
> >> > -	/* With INTx only one EQ is used */
> >> > -	num_evts = event_handle(&adapter->eq_obj[0]);
> >> > -	if (num_evts)
> >> > -		return IRQ_HANDLED;
> >> > -	else
> >> > -		return IRQ_NONE;
> >> > +	/* On Lancer, clear-intr bit of the EQ DB does not work.
> >> > +	 * INTx is de-asserted only on notifying num evts.
> >> > +	 */
> >> > +	if (lancer_chip(adapter))
> >> > +		num_evts = events_get(eqo);
> >> > +
> >> > +	/* The EQ-notify may not de-assert INTx rightaway, causing
> >> > +	 * the ISR to be invoked again. So, return HANDLED even when
> >> > +	 * num_evts is zero.
> >> > +	 */
> >> > +	be_eq_notify(adapter, eqo->q.id, false, true, num_evts);
> >> > +	napi_schedule(&eqo->napi);
> >> > +	return IRQ_HANDLED;
> >> >  }
> >> [...]
> >>
> >> You shouldn't unconditionally return IRQ_HANDLED.  This prevents
> >> interrupt storm detection from working, not just for your device but for
> >> anything else sharing its IRQ.
> >>
> >> I understand there is a real problem to be fixed (PCIe write completions
> >> overtaking INTx deassertion, and maybe a specific hardware bug).
> >[...]
> >
> >I was thinking of read completions; there are no write completions to
> >wait for so you're pretty much guaranteed to get called a second time.
> >Maybe you should add an MMIO read after calling be_eq_notify().
> 
> Ben, I'm very sorry for not replying to this thread earlier. I needed time to play with
> your suggested solution and better understand the HW behavior in this case.
> 
> Adding an extra PCI memory read after the EQ-notify helps in syncing the PCI de-assert
> message *only* if it was already issued.
> But, there are cases when the HW block takes some time (longer) to initiate the INTx de-assert.
> The PCI memory read would complete but the de-assert wouldn't have happened yet.
> The PCI read sync will work only if the de-assert was issued *before* the PCI-read request was seen by the HW.

Yes, I've seen the exact same problem with our controllers.  At the PCIe
transaction level, legacy interrupt messages and read completions are
queued and flow-controlled separately.  If the chip's PCIe core doesn't
provide a way to restrict reordering of the two TLPs, this seems to be
inevitable.

What we do in sfc is to count the number of times in a row we've seen no
reason for the interrupt (irq_zero_count), and return IRQ_HANDLED only
if this is the first time.  This might work for you too.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
