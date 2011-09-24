From: Jesse Gross <jesse@nicira.com>
Subject: Re: [net-next 02/10] ixgbevf: Fix broken trunk vlan
Date: Sat, 24 Sep 2011 09:33:13 -0700
Message-ID: <CAEP_g=93GcR7yE7N+GtaB6dpjPuGGtCBXznEmV6Sx=BX-kSbmg@mail.gmail.com>
References: <1316855863-6091-1-git-send-email-jeffrey.t.kirsher@intel.com> <1316855863-6091-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Greg Rose <gregory.v.rose@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jiri Pirko <jpirko@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:47340 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705Ab1IXQdf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2011 12:33:35 -0400
Received: by vws1 with SMTP id 1so4833150vws.19
        for <netdev@vger.kernel.org>; Sat, 24 Sep 2011 09:33:34 -0700 (PDT)
In-Reply-To: <1316855863-6091-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 24, 2011 at 2:17 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Greg Rose <gregory.v.rose@intel.com>
>
> Changes to clean up the vlan rx path broke trunk vlan. =C2=A0Trunk vl=
ans in
> a VF driver are those set using:
>
> "ip link set <pfdev> vf <n> <vlanid>"
>
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> CC: Jiri Pirko <jpirko@redhat.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> =C2=A0drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | =C2=A0 =C2=A0=
6 ++----
> =C2=A01 files changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/driv=
ers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> index d72905b..4930c46 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> @@ -293,12 +293,10 @@ static void ixgbevf_receive_skb(struct ixgbevf_=
q_vector *q_vector,
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ixgbevf_adapter *adapter =3D q_vect=
or->adapter;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0bool is_vlan =3D (status & IXGBE_RXD_STAT_=
VP);
> + =C2=A0 =C2=A0 =C2=A0 u16 tag =3D le16_to_cpu(rx_desc->wb.upper.vlan=
);
>
> - =C2=A0 =C2=A0 =C2=A0 if (is_vlan) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 u16 tag =3D le16_t=
o_cpu(rx_desc->wb.upper.vlan);
> -
> + =C2=A0 =C2=A0 =C2=A0 if (is_vlan && test_bit(tag, adapter->active_v=
lans))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__vlan_hwaccel=
_put_tag(skb, tag);
> - =C2=A0 =C2=A0 =C2=A0 }

What happens if you run tcpdump without configuring vlan devices?
Shouldn't you see tagged packets for the vlans that are being trunked
to you?  I think this will strip tags in that case.  The apparent
behavior of vlan filters here is also surprising to me because on one
hand if they're truly filtering this test shouldn't be needed and on
the other hand they don't seem to be disabled in promiscuous mode.
