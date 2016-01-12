From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [OOPS] In __netif_receive_skb_core
Date: Mon, 11 Jan 2016 18:25:15 -0800
Message-ID: <1452565515.1223.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <568EA671.7000502@gmail.com> <56929985.3020502@gmail.com>
	 <1452457610.16445.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5694188F.80907@gmail.com>
	 <CAO7SqHA9dNUDG+pYJoQvipE_ErM4Bgo0_o9er_OLxZLDgNVJ8Q@mail.gmail.com>
	 <56944DFA.4050002@gmail.com>
	 <1452560786.1223.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAO7SqHC+fTCyNd8ukSH4tJ1qPvAYzMGSfhrzXmMn0NLve6NTQA@mail.gmail.com>
	 <1452565288.1223.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Pali =?ISO-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Sebastian Reichel <sre@kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: Salam Noureddine <noureddine@arista.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452565288.1223.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-01-11 at 18:21 -0800, Eric Dumazet wrote:
> On Mon, 2016-01-11 at 17:19 -0800, Salam Noureddine wrote:
> > It must be that skb->dev was changed to NULL inside of
> > __netif_receive_skb_core, otherwise we would have crashed much
> > earlier. Also, orig_dev is saved at the beginning. Possibly a device
> > is layered on top of the original device.
> 
> Please do not top post on netdev / lkml mailing lists.
> 
> My guess is a protocol handler queued the skb without calling
> skb_share_check()
> 

OK please try this fix :

diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 10d42f3220ab..f925753668a7 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -377,6 +377,10 @@ static int phonet_rcv(struct sk_buff *skb, struct net_device *dev,
 	struct sockaddr_pn sa;
 	u16 len;
 
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (!skb)
+		return NET_RX_DROP;
+
 	/* check we have at least a full Phonet header */
 	if (!pskb_pull(skb, sizeof(struct phonethdr)))
 		goto out;
