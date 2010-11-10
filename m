From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-2.6 1/3] vlan: Add function to retrieve EtherType from
 vlan packets.
Date: Tue, 9 Nov 2010 23:18:26 -0800
Message-ID: <AANLkTinpdqhqRwNQ8mqsYcr5QM6y-OJwXOZPz7tg-R93@mail.gmail.com>
References: <1289351344-14340-1-git-send-email-jesse@nicira.com>
	<20101109215412.38412cff@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Hao Zheng <hzheng@nicira.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38755 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752901Ab0KJHS2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 02:18:28 -0500
Received: by wyb36 with SMTP id 36so339731wyb.19
        for <netdev@vger.kernel.org>; Tue, 09 Nov 2010 23:18:27 -0800 (PST)
In-Reply-To: <20101109215412.38412cff@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 9, 2010 at 9:54 PM, Stephen Hemminger <shemminger@vyatta.co=
m> wrote:
> On Tue, =A09 Nov 2010 17:09:02 -0800
> Jesse Gross <jesse@nicira.com> wrote:
>
>> From: Hao Zheng <hzheng@nicira.com>
>>
>> Depending on how a packet is vlan tagged (i.e. hardware accelerated =
or
>> not), the encapsulated protocol is stored in different locations. =A0=
This
>> provides a consistent method of accessing that protocol, which is ne=
eded
>> by drivers, security checks, etc.
>>
>> Signed-off-by: Hao Zheng <hzheng@nicira.com>
>> Signed-off-by: Jesse Gross <jesse@nicira.com>
>> ---
>> =A0include/linux/if_vlan.h | =A0 20 ++++++++++++++++++++
>> =A01 files changed, 20 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
>> index c2f3a72..ee06c52 100644
>> --- a/include/linux/if_vlan.h
>> +++ b/include/linux/if_vlan.h
>> @@ -339,6 +339,26 @@ static inline int vlan_get_tag(const struct sk_=
buff *skb, u16 *vlan_tci)
>> =A0 =A0 =A0 }
>> =A0}
>>
>> +/**
>> + * vlan_get_protocol - get protocol EtherType.
>> + * @skb: skbuff to query
>> + *
>> + * Returns the EtherType of the packet, regardless of whether it is
>> + * vlan encapsulated (normal or hardware accelerated) or not.
>> + */
>> +static inline __be16 vlan_get_protocol(struct sk_buff *skb)
>> +{
>> + =A0 =A0 __be16 protocol =3D 0;
>> +
>> + =A0 =A0 if (vlan_tx_tag_present(skb) ||
>> + =A0 =A0 =A0 =A0 =A0skb->protocol !=3D cpu_to_be16(ETH_P_8021Q))
>> + =A0 =A0 =A0 =A0 =A0 =A0 protocol =3D skb->protocol;
>> + =A0 =A0 else if (likely(pskb_may_pull(skb, VLAN_ETH_HLEN)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 protocol =3D ((const struct vlan_ethhdr *)=
skb->data)->
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0h_vlan_encapsulated=
_proto;
>> +
>> + =A0 =A0 return protocol;
>> +}
>
> This this calls pskb_may_pull, which modifies the skb data
> offsets and therefore could invalidate any callers pointers
> to ip header or other fields.
> Therefore you will need to audit all callers of this function!

That's a good point.  I switched it to use skb_header_pointer()
instead, which is probably more efficient anyways and avoids the
potential for a problem.

>
> Also, your code doesn't handle the case of too small a frame (VLAN he=
ader only).

The goal is to get equivalence to checking skb->protocol, except to
handle vlan accelerated vs non-accelerated consistently.  In this
case, the caller would need to check the length of the protocol header
as appropriate.  If the packet claims to be a vlan frame and the
length is less than the size of a vlan header then we'll return 0,
which should be sufficient to avoid any protocol processing.

Thanks.
