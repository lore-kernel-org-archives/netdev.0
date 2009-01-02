From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: 2.6.27.8 (+the idr fix) TCP Ack issue
Date: Fri, 2 Jan 2009 14:26:09 +0000
Message-ID: <20090102142608.GC26093@flint.arm.linux.org.uk>
References: <20081230195858.GA23530@flint.arm.linux.org.uk> <Pine.LNX.4.64.0812311200570.3120@wrl-59.cs.helsinki.fi> <20081231171016.GA1901@flint.arm.linux.org.uk> <Pine.LNX.4.64.0812312215590.3247@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:50314 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752315AbZABO0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2009 09:26:42 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0812312215590.3247@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 31, 2008 at 10:20:46PM +0200, Ilpo J=E4rvinen wrote:
> No, it's a sequence number, there are two sequence number spaces per =
flow,=20
> one for each direction (each has a corresponding field in the tcp hea=
der).=20
> For pure ACKs tcpdump won't show the sequence number by default even=20
> though it's still there...
>=20
> With tcpdump -n -v -v I get this for pure acks:
>=20
> ...: ., cksum 0x43c0 (correct), 671:671(0) ack 14649 win 36500
>=20
> That 671:671(0) won't be visible with smaller verbosity.

Ok, I think I see the problem - it's the remote end.

19:47:32.062670 IP (tos 0x0, ttl  64, id 30047, offset 0, flags [DF], p=
roto: TCP (6), length: 60) dyn-67.arm.linux.org.uk.38803 > 193.108.74.2=
09.http: S, cksum 0x6cf8 (correct), 3543174870:3543174870(0) win 5840 <=
mss 1460,sackOK,timestamp 26999689 0,nop,wscale 6>
19:47:32.135812 IP (tos 0x0, ttl 238, id 14, offset 0, flags [none], pr=
oto: TCP (6), length: 44) 193.108.74.209.http > dyn-67.arm.linux.org.uk=
=2E38803: S, cksum 0x49e2 (correct), 3016012818:3016012818(0) ack 35431=
74871 win 8192 <mss 1276>
19:47:32.135837 IP (tos 0x0, ttl  64, id 30048, offset 0, flags [DF], p=
roto: TCP (6), length: 40) dyn-67.arm.linux.org.uk.38803 > 193.108.74.2=
09.http: ., cksum 0x6a17 (correct), 1:1(0) ack 1 win 5840
19:47:32.135899 IP (tos 0x0, ttl  64, id 30049, offset 0, flags [DF], p=
roto: TCP (6), length: 683) dyn-67.arm.linux.org.uk.38803 > 193.108.74.=
209.http: P 1:644(643) ack 1 win 5840
19:47:32.167644 IP (tos 0x0, ttl  47, id 53954, offset 0, flags [DF], p=
roto: TCP (6), length: 40) 193.108.74.209.http > dyn-67.arm.linux.org.u=
k.38803: ., cksum 0x62c3 (correct), 1:1(0) ack 644 win 7073
19:47:32.174366 IP (tos 0x0, ttl  47, id 53955, offset 0, flags [DF], p=
roto: TCP (6), length: 1229) 193.108.74.209.http > dyn-67.arm.linux.org=
=2Euk.38803: P 1:1190(1189) ack 644 win 7073

Remote end sends 1:1190

19:47:32.174414 IP (tos 0x0, ttl  64, id 30050, offset 0, flags [DF], p=
roto: TCP (6), length: 40) dyn-67.arm.linux.org.uk.38803 > 193.108.74.2=
09.http: ., cksum 0x593c (correct), 644:644(0) ack 1190 win 8323
19:47:32.174701 IP (tos 0x0, ttl  64, id 30051, offset 0, flags [DF], p=
roto: TCP (6), length: 2592) dyn-67.arm.linux.org.uk.38803 > 193.108.74=
=2E209.http: . 644:3196(2552) ack 1190 win 8323

We ack 1190

19:47:32.174720 IP (tos 0x0, ttl  64, id 30053, offset 0, flags [DF], p=
roto: TCP (6), length: 60) dyn-67.arm.linux.org.uk.38803 > 193.108.74.2=
09.http: P, cksum 0xcd57 (incorrect (-> 0x1cd0), 3196:3216(20) ack 1190=
 win 8323
19:47:32.218718 IP (tos 0x0, ttl  47, id 53956, offset 0, flags [DF], p=
roto: TCP (6), length: 1065) 193.108.74.209.http > dyn-67.arm.linux.org=
=2Euk.38803: P 1190:2215(1025) ack 1920 win 8932

Remote end sends 1190:2215

19:47:32.258402 IP (tos 0x0, ttl  64, id 30054, offset 0, flags [DF], p=
roto: TCP (6), length: 40) dyn-67.arm.linux.org.uk.38803 > 193.108.74.2=
09.http: ., cksum 0x41e5 (correct), 3216:3216(0) ack 2215 win 10701

We ack 2215

19:47:32.285388 IP (tos 0x0, ttl 238, id 5, offset 0, flags [none], pro=
to: TCP (6), length: 40) 193.108.74.209.http > dyn-67.arm.linux.org.uk.=
38803: ., cksum 0x45e6 (correct), 1190:1190(0) ack 3216 win 10701

Remote end sequence number is still at 1190.

19:47:32.285397 IP (tos 0x0, ttl  64, id 30055, offset 0, flags [DF], p=
roto: TCP (6), length: 40) dyn-67.arm.linux.org.uk.38803 > 193.108.74.2=
09.http: ., cksum 0x41e5 (correct), 3216:3216(0) ack 2215 win 10701
19:47:32.320287 IP (tos 0x0, ttl 238, id 10, offset 0, flags [none], pr=
oto: TCP (6), length: 40) 193.108.74.209.http > dyn-67.arm.linux.org.uk=
=2E38803: ., cksum 0x45e6 (correct), 1190:1190(0) ack 3216 win 10701
19:47:32.320300 IP (tos 0x0, ttl  64, id 30056, offset 0, flags [DF], p=
roto: TCP (6), length: 40) dyn-67.arm.linux.org.uk.38803 > 193.108.74.2=
09.http: ., cksum 0x41e5 (correct), 3216:3216(0) ack 2215 win 10701
19:47:32.353016 IP (tos 0x0, ttl 238, id 12, offset 0, flags [none], pr=
oto: TCP (6), length: 40) 193.108.74.209.http > dyn-67.arm.linux.org.uk=
=2E38803: ., cksum 0x45e6 (correct), 1190:1190(0) ack 3216 win 10701
=2E..

So it looks to me like the remote end doesn't like our ack of 2215 for
some reason.


--=20
Russell King
