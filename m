From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Mon, 07 Aug 2006 21:19:31 -0400
Message-ID: <1154999971.5138.19.camel@jzny2>
References: <20060804101017.GA17393@gondor.apana.org.au>
	 <1154712532.3117.43.camel@rh4> <20060804110829.62136ebb@dxpl.pdx.osdl.net>
	 <20060804.163111.85390037.davem@davemloft.net>
	 <1154797002.5081.21.camel@jzny2>
	 <20060805230517.GA25468@gondor.apana.org.au>
	 <1154819868.5517.34.camel@jzny2>
	 <20060805231959.GA25768@gondor.apana.org.au>
	 <1154821010.5517.48.camel@jzny2>
	 <20060806025123.GA27051@gondor.apana.org.au>
	 <1154867083.6269.35.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ZnTIfDDZ/Dw2XLp/Wygj"
Cc: David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com,
	"Edgar E. Iglesias" <edgar.iglesias@axis.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:37076 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751087AbWHHBTe
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 21:19:34 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GAGFw-0002CP-2x
	for netdev@vger.kernel.org; Mon, 07 Aug 2006 21:19:40 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <1154867083.6269.35.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ZnTIfDDZ/Dw2XLp/Wygj
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2006-06-08 at 08:24 -0400, jamal wrote:
> On Sun, 2006-06-08 at 12:51 +1000, Herbert Xu wrote:
> > On Sat, Aug 05, 2006 at 07:36:50PM -0400, jamal wrote:
> > > 
> > > I know the qlen is >= 0 otherwise i will hit the BUG().
> > > A qlen of 0 will be interesting to find as well.
> > 
> > When the queue is woken it will always to qdisc_run regardless of
> > whether there are packets queued so this might explain what you're
> > seeing.
> > 
> 
> That aligns with what i was thinking as well - i.e what i referred to as
> possibly enthusiasm on part of the tx softirq.
> i.e if there was nothing queued, why is the softirq even woken up?
>
> Note, I observed this behavior to be a lot worse on systems that had
> very little traffic going out. Anyways, I hope to find out.
> 

The reason for this is _mostly_ not the tx softirq as i found out;->
It is actually a result of dev_queue_xmit.
The only way to tell if you can depart qdisc_is_running is by asking the
qdisc for a packet. So if you have slow traffic, its guaranteed that you
enter once to process a packet and the second time to find out that you
have to go away ;-> 

In any case, heres a patch that i believe saves some cycles in case of
a tx scheduling while some CPU is already processing the qdisc. Minimal
testing.

cheers,
jamal


--=-ZnTIfDDZ/Dw2XLp/Wygj
Content-Disposition: attachment; filename=qir-p
Content-Type: text/x-patch; name=qir-p; charset=utf-8
Content-Transfer-Encoding: 7bit

diff --git a/net/core/dev.c b/net/core/dev.c
index d95e262..977e77e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1092,7 +1092,8 @@ static void dev_queue_xmit_nit(struct sk
 
 void __netif_schedule(struct net_device *dev)
 {
-	if (!test_and_set_bit(__LINK_STATE_SCHED, &dev->state)) {
+	if (!test_bit(__LINK_STATE_QDISC_RUNNING, &dev->state) &&
+	    !test_and_set_bit(__LINK_STATE_SCHED, &dev->state)) {
 		unsigned long flags;
 		struct softnet_data *sd;
 

--=-ZnTIfDDZ/Dw2XLp/Wygj--

