From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: [net-next 5/5] ixgbe: convert to ndo_fix_features
Date: Tue, 12 Jul 2011 15:11:52 -0700
Message-ID: <C0716E470783B24A8178C9E38CD2F34505E768E5@orsmsx509.amr.corp.intel.com>
References: <1310212240-24623-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1310212240-24623-6-git-send-email-jeffrey.t.kirsher@intel.com>
 <20110709121108.GA7720@rere.qmqm.pl>
 <C0716E470783B24A8178C9E38CD2F34505DF1B3F@orsmsx509.amr.corp.intel.com>
 <20110712100932.GA6433@rere.qmqm.pl>
 <C0716E470783B24A8178C9E38CD2F34505E7682C@orsmsx509.amr.corp.intel.com>
 <20110712214445.GA14904@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Michal Miroslaw <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:60881 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755451Ab1GLWMH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 18:12:07 -0400
In-Reply-To: <20110712214445.GA14904@rere.qmqm.pl>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Michal Miroslaw [mailto:mirq-linux@rere.qmqm.pl]
>Sent: Tuesday, July 12, 2011 2:45 PM
>To: Skidmore, Donald C
>Cc: Kirsher, Jeffrey T; davem@davemloft.net; netdev@vger.kernel.org;
>gospo@redhat.com
>Subject: Re: [net-next 5/5] ixgbe: convert to ndo_fix_features
>
>Good to see the idea converging. :) More hints below.
>
>On Tue, Jul 12, 2011 at 02:28:15PM -0700, Skidmore, Donald C wrote:
>[...]
>> The logic in this conditional is a little complex. I believe it woul=
d
>> end up looking something like the following:
>>
>> in fix_features:
>>
>> 	/* Prevent change if not RSC capable or invalid ITR setting */
>> 	if (data & NETIF_F_LRO)
>
>That's not a fast path - you can drop (data & NETIF_F_LRO) check.

Nice - I was spending too much time looking at the old code didn't noti=
ce this.

>
>> 		if (!(adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE) {
>> 			data &=3D ~NETIF_F_LRO;
>> 		else if (!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) &&
>> 	    		   (adapter->rx_itr_setting !=3D 1 &&
>> 			    adapter->rx_itr_setting > IXGBE_MAX_RSC_INT_RATE))
>{
>> 				data &=3D ~NETIF_F_LRO;
>> 		}
>> 	}
>
>Same for !(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED). After this
>change,
>you might add a call to netdev_update_features() whenever the second
>part
>of the condition is changed by user and you get correctness all the ti=
me
>'for free'.

I like this too and makes much more sense to me.  This was a reflection=
 of the original code but really didn't matter since anytime RSC_ENABLE=
D was set the ITR values would have been correct anyway.
  =20
>
>> in set_feature:
>>
>> 	/* Make sure RSC matches LRO, reset if change */
>> 	if (!!(data & NETIF_F_LRO) !=3D
>> 	    !!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)) {
>> 		adapter->flags2 ^=3D IXGBE_FLAG2_RSC_ENABLED;
>> 		switch (adapter->hw.mac.type) {
>> 		case ixgbe_mac_X540:
>> 		case ixgbe_mac_82599EB:
>> 			need_reset =3D true;
>> 			break;
>> 		default:
>> 			break;
>> 		}
>> 	}
>
>Correct. Why would you need IXGBE_FLAG2_RSC_ENABLED now, when it just
>mirrors NETIF_F_LRO?
>

We currently have a lot of checks for the IXGBE_FLAG2_RSC_ENABLED flag =
all over the code.  I bet your next question is why not just using NETI=
=46_F_LRO. :)  Well this same code base is used in our source forge dri=
ver that has to be backward compatible with older kernels.  It might be=
 possible to do the kcompat magic to make it all work out but it won't =
be trivial and I didn't want to include it in this patch.  I had planne=
d on looking at it in the future to see if it was possible/worth doing.=
=20

>[...]
>> Thanks again for the clarifications, the netdev-features.txt helped =
a
>lot too.
>
>Nice to hear (read) that!
>
>Best Regards,
>Micha=B3 Miros=B3aw

I'll try to get a patch out soon.

Thanks again,
-Don Skidmore <donald.c.skidmore@intel.com>
