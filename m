From: =?iso-8859-1?Q?Bj=F6rn?= Steinbrink <B.Steinbrink@gmx.de>
Subject: Re: [PATCH] forcedeth: mac address fix
Date: Wed, 2 Apr 2008 02:24:59 +0200
Message-ID: <20080402002459.GA22649@atjola.homenet>
References: <47F1534A.7020402@nvidia.com> <20080401000502.GB7423@atjola.homenet> <47F180B8.6010801@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:45209 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752824AbYDBAZD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2008 20:25:03 -0400
Content-Disposition: inline
In-Reply-To: <47F180B8.6010801@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2008.03.31 19:24:24 -0500, Ayaz Abdulla wrote:
>
>
> Bj=F6rn Steinbrink wrote:
>> On 2008.03.31 16:10:34 -0500, Ayaz Abdulla wrote:
>>
>>> This critical patch fixes a mac address issue recently introduced. =
If=20
>>> =20
>>
>>
>> Does "recently" mean my commit 2e3884b5b16795c03a7bf295797c1b2402885=
b88?
>> If so, I like to be told directly when I break stuff ;-)
>>
> Thats why I cc'd you. :)

OK, it's just that "recently broken" can mean about anything ;-) So I
would have welcomed a "broken by xxx" in the commit message, or a small
note below the --- line. :-)

>>> the device's mac address was in correct order and the flag  =20
>>> NVREG_TRANSMITPOLL_MAC_ADDR_REV was set, during nv_remove the flag=20
>>> would  get cleared. During next load, the mac address would get=20
>>> reversed  because the flag is missing.
>>
>>
>> Hm, but nv_remove also writes back the reversed mac address. I don't=
 see
>> how a plain remove/probe cycle would mess things up.
>>
>>
>
> For example, NVREG_TRANSMITPOLL_MAC_ADDR_REV is set. That would mean =
=20
> that orig_mac will be stored with correct address. Then you call =20
> nv_remove (via ifdown) which set orig_mac back into the register and =
=20
> will clear the flag. On the next nv_probe (via ifup), you would perfo=
rm =20
> the logic to reverse the mac address. But it is still in correct orde=
r.

OK, that's the case when we had two consecutive nv_probe calls, without
a call to nv_remove in between, right? So yeah, kexec + rmmod + modprob=
e
breaks. AFAICT.

>>> As it has been indicated previously, the flag is cleared across a l=
ow=20
>>>  power transition. Therefore, the driver should set the mac address=
=20
>>> back  into the reversed order when clearing the flag.
>>
>>
>> That's what nv_remove is supposed to do. Is there a case where nv_re=
move
>> is not called?
>>
>
> Sorry for the confusion. I was merely stating what needs to be done a=
s =20
> the full solution. This logic was already in place by your patch.
>
>>
>>> Also, the driver should set back the flag after a low power=20
>>> transition  to protect against kexec command calling nv_probe a=20
>>> second time.
>>
>>
>> Sounds like suspend stopped calling nv_remove? That would make sense
>> then. I never checked whether suspend ever actually did call nv_remo=
ve
>> (I think), but as my patch worked, it basically must have done so, a=
t
>> least in the past, right?
>>
>
> My understanding is that nv_suspend will call nv_close and then =20
> nv_resume will call nv_open. I don't think nv_probe/nv_remove is call=
ed =20
> during the low power transitions.

Hm, then I fail to see why my patch had any effect. I only touched
nv_probe and nv_remove, and it solved the mac reversal on suspend
problem... *confused*

> We want to set back the flag in nv_resume in case kexec is call after=
 =20
> anytime nv_resume is called. Otherwise, nv_probe (via kexec ?) will =20
> think it needs to reverse the address.

Hmhm, that also somehow conflicts with the fact that my patch did
anything... I think.=20

Bj=F6rn
