From: Rex Ge <lungothrin@gmail.com>
Subject: Re: [Patch net] ipv4: fib: check forwarding before checking send_redirects
Date: Sat, 12 Apr 2014 17:52:04 +0800
Message-ID: <74E9BD9F-DDD6-46AB-AF9D-77D817EC5369@gmail.com>
References: <1396985482-30886-1-git-send-email-xiyou.wangcong@gmail.com> <20140408.164356.557108616710530006.davem@davemloft.net> <CAM_iQpXrmRNhQCWjiRSKwzxvtcq9XuT-cWS4vRxYVYxpUEN3qQ@mail.gmail.com> <20140408.172343.917107273854891906.davem@davemloft.net> <CAM_iQpXkmU9qw_KPeMPnE0KGbcCWo5R=Le7HsizyiuRJVkKshA@mail.gmail.com> <alpine.LFD.2.11.1404090110500.3310@ja.home.ssi.bg> <CAM_iQpXNf9rBCtZ2ipiHr2i2Kk4r0QtewiNC-qW8RzR0ChoWqA@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:48642 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752511AbaDLJwN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2014 05:52:13 -0400
Received: by mail-pb0-f48.google.com with SMTP id md12so6394143pbc.35
        for <netdev@vger.kernel.org>; Sat, 12 Apr 2014 02:52:13 -0700 (PDT)
In-Reply-To: <CAM_iQpXNf9rBCtZ2ipiHr2i2Kk4r0QtewiNC-qW8RzR0ChoWqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 9, 2014, at 6:55 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:

> Thanks for your reply, David and Julian!
>=20
> On Tue, Apr 8, 2014 at 3:15 PM, Julian Anastasov <ja@ssi.bg> wrote:
>>        Yes, the code will fail if input route is
>> tried on loopback device. My first thought was that
>> you forgot to 'ip route flush cache' after clearing
>> rp_filter.
>>=20
>=20
> route cache is removed after 3.6, so I don't need to do it?
>=20
>>> which looks good to me too, since the packet has src addr =3D=3D ds=
t addr.
>>>=20
>>> Which part am I missing?
>>=20
>>        What kind of packet is that and why the skb lost its
>> output route and now it is trying for input route?
>>=20
>=20
> Yeah, I just noticed that for normal loopback packets its ->dst
> are forced to be kept so that it will not need to lookup route
> again on rx. However, in our case, we redirect the packets
> from veth0 to lo when src_addr =3D=3D dst_addr, its ->dst is dropped
> after coming out of the network namespace, therefore goes into
> the slow path to validate the reverse path and lookup the route.

If what you say is true, this is exactly where the problem is caused.
  "redirect the packet from veth0 to lo when src_addr =3D=3D dst_addr=94
  =93its ->dst is dropped after coming out of the network namespace=94
these two does not suppose to happen at the same time.

loopback packets are suppose to be redirected to lo device
of the same network namespace, and ->dst is kept.
if ->dst is dropped, set rp_filter to 2 and enable accept_local,
it should be able to pass =93__fib_validate_source=94 check.

If you do these two at the same time, it is your responsibility to tric=
k
routing into believing =93dst_addr=94 is configured on lo device=20
of target namespace and enable accept_local on lo,
or rebuild a =93dst_entry=94 manually.

Throw away the assumption that ->dst is attached with
loopback packet is big for routing, some serious checking is required.


>=20
> I think David's point is still valid in this case, __fib_validate_sou=
rce()
> should not reject the packets. So hmm... the only reason I can find i=
s
> the following code:
>=20
>        if (fib_lookup(net, &fl4, &res) =3D=3D 0) {
>                if (res.type =3D=3D RTN_UNICAST)
>                        ret =3D FIB_RES_NH(res).nh_scope >=3D RT_SCOPE=
_HOST;
>        }
>=20
> where its nh_scope =3D=3D RT_SCOPE_HOST?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
