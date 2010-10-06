From: =?UTF-8?B?Q2h1bmctWWloIFdhbmcgKOeOi+W0h+aHvyk=?=
	<cywang@google.com>
Subject: Re: [PATCH] net: Fix sk_dst_check() to reset the obsolete dst_entry
 of a socket.
Date: Wed, 6 Oct 2010 02:47:12 -0700
Message-ID: <AANLkTimF7piLEy7BUP4-BnmiiGT4NimZw0gE+kmYQd-c@mail.gmail.com>
References: <AANLkTikkv4htP1f=KFwSaa8=K6LicDN0eusXctow-Efb@mail.gmail.com>
 <20101006.003541.71128466.davem@davemloft.net> <AANLkTikx+GadeYfg5rZNxsEig-0Af97ER7V94fjaVc+U@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	timo.teras@iki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:2110 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640Ab0JFJrg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 05:47:36 -0400
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o969lYcG012605
	for <netdev@vger.kernel.org>; Wed, 6 Oct 2010 02:47:34 -0700
Received: from qyk29 (qyk29.prod.google.com [10.241.83.157])
	by kpbe18.cbf.corp.google.com with ESMTP id o969lXlU026414
	for <netdev@vger.kernel.org>; Wed, 6 Oct 2010 02:47:33 -0700
Received: by qyk29 with SMTP id 29so3203377qyk.12
        for <netdev@vger.kernel.org>; Wed, 06 Oct 2010 02:47:33 -0700 (PDT)
In-Reply-To: <AANLkTikx+GadeYfg5rZNxsEig-0Af97ER7V94fjaVc+U@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I did not pay attention to the CL, actually that did not fix the issue
I encountered. I have a connected UDP socket which will not escape
from the "blackhole" since it will never enter the ipv4_blackhole
function.

In udp_sendmsg(), if the socket is connected one and the dst entry is
obsolete, you will never have a chance to reset the socket's dst entry
since rt will not be NULL.

udp_sendmsg() {
=2E...
if (connected)
               rt =3D (struct rtable *)sk_dst_check(sk, 0);
if (rt =3D=3D NULL) {
=2E..  blackhole_function_will_be_executed_here?
}
=2E..
}

On Wed, Oct 6, 2010 at 12:47 AM, Chung-Yih Wang (=E7=8E=8B=E5=B4=87=E6=87=
=BF) <cywang@google.com> wrote:
> In fact, that is what I intent to change originally. However, conside=
r
> Timo's issue, I intent to submit this patch instead.
>
> On Wed, Oct 6, 2010 at 12:35 AM, David Miller <davem@davemloft.net> w=
rote:
>>
>> This should have been fixed by:
>>
>> --------------------
>> commit ae2688d59b5f861dc70a091d003773975d2ae7fb
>> Author: Jianzhao Wang <jianzhao.wang@6wind.com>
>> Date: =C2=A0 Wed Sep 8 14:35:43 2010 -0700
>>
>> =C2=A0 =C2=A0net: blackhole route should always be recalculated
>>
>> =C2=A0 =C2=A0Blackhole routes are used when xfrm_lookup() returns -E=
REMOTE (error
>> =C2=A0 =C2=A0triggered by IKE for example), hence this kind of route=
 is always
>> =C2=A0 =C2=A0temporary and so we should check if a better route exis=
ts for next
>> =C2=A0 =C2=A0packets.
>> =C2=A0 =C2=A0Bug has been introduced by commit d11a4dc18bf41719c9f0d=
7ed494d295dd2973b92.
>>
>> =C2=A0 =C2=A0Signed-off-by: Jianzhao Wang <jianzhao.wang@6wind.com>
>> =C2=A0 =C2=A0Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.c=
om>
>> =C2=A0 =C2=A0Signed-off-by: David S. Miller <davem@davemloft.net>
>>
>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>> index 3f56b6e..6298f75 100644
>> --- a/net/ipv4/route.c
>> +++ b/net/ipv4/route.c
>> @@ -2738,6 +2738,11 @@ slow_output:
>> =C2=A0}
>> =C2=A0EXPORT_SYMBOL_GPL(__ip_route_output_key);
>>
>> +static struct dst_entry *ipv4_blackhole_dst_check(struct dst_entry =
*dst, u32 cookie)
>> +{
>> + =C2=A0 =C2=A0 =C2=A0 return NULL;
>> +}
>> +
>> =C2=A0static void ipv4_rt_blackhole_update_pmtu(struct dst_entry *ds=
t, u32 mtu)
>> =C2=A0{
>> =C2=A0}
>> @@ -2746,7 +2751,7 @@ static struct dst_ops ipv4_dst_blackhole_ops =3D=
 {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0.family =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =3D =C2=A0 =C2=A0 =C2=A0 AF_INET,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0.protocol =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =3D =C2=A0 =C2=A0 =C2=A0 cpu_to_be16(ETH_P_IP),
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0.destroy =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0=3D =C2=A0 =C2=A0 =C2=A0 ipv4_dst_destroy,
>> - =C2=A0 =C2=A0 =C2=A0 .check =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=3D =C2=A0 =C2=A0 =C2=A0 ipv4_dst_check,
>> + =C2=A0 =C2=A0 =C2=A0 .check =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=3D =C2=A0 =C2=A0 =C2=A0 ipv4_blackhole_dst_che=
ck,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0.update_pmtu =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0=3D =C2=A0 =C2=A0 =C2=A0 ipv4_rt_blackhole_update_pmtu,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0.entries =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0=3D =C2=A0 =C2=A0 =C2=A0 ATOMIC_INIT(0),
>> =C2=A0};
>>
>
