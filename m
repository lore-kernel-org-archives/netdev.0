From: Jesse Gross <jesse@nicira.com>
Subject: Re: [RFC PATCH 1/7] ebtables: Allow filtering of hardware accelerated
 vlan frames.
Date: Mon, 18 Oct 2010 20:14:12 -0700
Message-ID: <AANLkTi=MRRnViFeRhGXQt-aK_GboBDq2ME_Jcx-=K9sS@mail.gmail.com>
References: <1287000177-7126-1-git-send-email-jesse@nicira.com>
	<1287000177-7126-2-git-send-email-jesse@nicira.com>
	<1287431892.2252.575.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:41819 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753964Ab0JSDON convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 23:14:13 -0400
Received: by yxm8 with SMTP id 8so892400yxm.19
        for <netdev@vger.kernel.org>; Mon, 18 Oct 2010 20:14:12 -0700 (PDT)
In-Reply-To: <1287431892.2252.575.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 18, 2010 at 12:58 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Wed, 2010-10-13 at 13:02 -0700, Jesse Gross wrote:
>> An upcoming commit will allow packets with hardware vlan acceleratio=
n
>> information to be passed though more parts of the network stack, inc=
luding
>> packets trunked through the bridge. =A0This adds support for matchin=
g and
>> filtering those packets through ebtables.
>>
>> Signed-off-by: Jesse Gross <jesse@nicira.com>
>> ---
>> =A0net/bridge/br_netfilter.c =A0 =A0 =A0 | =A0 16 +++++++++-------
>> =A0net/bridge/netfilter/ebt_vlan.c | =A0 38 +++++++++++++++++++++++-=
--------------
>> =A0net/bridge/netfilter/ebtables.c | =A0 15 +++++++++++----
>> =A03 files changed, 43 insertions(+), 26 deletions(-)
>>
>> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
>> index 7f9ce96..d6a4fec 100644
>> --- a/net/bridge/br_netfilter.c
>> +++ b/net/bridge/br_netfilter.c
>> @@ -64,22 +64,24 @@ static int brnf_filter_pppoe_tagged __read_mostl=
y =3D 0;
>>
>> =A0static inline __be16 vlan_proto(const struct sk_buff *skb)
>> =A0{
>> - =A0 =A0 return vlan_eth_hdr(skb)->h_vlan_encapsulated_proto;
>> + =A0 =A0 if (skb->protocol =3D=3D htons(ETH_P_8021Q))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return vlan_eth_hdr(skb)->h_vlan_encapsula=
ted_proto;
>> + =A0 =A0 else if (vlan_tx_tag_present(skb))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return skb->protocol;
>
> If there are two levels of VLAN-encapsulation, this will return eithe=
r
> the inner or outer tag depending on whether VLAN acceleration is bein=
g
> used. =A0It should behave consistently.

Thanks, you're right.  I fixed it to always use the outer tag (same as
previous behavior).
