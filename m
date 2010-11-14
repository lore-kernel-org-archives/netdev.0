From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH/RFC] netfilter: nf_conntrack_sip: Handle quirky Cisco
 phones
Date: Sun, 14 Nov 2010 09:59:35 +0100
Message-ID: <1289725175.2743.65.camel@edumazet-laptop>
References: <28d666269c390965f1a4edca42f93c12@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Kevin Cernekee <cernekee@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59156 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754317Ab0KNI7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Nov 2010 03:59:44 -0500
In-Reply-To: <28d666269c390965f1a4edca42f93c12@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 14 novembre 2010 =C3=A0 00:32 -0800, Kevin Cernekee a =C3=A9=
crit :
> Most SIP devices use a source port of 5060/udp on SIP requests, so th=
e
> response automatically comes back to port 5060:
>=20
> phone_ip:5060 -> proxy_ip:5060   REGISTER
> proxy_ip:5060 -> phone_ip:5060   100 Trying
>=20
> The newer Cisco IP phones, however, use a randomly chosen high source
> port for the SIP request but expect the response on port 5060:
>=20
> phone_ip:49173 -> proxy_ip:5060  REGISTER
> proxy_ip:5060 -> phone_ip:5060   100 Trying
>=20
> Standard Linux NAT, with or without nf_nat_sip, will send the reply b=
ack
> to port 49173, not 5060:
>=20
> phone_ip:49173 -> proxy_ip:5060  REGISTER
> proxy_ip:5060 -> phone_ip:49173  100 Trying
>=20
> But the phone is not listening on 49173, so it will never see the rep=
ly.
>=20
> This issue was seen on a Cisco CP-7965G, firmware 8-5(3).  It appears
> to be a well-known problem on 7941 and newer:
>=20
> http://www.voip-info.org/wiki/view/Standalone+Cisco+7941%252F7961+wit=
hout+a+local+PBX
>=20
> Search for "Connecting to the outside world"
>=20
> I contacted Cisco support and they were not amenable to changing the
> behavior.  It appears to be RFC3261-compliant, as the "Sent-by port"
> field in the request specifies 5060:
>=20

There is a difference between being RFC compliant, and being usable.

Most SIP sotfwares I know will break with such a stupid CISCO behavior.



> 18.2.2 Sending Responses
>=20
>    The server transport uses the value of the top Via header field in
>    order to determine where to send a response.  It MUST follow the
>    following process:
>=20
> ...
>=20
>       o  Otherwise (for unreliable unicast transports), if the top Vi=
a
>          has a "received" parameter, the response MUST be sent to the
>          address in the "received" parameter, using the port indicate=
d
>          in the "sent-by" value, or using port 5060 if none is specif=
ied
>          explicitly.  If this fails, for example, elicits an ICMP "po=
rt
>          unreachable" response, the procedures of Section 5 of [4]
>          SHOULD be used to determine where to send the response.
>=20
> This patch modifies nf_*_sip to work around this quirk, by rewriting
> the response port to 5060 when the following conditions are met:
>=20
>  - User-Agent starts with "Cisco"
>=20
>  - Incoming TTL was exactly 64 (meaning that our system is the phone'=
s
>    local router, not an intermediate router)
>=20

This seems a hack to me, sorry. How many different vendors will switch
to "Cisco" broken way, and we have to patch over and over ?

I would like to get an exact SIP exchange to make sure their is not
another way to handle this without adding a "Cisco" string somewhere...

Please provide a pcap or tcpdump -A

Thanks


