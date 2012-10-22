From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH V2 0/7] support the cpts found on am335x devices
Date: Mon, 22 Oct 2012 13:02:40 +0200
Message-ID: <20121022110240.GA2285@netboy.at.omicron.at>
References: <cover.1350329726.git.richardcochran@gmail.com>
 <EB1619762EAF8B4E97A227FB77B7E0293E9F82F0@DBDE01.ent.ti.com>
 <20121016171407.GA2176@netboy.at.omicron.at>
 <EB1619762EAF8B4E97A227FB77B7E0293E9F86E9@DBDE01.ent.ti.com>
 <20121017182714.GC2412@netboy.at.omicron.at>
 <EB1619762EAF8B4E97A227FB77B7E0293E9FD697@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	"Chemparathy, Cyril" <cyril@ti.com>,
	"Govindarajan, Sriramakrishnan" <srk@ti.com>
To: "N, Mugunthan V" <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:37702 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753117Ab2JVLCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 07:02:52 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so766548eaa.19
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2012 04:02:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <EB1619762EAF8B4E97A227FB77B7E0293E9FD697@DBDE01.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 22, 2012 at 10:39:40AM +0000, N, Mugunthan V wrote:
> 
> I think the timecounter_init initializes only the software. But still I am
> not clear how the time given in cpts_ptp_settime will be projected to
> hardware. Can you correct me if I am wrong.

Look at the settime function:

+static int cpts_ptp_settime(struct ptp_clock_info *ptp,
+			    const struct timespec *ts)
+{
+	u64 ns;
+	unsigned long flags;
+	struct cpts *cpts = container_of(ptp, struct cpts, info);
+
+	ns = ts->tv_sec * 1000000000ULL;
+	ns += ts->tv_nsec;
+
+	spin_lock_irqsave(&cpts->lock, flags);
+	timecounter_init(&cpts->tc, &cpts->cc, ns);
+	spin_unlock_irqrestore(&cpts->lock, flags);
+
+	return 0;
+}

Then, look at the implementation of timecounter_init().

> > > Since we poll for the 32bit over flow for every HZ * 8 cycle, won't
> > > there be a system overhead. If the CPTS ref clock is changed
> > according
> > > to the ptp freq adjust api, how will the timecounter take care of
> > change
> > > in frequency
> > 
> > There is nothing to do here. What are you asking?
> 
> I think instead of fixing the driver to AM335X, let's make the driver
> generic as the same driver can be used to TI814X, TI813X and other
> upcoming platforms TI811X where the CPTS ref clock can be changed as
> per usage requirement.

Now I see what your are worried about, but it really isn't a big
problem. The solution in your driver of doing a 64 bit division in the
hot path is unattractive and unnecessary. We can accomodate variable
reference clock frequencies using a board specific DT, just as we do
for gianfar today.

Let's just get the am335x working, shall we? Until we actually have
the other boards working, all this talk about TI81xx is really just
talk. I mean, ATM the CPSW does not work on *any* board at all.

> > I hope that you meant, "better if we can configure _either_ slave."
> > Considering how SO_TIMESTAMPING works, you can't use both at once.
> > 
> 
> Since CPSW as a Ethernet switch, the PTP packet can be delivered to
> any downstream port. So if we fix the PTP time stamping to one port
> then the driver won't receive time stamping information when the packet
> is delivered to the other port.

And just how is this supposed to work with SO_TIMESTAMPING?

Thanks,
Richard
