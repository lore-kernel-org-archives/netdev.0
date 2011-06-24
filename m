From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 07/12] ixgbe: add support for modifying UDP RSS flow
 hash options
Date: Thu, 23 Jun 2011 20:57:51 -0700
Message-ID: <BANLkTi=-DjyeT7-KMFpuGY=4MGVA-uSXQg@mail.gmail.com>
References: <1308793476-11596-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1308793476-11596-8-git-send-email-jeffrey.t.kirsher@intel.com>
	<1308795900.3093.713.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56823 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563Ab1FXD5x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 23:57:53 -0400
Received: by fxm17 with SMTP id 17so1640922fxm.19
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2011 20:57:51 -0700 (PDT)
In-Reply-To: <1308795900.3093.713.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2011 at 19:25, Ben Hutchings <bhutchings@solarflare.com=
> wrote:
> On Wed, 2011-06-22 at 18:44 -0700, Jeff Kirsher wrote:
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>>
>> This patch adds the ability to add or remove the UDP source and dest=
ination
>> ports from the flow hash generated for RSS. =C2=A0Currently the UDP =
flow hash is
>> always disabled. =C2=A0By adding support for enabling the UDP flow h=
ash we are
>> now providing the option of generating an RSS hash based on the UDP =
source
>> and destination port numbers.
> [...]
>> --- a/drivers/net/ixgbe/ixgbe_ethtool.c
>> +++ b/drivers/net/ixgbe/ixgbe_ethtool.c
> [...]
>> @@ -2681,6 +2726,110 @@ static int ixgbe_del_ethtool_fdir_entry(stru=
ct ixgbe_adapter *adapter,
>> =C2=A0 =C2=A0 =C2=A0 return err;
>> =C2=A0}
>>
>> +#define UDP_RSS_FLAGS (IXGBE_FLAG2_RSS_FIELD_IPV4_UDP | \
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0IXGBE_FLAG2_RSS_FIELD_IPV6_UDP)
>> +static int ixgbe_set_rss_hash_opt(struct ixgbe_adapter *adapter,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct ethtool_rxnfc *nfc)
>> +{
>> + =C2=A0 =C2=A0 u32 flags2 =3D adapter->flags2;
>> +
>> + =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0* RSS does not support anything other than has=
hing
>> + =C2=A0 =C2=A0 =C2=A0* to queues on src and dst IPs and ports
>> + =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 if (nfc->data & ~(RXH_IP_SRC | RXH_IP_DST |
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 RXH_L4_B_0_1 | RXH_L4_B_2_3))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EINVAL;
>> +
>> + =C2=A0 =C2=A0 switch (nfc->flow_type) {
>> + =C2=A0 =C2=A0 case TCP_V4_FLOW:
>> + =C2=A0 =C2=A0 case TCP_V6_FLOW:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!(nfc->data & RXH_IP=
_SRC) ||
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 !(nfc->dat=
a & RXH_IP_DST) ||
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 !(nfc->dat=
a & RXH_L4_B_0_1) ||
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 !(nfc->dat=
a & RXH_L4_B_2_3))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 return -EINVAL;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>
> This can be written as a simple equality test.
>
>> + =C2=A0 =C2=A0 case UDP_V4_FLOW:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!(nfc->data & RXH_IP=
_SRC) ||
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 !(nfc->dat=
a & RXH_IP_DST))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 return -EINVAL;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 switch (nfc->data & (RXH=
_L4_B_0_1 | RXH_L4_B_2_3)) {
>
> You could just as well include all flags in the switch.
>
> [...]
>> + =C2=A0 =C2=A0 case AH_ESP_V4_FLOW:
>> + =C2=A0 =C2=A0 case AH_V4_FLOW:
>> + =C2=A0 =C2=A0 case ESP_V4_FLOW:
>> + =C2=A0 =C2=A0 case SCTP_V4_FLOW:
>> + =C2=A0 =C2=A0 case AH_ESP_V6_FLOW:
>> + =C2=A0 =C2=A0 case AH_V6_FLOW:
>> + =C2=A0 =C2=A0 case ESP_V6_FLOW:
>> + =C2=A0 =C2=A0 case SCTP_V6_FLOW:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!(nfc->data & RXH_IP=
_SRC) ||
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 !(nfc->dat=
a & RXH_IP_DST))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 return -EINVAL;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> [...]
>
> This should be written as an equality test, otherwise you will ignore=
 a
> request to include port numbers in the hash for these flow classes.
>
> Ben.
>
>

Alex is on vacation currently, so I will just pull this patch for now
to give Alex time to respond when he returns next week.

--=20
Cheers,
Jeff
