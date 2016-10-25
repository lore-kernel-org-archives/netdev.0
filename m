From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH v2 RESEND] xen-netback: prefer xenbus_scanf() over
 xenbus_gather()
Date: Tue, 25 Oct 2016 08:52:17 +0000
Message-ID: <a2ca5535d4344c8983a01db080199826@AMSPEX02CL03.citrite.net>
References: <580E40000200007800119234@prv-mh.provo.novell.com>
 <8cc49b57d5d64a439ddc99b94c99f9a3@AMSPEX02CL03.citrite.net>
 <580F32670200007800119584@prv-mh.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Vrabel <david.vrabel@citrix.com>,
        Wei Liu <wei.liu2@citrix.com>,
        "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
        "boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>,
        Juergen Gross <JGross@suse.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([185.25.65.24]:18791 "EHLO
        SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757254AbcJYIwe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 04:52:34 -0400
In-Reply-To: <580F32670200007800119584@prv-mh.provo.novell.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Jan Beulich [mailto:JBeulich@suse.com]
> Sent: 25 October 2016 09:23
> To: Paul Durrant <Paul.Durrant@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>; Wei Liu <wei.liu2@citrix.com>;
> xen-devel@lists.xenproject.org; boris.ostrovsky@oracle.com; Juergen Gross
> <JGross@suse.com>; netdev@vger.kernel.org
> Subject: RE: [PATCH v2 RESEND] xen-netback: prefer xenbus_scanf() over
> xenbus_gather()
> 
> >>> On 25.10.16 at 09:52, <Paul.Durrant@citrix.com> wrote:
> >> From: Jan Beulich [mailto:JBeulich@suse.com]
> >> Sent: 24 October 2016 16:08
> >> --- 4.9-rc2/drivers/net/xen-netback/xenbus.c
> >> +++ 4.9-rc2-xen-netback-prefer-xenbus_scanf/drivers/net/xen-
> netback/xenbus.c
> >> @@ -889,16 +889,16 @@ static int connect_ctrl_ring(struct back
> >>  	unsigned int evtchn;
> >>  	int err;
> >>
> >> -	err = xenbus_gather(XBT_NIL, dev->otherend,
> >> -			    "ctrl-ring-ref", "%u", &val, NULL);
> >> -	if (err)
> >> +	err = xenbus_scanf(XBT_NIL, dev->otherend,
> >> +			   "ctrl-ring-ref", "%u", &val);
> >> +	if (err <= 0)
> >
> > Looking at other uses of xenbus_scanf() in the same code I think the check
> > here should be if (err < 0). It's a nit, since xenbus_scanf() cannot return 0,
> > but it would be better for consistency I think.
> 
> Hmm, this goes back to the discussion following from
> https://lists.xenproject.org/archives/html/xen-devel/2016-
> 07/msg00678.html
> which in fact you had given your R-b back then. I continue to be
> of the opinion that callers should not leverage the fact that
> xenbus_scanf() can't return zero. They instead should check for
> an explicit success indicator (which only positive values are). But
> you're the maintainer of the code, so if you now think the same
> way David does, I guess I'll have to make the adjustment.
> 
> >>  		goto done; /* The frontend does not have a control ring */
> >>
> >>  	ring_ref = val;
> >>
> >> -	err = xenbus_gather(XBT_NIL, dev->otherend,
> >> -			    "event-channel-ctrl", "%u", &val, NULL);
> >> -	if (err) {
> >> +	err = xenbus_scanf(XBT_NIL, dev->otherend,
> >> +			   "event-channel-ctrl", "%u", &val);
> >> +	if (err <= 0) {
> >>  		xenbus_dev_fatal(dev, err,
> >>  				 "reading %s/event-channel-ctrl",
> >>  				 dev->otherend);
> >> @@ -919,7 +919,7 @@ done:
> >>  	return 0;
> >>
> >>  fail:
> >> -	return err;
> >> +	return err ?: -ENODATA;
> >
> > I don't think you need this.
> 
> If the other change gets made, then indeed this isn't needed.

Yes, and that's why I prefer to opt for consistency with other code in this case.

  Paul

> 
> Jan
