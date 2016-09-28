From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Subject: Re: [PATCH v2 net] net: skbuff: skb_vlan_push: Fix wrong unwinding
 of skb->data after __vlan_insert_tag call
Date: Wed, 28 Sep 2016 14:56:44 +0300
Message-ID: <20160928145644.662ecc04@pixies>
References: <1475053721-27676-1-git-send-email-shmulik.ladkani@gmail.com>
        <57EB9BE0.4080903@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Pravin Shelar <pshelar@ovn.org>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:35591 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932211AbcI1L4t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 07:56:49 -0400
Received: by mail-wm0-f43.google.com with SMTP id l132so231785413wmf.0
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 04:56:48 -0700 (PDT)
In-Reply-To: <57EB9BE0.4080903@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, 28 Sep 2016 12:30:56 +0200, daniel@iogearbox.net wrote:
> > @@ -4608,6 +4608,8 @@ int skb_vlan_push(struct sk_buff *skb, __be16 vla=
n_proto, u16 vlan_tci)
> >
> >   		skb->protocol =3D skb->vlan_proto;
> >   		skb->mac_len +=3D VLAN_HLEN;
> > +		if (offset)
> > +			offset +=3D VLAN_HLEN;
> >
> >   		skb_postpush_rcsum(skb, skb->data + (2 * ETH_ALEN), VLAN_HLEN);
> >   		__skb_pull(skb, offset);
>=20
> This looks much better indeed than your v1 of this patch.

Yep, after some meditation and history digging I happened to notice I
was barking at the wrong tree.

> So the issue might only be visible to act_vlan as the other remaining use=
r of
> skb_vlan_push().=20

Yes, this is correct. I'll amend the log message to express that.
The bug occurs for callers of skb_vlan_push() whose data is not
pointing at mac_header.

> My only question would be:
> what about __skb_vlan_pop(), wouldn't that then need the same adjustment
> a la offset -=3D VLAN_HLEN?

Well, theoretically, yes; but caller may expect 2 different things:

(assuming tags are in-payload)

(1) suppose upon entry we have

    DA,SA,0x8100,TCI,0x0800,
    ^                ^
    mac_hdr          data

initial offset is 18, and after current unwinding code we'll get

    DA,SA,0x0800,4_bytes,
    ^                    ^
    mac_hdr              data

which is probably incorrect, adjustment 'offset -=3D VLAN_HLEN' is needed.

(2) suppose upon entry we have

    DA,SA,0x8100,TCI,0x0800
    ^            ^
    mac_hdr      data

initial offset is 14, and after current unwinding code we'll get

    DA,SA,0x0800,
    ^            ^
    mac_hdr      data

which is probably what user has intended.
(had we adjusted offset to be 10, 'data' would point into SA)

=46rom test I've made using act_vlan upon ingress on QinQ tags, existing call
provides data as in (2).

Thoughts?
Should we adjust "offset" back, only if resulting offset is >=3D14 ?

Thanks,
Shmulik
