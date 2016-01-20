From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Fix potential NULL pointer dereference in
 __skb_try_recv_datagram
Date: Wed, 20 Jan 2016 07:48:34 -0800
Message-ID: <1453304914.1223.325.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1451416224-15871-1-git-send-email-jacob@teenage.engineering>
	 <87y4cdyrbn.fsf@doppelsaurus.mobileactivedefense.com>
	 <20151229.150843.2021692616139434395.davem@davemloft.net>
	 <CAEnXRPtJBoOn+JgXDEUdL07WkbYVViAT_+LBiV4X=NVQ3SiDaQ@mail.gmail.com>
	 <CANn89iLpuz4nP+hPoGUHY8KSv=GwSE1x13D3qDeAQDJjV-S7pw@mail.gmail.com>
	 <CAEnXRPsVe5ROz=Vo0fTODrs3EsEWoU1hzHVvyEwMyMCrE3BwDA@mail.gmail.com>
	 <CAM_iQpVQNPQ1LNvG+h3=UvTM9Lm-adhryQk-ad4aeckHS-V0ew@mail.gmail.com>
	 <CAEnXRPsH-eTwwd7FvODL+0Qu9CLY-uGYT9z81cH-by5baEdbhg@mail.gmail.com>
	 <1451921108.8255.74.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEnXRPu8As9sr44JcjqVW-omN8BshtzhZZd73cr7vFXLTVPFWQ@mail.gmail.com>
	 <1452003299.8255.87.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEnXRPuL6bUJWvJ=OWokHCvZkdcngaYmwX3wV70douDbnG8bVw@mail.gmail.com>
	 <1452004797.8255.90.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEnXRPtPYz4+UTA1dqL7AXe6OeN08tyXhKL2js5Wm681z=tsWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Al Viro <viro@zeniv.linux.org.uk>,
	LKML <linux-kernel@vger.kernel.org>
To: Jacob Siverskog <jacob@teenage.engineering>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33251 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756060AbcATPsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 10:48:37 -0500
In-Reply-To: <CAEnXRPtPYz4+UTA1dqL7AXe6OeN08tyXhKL2js5Wm681z=tsWQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-01-20 at 16:06 +0100, Jacob Siverskog wrote:
> On Tue, Jan 5, 2016 at 3:39 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Tue, 2016-01-05 at 15:34 +0100, Jacob Siverskog wrote:
> >> On Tue, Jan 5, 2016 at 3:14 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> >> >
> >> > You might build a kernel with KASAN support to get maybe more chances to
> >> > trigger the bug.
> >> >
> >> > ( https://www.kernel.org/doc/Documentation/kasan.txt )
> >> >
> >>
> >> Ah. Doesn't seem to be supported on arm(32) unfortunately.
> >
> > Then you could at least use standard debugging features :
> >
> > CONFIG_SLAB=y
> > CONFIG_SLABINFO=y
> > CONFIG_DEBUG_SLAB=y
> > CONFIG_DEBUG_SLAB_LEAK=y
> >
> > (Or equivalent SLUB options)
> >
> > and
> >
> > CONFIG_DEBUG_PAGEALLOC=y
> >
> > (If arm(32) has CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y)
> 
> I tried with those enabled and while toggling power on the Bluetooth
> interface I usually get this after a few iterations:
> kernel: Bluetooth: Unable to push skb to HCI core(-6)

Well, this code seems to be quite buggy.

I do not have time to audit it, but 5 minutes are enough to spot 2
issues.

skb, once given to another queue/layer should not be accessed anymore.

diff --git a/drivers/bluetooth/btwilink.c b/drivers/bluetooth/btwilink.c
index 24a652f9252b..2d3092aa6cfe 100644
--- a/drivers/bluetooth/btwilink.c
+++ b/drivers/bluetooth/btwilink.c
@@ -98,6 +98,7 @@ static void st_reg_completion_cb(void *priv_data, char data)
 static long st_receive(void *priv_data, struct sk_buff *skb)
 {
 	struct ti_st *lhst = priv_data;
+	unsigned int len;
 	int err;
 
 	if (!skb)
@@ -109,13 +110,14 @@ static long st_receive(void *priv_data, struct sk_buff *skb)
 	}
 
 	/* Forward skb to HCI core layer */
+	len = skb->len;
 	err = hci_recv_frame(lhst->hdev, skb);
 	if (err < 0) {
 		BT_ERR("Unable to push skb to HCI core(%d)", err);
 		return err;
 	}
 
-	lhst->hdev->stat.byte_rx += skb->len;
+	lhst->hdev->stat.byte_rx += len;
 
 	return 0;
 }
@@ -245,6 +247,7 @@ static int ti_st_send_frame(struct hci_dev *hdev, struct sk_buff *skb)
 {
 	struct ti_st *hst;
 	long len;
+	u8 pkt_type;
 
 	hst = hci_get_drvdata(hdev);
 
@@ -258,6 +261,7 @@ static int ti_st_send_frame(struct hci_dev *hdev, struct sk_buff *skb)
 	 * Freeing skb memory is taken care in shared transport layer,
 	 * so don't free skb memory here.
 	 */
+	pkt_type = hci_skb_pkt_type(skb);
 	len = hst->st_write(skb);
 	if (len < 0) {
 		kfree_skb(skb);
@@ -268,7 +272,7 @@ static int ti_st_send_frame(struct hci_dev *hdev, struct sk_buff *skb)
 
 	/* ST accepted our skb. So, Go ahead and do rest */
 	hdev->stat.byte_tx += len;
-	ti_st_tx_complete(hst, hci_skb_pkt_type(skb));
+	ti_st_tx_complete(hst, pkt_type);
 
 	return 0;
 }
