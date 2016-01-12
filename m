From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] phonet: properly unshare skbs in phonet_rcv()
Date: Tue, 12 Jan 2016 08:58:00 -0800
Message-ID: <1452617880.1223.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <568EA671.7000502@gmail.com> <56929985.3020502@gmail.com>
	 <1452457610.16445.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5694188F.80907@gmail.com>
	 <CAO7SqHA9dNUDG+pYJoQvipE_ErM4Bgo0_o9er_OLxZLDgNVJ8Q@mail.gmail.com>
	 <56944DFA.4050002@gmail.com>
	 <1452560786.1223.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAO7SqHC+fTCyNd8ukSH4tJ1qPvAYzMGSfhrzXmMn0NLve6NTQA@mail.gmail.com>
	 <1452565288.1223.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1452565515.1223.11.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5694A840.8030900@gmail.com>
	 <1452608377.1223.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Salam Noureddine <noureddine@arista.com>,
	"David S. Miller" <davem@davemloft.net>,
	Pali =?ISO-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Sebastian Reichel <sre@kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	Remi Denis-Courmont <courmisch@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452608377.1223.13.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

Ivaylo Dimitrov reported a regression caused by commit 7866a621043f
("dev: add per net_device packet type chains").

skb->dev becomes NULL and we crash in __netif_receive_skb_core().

Before above commit, different kind of bugs or corruptions could happen
without major crash.

But the root cause is that phonet_rcv() can queue skb without checking
if skb is shared or not.

Many thanks to Ivaylo Dimitrov for his help, diagnosis and tests.

Reported-by: Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>
Tested-by: Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Remi Denis-Courmont <courmisch@gmail.com>
---
 net/phonet/af_phonet.c |    4 ++++
 1 file changed, 4 insertions(+)

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
