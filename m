From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] tcp: allow timestamps even if SYN packet has tsval=0
Date: Wed, 11 Mar 2009 16:00:02 +0100
Message-ID: <49B7D1F2.5090504@cosmosbay.com>
References: <49B7ABF2.5040803@cosmosbay.com> <20090311.064710.255854254.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54586 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752304AbZCKPAQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 11:00:16 -0400
In-Reply-To: <20090311.064710.255854254.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Wed, 11 Mar 2009 13:17:54 +0100
>=20
>> So apparently WindowsXP sends a NULL tsval in SYN packet, then
>> subsequent packets get a real value (60498) in this case.
>>
>> This seems to work on other OS as well, so is the following patch
>> considered evil ?  Do we have security concerns or only risking
>> windows client to have slightly wrong rtt estimation at the begining
>> of the tcp session ?
>=20
> I think we'll have to accept this.
>=20
> I don't see other systems blocking initial ts_ecn values of
> zero like we do.

ts_ecn ? You meant tsval ?

OK, here is a patch against net-next-2.6 with a Changelog and Signoff t=
hen.

Thank you

[PATCH] tcp: allow timestamps even if SYN packet has tsval=3D0

Some systems send SYN packets with apparently wrong RFC1323 timestamp
option values [timestamp tsval=3D0 tsecr=3D0].
It might be for security reasons (http://www.secuobs.com/plugs/25220.sh=
tml )

Linux TCP stack ignores this option and sends back a SYN+ACK packet
without timestamp option, thus many TCP flows cannot use timestamps
and lose some benefit of RFC1323.

Other operating systems seem to not care about initial tsval value, and=
 let
tcp flows to negotiate timestamp option.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index cf74c41..4a55854 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1226,15 +1226,6 @@ int tcp_v4_conn_request(struct sock *sk, struct =
sk_buff *skb)
 	if (want_cookie && !tmp_opt.saw_tstamp)
 		tcp_clear_options(&tmp_opt);
=20
-	if (tmp_opt.saw_tstamp && !tmp_opt.rcv_tsval) {
-		/* Some OSes (unknown ones, but I see them on web server, which
-		 * contains information interesting only for windows'
-		 * users) do not send their stamp in SYN. It is easy case.
-		 * We simply do not advertise TS support.
-		 */
-		tmp_opt.saw_tstamp =3D 0;
-		tmp_opt.tstamp_ok  =3D 0;
-	}
 	tmp_opt.tstamp_ok =3D tmp_opt.saw_tstamp;
=20
 	tcp_openreq_init(req, &tmp_opt, skb);

