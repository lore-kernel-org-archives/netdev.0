From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [PATCH v12 10/17] Add a hook to intercept external buffers from
 NIC driver.
Date: Mon, 11 Oct 2010 15:06:52 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D793064B2A9DA@shsmsx502.ccr.corp.intel.com>
References: <1285855474-12110-1-git-send-email-xiaohui.xin@intel.com>
	 <fda262fa746dfc1feb8543cf88d5ecf60001c186.1285853725.git.xiaohui.xin@intel.com>
 <1285856533.2615.573.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1285856533.2615.573.camel@edumazet-laptop>
Content-Language: en-US
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
>Sent: Thursday, September 30, 2010 10:22 PM
>To: Xin, Xiaohui
>Cc: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.ker=
nel.org;
>mst@redhat.com; mingo@elte.hu; davem@davemloft.net; herbert@gondor.apa=
na.org.au;
>jdike@linux.intel.com
>Subject: Re: [PATCH v12 10/17] Add a hook to intercept external buffer=
s from NIC driver.
>
>Le jeudi 30 septembre 2010 =E0 22:04 +0800, xiaohui.xin@intel.com a
>=E9crit :
>> From: Xin Xiaohui <xiaohui.xin@intel.com>
>>
>> The hook is called in netif_receive_skb().
>> Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
>> Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
>> Reviewed-by: Jeff Dike <jdike@linux.intel.com>
>> ---
>>  net/core/dev.c |   35 +++++++++++++++++++++++++++++++++++
>>  1 files changed, 35 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index c11e32c..83172b8 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2517,6 +2517,37 @@ err:
>>  EXPORT_SYMBOL(netdev_mp_port_prep);
>>  #endif
>>
>> +#if defined(CONFIG_MEDIATE_PASSTHRU) ||
>defined(CONFIG_MEDIATE_PASSTHRU_MODULE)
>> +/* Add a hook to intercept mediate passthru(zero-copy) packets,
>> + * and insert it to the socket queue owned by mp_port specially.
>> + */
>> +static inline struct sk_buff *handle_mpassthru(struct sk_buff *skb,
>> +					       struct packet_type **pt_prev,
>> +					       int *ret,
>> +					       struct net_device *orig_dev)
>> +{
>> +	struct mp_port *mp_port =3D NULL;
>> +	struct sock *sk =3D NULL;
>> +
>> +	if (!dev_is_mpassthru(skb->dev))
>> +		return skb;
>> +	mp_port =3D skb->dev->mp_port;
>> +
>> +	if (*pt_prev) {
>> +		*ret =3D deliver_skb(skb, *pt_prev, orig_dev);
>> +		*pt_prev =3D NULL;
>> +	}
>> +
>> +	sk =3D mp_port->sock->sk;
>> +	skb_queue_tail(&sk->sk_receive_queue, skb);
>> +	sk->sk_state_change(sk);
>> +
>> +	return NULL;
>> +}
>> +#else
>> +#define handle_mpassthru(skb, pt_prev, ret, orig_dev)     (skb)
>> +#endif
>> +
>>  /**
>>   *	netif_receive_skb - process receive buffer from network
>>   *	@skb: buffer to process
>> @@ -2598,6 +2629,10 @@ int netif_receive_skb(struct sk_buff *skb)
>>  ncls:
>>  #endif
>>
>> +	/* To intercept mediate passthru(zero-copy) packets here */
>> +	skb =3D handle_mpassthru(skb, &pt_prev, &ret, orig_dev);
>> +	if (!skb)
>> +		goto out;
>>  	skb =3D handle_bridge(skb, &pt_prev, &ret, orig_dev);
>>  	if (!skb)
>>  		goto out;
>
>This does not apply to current net-next-2.6
>
>We now have dev->rx_handler (currently for bridge or macvlan)
>
>
Ok. Thanks, will rebase to fix that.

Thanks
Xiaohui

>commit ab95bfe01f9872459c8678572ccadbf646badad0
>Author: Jiri Pirko <jpirko@redhat.com>
>Date:   Tue Jun 1 21:52:08 2010 +0000
>
>    net: replace hooks in __netif_receive_skb V5
>
>    What this patch does is it removes two receive frame hooks (for br=
idge and for
>    macvlan) from __netif_receive_skb. These are replaced them with a =
single
>    hook for both. It only supports one hook per device because it mak=
es no
>    sense to do bridging and macvlan on the same device.
>
>    Then a network driver (of virtual netdev like macvlan or bridge) c=
an register
>    an rx_handler for needed net device.
>
>    Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>    Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>    Signed-off-by: David S. Miller <davem@davemloft.net>
>
>

