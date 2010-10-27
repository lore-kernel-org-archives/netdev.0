From: Jesse Gross <jesse@nicira.com>
Subject: Re: [RFC][net-next-2.6 PATCH v2] 8021q: set hard_header_len when VLAN
 offload features are toggled
Date: Wed, 27 Oct 2010 16:04:11 -0700
Message-ID: <AANLkTimTc2QwgsXk8qeU7ZBu977nOFLGQTx9sE5f4f-L@mail.gmail.com>
References: <20101026215933.2339.45454.stgit@jf-dev1-dcblab>
	<AANLkTi=9tL5yrVGWsOagcgyKte5z8R9ADdz5n-Uf2Lsw@mail.gmail.com>
	<4CC89C3A.7000209@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:56715 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756119Ab0J0XEL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 19:04:11 -0400
Received: by ywk9 with SMTP id 9so866259ywk.19
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 16:04:11 -0700 (PDT)
In-Reply-To: <4CC89C3A.7000209@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 27, 2010 at 2:40 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> On 10/26/2010 7:05 PM, Jesse Gross wrote:
>> On Tue, Oct 26, 2010 at 2:59 PM, John Fastabend
>> <john.r.fastabend@intel.com> wrote:
>>> Toggling the vlan tx|rx hw offloads needs to set the hard_header_le=
n
>>> as well otherwise we end up using LL_RESERVED_SPACE incorrectly.
>>> This results in pskb_expand_head() being used unnecessarily.
>>>
>>> This add a check in vlan_transfer_features =A0to catch the ETH_FLAG=
_TXVLAN
>>> flag and set the header length. This requires drivers to add the
>>> ETH_FLAG_TXVLAN to vlan_features.
>>>
>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>>
>> I think this addresses all of the original problems. =A0However, I d=
on't
>> think that we want to have drivers claim to support vlan offloading =
as
>> a feature for vlan packets. =A0That implies some type of QinQ
>> functionality to me. =A0In addition, if the vlan device claims to
>> support offloading and a second vlan device is stacked on top of it,
>> then the two will clobber skb->vlan_tci. =A0It's probably simpler to
>> just keep track of whether vlan offloading is currently enabled so w=
e
>> can find out whether it changed.
>>
>
> Agreed. Rather then trying to be clever this is probably the easiest.
>
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -334,6 +334,12 @@ Hunk #1, a/net/8021q/vlan.c static void vlan_tra=
nsfer_features(struct net_device *dev,
> =A0 =A0 =A0 =A0vlandev->features &=3D ~dev->vlan_features;
> =A0 =A0 =A0 =A0vlandev->features |=3D dev->features & dev->vlan_featu=
res;
> =A0 =A0 =A0 =A0vlandev->gso_max_size =3D dev->gso_max_size;
> +
> + =A0 =A0 =A0 if (dev->features & NETIF_F_HW_VLAN_TX)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlandev->hard_header_len =3D dev->hard_=
header_len;
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlandev->hard_header_len =3D dev->hard_=
header_len + VLAN_HLEN;
> +

Great, that's even simpler than I was thinking.

I think this series is ready to go.
