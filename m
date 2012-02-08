From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [RFC 2/2] e1000e: Support RXALL feature flag.
Date: Wed, 8 Feb 2012 01:06:42 +0100
Message-ID: <CAHXqBFJ9=fXYuzZd0SM0hGsDxQee5UPzOwThbxNkks03VLFunw@mail.gmail.com>
References: <1328656063-13129-1-git-send-email-greearb@candelatech.com> <1328656063-13129-2-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:65502 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755998Ab2BHAHD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 19:07:03 -0500
Received: by iacb35 with SMTP id b35so10816150iac.19
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2012 16:07:02 -0800 (PST)
In-Reply-To: <1328656063-13129-2-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/2/8  <greearb@candelatech.com>:
> From: Ben Greear <greearb@candelatech.com>
>
> This allows the NIC to receive all frames available, including
> those with bad FCS, un-matched vlans, ethernet control frames,
> and more.
>
> Tested by sending frames with bad FCS.

This should probably mark the bad packets somehow, so they are not
passed up the stack and mixed with correct traffic.

[...]
> @@ -2996,6 +3001,25 @@ static void e1000_setup_rctl(struct e1000_adap=
ter *adapter)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ew32(PSRCTL, p=
srctl);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> + =C2=A0 =C2=A0 =C2=A0 /* This is useful for sniffing bad packets. */
> + =C2=A0 =C2=A0 =C2=A0 if (adapter->netdev->features & NETIF_F_RXALL)=
 {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rctl |=3D (E1000_R=
CTL_SBP | /* Receive bad packets */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0E1000_RCTL_UPE | /* RX all Unicast Pkts */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0E1000_RCTL_MPE | /* RX all Mcast Pkts */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0E1000_RCTL_BAM | /* RX All Bcast Pkts Pkts */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0E1000_RCTL_PMCF); /* RX All MAC Ctrl Pkts */
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rctl &=3D ~(E1000_=
RCTL_VFE | /* Disable VLAN filter */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 E1000_RCTL_DPF | /* Allow filtered pause */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 E1000_RCTL_CFIEN); /* Dis VLAN CFIEN Filter */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* disable VLAN ta=
gging/striping */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* SKIP This, it a=
lso affects transmit side and
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0screw=
s up VLANs --Ben. */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* ctrl =3D er32(C=
TRL); */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* ctrl &=3D ~E100=
0_CTRL_VME; */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* ew32(CTRL, ctrl=
); */
> + =C2=A0 =C2=A0 =C2=A0 }
> +
[...]

Looks like it can be enabled independently of promisc mode: rx-all +
no-promisc would receive only bad packets destined for this host.

Best Regards,
Micha=C5=82 Miros=C5=82aw
