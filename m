From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific qdisc
Date: Wed, 25 Oct 2006 18:34:19 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F018B54D4@dhost002-46.dex002.intermedia.net>
References: <453FF357.6060007@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jiri Benc" <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:59000 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S965263AbWJZBeG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 21:34:06 -0400
Content-class: urn:content-classes:message
In-Reply-To: <453FF357.6060007@trash.net>
To: "Patrick McHardy" <kaber@trash.net>,
	"David Kimdon" <dwhedon@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pfifo_fast does not make sense because the 802.11 qdisc already
categorizes the frames based on DSCP. The better thing would be to
extract the pfifo qdisc so that it does not require NET_SCHED, but this
is more work.

Simon 

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Patrick McHardy
Sent: Wednesday, October 25, 2006 4:29 PM
To: David Kimdon
Cc: netdev@vger.kernel.org; John W. Linville; Jiri Benc
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than
d80211-specific qdisc

David Kimdon wrote:
> wme.c needs a generic fifo qdisc for each hardware queue.  Switch 
> wme.c to use the generic fifo qdisc in net/sched/sch_fifo.c.  This 
> allows removal of net/d80211/fifo_qdisc.c which isn't particularily 
> tied to IEEE 802.11 in any way.
> 
> -#define CHILD_QDISC_OPS pfifo_qdisc_ops
> -
>  static inline int WLAN_FC_IS_QOS_DATA(u16 fc)  {
>  	return (fc & 0x8C) == 0x88;
> @@ -433,7 +431,7 @@ static int wme_qdiscop_init(struct Qdisc
>  	/* create child queues */
>  	for (i = 0; i < queues; i++) {
>  		skb_queue_head_init(&q->requeued[i]);
> -		q->queues[i] = qdisc_create_dflt(qd->dev,
&CHILD_QDISC_OPS);
> +		q->queues[i] = qdisc_create_dflt(qd->dev,
&pfifo_qdisc_ops);
>  		if (q->queues[i] == 0) {
>  			q->queues[i] = &noop_qdisc;
>  			printk(KERN_ERR "%s child qdisc %i creation
failed", dev->name, 
> i);
> Index: wireless-dev/net/d80211/Kconfig 
> ===================================================================
> --- wireless-dev.orig/net/d80211/Kconfig
> +++ wireless-dev/net/d80211/Kconfig
> @@ -3,6 +3,7 @@ config D80211
>  	select CRYPTO
>  	select CRYPTO_ARC4
>  	select CRYPTO_AES
> +	select NET_SCHED


pfifo_fast is available even without CONFIG_NET_SCHED, maybe thats a
better choice to avoid unnecessary bloat.

-
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
