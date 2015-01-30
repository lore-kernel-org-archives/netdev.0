From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: [PATCHv3, ipsec-next] xfrm: Do not parse 32bits compiled xfrm
 netlink msg on 64bits host
Date: Fri, 30 Jan 2015 10:11:42 +0800
Message-ID: <54CAE85E.9070301@gmail.com>
References: <1422349230-17394-1-git-send-email-fan.du@intel.com> <54CA0B9F.8080104@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:58996 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756696AbbA3CPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 21:15:53 -0500
Received: by mail-pa0-f53.google.com with SMTP id kx10so46094061pab.12
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 18:15:52 -0800 (PST)
In-Reply-To: <54CA0B9F.8080104@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015=E5=B9=B401=E6=9C=8829=E6=97=A5 18:29, Nicolas Dichtel =E5=
=86=99=E9=81=93:
> Le 27/01/2015 10:00, Fan Du a =C3=A9crit :
>> structure like xfrm_usersa_info or xfrm_userpolicy_info
>> has different sizeof when compiled as 32bits and 64bits
>> due to not appending pack attribute in their definition.
>> This will result in broken SA and SP information when user
>> trying to configure them through netlink interface.
>>
>> Inform user land about this situation instead of keeping
>> silent, the upper test scripts would behave accordingly.
>>
>> Quotes from: http://marc.info/?l=3Dlinux-netdev&m=3D142226348715503&=
w=3D2
>>>
>>> Before a clean solution show up, I think it's better to warn user i=
n some way
>>> like http://patchwork.ozlabs.org/patch/323842/ did. Otherwise, many=
 people
>>> who stuck there will always spend time and try to fix this issue in=
 whatever way.
>>
>> Yes, this is the first thing we should do. I'm willing to accept a p=
atch
>>
>> Signed-off-by: Fan Du <fan.du@intel.com>
> A way to solve this problem was to provide to userland a xfrm compat =
header
> file, which match the ABI of the kernel. Something like:
>
> #include <linux/xfrm.h>
>
> #define xfrm_usersa_info xfrm_usersa_info_64
> #define xfrm_usersa_info_compat xfrm_usersa_info
> struct xfrm_usersa_info_compat {
>      struct xfrm_selector        sel;
>      struct xfrm_id            id;
>      xfrm_address_t            saddr;
>      struct xfrm_lifetime_cfg    lft;
>      struct xfrm_lifetime_cur    curlft;
>      struct xfrm_stats        stats;
>      __u32                seq;
>      __u32                reqid;
>      __u16                family;
>      __u8                mode;
>      __u8                replay_window;
>      __u8                flags;
>      __u8                hole1;
>      __u32                hole2;
> };
>
> The point I try to make is that patching userland apps allows to use =
xfrm on a
> 32bits userland / 64bits kernel.
>
> If I understand well your patch, it will not be possible anymore, all=
 messages
> will be rejected. And this may break existing apps.

Add padding in user space does not fix existing 32bits ip binary, moreo=
ver not sure all other ARCHes
require the same padding. Maillist has various of proposals AFAICT, all=
 is rejected for reasons
whatever for a very long time including padding user space structure. I=
n fact those structures
are exposed by uapi from kernel to userspace.

Speaking of "break", run 32bits ip xfrm {state/policy/monitor} is _alre=
ady_ broken on 64bits host.
This patch is making user not stumble there by seeing invalid xfrm info=
rmation and wondering what's
going on. They can switch to setkey temporally.

last, thanks for your comments after looking at the code...

>
> Regards,
> Nicolas
