From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] af_key: parse and send SADB_X_EXT_NAT_T_OA extension
Date: Thu, 22 Jan 2009 07:56:57 +0200
Message-ID: <49780AA9.9050508@iki.fi>
References: <1232523247-6893-1-git-send-email-timo.teras@iki.fi>	<20090121223329.GA8522@gondor.apana.org.au> <20090121.144054.70937985.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f20.google.com ([209.85.219.20]:62159 "EHLO
	mail-ew0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753898AbZAVF5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 00:57:00 -0500
Received: by ewy13 with SMTP id 13so2154672ewy.13
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2009 21:56:58 -0800 (PST)
In-Reply-To: <20090121.144054.70937985.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 22 Jan 2009 09:33:29 +1100
> 
>> Timo Teras <timo.teras@iki.fi> wrote:
>>> Parse and send SADB_X_EXT_NAT_T_OA along with other NAT-T extensions.
>>>
>>> Signed-off-by: Timo Teras <timo.teras@iki.fi>
>> Whatever application that you have in mind that's going to use
>> this should switch over to netlink.
> 
> Agreed, I won't be applying this patch.

It's for ipsec-tools. Currently the NAT OA in xfrm structs isn't
really used, but I need it later when implementing the NHRP/GRE/NAT
traversal I've sent couple mails about [1,2].

I do understand that netlink/xfrm is better, and I have it on
my long todo list. But rewriting 30-40 thousand lines of code
isn't going to happen that soon.

Is there any particular reason why setting NAT-OA info should/
must be done using netlink? Or is this just a way to try to
put more pressure for the change to happen?

I find it very confusing that NAT_T_[SD]PORT are supported, but
NAT_T_OA is not which is part of the same set of extensions
(required by some other kernels to make nat-t work in first
place; to fix up the checksums in transport mode SAs).

Even though if kernel currently does not use that information it
might confuse applications to get mismatching information back.

Currently if pfkey adds an NAT_T SA, and someone queries it
via xfrm you get back a random NAT OA. It's because
pfkey_msg2xfrm_state() kmallocs() the encap struct but does not
zero out or copy in the encap_oa field. IMHO, it's better to
just copy the information. But checking that again now, it looks
like we would need to memset() the encap_oa also when NAT_T_OA
is not present.

Also I find it a bit confusing which things are to be allowed
in pfkey and which not. We've had bigger fixes/changes to pfkey
in past like MIGRATE rewrite, etc.

- Timo

[1] http://marc.info/?l=linux-netdev&m=122232910618099&w=4
[2] http://marc.info/?l=linux-netdev&m=123252926623554&w=2

