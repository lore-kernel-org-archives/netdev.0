From: =?ISO-8859-15?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: bad nat connection tracking performance with ip_gre
Date: Tue, 18 Aug 2009 20:39:57 +0300
Message-ID: <4A8AE76D.7040707@iki.fi>
References: <4A8A7F14.3010103@iki.fi> <4A8A84AF.7050901@trash.net> <4A8AA253.8090300@iki.fi> <4A8AA63D.4000702@trash.net> <4A8AB25A.4000105@iki.fi> <4A8AC1A0.6000602@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4A8AC1A0.6000602@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Timo Ter=E4s wrote:
>> Looped back by multicast routing:
>>
>> raw:PREROUTING:policy:1 IN=3Deth1 OUT=3D MAC=3D SRC=3D10.252.5.1
>> DST=3D239.255.12.42 LEN=3D1344 TOS=3D0x00 PREC=3D0x00 TTL=3D8 ID=3D3=
6594 DF
>> PROTO=3DUDP SPT=3D33977 DPT=3D1234 LEN=3D1324 mangle:PREROUTING:poli=
cy:1 IN=3Deth1
>> OUT=3D MAC=3D SRC=3D10.252.5.1 DST=3D239.255.12.42 LEN=3D1344 TOS=3D=
0x00 PREC=3D0x00
>> TTL=3D8 ID=3D36594 DF PROTO=3DUDP SPT=3D33977 DPT=3D1234 LEN=3D1324
>> The cpu hogging happens somewhere below this, since the more
>> multicast destinations I have the more CPU it takes.
>=20
> So you're sending to multiple destinations? That obviously increases
> the time spent in netfilter and the remaining networking stack.

Yes. But my observation was that for the same amount of packets
sent locally the CPU usage is significantly higher than if they
are forwarded from physical interface. That's what made me
curious.

If I had remember that icmp conn track entries get pruned right
when they get icmp reply back, I would not have probably bothered
to bug you. But that made me think it was more of generic problem
than my patch.

>> Multicast forwarded (I hacked this into the code; but similar
>> dump happens on local sendto()):
>>
>> Actually, now that I think, here we should have the inner IP
>> contents, and not the incomplete outer yet. So apparently
>> the ipgre_header() messes the network_header position.
>=20
> It shouldn't even have been called at this point. Please retry this
> without your changes.

I patched ipmr.c to explicitly call dev_hard_header to setup the
ipgre nbma receiver. Sadly, the call was wrong side of the nf_hook.
Adjusting that makes the forward hooks look ok.

I thought hook was using network_header to figure out where the
IP header is, but looks like that isn't the case.

>> mangle:FORWARD:policy:1 IN=3Deth1 OUT=3Dgre1 SRC=3D0.0.0.0 DST=3Dre.=
mo.te.ip
>> LEN=3D0 TOS=3D0x00 PREC=3D0x00 TTL=3D64 ID=3D0 DF PROTO=3D47 filter:=
=46ORWARD:rule:2
>> IN=3Deth1 OUT=3Dgre1 SRC=3D0.0.0.0 DST=3Dre.mo.te.ip LEN=3D0 TOS=3D0=
x00 PREC=3D0x00
>> TTL=3D64 ID=3D0 DF PROTO=3D47
>=20
> This looks really broken. Why is the protocol already 47 before it ev=
en
> reaches the gre tunnel?

Broken by me as explained.

>> ip_gre xmit sends out:
>=20
> There should be a POSTROUTING hook here.

Hmm... Looking at the code I probably broke this too. Could missing
this hook have a performance penalty for future packets for the
same flow?

Ok. I'll go back to drawing board. I should have done the
multicast handling for nbma destinations on ip_gre side as I was
wondering earlier. I'll also double check with oprofile the local
sendto() approach where it dies.

- Timo
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
