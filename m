From: SathyaNarayanan <sathyan@teamf1.com>
Subject: Re: [PATCH] ibm_newemac: Fixes memory leak in ibm_newemac ethernet
	driver
Date: Wed, 2 Jul 2008 10:15:21 +0530
Message-ID: <1946a170807012145v6e6d629cvea443f2b8462d708@mail.gmail.com>
References: <1214225712-25882-1-git-send-email-sr@denx.de>
	<1214263310.8011.280.camel@pasglop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1081622414=="
Cc: linuxppc-dev@ozlabs.org, Stefan Roese <sr@denx.de>, netdev@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <1214263310.8011.280.camel@pasglop>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

--===============1081622414==
Content-Type: multipart/alternative;
	boundary="----=_Part_3388_4513222.1214973921901"

------=_Part_3388_4513222.1214973921901
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi Benn,

               Please find my comments below.

On Tue, Jun 24, 2008 at 4:51 AM, Benjamin Herrenschmidt <
benh@kernel.crashing.org> wrote:

> On Mon, 2008-06-23 at 14:55 +0200, Stefan Roese wrote:
> > From: Sathya Narayanan <sathyan@teamf1.com>
> >
> > This patch addresses the memory leak happenning in drivers transmit queue
> > under heavy load condition. Once the transmit queue becomes full, driver
> > does an automatic wrapup of queue. During which the untransmitted SKB's
> are
> > lost without getting freed up.
>
> This would be a bug. We should stop the queue when full instead.


Actually the meachanism of stopping the queue and starting it is already
there.  But even then due to some sync issue between the poll routine and
xmit, we were resulted in using the slots of skb which was not actually got
freed before.
I agree this could a bug , Since its not is not clear why buffers are not
getting transferred timely?. But to handle this we should have a work around
otherwise system may go out of memory. If we go for stopping the queue in
these scenario also ( Where a unfreed skbs slot has been assigned  to
another ), Then kernel may call tx timeout, And reset the driver. In that
case handelling this special case here could lead us better performance as
compared to stopping the queue
Let me know your comments.

>
>
> > Signed-off-by: Sathya Narayanan <sathyan@teamf1.com>
> > Signed-off-by: Stefan Roese <sr@denx.de>
> > ---
> >  drivers/net/ibm_newemac/core.c |    7 +++++++
> >  1 files changed, 7 insertions(+), 0 deletions(-)
> >
> > diff --git a/drivers/net/ibm_newemac/core.c
> b/drivers/net/ibm_newemac/core.c
> > index aa407b2..ee868b6 100644
> > --- a/drivers/net/ibm_newemac/core.c
> > +++ b/drivers/net/ibm_newemac/core.c
> > @@ -1328,6 +1328,13 @@ static int emac_start_xmit(struct sk_buff *skb,
> struct net_device *ndev)
> >
> >       DBG2(dev, "xmit(%u) %d" NL, len, slot);
> >
> > +     if (dev->tx_skb[slot] && dev->tx_desc[slot].data_ptr) {
> > +             dev_kfree_skb(dev->tx_skb[slot]);
> > +             dev->tx_skb[slot] = NULL;
> > +             dev->tx_cnt--;
> > +             ++dev->estats.tx_dropped;
> > +     }
> > +
> >       dev->tx_skb[slot] = skb;
> >       dev->tx_desc[slot].data_ptr = dma_map_single(&dev->ofdev->dev,
> >                                                    skb->data, len,
>
>

------=_Part_3388_4513222.1214973921901
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi Benn,<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Please find my comments below.<br><br><div class="gmail_quote">On Tue, Jun 24, 2008 at 4:51 AM, Benjamin Herrenschmidt &lt;<a href="mailto:benh@kernel.crashing.org">benh@kernel.crashing.org</a>&gt; wrote:<br>
<blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;"><div class="Ih2E3d">On Mon, 2008-06-23 at 14:55 +0200, Stefan Roese wrote:<br>
&gt; From: Sathya Narayanan &lt;<a href="mailto:sathyan@teamf1.com">sathyan@teamf1.com</a>&gt;<br>
&gt;<br>
&gt; This patch addresses the memory leak happenning in drivers transmit queue<br>
&gt; under heavy load condition. Once the transmit queue becomes full, driver<br>
&gt; does an automatic wrapup of queue. During which the untransmitted SKB&#39;s are<br>
&gt; lost without getting freed up.<br>
<br>
</div>This would be a bug. We should stop the queue when full instead.</blockquote><div><br>Actually the meachanism of stopping the queue and starting it is
already there.&nbsp; But even then due to some sync issue between the poll
routine and xmit, we were resulted in using the slots of skb which was
not actually got freed before. <br>I agree this could a bug , Since its not is not clear why buffers are not getting transferred timely?. But to handle this we should have a work around otherwise system may go out of memory. If we go for stopping the queue in these scenario also ( Where a unfreed skbs slot has been assigned&nbsp; to another ), Then kernel may call tx timeout, And reset the driver. In that case handelling this special case here could lead us better performance as compared to stopping the queue<br>
Let me know your comments.<br></div><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;"><br>
<div><div></div><div class="Wj3C7c"><br>
&gt; Signed-off-by: Sathya Narayanan &lt;<a href="mailto:sathyan@teamf1.com">sathyan@teamf1.com</a>&gt;<br>
&gt; Signed-off-by: Stefan Roese &lt;<a href="mailto:sr@denx.de">sr@denx.de</a>&gt;<br>
&gt; ---<br>
&gt; &nbsp;drivers/net/ibm_newemac/core.c | &nbsp; &nbsp;7 +++++++<br>
&gt; &nbsp;1 files changed, 7 insertions(+), 0 deletions(-)<br>
&gt;<br>
&gt; diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c<br>
&gt; index aa407b2..ee868b6 100644<br>
&gt; --- a/drivers/net/ibm_newemac/core.c<br>
&gt; +++ b/drivers/net/ibm_newemac/core.c<br>
&gt; @@ -1328,6 +1328,13 @@ static int emac_start_xmit(struct sk_buff *skb, struct net_device *ndev)<br>
&gt;<br>
&gt; &nbsp; &nbsp; &nbsp; DBG2(dev, &quot;xmit(%u) %d&quot; NL, len, slot);<br>
&gt;<br>
&gt; + &nbsp; &nbsp; if (dev-&gt;tx_skb[slot] &amp;&amp; dev-&gt;tx_desc[slot].data_ptr) {<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; dev_kfree_skb(dev-&gt;tx_skb[slot]);<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; dev-&gt;tx_skb[slot] = NULL;<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; dev-&gt;tx_cnt--;<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ++dev-&gt;estats.tx_dropped;<br>
&gt; + &nbsp; &nbsp; }<br>
&gt; +<br>
&gt; &nbsp; &nbsp; &nbsp; dev-&gt;tx_skb[slot] = skb;<br>
&gt; &nbsp; &nbsp; &nbsp; dev-&gt;tx_desc[slot].data_ptr = dma_map_single(&amp;dev-&gt;ofdev-&gt;dev,<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;skb-&gt;data, len,<br>
<br>
</div></div></blockquote></div><br>

------=_Part_3388_4513222.1214973921901--

--===============1081622414==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev
--===============1081622414==--
