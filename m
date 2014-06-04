From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v3 2/4] net: Allow for more then a single subclass for
 netif_addr_lock
Date: Wed, 04 Jun 2014 19:17:33 -0400
Message-ID: <538FA90D.3050307@gmail.com>
References: <1400274296-14765-1-git-send-email-vyasevic@redhat.com>	 <1400274296-14765-3-git-send-email-vyasevic@redhat.com> <1401918131.24086.9.camel@jekeller-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dingtianhong@huawei.com" <dingtianhong@huawei.com>,
	"vfalico@gmail.com" <vfalico@gmail.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"jiri@resnulli.us" <jiri@resnulli.us>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:52792 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbaFDXRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 19:17:36 -0400
Received: by mail-qa0-f51.google.com with SMTP id w8so296807qac.24
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2014 16:17:36 -0700 (PDT)
In-Reply-To: <1401918131.24086.9.camel@jekeller-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/2014 05:42 PM, Keller, Jacob E wrote:
> On Fri, 2014-05-16 at 17:04 -0400, Vlad Yasevich wrote:
>> Currently netif_addr_lock_nested assumes that there can be only
>> a single nesting level between 2 devices.  However, if we
>> have multiple devices of the same type stacked, this fails.
>> For example:
>>  eth0 <-- vlan0.10 <-- vlan0.10.20
>>
>> A more complicated configuration may stack more then one type of
>> device in different order.
>> Ex:
>>   eth0 <-- vlan0.10 <-- macvlan0 <-- vlan1.10.20 <-- macvlan1
>>
>> This patch adds an ndo_* function that allows each stackable
>> device to report its nesting level.  If the device doesn't
>> provide this function default subclass of 1 is used.
>>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> ---
>>  include/linux/netdevice.h | 8 +++++++-
>>  1 file changed, 7 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index fb912e8..9d4b1f1 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -1144,6 +1144,7 @@ struct net_device_ops {
>>  	netdev_tx_t		(*ndo_dfwd_start_xmit) (struct sk_buff *skb,
>>  							struct net_device *dev,
>>  							void *priv);
>> +	int			(*ndo_get_lock_subclass)(struct net_device *dev);
>>  };
>> =20
>>  /**
>> @@ -2950,7 +2951,12 @@ static inline void netif_addr_lock(struct net=
_device *dev)
>> =20
>>  static inline void netif_addr_lock_nested(struct net_device *dev)
>>  {
>> -	spin_lock_nested(&dev->addr_list_lock, SINGLE_DEPTH_NESTING);
>> +	int subclass =3D SINGLE_DEPTH_NESTING;
>> +
>> +	if (dev->netdev_ops->ndo_get_lock_subclass)
>> +		subclass =3D dev->netdev_ops->ndo_get_lock_subclass(dev);
>> +
>> +	spin_lock_nested(&dev->addr_list_lock, subclass);
>>  }
>> =20
>=20
> Hi,
>=20
> I know this has already been applied. However, this commit causes a
> warning in include/linux/netdevice.h when W=3D1
>=20
> In file included from ixgbe/ixgbe.h:35:0,
>                  from ixgbe/ixgbe_lib.c:29:
> include/linux/netdevice.h: In function =E2=80=98netif_addr_lock_neste=
d=E2=80=99:
> include/linux/netdevice.h:2954:6: warning: variable =E2=80=98subclass=
=E2=80=99 set but not used [-Wunused-but-set-variable]
>   int subclass =3D SINGLE_DEPTH_NESTING;
>       ^
>=20
> This only occurs if CONFIG_DEBUG_LOCK_ALLOC=3DY, and there seems to b=
e no
> easy fix for the warning, due to how spin_lock_nested is a macro that
> discards the second parameter when DEBUG_LOCK_ALLOC is disabled.
>=20
> I'm not sure how big a deal this is, considering that it only occurs =
at
> W=3D1, and the patch is already committed.
>=20

Yuck.  It's actually raw_spin_lock_nested() macro that discards the
subclass argument...

We could do something really silly like:

# define raw_spin_lock_nested(lock, subclass) \
                             sublcass;_raw_spin_lock(lock)

That seems to get rid of the warning for me.

-vlad

>>  static inline void netif_addr_lock_bh(struct net_device *dev)
>=20
> Regards,
> Jake
>=20
> N=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BDr=EF=BF=BD=EF=BF=BDy=EF=
=BF=BD=EF=BF=BD=EF=BF=BDb=EF=BF=BDX=EF=BF=BD=EF=BF=BD=C7=A7v=EF=BF=BD^=EF=
=BF=BD)=DE=BA{.n=EF=BF=BD+=EF=BF=BD=EF=BF=BD=EF=BF=BDz=EF=BF=BD^=EF=BF=BD=
)=EF=BF=BD=EF=BF=BD=EF=BF=BDw*=1Fjg=EF=BF=BD=EF=BF=BD=EF=BF=BD=1E=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=DD=A2j/=EF=BF=BD=EF=BF=BD=EF=BF=
=BDz=EF=BF=BD=DE=96=EF=BF=BD=EF=BF=BD2=EF=BF=BD=DE=99=EF=BF=BD=EF=BF=BD=
=EF=BF=BD&=EF=BF=BD)=DF=A1=EF=BF=BDa=EF=BF=BD=EF=BF=BD=7F=EF=BF=BD=EF=BF=
=BD=1E=EF=BF=BDG=EF=BF=BD=EF=BF=BD=EF=BF=BDh=EF=BF=BD=0F=EF=BF=BDj:+v=EF=
=BF=BD=EF=BF=BD=EF=BF=BDw=EF=BF=BD=D9=A5
>=20
