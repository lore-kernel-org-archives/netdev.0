From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH V2 2/3 net-next] Drivers: hv: vmbus: Fix a bug in the
 signalling logic with kick_q
Date: Thu, 12 Mar 2015 04:49:33 +0000
Message-ID: <BY2PR0301MB0711C895BC9A8AB83B7A0789A0060@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <1426100635-9508-1-git-send-email-kys@microsoft.com>
 <1426100660-9547-1-git-send-email-kys@microsoft.com>
 <1426100660-9547-2-git-send-email-kys@microsoft.com>
 <1426129662.12154.2@smtp.corp.redhat.com>
 <BY2PR0301MB07112F975DF45C35BAD926B7A0060@BY2PR0301MB0711.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"apw@canonical.com" <apw@canonical.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: KY Srinivasan <kys@microsoft.com>, Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BY2PR0301MB07112F975DF45C35BAD926B7A0060@BY2PR0301MB0711.namprd03.prod.outlook.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: devel [mailto:driverdev-devel-bounces@linuxdriverproject.org] On
> Behalf Of KY Srinivasan
> Sent: Wednesday, March 11, 2015 8:32 PM
> To: Jason Wang
> Cc: olaf@aepfle.de; netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> gregkh@linuxfoundation.org; apw@canonical.com;
> devel@linuxdriverproject.org; davem@davemloft.net
> Subject: RE: [PATCH V2 2/3 net-next] Drivers: hv: vmbus: Fix a bug in the
> signalling logic with kick_q
> 
> 
> 
> > -----Original Message-----
> > From: Jason Wang [mailto:jasowang@redhat.com]
> > Sent: Wednesday, March 11, 2015 8:08 PM
> > To: KY Srinivasan
> > Cc: davem@davemloft.net; netdev@vger.kernel.org; linux-
> > kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> > apw@canonical.com; gregkh@linuxfoundation.org; KY Srinivasan
> > Subject: Re: [PATCH V2 2/3 net-next] Drivers: hv: vmbus: Fix a bug in
> > the signalling logic with kick_q
> >
> >
> >
> > On Thu, Mar 12, 2015 at 3:04 AM, K. Y. Srinivasan <kys@microsoft.com>
> > wrote:
> > > When the caller specifies that signalling should be deferred, we
> > > need to address the case where we are not able to place the current
> > > packet because the buffer is full. In this case, we will signal the
> > > host as some packets may have been placed on the ring buffer.
> > > I would like to thank Jason Wang <jasowang@redhat.com> for pointing
> > > out this issue.
> > >
> > > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> > > ---
> > >  drivers/hv/channel.c |   32 ++++++++++++++++++++++++++++++++
> > >  1 files changed, 32 insertions(+), 0 deletions(-)
> > >
> > > diff --git a/drivers/hv/channel.c b/drivers/hv/channel.c index
> > > e58cdb7..ae06ba9 100644
> > > --- a/drivers/hv/channel.c
> > > +++ b/drivers/hv/channel.c
> > > @@ -614,8 +614,24 @@ int vmbus_sendpacket_ctl(struct
> vmbus_channel
> > > *channel, void *buffer,
> > >
> > >  	ret = hv_ringbuffer_write(&channel->outbound, bufferlist, 3,
> > > &signal);
> > >
> > > +	/*
> > > +	 * Here is the logic for signalling the host:
> > > +	 * 1. If the host is already draining the ringbuffer,
> > > +	 *    don't signal. This is indicated by the parameter
> > > +	 *    "signal".
> > > +	 *
> > > +	 * 2. If we are not able to write, signal if kick_q is false.
> > > +	 *    kick_q being false indicates that we may have placed zero or
> > > +	 *    more packets with more packets to come. We will signal in
> > > +	 *    this case even if potentially we may have not placed any
> > > +	 *    packet. This is a rare enough condition that it should not
> > > +	 *    matter.
> > > +	 */
> > > +
> > >  	if ((ret == 0) && kick_q && signal)
> > >  		vmbus_setevent(channel);
> > > +	else if ((ret != 0) && !kick_q)
> > > +		vmbus_setevent(channel);
> > >
> > >  	return ret;
> > >  }
> > > @@ -705,8 +721,24 @@ int vmbus_sendpacket_pagebuffer_ctl(struct
> > > vmbus_channel *channel,
> > >
> > >  	ret = hv_ringbuffer_write(&channel->outbound, bufferlist, 3,
> > > &signal);
> > >
> > > +	/*
> > > +	 * Here is the logic for signalling the host:
> > > +	 * 1. If the host is already draining the ringbuffer,
> > > +	 *    don't signal. This is indicated by the parameter
> > > +	 *    "signal".
> > > +	 *
> > > +	 * 2. If we are not able to write, signal if kick_q is false.
> > > +	 *    kick_q being false indicates that we may have placed zero or
> > > +	 *    more packets with more packets to come. We will signal in
> > > +	 *    this case even if potentially we may have not placed any
> > > +	 *    packet. This is a rare enough condition that it should not
> > > +	 *    matter.
> > > +	 */
> > > +
> > >  	if ((ret == 0) && kick_q && signal)
> > >  		vmbus_setevent(channel);
> > > +	else if ((ret != 0) && !kick_q)
> > > +		vmbus_setevent(channel);
> > >
> > >  	return ret;
> > >  }
> > > --
> >
> > Looks like we need to kick unconditionally here. Consider we may get -
> > EAGAIN when we want to send the last skb (kick_q is true) from the
> > list. We need kick host in this case.
> >
> > Btw, another method is let the driver to decide e.g exporting the
> > vmbus_setevent() and call it in netvsc_start_xmit().
> 
> There is other state that governs if the host needs to be signaled and I don't
> think we want to expose that to netvsc. In any case, netvsc will have to signal
> the host when EGAIN is received.
> We might as well do it in the vmbus driver.
> 
> Thank you Jason, I will respin and resubmit the series.

Looks like there may be a way to make the signaling more precise even in this case.
I am going to experiment with it.

K. Y
> 
> K. Y
> >
> >
> >
> 
> _______________________________________________
> devel mailing list
> devel@linuxdriverproject.org
> http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel
