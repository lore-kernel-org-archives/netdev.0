From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] appletalk: Set skb with destructor
Date: Mon, 07 Jul 2014 18:56:59 +0200
Message-ID: <1404752219.4501.18.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140705202821.GA25880@mwanda>
	 <1404647816-7564-1-git-send-email-andrey.krieger.utkin@gmail.com>
	 <1404682932.4501.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CANZNk81v7YHKpzjZ65KHdUi1BgBiV_ibZO24b8uauuCVZeUv2A@mail.gmail.com>
	 <1404723456.4501.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1404725217.4501.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CANZNk81UtoCOANXnmUPLx3uCP37BH=Wb54YjD3UQ1BwNc1P2Vw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	acme@ghostprotocols.net, netdev@vger.kernel.org,
	davem@davemloft.net
To: Andrey Utkin <andrey.krieger.utkin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANZNk81UtoCOANXnmUPLx3uCP37BH=Wb54YjD3UQ1BwNc1P2Vw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-07-07 at 13:02 +0300, Andrey Utkin wrote:
> 2014-07-07 12:26 GMT+03:00 Eric Dumazet <eric.dumazet@gmail.com>:
> > Reading again this code, I think all you need is to remove the 2 buggy
> > lines.
> >
> > No need for setup destructors.
> 
> Reviewing the code again, i find you're right and adding a destructor
> in that place is stupid, and just not setting skb->sk would make bug
> disappear, assuming skb->sk is previously NULL.
> And what about the second case, at ddp.c near line 1650? Is destructor
> needed here?

Not needed at all.

There is already a proper destructor set by sock_alloc_send_skb()

As I said, all you need is to remove the 2 lines.

Something like :

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 01a1082e02b3..5563dcb7a1fc 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1489,7 +1489,6 @@ static int atalk_rcv(struct sk_buff *skb, struct net_device *dev,
 		goto drop;
 
 	/* Queue packet (standard) */
-	skb->sk = sock;
 
 	if (sock_queue_rcv_skb(sock, skb) < 0)
 		goto drop;
@@ -1644,7 +1643,6 @@ static int atalk_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
 	if (!skb)
 		goto out;
 
-	skb->sk = sk;
 	skb_reserve(skb, ddp_dl->header_length);
 	skb_reserve(skb, dev->hard_header_len);
 	skb->dev = dev;
