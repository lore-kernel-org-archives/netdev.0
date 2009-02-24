From: Helmut Schaa <helmut.schaa@googlemail.com>
Subject: Re: [Ipw2100-devel] ipw2100: race between isr_indicate_associated and rx path
Date: Tue, 24 Feb 2009 13:15:42 +0100
Message-ID: <200902241315.43128.helmut.schaa@gmail.com>
References: <200901211734.48625.helmut.schaa@gmail.com> <200902231138.58067.helmut.schaa@gmail.com> <1235446447.6354.549.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless@vger.kernel.org, Jouni Malinen <j@w1.fi>
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f167.google.com ([209.85.220.167]:43174 "EHLO
	mail-fx0-f167.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752175AbZBXMQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 07:16:02 -0500
In-Reply-To: <1235446447.6354.549.camel@debian>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, 24. Februar 2009 schrieb Zhu Yi:

[...]

> Thanks for the analysis. Are you sure noop_qdisc is still used when we
> are about to netif_carrier_on() after receiving the association success
> response? 

Yes, had a printk in noop_enqueue.

> From dev_open(), dev_activate() is called after netdev->open.
> So the txq->qdisc_sleeping should be already replaced with pfifo_fast.
> But the state is still DEACTIVATED.

Right. But for example when a connection cannot be established by ipw2100
it will call netif_carrier_off on disassociation which in turn leads to a
call to dev_deavtivate. Hence, it is possible that a noop_qdisc is
assigned while the device is up and carrier is off.

> Should the packet from 
> wpa_supplicant be dropped by dev_queue_xmit()?
>
> > So, how should I proceed here?
> > 
> > Some possibilities that come to mind:
> > 
> > 1) let the noop_qdisc return NET_XMIT_DROP instead of NET_XMIT_CN and extend
> >    wpa_supplicant to retry after a short timeout. Already tried this approach
> >    and it works fine for me. wpa_supplicant typically needs one retry (200ms
> >    delay) until the frame is successfully send out.
> > 
> > 2) Run activate_dev somehow without a delay. I guess this could be achieved by
> >    changing linkwatch_urgent_event. I haven't tested this yet. But I guess we
> >    would still have a small race here.
> > 
> > 3) Wait until activate_dev was called in ipw2100 before replaying the cached
> >    frames.
> 
> I think making a sync version of netif_carrier_on/activate_dev should be
> the way to go. This could be a requirement from wireless. In wired
> network, netif_carrier_on() is called after a network cable plug event
> is detected. Some delay should be OK.

Maybe, but I can imagine a similar race when using a wired 802.1x secured
network. The switch might send an EAP-request very quickly after the carrier
was detected.

> But in wireless, 
> netif_carrier_on() is usually called after an association is succeeded.
> The driver has already some management frames transfered with AP. Now
> it's the time to open the data frame transmission. The driver requires
> to get the activate_dev() result (synchronously or via callback) because
> otherwise the driver has no idea when the Qdisc is ready and then it can
> start to deliver data frames to network stack and user space.

Exactly.

[...]

Helmut

