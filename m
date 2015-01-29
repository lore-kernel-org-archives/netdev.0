From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCHv3, ipsec-next] xfrm: Do not parse 32bits compiled xfrm
 netlink msg on 64bits host
Date: Thu, 29 Jan 2015 11:29:51 +0100
Message-ID: <54CA0B9F.8080104@6wind.com>
References: <1422349230-17394-1-git-send-email-fan.du@intel.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org, fengyuleidian0615@gmail.com
To: Fan Du <fan.du@intel.com>, steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:58102 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932264AbbA2K3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 05:29:55 -0500
Received: by mail-wi0-f177.google.com with SMTP id r20so22508678wiv.4
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 02:29:53 -0800 (PST)
In-Reply-To: <1422349230-17394-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 27/01/2015 10:00, Fan Du a =C3=A9crit :
> structure like xfrm_usersa_info or xfrm_userpolicy_info
> has different sizeof when compiled as 32bits and 64bits
> due to not appending pack attribute in their definition.
> This will result in broken SA and SP information when user
> trying to configure them through netlink interface.
>
> Inform user land about this situation instead of keeping
> silent, the upper test scripts would behave accordingly.
>
> Quotes from: http://marc.info/?l=3Dlinux-netdev&m=3D142226348715503&w=
=3D2
>>
>> Before a clean solution show up, I think it's better to warn user in=
 some way
>> like http://patchwork.ozlabs.org/patch/323842/ did. Otherwise, many =
people
>> who stuck there will always spend time and try to fix this issue in =
whatever way.
>
> Yes, this is the first thing we should do. I'm willing to accept a pa=
tch
>
> Signed-off-by: Fan Du <fan.du@intel.com>
A way to solve this problem was to provide to userland a xfrm compat he=
ader
file, which match the ABI of the kernel. Something like:

#include <linux/xfrm.h>

#define xfrm_usersa_info xfrm_usersa_info_64
#define xfrm_usersa_info_compat xfrm_usersa_info
struct xfrm_usersa_info_compat {
	struct xfrm_selector		sel;
	struct xfrm_id			id;
	xfrm_address_t			saddr;
	struct xfrm_lifetime_cfg	lft;
	struct xfrm_lifetime_cur	curlft;
	struct xfrm_stats		stats;
	__u32				seq;
	__u32				reqid;
	__u16				family;
	__u8				mode;
	__u8				replay_window;
	__u8				flags;
	__u8				hole1;
	__u32				hole2;
};

The point I try to make is that patching userland apps allows to use xf=
rm on a
32bits userland / 64bits kernel.

If I understand well your patch, it will not be possible anymore, all m=
essages
will be rejected. And this may break existing apps.


Regards,
Nicolas
