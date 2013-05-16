From: David Hauweele <david-1EggE+PRa6vk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH 1/2] mrf24j40: Avoid transmission
 while receiving a frame
Date: Thu, 16 May 2013 19:45:58 +0200
Message-ID: <CAO+c-UVJQJbmmmCS4hxAEYHKa8gEU1Bs=y+Rv_A75UHeBZxc+w@mail.gmail.com>
References: <1368112788-25701-1-git-send-email-david@hauweele.net>
	<5191ADE4.8040709@signal11.us>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5632252579762698796=="
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <5191ADE4.8040709-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============5632252579762698796==
Content-Type: multipart/alternative; boundary=047d7b62495663e3d404dcd970c2

--047d7b62495663e3d404dcd970c2
Content-Type: text/plain; charset=UTF-8

I've observed this failure with two 'ping -f' between the transceivers.
After some time one of the transceivers will stop transmitting. I've
checked with a sniffer and it doesn't send frames on the air anymore. It
doesn't reply to ACK request neither.

I'm able to reproduce the bug but it may take several minutes to do so.
With this patch, I've been able to flood both transceivers for more than 2
hours. However it would be nice to look deeper into the problem as it
introduces more losses on the link in case of heavy traffic.

The secondary working queue is needed to avoid a lock with the mutexes.
Suppose you have a frame on the air, waiting for its TX interrupt, the
txrx_mutex is locked to avoid reception. At the same time an RX interrupt
is triggered. As everything is done within the same workqueue, the
scheduled work will wait for the end of the transmission. Hence preventing
the expected TX interrupt to be processed. The transmission is locked until
the completion times out.

I must admit that this solution is a bit twisted though and I'd be glad if
anyone comes with a better solution.

David

2013/5/14 Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>

> On 5/9/13 11:19 AM, David Hauweele wrote:
>
>> The transceiver may fail under heavy traffic when a frame is transmitted
>> while receiving another frame.
>>
>> This patch uses a mutex to separate the transmission and reception of
>> frames along with a secondary working queue to avoid a deadlock while
>> waiting for the transmission interrupt.
>>
>>
> Have you observed this failure? I have put this kind of thing in before
> (several times actually) but ultimately convinced myself each time that it
> was not necessary. I'm happy to be shown wrong.
>
>
>
>  Signed-off-by: David Hauweele <david-1EggE+PRa6vk1uMJSBkQmQ@public.gmane.org>
>> ---
>>   drivers/net/ieee802154/**mrf24j40.c |   22 +++++++++++++++++++++-
>>   1 file changed, 21 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ieee802154/**mrf24j40.c
>> b/drivers/net/ieee802154/**mrf24j40.c
>> index ede3ce4..1e3ddf3 100644
>> --- a/drivers/net/ieee802154/**mrf24j40.c
>> +++ b/drivers/net/ieee802154/**mrf24j40.c
>> @@ -82,8 +82,10 @@ struct mrf24j40 {
>>         struct ieee802154_dev *dev;
>>
>>         struct mutex buffer_mutex; /* only used to protect buf */
>> +       struct mutex txrx_mutex; /* avoid transmission while receiving a
>> frame */
>>         struct completion tx_complete;
>>         struct work_struct irqwork;
>> +       struct work_struct rxwork;
>>         u8 *buf; /* 3 bytes. Used for SPI single-register transfers. */
>>   };
>>
>> @@ -353,6 +355,8 @@ static int mrf24j40_tx(struct ieee802154_dev *dev,
>> struct sk_buff *skb)
>>         /* Set TXNACKREQ if the ACK bit is set in the packet. */
>>         if (skb->data[0] & IEEE802154_FC_ACK_REQ)
>>                 val |= 0x4;
>> +
>> +       mutex_lock(&devrec->txrx_**mutex);
>>         write_short_reg(devrec, REG_TXNCON, val);
>>
>>         INIT_COMPLETION(devrec->tx_**complete);
>> @@ -361,6 +365,9 @@ static int mrf24j40_tx(struct ieee802154_dev *dev,
>> struct sk_buff *skb)
>>         ret = wait_for_completion_**interruptible_timeout(
>>                                                 &devrec->tx_complete,
>>                                                 5 * HZ);
>> +
>> +       mutex_unlock(&devrec->txrx_**mutex);
>> +
>>         if (ret == -ERESTARTSYS)
>>                 goto err;
>>         if (ret == 0) {
>> @@ -535,6 +542,8 @@ static int mrf24j40_handle_rx(struct mrf24j40 *devrec)
>>         int ret = 0;
>>         struct sk_buff *skb;
>>
>> +       mutex_lock(&devrec->txrx_**mutex);
>> +
>>         /* Turn off reception of packets off the air. This prevents the
>>          * device from overwriting the buffer while we're reading it. */
>>         ret = read_short_reg(devrec, REG_BBREG1, &val);
>> @@ -575,6 +584,8 @@ out:
>>         val &= ~0x4; /* Clear RXDECINV */
>>         write_short_reg(devrec, REG_BBREG1, val);
>>
>> +       mutex_unlock(&devrec->txrx_**mutex);
>> +
>>         return ret;
>>   }
>>
>> @@ -616,12 +627,19 @@ static void mrf24j40_isrwork(struct work_struct
>> *work)
>>
>>         /* Check for Rx */
>>         if (intstat & 0x8)
>> -               mrf24j40_handle_rx(devrec);
>> +               schedule_work(&devrec->rxwork)**;
>>
>>
> mrf24f40_isrwork() is already called from a workqueue.
>
>
>    out:
>>         enable_irq(devrec->spi->irq);
>>   }
>>
>> +static void mrf24j40_rxwork(struct work_struct *work)
>> +{
>> +       struct mrf24j40 *devrec = container_of(work, struct mrf24j40,
>> rxwork);
>> +
>> +       mrf24j40_handle_rx(devrec);
>> +}
>> +
>>   static int mrf24j40_probe(struct spi_device *spi)
>>   {
>>         int ret = -ENOMEM;
>> @@ -648,8 +666,10 @@ static int mrf24j40_probe(struct spi_device *spi)
>>                 spi->max_speed_hz = MAX_SPI_SPEED_HZ;
>>
>>         mutex_init(&devrec->buffer_**mutex);
>> +       mutex_init(&devrec->txrx_**mutex);
>>         init_completion(&devrec->tx_**complete);
>>         INIT_WORK(&devrec->irqwork, mrf24j40_isrwork);
>> +       INIT_WORK(&devrec->rxwork, mrf24j40_rxwork);
>>         devrec->spi = spi;
>>         spi_set_drvdata(spi, devrec);
>>
>>
>>
>

--047d7b62495663e3d404dcd970c2
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div>I&#39;ve observed this failure with two &#39;ping -f&#39; between the =
transceivers. After some time one of the transceivers will stop transmittin=
g. I&#39;ve checked with a sniffer and it doesn&#39;t send frames on the ai=
r anymore. It doesn&#39;t reply to ACK request neither.</div>
<div><br></div><div>I&#39;m able to reproduce the bug but it may take sever=
al minutes to do so. With this patch, I&#39;ve been able to flood both tran=
sceivers for more than 2 hours. However it would be nice to look deeper int=
o the problem as it introduces more losses on the link in case of heavy tra=
ffic.</div>
<div><br></div><div>The secondary working queue is needed to avoid a lock w=
ith the mutexes. Suppose you have a frame on the air, waiting for its TX in=
terrupt, the txrx_mutex is locked to avoid reception. At the same time an R=
X interrupt is triggered. As everything is done within the same workqueue, =
the scheduled work will wait for the end of the transmission. Hence prevent=
ing the expected TX interrupt to be processed. The transmission is locked u=
ntil the completion times out.=C2=A0</div>
<div><br></div><div>I must admit that this solution is a bit twisted though=
 and I&#39;d be glad if anyone comes with a better solution.</div><div><br>=
</div><div>David</div><br><div class=3D"gmail_quote">2013/5/14 Alan Ott <sp=
an dir=3D"ltr">&lt;<a href=3D"mailto:alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org" target=3D"_blank">al=
an-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org</a>&gt;</span><br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"im">On 5/9/13 11:19 AM, David =
Hauweele wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
The transceiver may fail under heavy traffic when a frame is transmitted<br=
>
while receiving another frame.<br>
<br>
This patch uses a mutex to separate the transmission and reception of<br>
frames along with a secondary working queue to avoid a deadlock while<br>
waiting for the transmission interrupt.<br>
<br>
</blockquote>
<br></div>
Have you observed this failure? I have put this kind of thing in before (se=
veral times actually) but ultimately convinced myself each time that it was=
 not necessary. I&#39;m happy to be shown wrong.<div><div class=3D"h5"><br>

<br>
<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
Signed-off-by: David Hauweele &lt;<a href=3D"mailto:david-1EggE+PRa6vk1uMJSBkQmQ@public.gmane.org" tar=
get=3D"_blank">david-1EggE+PRa6vk1uMJSBkQmQ@public.gmane.org</a>&gt;<br>
---<br>
=C2=A0 drivers/net/ieee802154/<u></u>mrf24j40.c | =C2=A0 22 +++++++++++++++=
++++++-<br>
=C2=A0 1 file changed, 21 insertions(+), 1 deletion(-)<br>
<br>
diff --git a/drivers/net/ieee802154/<u></u>mrf24j40.c b/drivers/net/ieee802=
154/<u></u>mrf24j40.c<br>
index ede3ce4..1e3ddf3 100644<br>
--- a/drivers/net/ieee802154/<u></u>mrf24j40.c<br>
+++ b/drivers/net/ieee802154/<u></u>mrf24j40.c<br>
@@ -82,8 +82,10 @@ struct mrf24j40 {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct ieee802154_dev *dev;<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct mutex buffer_mutex; /* only used to prot=
ect buf */<br>
+ =C2=A0 =C2=A0 =C2=A0 struct mutex txrx_mutex; /* avoid transmission while=
 receiving a frame */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct completion tx_complete;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct work_struct irqwork;<br>
+ =C2=A0 =C2=A0 =C2=A0 struct work_struct rxwork;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 u8 *buf; /* 3 bytes. Used for SPI single-regist=
er transfers. */<br>
=C2=A0 };<br>
<br>
@@ -353,6 +355,8 @@ static int mrf24j40_tx(struct ieee802154_dev *dev, stru=
ct sk_buff *skb)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Set TXNACKREQ if the ACK bit is set in the p=
acket. */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (skb-&gt;data[0] &amp; IEEE802154_FC_ACK_REQ=
)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 val |=3D 0x4;<br>
+<br>
+ =C2=A0 =C2=A0 =C2=A0 mutex_lock(&amp;devrec-&gt;txrx_<u></u>mutex);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 write_short_reg(devrec, REG_TXNCON, val);<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 INIT_COMPLETION(devrec-&gt;tx_<u></u>complete);=
<br>
@@ -361,6 +365,9 @@ static int mrf24j40_tx(struct ieee802154_dev *dev, stru=
ct sk_buff *skb)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D wait_for_completion_<u></u>interruptibl=
e_timeout(<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 &amp;devrec-&gt;tx_complete,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 5 * HZ);<br>
+<br>
+ =C2=A0 =C2=A0 =C2=A0 mutex_unlock(&amp;devrec-&gt;txrx_<u></u>mutex);<br>
+<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ret =3D=3D -ERESTARTSYS)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ret =3D=3D 0) {<br>
@@ -535,6 +542,8 @@ static int mrf24j40_handle_rx(struct mrf24j40 *devrec)<=
br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 int ret =3D 0;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct sk_buff *skb;<br>
<br>
+ =C2=A0 =C2=A0 =C2=A0 mutex_lock(&amp;devrec-&gt;txrx_<u></u>mutex);<br>
+<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Turn off reception of packets off the air. T=
his prevents the<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* device from overwriting the buffer whil=
e we&#39;re reading it. */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D read_short_reg(devrec, REG_BBREG1, &amp=
;val);<br>
@@ -575,6 +584,8 @@ out:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 val &amp;=3D ~0x4; /* Clear RXDECINV */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 write_short_reg(devrec, REG_BBREG1, val);<br>
<br>
+ =C2=A0 =C2=A0 =C2=A0 mutex_unlock(&amp;devrec-&gt;txrx_<u></u>mutex);<br>
+<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;<br>
=C2=A0 }<br>
<br>
@@ -616,12 +627,19 @@ static void mrf24j40_isrwork(struct work_struct *work=
)<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Check for Rx */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (intstat &amp; 0x8)<br>
- =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mrf24j40_handle_rx(devre=
c);<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 schedule_work(&amp;devre=
c-&gt;rxwork)<u></u>;<br>
<br>
</blockquote>
<br></div></div>
mrf24f40_isrwork() is already called from a workqueue.<div class=3D"HOEnZb"=
><div class=3D"h5"><br>
<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
=C2=A0 out:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 enable_irq(devrec-&gt;spi-&gt;irq);<br>
=C2=A0 }<br>
<br>
+static void mrf24j40_rxwork(struct work_struct *work)<br>
+{<br>
+ =C2=A0 =C2=A0 =C2=A0 struct mrf24j40 *devrec =3D container_of(work, struc=
t mrf24j40, rxwork);<br>
+<br>
+ =C2=A0 =C2=A0 =C2=A0 mrf24j40_handle_rx(devrec);<br>
+}<br>
+<br>
=C2=A0 static int mrf24j40_probe(struct spi_device *spi)<br>
=C2=A0 {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 int ret =3D -ENOMEM;<br>
@@ -648,8 +666,10 @@ static int mrf24j40_probe(struct spi_device *spi)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spi-&gt;max_speed_h=
z =3D MAX_SPI_SPEED_HZ;<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 mutex_init(&amp;devrec-&gt;buffer_<u></u>mutex)=
;<br>
+ =C2=A0 =C2=A0 =C2=A0 mutex_init(&amp;devrec-&gt;txrx_<u></u>mutex);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 init_completion(&amp;devrec-&gt;tx_<u></u>compl=
ete);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 INIT_WORK(&amp;devrec-&gt;irqwork, mrf24j40_isr=
work);<br>
+ =C2=A0 =C2=A0 =C2=A0 INIT_WORK(&amp;devrec-&gt;rxwork, mrf24j40_rxwork);<=
br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 devrec-&gt;spi =3D spi;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 spi_set_drvdata(spi, devrec);<br>
<br>
<br>
</blockquote>
<br>
</div></div></blockquote></div><br>

--047d7b62495663e3d404dcd970c2--


--===============5632252579762698796==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
AlienVault Unified Security Management (USM) platform delivers complete
security visibility with the essential security capabilities. Easily and
efficiently configure, manage, and operate all of your security controls
from a single console and one unified framework. Download a free trial.
http://p.sf.net/sfu/alienvault_d2d
--===============5632252579762698796==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linux-zigbee-devel mailing list
Linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel

--===============5632252579762698796==--
