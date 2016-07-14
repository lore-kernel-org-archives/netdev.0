From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: mlx5 PF and VF Vlan Restrictions
Date: Thu, 14 Jul 2016 13:28:45 +0300
Message-ID: <CALzJLG-syycBZPeR6cWjoEiEYqXUhCm266CpiREQ2yLP5cdtbQ@mail.gmail.com>
References: <CAOYAsNm+Vdhp=pZ6Dt7tw6gocaOZdkBOHC1qyO8CtKhUO12dNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: domingo montoya <reach.domingomontoya@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.161.179]:34620 "EHLO
	mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbcGNK3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 06:29:06 -0400
Received: by mail-yw0-f179.google.com with SMTP id i12so67978491ywa.1
        for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 03:29:05 -0700 (PDT)
In-Reply-To: <CAOYAsNm+Vdhp=pZ6Dt7tw6gocaOZdkBOHC1qyO8CtKhUO12dNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 14, 2016 at 11:27 AM, domingo montoya
<reach.domingomontoya@gmail.com> wrote:
> Hello,
>
> Can we have VLAN restrictions at both PF and VF level in mlx5 CX4 driver?
>
> For a particular VF, I would like to restrict VLANs from the PF driver
>
> For e.g, Let's say there is VF0. I would like to restrict the allowed
> vlans from the VF0 to be one of 10,20,30.
>
> I would like to do this enforcement at the PF driver.
>
> How do i do this?
>

in mlx5 driver you will need to configure both egress and ingress ACLs
with the allowed vlan list

same as we did in VST but without the HW vlan insertion/stripping.
i.e don't configure the HW (don't call modify_esw_vport_cvlan with non
0 vlan and qos).

today for vst mode we allow one vlan:
- VST vlan On VF TX is enforced via modify_esw_vport_cvlan command to
insert inforced vlan for all VF TX packets
- VST vlan On VF RX is enforced  via ingress ACL (Allowed vlan rule).

You need
- VGT vlan list allowed ACL rules in both ingress and egress ACLs and
drop all other traffic.


>
> So if the VF tries to configure any vlan other than 10,20,30, it should fail.
>
> Also how to communicate the vlans that are allowed to the vf from the PF.

you don't need to communicate them, the vf should initiate VGT Vlans
and try to work in best effort manner, if the PF allows it it will
work.
if not, traffic won't pass.

>
>
> Is this feature already implemented in the mlx5 ?
>

No, missing kernel/userspace API for PF admin to configure allowed vlan list.

>
> If not, can anyone please help me understand how to do that.
>

add new command for iproute to configure allowed vlan list per VF it
should be mutually exclusive with VST.
add new ndo to configure vlan list for VF in device driver, better if
we extend the existing ndo (set_vf_valn).

Thanks,
Saeed.
