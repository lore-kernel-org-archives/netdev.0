From: Lee Revell <rlrevell@joe-job.com>
Subject: Re: [PATCH] Make netif_rx_ni preempt-safe
Date: Tue, 19 Oct 2004 20:22:18 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098231737.23628.42.camel@krustophenia.net>
References: <1098230132.23628.28.camel@krustophenia.net>
	 <20041020000009.GA17246@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        vda@port.imtp.ilyichevsk.odessa.ua, linux-kernel@gondor.apana.org.au,
        maxk@qualcomm.com, irda-users@lists.sourceforge.net,
        Linux Network Development <netdev@oss.sgi.com>,
        Alain Schroeder <alain@parkautomat.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041020000009.GA17246@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-10-19 at 20:00, Herbert Xu wrote:
> On Tue, Oct 19, 2004 at 07:55:33PM -0400, Lee Revell wrote:
> > 
> > --- include/linux/netdevice.h~	2004-10-19 18:50:18.000000000 -0400
> > +++ include/linux/netdevice.h	2004-10-19 18:51:01.000000000 -0400
> > @@ -696,9 +696,11 @@
> >   */
> >  static inline int netif_rx_ni(struct sk_buff *skb)
> >  {
> > +       preempt_disable();
> >         int err = netif_rx(skb);
> 
> This is broken on older compilers.

How about this:

Signed-Off-By: Lee Revell <rlrevell@joe-job.com>

--- include/linux/netdevice.h~	2004-10-19 20:16:48.000000000 -0400
+++ include/linux/netdevice.h	2004-10-19 20:21:01.000000000 -0400
@@ -696,9 +696,12 @@
  */
 static inline int netif_rx_ni(struct sk_buff *skb)
 {
-       int err = netif_rx(skb);
+       int err;
+       preempt_disable();
+       err = netif_rx(skb);
        if (softirq_pending(smp_processor_id()))
                do_softirq();
+       preempt_enable();
        return err;
 }
 
