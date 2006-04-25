From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: skb->truesize assertion checking for TCP
Date: Tue, 25 Apr 2006 09:49:58 -0700
Message-ID: <4807377b0604250949q3e7470baiacb2b4a15de35e6c@mail.gmail.com>
References: <20060419.215513.13034269.davem@davemloft.net>
	 <20060420050406.GA22105@gondor.apana.org.au>
	 <20060419.231703.35841080.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xproxy.gmail.com ([66.249.82.194]:7329 "EHLO xproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751571AbWDYQt7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Apr 2006 12:49:59 -0400
Received: by xproxy.gmail.com with SMTP id t10so885334wxc
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2006 09:49:58 -0700 (PDT)
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060419.231703.35841080.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/19/06, David S. Miller <davem@davemloft.net> wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 20 Apr 2006 15:04:06 +1000
>
> > On Wed, Apr 19, 2006 at 09:55:13PM -0700, David S. Miller wrote:
> > > +static inline void skb_truesize_check(struct sk_buff *skb)
> > > +{
> > > +   if (unlikely((int)skb->truesize < sizeof(struct sk_buff)))
> > > +           skb_truesize_bug(skb);
> > > +}
> >
> > I think we can go for the stronger test:
> >
> > skb->truesize < sizeof(struct sk_buff) + skb->len
>
> Agreed, let me see if that triggers on my machine before
> I commit this :-)

Um, I get a log full of these now with the 7.0.33 driver in the
kernel.  BTW, it seems like it is missing a WARN_ON or
printk(__function__) - or whatever prints the function name of a
caller in the debug output.

Apr 24 15:48:36 lindenhurst-2 kernel: e1000: eth1:
e1000_watchdog_task: NIC Link is Up 100 Mbps Half Duplex
Apr 24 15:48:36 lindenhurst-2 kernel: e1000: eth1:
e1000_watchdog_task: 10/100 speed: disabling TSO
Apr 24 15:49:21 lindenhurst-2 kernel: SKB BUG: Invalid truesize (616)
len=1448, sizeof(sk_buff)=232
Apr 24 15:49:21 lindenhurst-2 last message repeated 13 times
Apr 24 15:49:21 lindenhurst-2 kernel: SKB BUG: Invalid truesize (616)
len=1408, sizeof(sk_buff)=232
Apr 24 15:49:21 lindenhurst-2 kernel: SKB BUG: Invalid truesize (616)
len=1448, sizeof(sk_buff)=232
Apr 24 15:49:21 lindenhurst-2 last message repeated 15 times
Apr 24 15:49:21 lindenhurst-2 kernel: SKB BUG: Invalid truesize (616)
len=1408, sizeof(sk_buff)=232
Apr 24 15:49:21 lindenhurst-2 kernel: SKB BUG: Invalid truesize (616)
len=1448, sizeof(sk_buff)=232
Apr 24 15:49:21 lindenhurst-2 last message repeated 97 times

I have the latest version of net/core/skbuff.c in git.

I've verified that the below patch fixes the message appearing but I
still think the message could be refined a little bit.  We're working
on seperate patches for this for 17-rc and 16 stable.

Jesse

PS this is just for reference, this patch is mangled due to cut/paste

 drivers/net/e1000/e1000_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index add8dc4..c99e878 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3768,6 +3768,7 @@ e1000_clean_rx_irq_ps(struct e1000_adapt
                        ps_page->ps_page[j] = NULL;
                        skb->len += length;
                        skb->data_len += length;
+                       skb->truesize += length;
                }

 copydone:
