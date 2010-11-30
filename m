From: Jesse Gross <jesse@nicira.com>
Subject: Re: Broken TX checksumming offloads
Date: Mon, 29 Nov 2010 18:35:44 -0800
Message-ID: <AANLkTi=U51Y7rsQXr+_6TreUks_MyRMdRU=TtdxKOG2Z@mail.gmail.com>
References: <20101129181742.GA29192@rere.qmqm.pl>
	<1291058003.20703.16.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org,
	Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>,
	e1000-devel@lists.sourceforge.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52475 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751764Ab0K3Cfq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 21:35:46 -0500
Received: by fxm8 with SMTP id 8so751470fxm.19
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 18:35:45 -0800 (PST)
In-Reply-To: <1291058003.20703.16.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/11/29 Ben Hutchings <bhutchings@solarflare.com>:
> On Mon, 2010-11-29 at 19:17 +0100, Micha=C5=82 Miros=C5=82aw wrote:
>> Hi!
>>
>> Unless I'm horribly mistaken, generic HW checksumming works as follo=
ws:
>> =C2=A0- driver sets netdev->features & NETIF_F_HW_CSUM to indicate s=
upport
>> =C2=A0 =C2=A0for generic checksumming; if the flag is not set, netwo=
rking core
>> =C2=A0 =C2=A0will checksum skb before calling ndo_start_xmit (let's =
ignore
>> =C2=A0 =C2=A0other checksumming options for now) and not pass skb wi=
th
>> =C2=A0 =C2=A0skb->ip_summed =3D=3D CHECKSUM_PARTIAL
>> =C2=A0- ndo_start_xmit() should use skb->csum_start and skb->csum_of=
fset
>> =C2=A0 =C2=A0(or skb->csum) to update checksum in software or instru=
ct HW to do so
>>
>> Looking at pch_gbe_xmit_frame() and its callee - pch_gbe_tx_queue() =
it
>> looks like the driver should set NETIF_F_IP_CSUM instead of NETIF_F_=
HW_CSUM
>> feature.
>>
>> Similar thing happens in ixgbe driver: it sets NETIF_F_HW_CSUM and c=
hecks
>> for skb->ip_summed =3D=3D CHECKSUM_PARTIAL, but then just warns on p=
rotocols
>> other that TCP and SCTP (see: ixgbe_psum()).
>
> AFAIK only {TCP,UDP}/IPv{4,6} use the simple 16-bit checksum algorith=
m
> that NETIF_F_HW_CSUM implies, so in practice it is equivalent to
> NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM even though it doesn't mean the s=
ame
> thing.

There are a few cases that I can think of where the extra generality
of NETIF_F_HW_CSUM is useful:

* The checksum in GRE (maybe other protocols as well) uses the same
algorithm as TCP/UDP.  In theory this means that we could use hardware
offloading for GRE on cards that have NETIF_F_HW_CSUM.  The one issue
is that NETIF_F_IP_CSUM really means TCP/UDP checksumming but we only
test if the protocol is IP.  This means that other IP based protocols
(like GRE) can't use checksum offloading since there is no software
fallback path.

* TCP/UDP packets that are deeply encapsulated.  Currently we can
express that checksum offloading is supported in one level of vlan
encapsulation through vlan_features.  However, a NIC that exposes
NETIF_F_HW_CSUM should in theory be able to checksum over a packet
that has an arbitrary number of vlan tags in front of it, a GRE
header, or any other type of encapsulation.
