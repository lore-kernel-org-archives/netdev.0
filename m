From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Difficulties to get 1Gbps on be2net ethernet card
Date: Wed, 30 May 2012 12:30:57 +0200
Message-ID: <1338373857.2760.150.camel@edumazet-glaptop>
References: <CAL8zT=hHAc5-wGMKgumV=K9jG6tDxzej9Dffe9UYQ24gdWQRtw@mail.gmail.com>
	 <CAL8zT=jKhRjVCdYRCerMzimxPAhP5Gi+JBBfuKjG-rfg-LMoVw@mail.gmail.com>
	 <1338360536.2760.85.camel@edumazet-glaptop>
	 <CAL8zT=h2hoTWDMpTe8P-xfm-USXD6spx8fFVmm1UXyOfuuqhZw@mail.gmail.com>
	 <1338361587.2760.94.camel@edumazet-glaptop>
	 <CAL8zT=jHWhDdv-DyXL8XnL8qRc7o-jZfA7ADU-qt54hB5aLyCw@mail.gmail.com>
	 <CAL8zT=gJT1Frn_44SU0CrpZjPxwC_VuHFE4k9jvOGNmFomzhHA@mail.gmail.com>
	 <3367B80B08154D42A3B2BC708B5D41F647C678B73F@EXMAIL.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jhautbois@gmail.com, netdev@vger.kernel.org
To: Sathya.Perla@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:42364 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752098Ab2E3KbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 06:31:02 -0400
Received: by bkcji2 with SMTP id ji2so3950228bkc.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 03:31:00 -0700 (PDT)
In-Reply-To: <3367B80B08154D42A3B2BC708B5D41F647C678B73F@EXMAIL.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-30 at 03:04 -0700, Sathya.Perla@Emulex.Com wrote:
> >-----Original Message-----
> >From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
> >Behalf Of Jean-Michel Hautbois
> >
> >2012/5/30 Jean-Michel Hautbois <jhautbois@gmail.com>:
> >
> >I used vmstat in order to see the differences between the two kernels.
> >The main difference is the number of interrupts per second.
> >I have an average of 87500 on 3.2 and 7500 on 2.6, 10 times lower !
> >I suspect the be2net driver to be the main cause, and I checkes the
> >/proc/interrupts file in order to be sure.
> >
> >I have for eth1-tx on 2.6.26 about 2200 interrupts per second and 23000 on 3.2.
> >BTW, it is named eth1-q0 on 3.2 (and tx and rx are the same IRQ)
> >whereas there is eth1-rx0 and eth1-tx on 2.6.26.
> 
> Yes, there is an issue with be2net interrupt mitigation in the recent code with
> RX and TX on the same Evt-Q (commit 10ef9ab4). The high interrupt rate happens when a TX blast is
> done while RX is relatively silent on a queue pair. Interrupt rate due to TX completions is not being
> mitigated.
> 
> I have a fix and will send it out soon..

I also have a benet fix for non GRO :

Pulling 64 bytes in skb head is too much for TCP IPv4 with no
timestamps, as this makes splice() or TCP coalescing less effective.

(Having tcp payload in linear part of the skb disables various optims)

Could you please test it ?

Thanks

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 08efd30..f446b11 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1202,15 +1202,19 @@ static void skb_fill_rx_data(struct be_rx_obj *rxo, struct sk_buff *skb,
 	/* Copy data in the first descriptor of this completion */
 	curr_frag_len = min(rxcp->pkt_size, rx_frag_size);
 
-	/* Copy the header portion into skb_data */
-	hdr_len = min(BE_HDR_LEN, curr_frag_len);
+	/* If frame is small enough to fit in skb->head, pull it completely.
+	 * If not, only pull ethernet header so that splice() or TCP coalesce
+	 * are more efficient.
+	 */
+	hdr_len = (curr_frag_len <= skb_tailroom(skb)) ?
+			curr_frag_len : ETH_HLEN;
+
 	memcpy(skb->data, start, hdr_len);
 	skb->len = curr_frag_len;
-	if (curr_frag_len <= BE_HDR_LEN) { /* tiny packet */
+	skb->tail += hdr_len;
+	if (hdr_len == curr_frag_len) { /* tiny packet */
 		/* Complete packet has now been moved to data */
 		put_page(page_info->page);
-		skb->data_len = 0;
-		skb->tail += curr_frag_len;
 	} else {
 		skb_shinfo(skb)->nr_frags = 1;
 		skb_frag_set_page(skb, 0, page_info->page);
@@ -1219,7 +1223,6 @@ static void skb_fill_rx_data(struct be_rx_obj *rxo, struct sk_buff *skb,
 		skb_frag_size_set(&skb_shinfo(skb)->frags[0], curr_frag_len - hdr_len);
 		skb->data_len = curr_frag_len - hdr_len;
 		skb->truesize += rx_frag_size;
-		skb->tail += hdr_len;
 	}
 	page_info->page = NULL;
 
