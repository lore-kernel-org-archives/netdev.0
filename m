From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 3/3] net: allocate tx queues in register_netdevice
Date: Mon, 18 Oct 2010 17:17:41 -0700
Message-ID: <AANLkTinX+2aW_yDa0o=oiaxt6BJGNWjiifGCS7auz0O9@mail.gmail.com>
References: <alpine.DEB.1.00.1010181057580.16304@pokey.mtv.corp.google.com>
	<1287438080.2252.792.camel@achroite.uk.solarflarecom.com>
	<4CBCE26E.4020405@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:19792 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187Ab0JSARo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 20:17:44 -0400
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o9J0HgmE009066
	for <netdev@vger.kernel.org>; Mon, 18 Oct 2010 17:17:42 -0700
Received: from pwi1 (pwi1.prod.google.com [10.241.219.1])
	by kpbe17.cbf.corp.google.com with ESMTP id o9J0Hfuh001593
	for <netdev@vger.kernel.org>; Mon, 18 Oct 2010 17:17:41 -0700
Received: by pwi1 with SMTP id 1so410122pwi.35
        for <netdev@vger.kernel.org>; Mon, 18 Oct 2010 17:17:41 -0700 (PDT)
In-Reply-To: <4CBCE26E.4020405@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 18, 2010 at 5:12 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> On 10/18/2010 2:41 PM, Ben Hutchings wrote:
>> On Mon, 2010-10-18 at 11:02 -0700, Tom Herbert wrote:
>>> This patch introduces netif_alloc_netdev_queues which is called fro=
m
>>> register_device instead of alloc_netdev_mq. =A0This makes TX queue
>>> allocation symmetric with RX allocation similarly allows drivers to
>>> change dev->num_tx_queues after allocating netdev and before
>>> registering it.
>>
>> Changing num_tx_queues is probably *not* desirable, same as for
>> num_rx_queues.
>>

Okay, so both netif_set_real_num_rx_queues and
netif_set_real_num_tx_queues should return -EINVAL if queue count >
num_[tr]x_queues?

>
> Right, this will break ixgbe and other drivers that may call netif_se=
t_real_num_{rx|tx}_queues() to increase the number of
> queues. Returning an error code seems like a good idea though.
>
> John.
>
>> [...]
>>> --- a/net/core/dev.c
>>> +++ b/net/core/dev.c
>>> @@ -1553,18 +1553,24 @@ static void dev_queue_xmit_nit(struct sk_bu=
ff *skb, struct net_device *dev)
>>> =A0 * Routine to help set real_num_tx_queues. To avoid skbs mapped =
to queues
>>> =A0 * greater then real_num_tx_queues stale skbs on the qdisc must =
be flushed.
>>> =A0 */
>>> -void netif_set_real_num_tx_queues(struct net_device *dev, unsigned=
 int txq)
>>> +int netif_set_real_num_tx_queues(struct net_device *dev, unsigned =
int txq)
>>> =A0{
>>> - =A0 =A0unsigned int real_num =3D dev->real_num_tx_queues;
>>> + =A0 =A0if (txq < 1)
>>> + =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
>>>
>>> - =A0 =A0if (unlikely(txq > dev->num_tx_queues))
>>> - =A0 =A0 =A0 =A0 =A0 =A0;
>>> - =A0 =A0else if (txq > real_num)
>>> - =A0 =A0 =A0 =A0 =A0 =A0dev->real_num_tx_queues =3D txq;
>>> - =A0 =A0else if (txq < real_num) {
>>> - =A0 =A0 =A0 =A0 =A0 =A0dev->real_num_tx_queues =3D txq;
>>> - =A0 =A0 =A0 =A0 =A0 =A0qdisc_reset_all_tx_gt(dev, txq);
>>> - =A0 =A0}
>>> + =A0 =A0if (dev->reg_state =3D=3D NETREG_REGISTERED) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0ASSERT_RTNL();
>>> +
>>> + =A0 =A0 =A0 =A0 =A0 =A0if (txq > dev->num_tx_queues)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
>>> +
>>> + =A0 =A0 =A0 =A0 =A0 =A0if (txq < dev->real_num_tx_queues)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0qdisc_reset_all_tx_gt(dev,=
 txq);
>>> + =A0 =A0} else
>>> + =A0 =A0 =A0 =A0 =A0 =A0dev->num_tx_queues =3D txq;
>> [...]
>>
>> The kernel-doc comment should be updated to reflect the locking
>> requirement and the possibility of failure when called after
>> registration.
>>
>> Ben.
>>
>
>
