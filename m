From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: GPF in eth_header
Date: Mon, 28 Nov 2016 13:05:52 -0800
Message-ID: <1480367152.18162.86.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+at4Fp6i7WRggYq7M1+z1aHo=Bff63p+1DzC2SnTjuWdA@mail.gmail.com>
         <CANn89iJeWV9YnOzy4eXL4Sbcyw_kj_CA8JrfGaFxMse_MUFL6Q@mail.gmail.com>
         <CAAeHK+x48aKLcKfN2aYA1pBPr4Y4ESUvjCTu0xGPoYZuiRbaaw@mail.gmail.com>
         <1480359019.18162.79.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAAeHK+wWVp46ej0tk5mDnOHpH5Ky0+HiH9_SUqGcT0iTppLaGw@mail.gmail.com>
         <CACT4Y+Yr6UJxXosjx2FO=KtxGr40X07_UBiscs1BP1s8cTaqAA@mail.gmail.com>
         <1480362459.18162.83.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: syzkaller <syzkaller@googlegroups.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        David Miller <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Jiri Benc <jbenc@redhat.com>,
        Sabrina Dubroca <sd@queasysnail.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Dmitry Vyukov <dvyukov@google.com>, Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480362459.18162.83.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-11-28 at 11:47 -0800, Eric Dumazet wrote:
> On Mon, 2016-11-28 at 20:34 +0100, Dmitry Vyukov wrote:
> > On Mon, Nov 28, 2016 at 8:04 PM, 'Andrey Konovalov' via syzkaller
> 
> > > Hi Eric,
> > >
> > > As far as I can see, skb_network_offset() becomes negative after
> > > pskb_pull(skb, (u8 *) (fhdr + 1) - skb->data) in nf_ct_frag6_queue().
> > > At least I'm able to detect that with a BUG_ON().
> > >
> > > Also it seems that the issue is only reproducible (at least with the
> > > poc I provided) for a short time after boot.
> > 
> > 
> > Eric,
> > 
> > Is it enough to debug? Or maybe Andrey can trace some values for you.
> 
> Well, now we are talking, if you tell me how many modules you load, it
> might help ;)
> 
> nf_ct_frag6_queue is nowhere to be seen in my kernels, that might
> explain why I could not reproduce the bug.
> 
> Let me try ;)
> 

Might be a bug added in commit daaa7d647f81f3
("netfilter: ipv6: avoid nf_iterate recursion")

Florian, what do you think of dropping a packet that presumably was
mangled badly by nf_ct_frag6_queue() ?

(Like about 48 byte pulled :(, and/or skb->csum changed )

diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index f7aab5ab93a5..31aa947332d8 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -65,8 +65,8 @@ static unsigned int ipv6_defrag(void *priv,
 
 	err = nf_ct_frag6_gather(state->net, skb,
 				 nf_ct6_defrag_user(state->hook, skb));
-	/* queued */
-	if (err == -EINPROGRESS)
+	/* queued or mangled ... */
+	if (err)
 		return NF_STOLEN;
 
 	return NF_ACCEPT;
