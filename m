From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH] net: Handle gso packets in dev_forward_skb
Date: Tue, 29 Mar 2011 14:54:43 +0200
Message-ID: <4D91D693.1070202@free.fr>
References: <m1wrjsi2tf.fsf@fess.ebiederm.org>	 <1300743744.2837.7.camel@edumazet-laptop>	 <m1hbawi15z.fsf@fess.ebiederm.org>	 <20110327.180922.59673799.davem@davemloft.net> <1301340048.2506.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, ebiederm@xmission.com,
	netdev@vger.kernel.org, greearb@candelatech.com, arnd@arndb.de,
	kaber@trash.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:53502 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753436Ab1C2Myx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Mar 2011 08:54:53 -0400
In-Reply-To: <1301340048.2506.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/28/2011 09:20 PM, Eric Dumazet wrote:
> Le dimanche 27 mars 2011 =C3=A0 18:09 -0700, David Miller a =C3=A9cri=
t :
>> From: ebiederm@xmission.com (Eric W. Biederman)
>> Date: Mon, 21 Mar 2011 15:00:56 -0700
>>
>>> Eric Dumazet<eric.dumazet@gmail.com>  writes:
>>>
>>>> Hmm, did you follow http://patchwork.ozlabs.org/patch/86815/
>>>> discussion ?
>>> No.  It seems I missed it, but I do have the same problem, and
>>> essentially the same fix.
>> Can someone work on getting this straightened out and resubmit the
>> final patch so I can apply something?
>>
> Apparently Daniel is busy.

Yes, sorry for the delay.
I would like to fix it but I am not sure to understand the different=20
solutions proposed.

On 03/28/2011 09:20 PM, Eric Dumazet wrote:
> Le dimanche 27 mars 2011 =C3=A0 18:09 -0700, David Miller a =C3=A9cri=
t :
>> From: ebiederm@xmission.com (Eric W. Biederman)
>> Date: Mon, 21 Mar 2011 15:00:56 -0700
>>
>>> Eric Dumazet<eric.dumazet@gmail.com>  writes:
>>>
>>>> Hmm, did you follow http://patchwork.ozlabs.org/patch/86815/
>>>> discussion ?
>>> No.  It seems I missed it, but I do have the same problem, and
>>> essentially the same fix.
>> Can someone work on getting this straightened out and resubmit the
>> final patch so I can apply something?
>>
> Apparently Daniel is busy.

Yes, sorry for the delay.
I would like to fix it, but my knowledge in limited on offloading.

I did the following patch, it fixes the problem. If it looks good I can=
=20
resend it in patch format:

Index: net-2.6/net/core/dev.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- net-2.6.orig/net/core/dev.c 2011-03-29 14:50:00.047646000 +0200
+++ net-2.6/net/core/dev.c      2011-03-29 14:50:35.587646000 +0200
@@ -1454,6 +1454,27 @@ static inline void net_timestamp_check(s
                 __net_timestamp(skb);
  }

+static inline bool is_skb_forwardable(struct net_device *dev,
+                                     struct sk_buff *skb)
+{
+       unsigned int len;
+
+       if (!(dev->flags & IFF_UP))
+               return false;
+
+       len =3D dev->mtu + dev->hard_header_len + VLAN_HLEN;
+       if (skb->len <=3D len)
+               return true;
+
+       /* if TSO is enabled, we don't care about the length as the pac=
ket
+        * could be forwarded without being segmented before
+        */
+       if (skb_is_gso(skb))
+               return true;
+
+       return false;
+}
+
  /**
   * dev_forward_skb - loopback an skb to another netif
   *
@@ -1477,8 +1498,7 @@ int dev_forward_skb(struct net_device *d
         skb_orphan(skb);
         nf_reset(skb);

-       if (unlikely(!(dev->flags & IFF_UP) ||
-                    (skb->len > (dev->mtu + dev->hard_header_len +=20
VLAN_HLEN)))) {
+       if (unlikely(!is_skb_forwardable(dev, skb))) {
                 atomic_long_inc(&dev->rx_dropped);
                 kfree_skb(skb);
                 return NET_RX_DROP;

