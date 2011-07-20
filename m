From: Jesse Gross <jesse@nicira.com>
Subject: Re: [patch net-next-2.6 37/47] igb: do vlan cleanup
Date: Wed, 20 Jul 2011 10:35:33 -0700
Message-ID: <CAEP_g=_0Ej09+KYbvEJz1+joYtms+S_67XSVVPMoG_hfJnmrBQ@mail.gmail.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com> <1311173689-17419-38-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com,
	greearb@candelatech.com, mirqus@gmail.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	peter.p.waskiewicz.jr@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, e1000-devel@lists.sourceforge.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:38740 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193Ab1GTRfy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 13:35:54 -0400
Received: by gxk21 with SMTP id 21so218121gxk.19
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 10:35:53 -0700 (PDT)
In-Reply-To: <1311173689-17419-38-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2011 at 7:54 AM, Jiri Pirko <jpirko@redhat.com> wrote:
> @@ -2943,7 +2944,7 @@ static void igb_rlpml_set(struct igb_adapter *a=
dapter)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct e1000_hw *hw =3D &adapter->hw;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 pf_id =3D adapter->vfs_allocated_count=
;
>
> - =C2=A0 =C2=A0 =C2=A0 if (adapter->vlgrp)
> + =C2=A0 =C2=A0 =C2=A0 if (igb_vlan_used(adapter))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0max_frame_size=
 +=3D VLAN_TAG_SIZE;

There are similar issues here as with the VF driver.  I think you're
also confusing vlan acceleration with vlan filtering.  If no vlan
filters are in use but the card is in promiscuous mode, the buffer
will be undersized and we lose tagged packets.

> +static void igb_vlan_mode(struct net_device *netdev, bool vlan_on)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct igb_adapter *adapter =3D netdev_pri=
v(netdev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct e1000_hw *hw =3D &adapter->hw;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 ctrl, rctl;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0igb_irq_disable(adapter);
> - =C2=A0 =C2=A0 =C2=A0 adapter->vlgrp =3D grp;
>
> - =C2=A0 =C2=A0 =C2=A0 if (grp) {
> + =C2=A0 =C2=A0 =C2=A0 if (vlan_on) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* enable VLAN=
 tag insert/strip */

This should be controlled by ethtool, not by whether vlan filters are
enabled.  Essentially, with this, you are recreating the logic of the
old vlan model in the new one.
