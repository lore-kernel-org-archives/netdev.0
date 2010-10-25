From: Jesse Gross <jesse@nicira.com>
Subject: Re: [RFC][net-next-2.6 PATCH 2/4] net: 8021Q consolidate header_ops routines
Date: Mon, 25 Oct 2010 15:44:53 -0700
Message-ID: <AANLkTinhhakzYdZc3BUWfsx13fRYLjk5LghSPW5a2yih@mail.gmail.com>
References: <20101021221004.22906.58438.stgit@jf-dev1-dcblab>
	<20101021221010.22906.60238.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:47357 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007Ab0JYWoy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 18:44:54 -0400
Received: by ywk9 with SMTP id 9so2524832ywk.19
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 15:44:53 -0700 (PDT)
In-Reply-To: <20101021221010.22906.60238.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 21, 2010 at 3:10 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> =A0static inline struct sk_buff *vlan_check_reorder_header(struct sk_=
buff *skb)
> =A0{
> =A0 =A0 =A0 =A0if (vlan_dev_info(skb->dev)->flags & VLAN_FLAG_REORDER=
_HDR) {
> @@ -269,33 +236,26 @@ static int vlan_dev_hard_header(struct sk_buff =
*skb, struct net_device *dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const =
void *daddr, const void *saddr,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsign=
ed int len)
> =A0{
> - =A0 =A0 =A0 struct vlan_hdr *vhdr;
> - =A0 =A0 =A0 unsigned int vhdrlen =3D 0;
> - =A0 =A0 =A0 u16 vlan_tci =3D 0;
> =A0 =A0 =A0 =A0int rc;
>
> =A0 =A0 =A0 =A0if (WARN_ON(skb_headroom(skb) < dev->hard_header_len))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOSPC;
>
> + =A0 =A0 =A0 /* When this flag is not set we make the vlan_tci visib=
le
> + =A0 =A0 =A0 =A0* by setting the skb field.
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* We do not immediately insert the tag here the inte=
nt
> + =A0 =A0 =A0 =A0* of setting VLAN_FLAG_REORDER_HDR is to make the vl=
an
> + =A0 =A0 =A0 =A0* info avaiable to tap devices and the QOS layer. Ad=
ding
> + =A0 =A0 =A0 =A0* the tag present bit shoould be enough for other la=
yers
> + =A0 =A0 =A0 =A0* to learn the vlan tag.
> + =A0 =A0 =A0 =A0*/

There's a typo in the comment: "shoould".

> =A0 =A0 =A0 =A0if (!(vlan_dev_info(dev)->flags & VLAN_FLAG_REORDER_HD=
R)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 vhdr =3D (struct vlan_hdr *) skb_push(s=
kb, VLAN_HLEN);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 vlan_tci =3D 0;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0vlan_tci =3D vlan_dev_info(dev)->vlan_=
id;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0vlan_tci |=3D vlan_dev_get_egress_qos_=
mask(dev, skb);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 vhdr->h_vlan_TCI =3D htons(vlan_tci);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0Set the protocol type. For a pa=
cket of type ETH_P_802_3/2 we
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0put the length in here instead.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (type !=3D ETH_P_802_3 && type !=3D =
ETH_P_802_2)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vhdr->h_vlan_encapsulat=
ed_proto =3D htons(type);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vhdr->h_vlan_encapsulat=
ed_proto =3D htons(len);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->protocol =3D htons(ETH_P_8021Q);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 type =3D ETH_P_8021Q;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 vhdrlen =3D VLAN_HLEN;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D __vlan_hwaccel_put_tag(skb, vla=
n_tci);
> =A0 =A0 =A0 =A0}

The only possible downside that I can see to this is that in the
non-accelerated case it requires some extra work because we'll need to
move the MAC addresses around as well.  However, given that
VLAN_FLAG_REORDER_HDR is generally set, I think this is a good code
consolidation.

>
> =A0 =A0 =A0 =A0/* Before delegating work to the lower layer, enter ou=
r MAC-address */
> @@ -304,9 +264,7 @@ static int vlan_dev_hard_header(struct sk_buff *s=
kb, struct net_device *dev,
>
> =A0 =A0 =A0 =A0/* Now make the underlying real hard header */
> =A0 =A0 =A0 =A0dev =3D vlan_dev_info(dev)->real_dev;
> - =A0 =A0 =A0 rc =3D dev_hard_header(skb, dev, type, daddr, saddr, le=
n + vhdrlen);
> - =A0 =A0 =A0 if (rc > 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rc +=3D vhdrlen;
> + =A0 =A0 =A0 rc =3D dev_hard_header(skb, dev, type, daddr, saddr, le=
n);
> =A0 =A0 =A0 =A0return rc;

Might as well just drop the rc variable.  It's not adding anything anym=
ore.
