From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] af_key: parse and send SADB_X_EXT_NAT_T_OA extension
Date: Thu, 22 Jan 2009 10:31:32 +0200
Message-ID: <49782EE4.2070809@iki.fi>
References: <49780AA9.9050508@iki.fi> <20090121.220304.211246256.davem@davemloft.net> <49780EB5.60300@iki.fi> <20090121.222112.245293949.davem@davemloft.net> <20090122063206.GA11818@gondor.apana.org.au> <497814A7.3060302@iki.fi> <20090122064719.GA12043@gondor.apana.org.au> <4978180A.6080304@iki.fi> <20090122073946.GB12395@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:25109 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788AbZAVIbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 03:31:37 -0500
Received: by fg-out-1718.google.com with SMTP id 19so2076410fgg.17
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2009 00:31:35 -0800 (PST)
In-Reply-To: <20090122073946.GB12395@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Jan 22, 2009 at 08:54:02AM +0200, Timo Ter=E4s wrote:
>> That ipsec-tools feature works on *BSD. Works on Linux too
>> as kernel does not (yet) use that for anything except reporting
>> it back. Other OSes might use it already to e.g. fix-up the
>> packet checksums in transport mode SAs; I believe Linux just
>> recalculates the checksum.
>=20
> Right, the reason nobody has noticed is because transport mode
> NAT-T is inherently insecure (and difficult to deploy if you have
> multiple peers behind one gateway) so nobody uses it in the field.

Yes, if you have TCP or UDP as upper protocol. DMVPN has GRE as
upper protocol, so most of the problems are handled at GRE
layer with NHRP, dynamic routing protocols, etc.

> So I think there is even less reason to do this for af_key.
>
> If you don't have the time to convert racoon, couldn't you look
> at one of the *swans and use that as the basis of your work?

I did look into them in the beginning. They have a bit different
way of looking into ipsec connections than dmvpn. So I thought
ipsec-tools would be easiest to modify. I did not tie opennhrp
to ipsec-tools specifically (ipsec glue is a script) so it's
changeable.

Basically NHRP works as private IP to public IP mapping
protocol. And wants to be in charge of establishing the IPsec
SAs dynamically. Basically the option of having "unnamed"
connections distinguished by IP:s was the criteria why I went
with ipsec-tools.

The (quickish) look on *swans would imply that for each
dynamic connection I would need to hand create a new connection
entity. Could be scriptable, but then I would somehow
need to make up connection names based on the IPs and always
inject full config by the admin tool.

>> The future patch I have in my mind I've been talking about,
>> does make use of NAT-OA. So that's why I noticed it only
>> just now. Btw, could someone comment on the idea of passing
>> NAT-OA to neighbour cache and make xfrm use it when choosing
>> which xfrm state to use?
>=20
> I'm concerned about using NAT-OA for anything policy related
> because it is impossible to authenticate or verify.

I'm not sure if you are familiar how DMVPN works (=3D IPsec
transport mode + NBMA GRE + NHRP), but I can explain it more
detailed if you want to hear more about it.

In any case the NAT-OA would be used as hint to choose which
cached xfrm state the global xfrm policy "encrypt all GRE
traffic" would return when kernel sends packets out from
the GRE tunnel interface.

Basically, OpenNHRP would:
1. Make ipsec-tools (or some other keying manager) create
   new SAs for the dynamic IPsec connection. The KM would
   inject the NAT-OA for the negotiated xfrm state.

2. OpenNHRP after ensuring the IPsec SA is there, would
   inject GRE interface neighbor entry saying:
      "packets to this IP in GRE subnet, go to this public
       IP. do use this NAT-OA as hint when choosing xfrm state."
   This would be sent via Netlink.

This all works already, if all DMVPN nodes have different
public IP (xfrm chooses correct SA to use based on public IP).

But if there's multiple nodes behind same public IP the xfrm
has two (or more) choices for which xfrm state to use. The
NAT-OA can be used as distinguishing factor. So when ip_gre
sends out packet, the xfrm can choose the correct xfrm state.

Would that sound acceptable?

- Timo
