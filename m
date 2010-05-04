From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v2] ethernet: call __skb_pull() in eth_type_trans()
Date: Tue, 4 May 2010 10:34:07 +0800
Message-ID: <h2h412e6f7f1005031934m971342dw965e046d40485ec7@mail.gmail.com>
References: <1272895972-13799-1-git-send-email-xiaosuo@gmail.com>
	<20100503.125404.134122628.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:39452 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751402Ab0EDCe1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 22:34:27 -0400
Received: by pzk42 with SMTP id 42so524580pzk.4
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 19:34:27 -0700 (PDT)
In-Reply-To: <20100503.125404.134122628.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 4, 2010 at 3:54 AM, David Miller <davem@davemloft.net> wrot=
e:
> From: Changli Gao <xiaosuo@gmail.com>
> Date: Mon, =C2=A03 May 2010 22:12:52 +0800
>
>> @@ -162,7 +162,10 @@ __be16 eth_type_trans(struct sk_buff *skb, stru=
ct net_device *dev)
>>
>> =C2=A0 =C2=A0 =C2=A0 skb->dev =3D dev;
>> =C2=A0 =C2=A0 =C2=A0 skb_reset_mac_header(skb);
>> - =C2=A0 =C2=A0 skb_pull_inline(skb, ETH_HLEN);
>> + =C2=A0 =C2=A0 if (unlikely(skb->len < ETH_ZLEN))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_warn(&dev->dev, "too=
 small ethernet packet: %u bytes\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0skb->len);
>> + =C2=A0 =C2=A0 __skb_pull(skb, ETH_HLEN);
>> =C2=A0 =C2=A0 =C2=A0 eth =3D eth_hdr(skb);
>
> And now it's even more expensive than skb_pull_inline() :-)
>
> Really, things are fine as-is.
>

It seems no callers pass eth_type_trans() a packet, whose length is
less than ETH_HLEN. It means that skb_pull() always returns non-NULL.
And if skb_pull() returns NULL, the later memory dereferences must be
invalid. So, we can safely call __skb_pull() instead of skb_pull().
And If the current code works, there is no reason the new code without
the check(skb->len < ETH_HLEN) doesn't work.

As Eric mentioned above, GRE only assures the length of the packets
passed to eth_type_trans() isn't less than ETH_HLEN, we should check
skb->len before we dereference skb->data.

        rawp =3D skb->data;

        /*
         *      This is a magic hack to spot IPX packets. Older Novell =
breaks
         *      the protocol design and runs IPX over 802.3 without an =
802.2 LLC
         *      layer. We look for FFFF which isn't a used 802.2 SSAP/D=
SAP. This
         *      won't work for fault tolerant netware but does for the =
rest.
         */
        if (*(unsigned short *)rawp =3D=3D 0xFFFF)
                return htons(ETH_P_802_3);


=46or performance, how about inlining eth_type_trans(). Because its mai=
n
users are NIC drivers, and there aren't likely many kinds of NICs at
the same time, inlining it won't increases the size of the kernel
image much.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
