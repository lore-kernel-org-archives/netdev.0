From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: multicast: disable port when in blocking state
Date: Mon, 22 Jun 2015 23:38:36 +0300
Message-ID: <709324EA-9BEC-43AD-9DC1-55F712C378E6@cumulusnetworks.com>
References: <1434703550-29305-1-git-send-email-nikolay@cumulusnetworks.com> <1435003931-6418-1-git-send-email-nikolay@cumulusnetworks.com> <EA66CF77-F024-471C-A8F1-A7E6C3DB1721@cumulusnetworks.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sashok@cumulusnetworks.com,
	davem@davemloft.net, stephen@networkplumber.org,
	herbert@gondor.apana.org.au
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:35839 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707AbbFVUik convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 16:38:40 -0400
Received: by wgbhy7 with SMTP id hy7so151304163wgb.2
        for <netdev@vger.kernel.org>; Mon, 22 Jun 2015 13:38:39 -0700 (PDT)
In-Reply-To: <EA66CF77-F024-471C-A8F1-A7E6C3DB1721@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Jun 22, 2015, at 11:25 PM, Nikolay Aleksandrov <nikolay@cumulusnet=
works.com> wrote:
>=20
>=20
>> On Jun 22, 2015, at 11:12 PM, Nikolay Aleksandrov <nikolay@cumulusne=
tworks.com> wrote:
>>=20
>> Currently when a port goes in blocking state the multicast is not
>> disabled. Fix it by disabling a port if its state has transitioned t=
o
>> blocking, this has effect for both user- and kernel-space stp.
>>=20
>> Reported-by: Herbert Xu <herbert@gondor.apana.org.au>
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> ---
>> note: this is on top of patch:
>> "bridge: multicast: start querier timer when running user-space stp"
>>=20
>> net/bridge/br_stp.c | 2 ++
>> 1 file changed, 2 insertions(+)
>>=20
>> diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
>> index e7ab74b405a1..1a73c5595f52 100644
>> --- a/net/bridge/br_stp.c
>> +++ b/net/bridge/br_stp.c
>> @@ -463,6 +463,8 @@ void br_port_state_selection(struct net_bridge *=
br)
>>=20
>> 		if (p->state !=3D BR_STATE_BLOCKING)
>> 			br_multicast_enable_port(p);
>> +		else
>> +			br_multicast_disable_port(p);
>> 		if (p->state =3D=3D BR_STATE_FORWARDING)
>> 			++liveports;
>> 	}
>> --=20
>> 2.4.3
>>=20
>=20
> Actually I don=E2=80=99t think this is the correct way to go about th=
is because when the
> port goes in blocking state and br_multicast_disable_port() is called=
 then all groups are deleted
> which includes the user-added ones.--
> To unsubscribe from this list: send the line "unsubscribe netdev=E2=80=
=9D in

One more thing - I don=E2=80=99t think we need any additional changes b=
ecause there=E2=80=99s a check in
br_multicast_port_query_expired():
      if (port->state =3D=3D BR_STATE_DISABLED ||
            port->state =3D=3D BR_STATE_BLOCKING)
                goto out;

So it looks like the port should be fine (i.e. not sending) when it goe=
s in blocking state.
