From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/6] drivers: isdn: act2000: capi.c: fix checkpatch
 errors
Date: Sat, 07 Feb 2015 11:19:21 -0800
Message-ID: <1423336761.2933.7.camel@perches.com>
References: <1423328797-17865-1-git-send-email-baspeters93@gmail.com>
	 <1423328797-17865-3-git-send-email-baspeters93@gmail.com>
	 <54D650BF.5000400@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Bas Peters <baspeters93@gmail.com>, isdn@linux-pingi.de,
	julia.lawall@lip6.fr, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D650BF.5000400@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2015-02-07 at 20:51 +0300, Sergei Shtylyov wrote:
> On 02/07/2015 08:06 PM, Bas Peters wrote:
> 
> > This patch fixes the following checkpatch errors:
> > 	1. trailing statement
> > 	1. assignment of variable in if condition
> > 	1. incorrectly placed brace after function definition

I wonder about the usefulness of these changes.

Does anyone still use these cards?

> > diff --git a/drivers/isdn/act2000/capi.c b/drivers/isdn/act2000/capi.c
[]
> > @@ -113,7 +113,8 @@ actcapi_chkhdr(act2000_card *card, actcapi_msghdr *hdr)
> >   			m->hdr.cmd.cmd = c;			\
> >   			m->hdr.cmd.subcmd = s;			\
> >   			m->hdr.msgnum = actcapi_nextsmsg(card); \
> > -		} else m = NULL;				\
> > +		} else
> > +			m = NULL;				\
> 
>     Documentation/CodingStyle has an extra rule for such case: *else* branch 
> should also have {} since *if* branch has {}.

The macro itself is already poor form.
-----
#define ACTCAPI_MKHDR(l, c, s) {				\
		skb = alloc_skb(l + 8, GFP_ATOMIC);		\
		if (skb) {					\
			m = (actcapi_msg *)skb_put(skb, l + 8); \
			m->hdr.len = l + 8;			\
			m->hdr.applicationID = 1;		\
			m->hdr.cmd.cmd = c;			\
			m->hdr.cmd.subcmd = s;			\
			m->hdr.msgnum = actcapi_nextsmsg(card); \
		} else m = NULL;				\
	}
-----

o hidden arguments skb, m and card
o missing do {} while around multi-statement macro

It'd probably be nicer to change the macro to a function
and pass m and card.

This would reduce the object size too.

But maybe any change here is not necessary.

If anything is done, I suggest something like:
---
 drivers/isdn/act2000/capi.c | 204 +++++++++++++++++++++++++-------------------
 1 file changed, 115 insertions(+), 89 deletions(-)

diff --git a/drivers/isdn/act2000/capi.c b/drivers/isdn/act2000/capi.c
index 3f66ca2..a7ecf51 100644
--- a/drivers/isdn/act2000/capi.c
+++ b/drivers/isdn/act2000/capi.c
@@ -104,29 +104,36 @@ actcapi_chkhdr(act2000_card *card, actcapi_msghdr *hdr)
 	return 0;
 }
 
-#define ACTCAPI_MKHDR(l, c, s) {				\
-		skb = alloc_skb(l + 8, GFP_ATOMIC);		\
-		if (skb) {					\
-			m = (actcapi_msg *)skb_put(skb, l + 8); \
-			m->hdr.len = l + 8;			\
-			m->hdr.applicationID = 1;		\
-			m->hdr.cmd.cmd = c;			\
-			m->hdr.cmd.subcmd = s;			\
-			m->hdr.msgnum = actcapi_nextsmsg(card); \
-		} else m = NULL;				\
-	}
+static struct sk_buff *actcapi_mkhdr(act2000_card *card, actcapi_msg **m,
+				     int len, int cmd, int subcmd)
+{
+	struct sk_buff *skb;
 
-#define ACTCAPI_CHKSKB if (!skb) {					\
-		printk(KERN_WARNING "actcapi: alloc_skb failed\n");	\
-		return;							\
-	}
+	len += 8;
 
-#define ACTCAPI_QUEUE_TX {				\
-		actcapi_debug_msg(skb, 1);		\
-		skb_queue_tail(&card->sndq, skb);	\
-		act2000_schedule_tx(card);		\
+	skb = alloc_skb(len, GFP_ATOMIC);
+	if (!skb) {
+		*m = NULL;
+		return NULL;
 	}
 
+	*m = (actcapi_msg *)skb_put(skb, len);
+	(*m)->hdr.len = len;
+	(*m)->hdr.applicationID = 1;
+	(*m)->hdr.cmd.cmd = cmd;
+	(*m)->hdr.cmd.subcmd = subcmd;
+	(*m)->hdr.msgnum = actcapi_nextsmsg(card);
+
+	return skb;
+}
+
+static void actcapi_queue_tx(act2000_card *card, struct sk_buff *skb)
+{
+	actcapi_debug_msg(skb, 1);
+	skb_queue_tail(&card->sndq, skb);
+	act2000_schedule_tx(card);
+}
+
 int
 actcapi_listen_req(act2000_card *card)
 {
@@ -137,16 +144,15 @@ actcapi_listen_req(act2000_card *card)
 
 	for (i = 0; i < ACT2000_BCH; i++)
 		eazmask |= card->bch[i].eazmask;
-	ACTCAPI_MKHDR(9, 0x05, 0x00);
-	if (!skb) {
-		printk(KERN_WARNING "actcapi: alloc_skb failed\n");
+	skb = actcapi_mkhdr(card, &m, 9, 0x05, 0x00);
+	if (!skb)
 		return -ENOMEM;
-	}
+
 	m->msg.listen_req.controller = 0;
 	m->msg.listen_req.infomask = 0x3f; /* All information */
 	m->msg.listen_req.eazmask = eazmask;
 	m->msg.listen_req.simask = (eazmask) ? 0x86 : 0; /* All SI's  */
-	ACTCAPI_QUEUE_TX;
+	actcapi_queue_tx(card, skb);
 	return 0;
 }
 
@@ -157,12 +163,12 @@ actcapi_connect_req(act2000_card *card, act2000_chan *chan, char *phone,
 	actcapi_msg *m;
 	struct sk_buff *skb;
 
-	ACTCAPI_MKHDR((11 + strlen(phone)), 0x02, 0x00);
+	skb = actcapi_mkhdr(card, &m, 11 + strlen(phone), 0x02, 0x00);
 	if (!skb) {
-		printk(KERN_WARNING "actcapi: alloc_skb failed\n");
 		chan->fsm_state = ACT2000_STATE_NULL;
 		return -ENOMEM;
 	}
+
 	m->msg.connect_req.controller = 0;
 	m->msg.connect_req.bchan = 0x83;
 	m->msg.connect_req.infomask = 0x3f;
@@ -173,7 +179,7 @@ actcapi_connect_req(act2000_card *card, act2000_chan *chan, char *phone,
 	m->msg.connect_req.addr.tnp = 0x81;
 	memcpy(m->msg.connect_req.addr.num, phone, strlen(phone));
 	chan->callref = m->hdr.msgnum;
-	ACTCAPI_QUEUE_TX;
+	actcapi_queue_tx(card, skb);
 	return 0;
 }
 
@@ -183,14 +189,16 @@ actcapi_connect_b3_req(act2000_card *card, act2000_chan *chan)
 	actcapi_msg *m;
 	struct sk_buff *skb;
 
-	ACTCAPI_MKHDR(17, 0x82, 0x00);
-	ACTCAPI_CHKSKB;
+	skb = actcapi_mkhdr(card, &m, 17, 0x82, 0x00);
+	if (!skb)
+		return;
+
 	m->msg.connect_b3_req.plci = chan->plci;
 	memset(&m->msg.connect_b3_req.ncpi, 0,
 	       sizeof(m->msg.connect_b3_req.ncpi));
 	m->msg.connect_b3_req.ncpi.len = 13;
 	m->msg.connect_b3_req.ncpi.modulo = 8;
-	ACTCAPI_QUEUE_TX;
+	actcapi_queue_tx(card, skb);
 }
 
 /*
@@ -202,15 +210,14 @@ actcapi_manufacturer_req_net(act2000_card *card)
 	actcapi_msg *m;
 	struct sk_buff *skb;
 
-	ACTCAPI_MKHDR(5, 0xff, 0x00);
-	if (!skb) {
-		printk(KERN_WARNING "actcapi: alloc_skb failed\n");
+	skb = actcapi_mkhdr(card, &m, 5, 0xff, 0x00);
+	if (!skb)
 		return -ENOMEM;
-	}
+
 	m->msg.manufacturer_req_net.manuf_msg = 0x11;
 	m->msg.manufacturer_req_net.controller = 1;
 	m->msg.manufacturer_req_net.nettype = (card->ptype == ISDN_PTYPE_EURO) ? 1 : 0;
-	ACTCAPI_QUEUE_TX;
+	actcapi_queue_tx(card, skb);
 	printk(KERN_INFO "act2000 %s: D-channel protocol now %s\n",
 	       card->interface.id, (card->ptype == ISDN_PTYPE_EURO) ? "euro" : "1tr6");
 	card->interface.features &=
@@ -230,16 +237,14 @@ actcapi_manufacturer_req_v42(act2000_card *card, ulong arg)
 	actcapi_msg *m;
 	struct sk_buff *skb;
 
-	ACTCAPI_MKHDR(8, 0xff, 0x00);
-	if (!skb) {
-
-		printk(KERN_WARNING "actcapi: alloc_skb failed\n");
+	skb = actcapi_mkhdr(card, &m, 8, 0xff, 0x00);
+	if (!skb)
 		return -ENOMEM;
-	}
+
 	m->msg.manufacturer_req_v42.manuf_msg = 0x10;
 	m->msg.manufacturer_req_v42.controller = 0;
 	m->msg.manufacturer_req_v42.v42control = (arg ? 1 : 0);
-	ACTCAPI_QUEUE_TX;
+	actcapi_queue_tx(card, skb);
 	return 0;
 }
 #endif  /*  0  */
@@ -253,15 +258,13 @@ actcapi_manufacturer_req_errh(act2000_card *card)
 	actcapi_msg *m;
 	struct sk_buff *skb;
 
-	ACTCAPI_MKHDR(4, 0xff, 0x00);
-	if (!skb) {
-
-		printk(KERN_WARNING "actcapi: alloc_skb failed\n");
+	skb = actcapi_mkhdr(card, &m, 4, 0xff, 0x00);
+	if (!skb)
 		return -ENOMEM;
-	}
+
 	m->msg.manufacturer_req_err.manuf_msg = 0x03;
 	m->msg.manufacturer_req_err.controller = 0;
-	ACTCAPI_QUEUE_TX;
+	actcapi_queue_tx(card, skb);
 	return 0;
 }
 
@@ -281,17 +284,16 @@ actcapi_manufacturer_req_msn(act2000_card *card)
 
 		len = strlen(p->msn);
 		for (i = 0; i < 2; i++) {
-			ACTCAPI_MKHDR(6 + len, 0xff, 0x00);
-			if (!skb) {
-				printk(KERN_WARNING "actcapi: alloc_skb failed\n");
+			skb = actcapi_mkhdr(card, &m, 6 + len, 0xff, 0x00);
+			if (!skb)
 				return -ENOMEM;
-			}
+
 			m->msg.manufacturer_req_msn.manuf_msg = 0x13 + i;
 			m->msg.manufacturer_req_msn.controller = 0;
 			m->msg.manufacturer_req_msn.msnmap.eaz = p->eaz;
 			m->msg.manufacturer_req_msn.msnmap.len = len;
 			memcpy(m->msg.manufacturer_req_msn.msnmap.msn, p->msn, len);
-			ACTCAPI_QUEUE_TX;
+			actcapi_queue_tx(card, skb);
 		}
 		p = p->next;
 	}
@@ -304,8 +306,10 @@ actcapi_select_b2_protocol_req(act2000_card *card, act2000_chan *chan)
 	actcapi_msg *m;
 	struct sk_buff *skb;
 
-	ACTCAPI_MKHDR(10, 0x40, 0x00);
-	ACTCAPI_CHKSKB;
+	skb = actcapi_mkhdr(card, &m, 10, 0x40, 0x00);
+	if (!skb)
+		return;
+
 	m->msg.select_b2_protocol_req.plci = chan->plci;
 	memset(&m->msg.select_b2_protocol_req.dlpd, 0,
 	       sizeof(m->msg.select_b2_protocol_req.dlpd));
@@ -330,7 +334,7 @@ actcapi_select_b2_protocol_req(act2000_card *card, act2000_chan *chan)
 		m->msg.select_b2_protocol_req.dlpd.modulo = 8;
 		break;
 	}
-	ACTCAPI_QUEUE_TX;
+	actcapi_queue_tx(card, skb);
 }
 
 static void
@@ -339,8 +343,10 @@ actcapi_select_b3_protocol_req(act2000_card *card, act2000_chan *chan)
 	actcapi_msg *m;
 	struct sk_buff *skb;
 
-	ACTCAPI_MKHDR(17, 0x80, 0x00);
-	ACTCAPI_CHKSKB;
+	skb = actcapi_mkhdr(card, &m, 17, 0x80, 0x00);
+	if (!skb)
+		return;
+
 	m->msg.select_b3_protocol_req.plci = chan->plci;
 	memset(&m->msg.select_b3_protocol_req.ncpd, 0,
 	       sizeof(m->msg.select_b3_protocol_req.ncpd));
@@ -351,7 +357,7 @@ actcapi_select_b3_protocol_req(act2000_card *card, act2000_chan *chan)
 		m->msg.select_b3_protocol_req.ncpd.modulo = 8;
 		break;
 	}
-	ACTCAPI_QUEUE_TX;
+	actcapi_queue_tx(card, skb);
 }
 
 static void
@@ -360,10 +366,12 @@ actcapi_listen_b3_req(act2000_card *card, act2000_chan *chan)
 	actcapi_msg *m;
 	struct sk_buff *skb;
 
-	ACTCAPI_MKHDR(2, 0x81, 0x00);
-	ACTCAPI_CHKSKB;
+	skb = actcapi_mkhdr(card, &m, 2, 0x81, 0x00);
+	if (!skb)
+		return;
+
 	m->msg.listen_b3_req.plci = chan->plci;
-	ACTCAPI_QUEUE_TX;
+	actcapi_queue_tx(card, skb);
 }
 
 static void
@@ -372,11 +380,13 @@ actcapi_disconnect_req(act2000_card *card, act2000_chan *chan)
 	actcapi_msg *m;
 	struct sk_buff *skb;
 
-	ACTCAPI_MKHDR(3, 0x04, 0x00);
-	ACTCAPI_CHKSKB;
+	skb = actcapi_mkhdr(card, &m, 3, 0x04, 0x00);
+	if (!skb)
+		return;
+
 	m->msg.disconnect_req.plci = chan->plci;
 	m->msg.disconnect_req.cause = 0;
-	ACTCAPI_QUEUE_TX;
+	actcapi_queue_tx(card, skb);
 }
 
 void
@@ -385,15 +395,17 @@ actcapi_disconnect_b3_req(act2000_card *card, act2000_chan *chan)
 	actcapi_msg *m;
 	struct sk_buff *skb;
 
-	ACTCAPI_MKHDR(17, 0x84, 0x00);
-	ACTCAPI_CHKSKB;
+	skb = actcapi_mkhdr(card, &m, 17, 0x84, 0x00);
+	if (!skb)
+		return;
+
 	m->msg.disconnect_b3_req.ncci = chan->ncci;
 	memset(&m->msg.disconnect_b3_req.ncpi, 0,
 	       sizeof(m->msg.disconnect_b3_req.ncpi));
 	m->msg.disconnect_b3_req.ncpi.len = 13;
 	m->msg.disconnect_b3_req.ncpi.modulo = 8;
 	chan->fsm_state = ACT2000_STATE_BHWAIT;
-	ACTCAPI_QUEUE_TX;
+	actcapi_queue_tx(card, skb);
 }
 
 void
@@ -402,8 +414,10 @@ actcapi_connect_resp(act2000_card *card, act2000_chan *chan, __u8 cause)
 	actcapi_msg *m;
 	struct sk_buff *skb;
 
-	ACTCAPI_MKHDR(3, 0x02, 0x03);
-	ACTCAPI_CHKSKB;
+	skb = actcapi_mkhdr(card, &m, 3, 0x02, 0x03);
+	if (!skb)
+		return;
+
 	m->msg.connect_resp.plci = chan->plci;
 	m->msg.connect_resp.rejectcause = cause;
 	if (cause) {
@@ -411,7 +425,7 @@ actcapi_connect_resp(act2000_card *card, act2000_chan *chan, __u8 cause)
 		chan->plci = 0x8000;
 	} else
 		chan->fsm_state = ACT2000_STATE_IWAIT;
-	ACTCAPI_QUEUE_TX;
+	actcapi_queue_tx(card, skb);
 }
 
 static void
@@ -420,12 +434,14 @@ actcapi_connect_active_resp(act2000_card *card, act2000_chan *chan)
 	actcapi_msg *m;
 	struct sk_buff *skb;
 
-	ACTCAPI_MKHDR(2, 0x03, 0x03);
-	ACTCAPI_CHKSKB;
+	skb = actcapi_mkhdr(card, &m, 2, 0x03, 0x03);
+	if (!skb)
+		return;
+
 	m->msg.connect_resp.plci = chan->plci;
 	if (chan->fsm_state == ACT2000_STATE_IWAIT)
 		chan->fsm_state = ACT2000_STATE_IBWAIT;
-	ACTCAPI_QUEUE_TX;
+	actcapi_queue_tx(card, skb);
 }
 
 static void
@@ -434,8 +450,10 @@ actcapi_connect_b3_resp(act2000_card *card, act2000_chan *chan, __u8 rejectcause
 	actcapi_msg *m;
 	struct sk_buff *skb;
 
-	ACTCAPI_MKHDR((rejectcause ? 3 : 17), 0x82, 0x03);
-	ACTCAPI_CHKSKB;
+	skb = actcapi_mkhdr(card, &m, rejectcause ? 3 : 17, 0x82, 0x03);
+	if (!skb)
+		return;
+
 	m->msg.connect_b3_resp.ncci = chan->ncci;
 	m->msg.connect_b3_resp.rejectcause = rejectcause;
 	if (!rejectcause) {
@@ -445,7 +463,7 @@ actcapi_connect_b3_resp(act2000_card *card, act2000_chan *chan, __u8 rejectcause
 		m->msg.connect_b3_resp.ncpi.modulo = 8;
 		chan->fsm_state = ACT2000_STATE_BWAIT;
 	}
-	ACTCAPI_QUEUE_TX;
+	actcapi_queue_tx(card, skb);
 }
 
 static void
@@ -454,11 +472,13 @@ actcapi_connect_b3_active_resp(act2000_card *card, act2000_chan *chan)
 	actcapi_msg *m;
 	struct sk_buff *skb;
 
-	ACTCAPI_MKHDR(2, 0x83, 0x03);
-	ACTCAPI_CHKSKB;
+	skb = actcapi_mkhdr(card, &m, 2, 0x83, 0x03);
+	if (!skb)
+		return;
+
 	m->msg.connect_b3_active_resp.ncci = chan->ncci;
 	chan->fsm_state = ACT2000_STATE_ACTIVE;
-	ACTCAPI_QUEUE_TX;
+	actcapi_queue_tx(card, skb);
 }
 
 static void
@@ -467,10 +487,12 @@ actcapi_info_resp(act2000_card *card, act2000_chan *chan)
 	actcapi_msg *m;
 	struct sk_buff *skb;
 
-	ACTCAPI_MKHDR(2, 0x07, 0x03);
-	ACTCAPI_CHKSKB;
+	skb = actcapi_mkhdr(card, &m, 2, 0x07, 0x03);
+	if (!skb)
+		return;
+
 	m->msg.info_resp.plci = chan->plci;
-	ACTCAPI_QUEUE_TX;
+	actcapi_queue_tx(card, skb);
 }
 
 static void
@@ -479,12 +501,14 @@ actcapi_disconnect_b3_resp(act2000_card *card, act2000_chan *chan)
 	actcapi_msg *m;
 	struct sk_buff *skb;
 
-	ACTCAPI_MKHDR(2, 0x84, 0x03);
-	ACTCAPI_CHKSKB;
+	skb = actcapi_mkhdr(card, &m, 2, 0x84, 0x03);
+	if (!skb)
+		return;
+
 	m->msg.disconnect_b3_resp.ncci = chan->ncci;
 	chan->ncci = 0x8000;
 	chan->queued = 0;
-	ACTCAPI_QUEUE_TX;
+	actcapi_queue_tx(card, skb);
 }
 
 static void
@@ -493,11 +517,13 @@ actcapi_disconnect_resp(act2000_card *card, act2000_chan *chan)
 	actcapi_msg *m;
 	struct sk_buff *skb;
 
-	ACTCAPI_MKHDR(2, 0x04, 0x03);
-	ACTCAPI_CHKSKB;
+	skb = actcapi_mkhdr(card, &m, 2, 0x04, 0x03);
+	if (!skb)
+		return;
+
 	m->msg.disconnect_resp.plci = chan->plci;
 	chan->plci = 0x8000;
-	ACTCAPI_QUEUE_TX;
+	actcapi_queue_tx(card, skb);
 }
 
 static int
@@ -575,7 +601,7 @@ actcapi_data_b3_ind(act2000_card *card, struct sk_buff *skb) {
 	msg->hdr.msgnum = actcapi_nextsmsg(card);
 	msg->msg.data_b3_resp.ncci = ncci;
 	msg->msg.data_b3_resp.blocknr = blocknr;
-	ACTCAPI_QUEUE_TX;
+	actcapi_queue_tx(card, skb);
 	return 1;
 }
 
