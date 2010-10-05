From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH] net: netif_set_real_num_rx_queues may cap
 num_rx_queues at init time
Date: Tue, 05 Oct 2010 09:08:47 -0700
Message-ID: <4CAB4D8F.8080108@intel.com>
References: <20101004220042.3471.92774.stgit@jf-dev1-dcblab> <1286256926.2457.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"therbert@google.com" <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:21204 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751226Ab0JEQIs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Oct 2010 12:08:48 -0400
In-Reply-To: <1286256926.2457.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/4/2010 10:35 PM, Eric Dumazet wrote:
> Le lundi 04 octobre 2010 =C3=A0 15:00 -0700, John Fastabend a =C3=A9c=
rit :
>> The logic for netif_set_real_num_rx_queues is the following,
>>
>> netif_set_real_num_rx_queues(dev, rxq)
>> {
>> 	...
>> 	if (dev->reg_state =3D=3D NETREG_REGISTERED) {
>> 		...
>> 	} else {
>> 		dev->num_rx_queues =3D rxq;
>> 	}
>>
>> 	dev->real_num_rx_queues =3D rxq;
>> 	return 0;
>> }
>>
>> Some drivers init path looks like the following,
>>
>> alloc_etherdev_mq(priv_sz, max_num_queues_ever);
>> ...
>> netif_set_real_num_rx_queues(dev, queues_to_use_now);
>> ...
>> register_netdev(dev);
>> ...
>>
>> Because netif_set_real_num_rx_queues sets num_rx_queues if the
>> reg state is not NETREG_REGISTERED we end up with the incorrect
>> max number of rx queues. This patch proposes to remove the else
>> clause above so this does not occur.  Also just reading the
>> function set_real_num it seems a bit unexpected that num_rx_queues
>> gets set.
>>
>=20
> You dont tell why its "incorrect".
>=20

OK that is a poor description.

> Why should we keep num_rx_queues > real_num_rx_queues ?
>=20

If we do not ever need them then we should not keep them I agree.
But having netif_set_real_num_rx_queues set something other then
'real_num_rx_queues' does not seem right to me at least. Also
netif_set_real_num_tx_queues and netif_set_real_num_rx_queues have
different behavior. It would be nice if this weren't the case but
they allocate queues in two places.

The drivers Ben modified seem to be split between these two flows

alloc_etherdev_mq(priv_sz, max_num_queues_ever);
register_netdev(dev);
netif_set_real_num_rx_queues(dev, queues_to_use_now);

and

alloc_etherdev_mq(priv_sz, max_num_queues_ever);
netif_set_real_num_rx_queues(dev, queues_to_use_now);
register_netdev(dev);

In the first case we never set 'num_rx_queues' because its after
the register so that leaves the second case. All the remaining
drivers except ixgbe, igb, and myri10ge know or could easily find
out the number of rx queues at alloc_etherdev_mq and are really trying
to explicitly set the num_rx_queues. Adding a num_rx_queues param to
alloc_etherdev_mq might make more sense in this case.

The myri10ge is querying the firmware which seems to be tangled up with
the netdev priv space, but otherwise isn't using any new knowledge. And
ixgbe/igb may end up capping the max number of queues because it is
trying to set the number of queues it intends to use now not the max it
will ever consume.

My point with this patch is I do not see any cases where we really do
not know the max number rx queues until after alloc_etherdev_mq() but b=
efore
register_netdev(). The piece I missed is if a driver wants to set rx qu=
eues
and tx queues separately they either need to explicitly set rx_num_queu=
es or
use netif_set_real_num_rx_queues before registering the netdev. This sy=
ntax
seems error prone to me, and it would be better to set this in alloc_et=
herdev_mq().
But, maybe you disagree?

So I can either go rework the ixgbe/igb init flow so it does what I wan=
t.
Or add a parameter to alloc_etherdev_mq for rx queues, remove the
netif_set_real_num_rx_queues where it is not needed and modify the driv=
ers
to use this interface. I like the second case because it makes the
netif_set_real_num_[rx|tx}_queues() behave the same but could do the fi=
rst
just as easily.

Thanks,
John=20

> It creates /sys files, and Qdisc stuff for nothing...
>=20
>=20
>=20
>> CC: Ben Hutchings <bhutchings@solarflare.com>
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>
>>  net/core/dev.c |    2 --
>>  1 files changed, 0 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index a313bab..f78d996 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -1592,8 +1592,6 @@ int netif_set_real_num_rx_queues(struct net_de=
vice *dev, unsigned int rxq)
>>  						  rxq);
>>  		if (rc)
>>  			return rc;
>> -	} else {
>> -		dev->num_rx_queues =3D rxq;
>>  	}
>> =20
>>  	dev->real_num_rx_queues =3D rxq;
>>
>> --
>=20
>=20

