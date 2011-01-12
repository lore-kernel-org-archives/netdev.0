From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH v2] net: Allow ethtool to set interface in loopback mode.
Date: Wed, 12 Jan 2011 11:24:38 -0800
Message-ID: <AANLkTinpw1DF-p=L1jn1Y1uATKaCQNy38Yf0_SQCBmHp@mail.gmail.com>
References: <AANLkTikW24AcLEAioYtCwuQOoVnTrqVoAaZw3sksZ_jU@mail.gmail.com>
	<1294187401-4662-1-git-send-email-maheshb@google.com>
	<20110104163645.0b3a3687@nehalam>
	<1294190504.2992.3.camel@localhost>
	<4D249ABD.4080209@garzik.org>
	<1294352011.11825.50.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jeff@garzik.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Laurent Chavey <chavey@google.com>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:9694 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754853Ab1ALTYm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 14:24:42 -0500
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p0CJOeK6030003
	for <netdev@vger.kernel.org>; Wed, 12 Jan 2011 11:24:41 -0800
Received: from bwz4 (bwz4.prod.google.com [10.188.26.4])
	by hpaq11.eem.corp.google.com with ESMTP id p0CJOdLa024244
	for <netdev@vger.kernel.org>; Wed, 12 Jan 2011 11:24:39 -0800
Received: by bwz4 with SMTP id 4so839076bwz.11
        for <netdev@vger.kernel.org>; Wed, 12 Jan 2011 11:24:39 -0800 (PST)
In-Reply-To: <1294352011.11825.50.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 6, 2011 at 2:13 PM, Ben Hutchings <bhutchings@solarflare.co=
m> wrote:
> On Wed, 2011-01-05 at 11:22 -0500, Jeff Garzik wrote:
>> On 01/04/2011 08:21 PM, Ben Hutchings wrote:
>> > On Tue, 2011-01-04 at 16:36 -0800, Stephen Hemminger wrote:
>> >> On Tue, =A04 Jan 2011 16:30:01 -0800
>> >> Mahesh Bandewar<maheshb@google.com> =A0wrote:
>> >>
>> >>> This patch enables ethtool to set the loopback mode on a given i=
nterface.
>> >>> By configuring the interface in loopback mode in conjunction wit=
h a policy
>> >>> route / rule, a userland application can stress the egress / ing=
ress path
>> >>> exposing the flows of the change in progress and potentially hel=
p developer(s)
>> >>> understand the impact of those changes without even sending a pa=
cket out
>> >>> on the network.
>> >>>
>> >>> Following set of commands illustrates one such example -
>> >>> =A0 a) ip -4 addr add 192.168.1.1/24 dev eth1
>> >>> =A0 b) ip -4 rule add from all iif eth1 lookup 250
>> >>> =A0 c) ip -4 route add local 0/0 dev lo proto kernel scope host =
table 250
>> >>> =A0 d) arp -Ds 192.168.1.100 eth1
>> >>> =A0 e) arp -Ds 192.168.1.200 eth1
>> >>> =A0 f) sysctl -w net.ipv4.ip_nonlocal_bind=3D1
>> >>> =A0 g) sysctl -w net.ipv4.conf.all.accept_local=3D1
>> >>> =A0 # Assuming that the machine has 8 cores
>> >>> =A0 h) taskset 000f netserver -L 192.168.1.200
>> >>> =A0 i) taskset 00f0 netperf -t TCP_CRR -L 192.168.1.100 -H 192.1=
68.1.200 -l 30
>> >>>
>> >>> Signed-off-by: Mahesh Bandewar<maheshb@google.com>
>> >>> Reviewed-by: Ben Hutchings<bhutchings@solarflare.com>
>> >>
>> >> Since this is a boolean it SHOULD go into ethtool_flags rather th=
an
>> >> being a high level operation.
>> >
>> > It could do, but I though ETHTOOL_{G,S}FLAGS were intended for
>> > controlling offload features.
>>
>> It doesn't have to be. =A0As Stephen guessed, [GS]FLAGS are basicall=
y
>> common flags -- as differentiated from private,
>> driver-specific/hardware-specific flags.
>
> Well, that would allow the patch to be simplified quite a bit. :-)
>
> Ben.
>
> From: Ben Hutchings <bhutchings@solarflare.com>
> Subject: [PATCH net-2.6] ethtool: Define ETH_FLAG_LOOPBACK
> Date: Thu, 6 Jan 2011 22:10:55 +0000
>
> Mahesh Bandewar <maheshb@google.com> requested this, writing:
>
> By configuring the interface in loopback mode in conjunction with a p=
olicy
> route / rule, a userland application can stress the egress / ingress =
path
> exposing the flows of the change in progress and potentially help dev=
eloper(s)
> understand the impact of those changes without even sending a packet =
out
> on the network.
>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Acked-by: Mahesh Bandewar <maheshb@google.com>
>
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -309,6 +309,7 @@ struct ethtool_perm_addr {
> =A0* flag differs from the read-only value.
> =A0*/
> =A0enum ethtool_flags {
> + =A0 =A0 =A0 ETH_FLAG_LOOPBACK =A0 =A0 =A0 =3D (1 << 2), =A0 =A0 /* =
Host-side loopback enabled */
> =A0 =A0 =A0 =A0ETH_FLAG_TXVLAN =A0 =A0 =A0 =A0 =3D (1 << 7), =A0 =A0 =
/* TX VLAN offload enabled */
> =A0 =A0 =A0 =A0ETH_FLAG_RXVLAN =A0 =A0 =A0 =A0 =3D (1 << 8), =A0 =A0 =
/* RX VLAN offload enabled */
> =A0 =A0 =A0 =A0ETH_FLAG_LRO =A0 =A0 =A0 =A0 =A0 =A0=3D (1 << 15), =A0=
 =A0/* LRO is enabled */
> ---
I tried this one with e1000e driver changes. It works but the ethtool
changes are not very clean and I would still prefer the earlier patch
since changes are clean across the board. I'll post ethtool changes
soon.

>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>
