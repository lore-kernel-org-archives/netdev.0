From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 09/12] net: dsa: add Broadcom tag RX/TX handler
Date: Sun, 24 Aug 2014 19:37:12 -0700
Message-ID: <53FAA158.6050600@gmail.com>
References: <1408905869-10471-1-git-send-email-f.fainelli@gmail.com> <1408905869-10471-10-git-send-email-f.fainelli@gmail.com> <53FA6C55.5040903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, jhs@mojatatu.com, linville@tuxdriver.com,
	alexander.h.duyck@intel.com
To: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:60455 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753748AbaHYChO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 22:37:14 -0400
Received: by mail-oa0-f45.google.com with SMTP id i7so10371022oag.32
        for <netdev@vger.kernel.org>; Sun, 24 Aug 2014 19:37:14 -0700 (PDT)
In-Reply-To: <53FA6C55.5040903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/08/2014 15:51, Alexander Duyck a =E9crit :
> On 08/24/2014 11:44 AM, Florian Fainelli wrote:
>> Add support for the 4-bytes Broadcom tag that built-in switches such=
 as
>> the Starfighter 2 might insert when receiving packets, or that we ne=
ed
>> to insert while targetting specific switch ports. We use a fake
>> EtherType field for this 4-bytes switch tag: ETH_P_BRCMTAG since we =
need
>> to use the skb->protocol override in the receive path.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>> Changes in v3:
>> - add ETH_P_BRCMTAG as part of this changeset and not in a previous =
patch
>> - fixed an early de-reference in the receive hook
>
> I was just wondering.  Is there a reason we need to register this as =
yet
> another protocol?

=46or the broadcom tag format, not specifically no, this is mostly so i=
t=20
looks like what has been done so far, but since this is not a real=20
ethertype, there is no need for this.

>
> It seems like we should be able to just register one DSA tag protocol
> and then we could push the parsing function out to a function pointer
> contained in the DSA switch structure.  My concern is that as we add
> each new switch message format we are looking at the potential for ye=
t
> another Ethertype and they are a limited resource.
>
> So for example in the section below you already have to dig out the
> dsa_switch structure and tree before you even start processing the
> headers.
>
>> +
>> +static int brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev=
,
>> +			struct packet_type *pt, struct net_device *orig_dev)
>> +{
>> +	struct dsa_switch_tree *dst =3D dev->dsa_ptr;
>> +	struct dsa_switch *ds;
>> +	int source_port;
>> +	u8 *brcm_tag;
>> +
>> +	if (unlikely(dst =3D=3D NULL))
>> +		goto out_drop;
>> +
>> +	ds =3D dst->ds[0];
>> +
>> +	skb =3D skb_unshare(skb, GFP_ATOMIC);
>> +	if (skb =3D=3D NULL)
>> +		goto out;
>
> At this point here we already have the dsa pointers and could just pu=
ll
> up a function pointer so all of the code below could potentially be
> moved into a separate function allowing us to drop the need to have
> multiple Ethertypes and so we could just use ETH_P_DSA for all DSA
> tagging type.

I see, or rather maybe just use ETH_P_EDSA which is a real assigned=20
ethertype?
--
=46lorian
