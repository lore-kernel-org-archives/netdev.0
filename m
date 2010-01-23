From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [PATCH] tcp: fix ICMP-RTO war
Date: Sun, 24 Jan 2010 01:28:52 +0200
Message-ID: <201001240128.52570.denys@visp.net.lb>
References: <200912261703.49067.denys@visp.net.lb> <201001232337.19122.denys@visp.net.lb> <alpine.DEB.2.00.1001240007530.16552@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: "Ilpo =?iso-8859-15?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:35080 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773Ab0AWX0u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 18:26:50 -0500
In-Reply-To: <alpine.DEB.2.00.1001240007530.16552@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 24 January 2010 00:34:43 Ilpo J=E4rvinen wrote:
> Restored Damian cc, please keep them.
>=20
> On Sat, 23 Jan 2010, Denys Fedoryshchenko wrote:
> > On Tuesday 19 January 2010 13:17:51 you wrote:
> > > On Tue, 19 Jan 2010, Denys Fedoryshchenko wrote:
> > > > On Tuesday 19 January 2010 11:10:12 you wrote:
> > > > > Hi,
> > > > > thank you for testing. So srtt and rttvar is zero in any of t=
hose
> > > > > cases. Ilpo, it is a bug in tcp_rtt_estimator then, I suppose=
?
> > > > >
> > > > > There is also a code comment in tcp_input.c, saying:
> > > > > > * NOTE: clamping at TCP_RTO_MIN is not required, current al=
go
> > > > > > * guarantees that rto is higher.
> > > > >
> > > > > So we either fix tcp_rtt_estimator or simply clamp at TCP_RTO=
_MIN?
> > > > >
> > > > > Damian
> > > > >
> > > > > > On Monday 11 January 2010 15:02:34 you wrote:
> > > > > >> On Sat, 26 Dec 2009, Denys Fedoryshchenko wrote:
> > > > > >>> Few more dumps. I notice:
> > > > > >>> 1)Ack always equal 1
> > > > > >>> 2)It is usually first segment of data sent (?)
> > > > > >>>
> > > > > >>> Maybe some value not initialised properly?
> > > > > >>
> > > > > >> Can you see if the RTO lower bound is violated (I added so=
me
> > > > > >> printing of vars there too already now if it turns out to =
be
> > > > > >> something):
> > > > > >>
> > > > > >> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> > > > > >> index 65b8ebf..d84469f 100644
> > > > > >> --- a/net/ipv4/tcp_ipv4.c
> > > > > >> +++ b/net/ipv4/tcp_ipv4.c
> > > >
> > > > As i see in code it is rounding RTO to minimum value.
> > > > It fixes my problem seems.
> > > >
> > > > Btw just a bit about my environment - wireless networks (someti=
mes
> > > > lossy!) with low speed (128-512Kbps) customers working over ppp=
oe.
> > > > Maybe it will give a tip why rtt value is too low.
> > >
> > > What I find most strange in it is the fact that when it triggers =
for
> > > the first time, the srtt and mdev are zero, not some value in bet=
ween 0
> > > and 200ms. Therefore I suspect that this case might be something =
that
> > > we've overlooked where srtt/mdev are not valid at all.
> > >
> > > Maybe the patch below helps...
> >
> > Seems after this patch (and debug patch with warnings) my dmesg is =
clean.
>=20
> Cool, thanks for testing.
>=20
> Dave, please send into stable too (besides net-2.6). If we want less =
strict
> state check we can continue playing with that in net-next, IMHO.
>=20
I extend a little bit debug to=20
printk("lower bound violation: %u code %u sk_state %u\n", icsk->icsk_rt=
o,=20
code,sk->sk_state);

Here is result:
[  566.990065] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  566.990111] rto: 200 (0 >> 3 + 0, 5) time: 266990 sent: 263925 pen: =
1=20
383925 rem: 0                                                          =
                                =20
[  570.058555] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  570.058603] rto: 200 (0 >> 3 + 0, 8) time: 270058 sent: 269790 pen: =
1=20
272990 rem: 0                                                          =
                                =20
[  570.058660] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  570.058698] rto: 200 (0 >> 3 + 0, 8) time: 270058 sent: 270058 pen: =
1=20
270458 rem: 200                                                        =
                                =20
[  573.122550] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  573.122626] rto: 200 (0 >> 3 + 0, 11) time: 273122 sent: 273058 pen:=
 1=20
276258 rem: 136                                                        =
                               =20
[  573.122745] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  573.122815] rto: 200 (0 >> 3 + 0, 10) time: 273122 sent: 273058 pen:=
 1=20
273258 rem: 136                                                        =
                               =20
[  573.122931] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  573.123001] rto: 200 (0 >> 3 + 0, 9) time: 273122 sent: 273058 pen: =
1=20
273258 rem: 136                                                        =
                                =20
[  576.304338] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  576.304423] rto: 200 (0 >> 3 + 0, 12) time: 276304 sent: 276059 pen:=
 1=20
279259 rem: 0                                                          =
                               =20
[  576.326167] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  576.326251] rto: 200 (0 >> 3 + 0, 12) time: 276326 sent: 276304 pen:=
 1=20
276704 rem: 178                                                        =
                               =20
[  579.360343] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  579.360427] rto: 200 (0 >> 3 + 0, 15) time: 279360 sent: 279304 pen:=
 1=20
282504 rem: 144                                                        =
                               =20
[  582.566834] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  582.566919] rto: 200 (0 >> 3 + 0, 18) time: 282566 sent: 282304 pen:=
 1=20
285504 rem: 0                                                          =
                               =20
[  582.567085] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  582.567162] rto: 200 (0 >> 3 + 0, 18) time: 282567 sent: 282567 pen:=
 1=20
282967 rem: 200                                                        =
                               =20
[  582.567280] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  582.567351] rto: 200 (0 >> 3 + 0, 17) time: 282567 sent: 282567 pen:=
 1=20
282767 rem: 200                                                        =
                               =20
[  585.649877] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  585.649962] rto: 200 (0 >> 3 + 0, 20) time: 285649 sent: 285567 pen:=
 1=20
288767 rem: 118                                                        =
                               =20
[  585.650097] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  585.650178] rto: 200 (0 >> 3 + 0, 19) time: 285650 sent: 285567 pen:=
 1=20
285768 rem: 117                                                        =
                               =20
[  588.836754] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  588.836845] rto: 200 (0 >> 3 + 0, 22) time: 288836 sent: 288567 pen:=
 1=20
291767 rem: 0                                                          =
                               =20
[  588.836970] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  588.837042] rto: 200 (0 >> 3 + 0, 22) time: 288836 sent: 288836 pen:=
 1=20
289236 rem: 200                                                        =
                               =20
[  591.902908] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  591.902996] rto: 200 (0 >> 3 + 0, 25) time: 291902 sent: 291837 pen:=
 1=20
295037 rem: 135                                                        =
                               =20
[  591.903129] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  591.903205] rto: 200 (0 >> 3 + 0, 24) time: 291903 sent: 291837 pen:=
 1=20
292038 rem: 134                                                        =
                               =20
[  595.091391] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  595.091477] rto: 200 (0 >> 3 + 0, 27) time: 295091 sent: 294837 pen:=
 1=20
298037 rem: 0                                                          =
                               =20
[  595.091627] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  595.091702] rto: 200 (0 >> 3 + 0, 27) time: 295091 sent: 295091 pen:=
 1=20
295491 rem: 200                                                        =
                               =20
[  598.141828] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  598.141913] rto: 200 (0 >> 3 + 0, 30) time: 298141 sent: 298091 pen:=
 1=20
301291 rem: 150                                                        =
                               =20
[  598.142043] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  598.142114] rto: 200 (0 >> 3 + 0, 29) time: 298141 sent: 298091 pen:=
 1=20
298291 rem: 150                                                        =
                               =20
[  598.142252] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  598.142344] rto: 200 (0 >> 3 + 0, 28) time: 298142 sent: 298091 pen:=
 1=20
298291 rem: 149                                                        =
                               =20
[  601.146649] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  601.146734] rto: 200 (0 >> 3 + 0, 31) time: 301146 sent: 301091 pen:=
 1=20
304291 rem: 145                                                        =
                               =20
[  601.178998] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  601.179090] rto: 200 (0 >> 3 + 0, 30) time: 301179 sent: 301091 pen:=
 1=20
301291 rem: 112                                                        =
                               =20
[  601.179227] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  601.179298] rto: 200 (0 >> 3 + 0, 29) time: 301179 sent: 301091 pen:=
 1=20
301291 rem: 112                                                        =
                               =20
[  604.193304] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  604.193389] rto: 200 (0 >> 3 + 0, 32) time: 304193 sent: 304091 pen:=
 1=20
307291 rem: 98                                                         =
                               =20
[  604.193518] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  604.193589] rto: 200 (0 >> 3 + 0, 31) time: 304193 sent: 304091 pen:=
 1=20
304291 rem: 98                                                         =
                               =20
[  604.193706] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  604.193776] rto: 200 (0 >> 3 + 0, 30) time: 304193 sent: 304091 pen:=
 1=20
304291 rem: 98                                                         =
                               =20
[  607.341327] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  607.341412] rto: 200 (0 >> 3 + 0, 33) time: 307341 sent: 307091 pen:=
 1=20
310291 rem: 0                                                          =
                               =20
[  607.370345] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  607.370427] rto: 200 (0 >> 3 + 0, 33) time: 307370 sent: 307341 pen:=
 1=20
307741 rem: 171                                                        =
                               =20
[  607.370657] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  607.370730] rto: 200 (0 >> 3 + 0, 32) time: 307370 sent: 307341 pen:=
 1=20
307541 rem: 171                                                        =
                               =20
[  610.437075] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  610.437161] rto: 200 (0 >> 3 + 0, 35) time: 310437 sent: 310341 pen:=
 1=20
313541 rem: 104                                                        =
                               =20
[  610.437302] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  610.437374] rto: 200 (0 >> 3 + 0, 34) time: 310437 sent: 310341 pen:=
 1=20
310541 rem: 104                                                        =
                               =20
[  610.437497] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  610.437567] rto: 200 (0 >> 3 + 0, 33) time: 310437 sent: 310341 pen:=
 1=20
310541 rem: 104                                                        =
                               =20
[  613.429680] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  613.429770] rto: 200 (0 >> 3 + 0, 36) time: 313429 sent: 313341 pen:=
 1=20
316541 rem: 112                                                        =
                               =20
[  613.429899] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  613.429970] rto: 200 (0 >> 3 + 0, 35) time: 313429 sent: 313341 pen:=
 1=20
313541 rem: 112                                                        =
                               =20
[  613.430087] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  613.430164] rto: 200 (0 >> 3 + 0, 34) time: 313430 sent: 313341 pen:=
 1=20
313542 rem: 111                                                        =
                               =20
[  616.644279] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  616.644364] rto: 200 (0 >> 3 + 0, 37) time: 316644 sent: 316341 pen:=
 1=20
319541 rem: 0                                                          =
                               =20
[  616.644500] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  616.644572] rto: 200 (0 >> 3 + 0, 37) time: 316644 sent: 316644 pen:=
 1=20
317044 rem: 200                                                        =
                               =20
[  616.644689] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  616.644760] rto: 200 (0 >> 3 + 0, 36) time: 316644 sent: 316644 pen:=
 1=20
316844 rem: 200                                                        =
                               =20
[  617.028542] rto: 120000 (788 >> 3 + 266, 10) time: 317028 sent: 3139=
93 pen:=20
1 433993 rem: 116965                                                   =
                          =20
[  619.711969] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  619.712050] rto: 200 (0 >> 3 + 0, 39) time: 319712 sent: 319644 pen:=
 1=20
322844 rem: 132                                                        =
                               =20
[  619.712169] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  619.712240] rto: 200 (0 >> 3 + 0, 38) time: 319712 sent: 319644 pen:=
 1=20
319844 rem: 132                                                        =
                               =20
[  619.712364] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  619.712435] rto: 200 (0 >> 3 + 0, 37) time: 319712 sent: 319644 pen:=
 1=20
319844 rem: 132                                                        =
                               =20
[  622.908447] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  622.908531] rto: 200 (0 >> 3 + 0, 40) time: 322908 sent: 322644 pen:=
 1=20
325844 rem: 0                                                          =
                               =20
[  622.909274] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  622.909347] rto: 200 (0 >> 3 + 0, 40) time: 322909 sent: 322908 pen:=
 1=20
323308 rem: 199                                                        =
                               =20
[  622.914930] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  622.915014] rto: 200 (0 >> 3 + 0, 39) time: 322914 sent: 322908 pen:=
 1=20
323108 rem: 194                                                        =
                               =20
[  625.975145] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  625.975232] rto: 200 (0 >> 3 + 0, 42) time: 325975 sent: 325909 pen:=
 1=20
329109 rem: 134                                                        =
                               =20
[  625.975350] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  625.975422] rto: 200 (0 >> 3 + 0, 41) time: 325975 sent: 325909 pen:=
 1=20
326109 rem: 134                                                        =
                               =20
[  625.975538] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  625.975609] rto: 200 (0 >> 3 + 0, 40) time: 325975 sent: 325909 pen:=
 1=20
326109 rem: 134                                                        =
                               =20
[  629.187199] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  629.187286] rto: 200 (0 >> 3 + 0, 43) time: 329187 sent: 328909 pen:=
 1=20
332109 rem: 0                                                          =
                               =20
[  629.187454] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  629.187529] rto: 200 (0 >> 3 + 0, 43) time: 329187 sent: 329187 pen:=
 1=20
329587 rem: 200                                                        =
                               =20
[  629.187646] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  629.187717] rto: 200 (0 >> 3 + 0, 42) time: 329187 sent: 329187 pen:=
 1=20
329387 rem: 200                                                        =
                               =20
[  632.232822] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  632.232907] rto: 200 (0 >> 3 + 0, 45) time: 332232 sent: 332187 pen:=
 1=20
335387 rem: 155                                                        =
                               =20
[  632.250500] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  632.250585] rto: 200 (0 >> 3 + 0, 44) time: 332250 sent: 332187 pen:=
 1=20
332388 rem: 137                                                        =
                               =20
[  632.250714] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  632.250785] rto: 200 (0 >> 3 + 0, 43) time: 332250 sent: 332187 pen:=
 1=20
332387 rem: 137                                                        =
                               =20
[  635.247889] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  635.247974] rto: 200 (0 >> 3 + 0, 46) time: 335247 sent: 335187 pen:=
 1=20
338387 rem: 140                                                        =
                               =20
[  635.248416] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  635.248490] rto: 200 (0 >> 3 + 0, 45) time: 335248 sent: 335187 pen:=
 1=20
335387 rem: 139                                                        =
                               =20
[  635.251046] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  635.251122] rto: 200 (0 >> 3 + 0, 44) time: 335251 sent: 335187 pen:=
 1=20
335387 rem: 136                                                        =
                               =20
[  638.434799] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  638.434883] rto: 200 (0 >> 3 + 0, 47) time: 338434 sent: 338187 pen:=
 1=20
341387 rem: 0                                                          =
                               =20
[  638.435018] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  638.435090] rto: 200 (0 >> 3 + 0, 47) time: 338435 sent: 338434 pen:=
 1=20
338834 rem: 199                                                        =
                               =20
[  638.435215] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  638.435993] rto: 200 (0 >> 3 + 0, 46) time: 338435 sent: 338434 pen:=
 1=20
338634 rem: 199                                                        =
                               =20
[  641.501303] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  641.501380] rto: 200 (0 >> 3 + 0, 49) time: 341501 sent: 341435 pen:=
 1=20
344635 rem: 134                                                        =
                               =20
[  641.501501] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  641.501571] rto: 200 (0 >> 3 + 0, 48) time: 341501 sent: 341435 pen:=
 1=20
341635 rem: 134                                                        =
                               =20
[  641.501687] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  641.501757] rto: 200 (0 >> 3 + 0, 47) time: 341501 sent: 341435 pen:=
 1=20
341635 rem: 134                                                        =
                               =20
[  644.518586] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  644.518672] rto: 200 (0 >> 3 + 0, 50) time: 344518 sent: 344435 pen:=
 1=20
347635 rem: 117                                                        =
                               =20
[  644.518849] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  644.518930] rto: 200 (0 >> 3 + 0, 49) time: 344518 sent: 344435 pen:=
 1=20
344635 rem: 117                                                        =
                               =20
[  644.519071] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  644.519158] rto: 200 (0 >> 3 + 0, 48) time: 344519 sent: 344435 pen:=
 1=20
344636 rem: 116                                                        =
                               =20
[  647.725632] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  647.725717] rto: 200 (0 >> 3 + 0, 51) time: 347725 sent: 347435 pen:=
 1=20
350635 rem: 0                                                          =
                               =20
[  647.725850] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  647.725921] rto: 200 (0 >> 3 + 0, 51) time: 347725 sent: 347725 pen:=
 1=20
348125 rem: 200                                                        =
                               =20
[  647.729343] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  647.729417] rto: 200 (0 >> 3 + 0, 50) time: 347729 sent: 347725 pen:=
 1=20
347925 rem: 196                                                        =
                               =20
[  650.787543] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  650.787619] rto: 200 (0 >> 3 + 0, 53) time: 350787 sent: 350726 pen:=
 1=20
353926 rem: 139                                                        =
                               =20
[  650.798651] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  650.798749] rto: 200 (0 >> 3 + 0, 52) time: 350798 sent: 350726 pen:=
 1=20
350926 rem: 128                                                        =
                               =20
[  650.805039] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  650.805123] rto: 200 (0 >> 3 + 0, 51) time: 350805 sent: 350726 pen:=
 1=20
350926 rem: 121                                                        =
                               =20
[  653.801712] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  653.801788] rto: 200 (0 >> 3 + 0, 54) time: 353801 sent: 353726 pen:=
 1=20
356926 rem: 125                                                        =
                               =20
[  653.801937] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  653.802023] rto: 200 (0 >> 3 + 0, 53) time: 353802 sent: 353726 pen:=
 1=20
353926 rem: 124                                                        =
                               =20
[  653.802475] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  653.802548] rto: 200 (0 >> 3 + 0, 52) time: 353802 sent: 353726 pen:=
 1=20
353926 rem: 124                                                        =
                               =20
[  656.985567] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  656.985653] rto: 200 (0 >> 3 + 0, 55) time: 356985 sent: 356726 pen:=
 1=20
359926 rem: 0                                                          =
                               =20
[  656.986226] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  656.986299] rto: 200 (0 >> 3 + 0, 55) time: 356986 sent: 356985 pen:=
 1=20
357385 rem: 199                                                        =
                               =20
[  656.986416] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  656.986486] rto: 200 (0 >> 3 + 0, 54) time: 356986 sent: 356985 pen:=
 1=20
357185 rem: 199                                                        =
                               =20
[  660.042091] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  660.042168] rto: 200 (0 >> 3 + 0, 57) time: 360042 sent: 359985 pen:=
 1=20
363185 rem: 143                                                        =
                               =20
[  660.042286] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  660.042357] rto: 200 (0 >> 3 + 0, 56) time: 360042 sent: 359985 pen:=
 1=20
360185 rem: 143                                                        =
                               =20
[  660.076230] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  660.076315] rto: 200 (0 >> 3 + 0, 55) time: 360076 sent: 359985 pen:=
 1=20
360185 rem: 109                                                        =
                               =20
[  663.256655] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  663.256731] rto: 200 (0 >> 3 + 0, 58) time: 363256 sent: 362985 pen:=
 1=20
366185 rem: 0                                                          =
                               =20
[  663.341934] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  663.342010] rto: 200 (0 >> 3 + 0, 58) time: 363341 sent: 363256 pen:=
 1=20
363656 rem: 115                                                        =
                               =20
[  663.428067] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  663.428156] rto: 200 (0 >> 3 + 0, 57) time: 363428 sent: 363256 pen:=
 1=20
363457 rem: 28                                                         =
                               =20
[  666.308896] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  666.308980] rto: 200 (0 >> 3 + 0, 60) time: 366308 sent: 366256 pen:=
 1=20
369456 rem: 148                                                        =
                               =20
[  666.309110] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  666.309186] rto: 200 (0 >> 3 + 0, 59) time: 366309 sent: 366256 pen:=
 1=20
366457 rem: 147                                                        =
                               =20
[  666.309315] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  666.309386] rto: 200 (0 >> 3 + 0, 58) time: 366309 sent: 366256 pen:=
 1=20
366456 rem: 147                                                        =
                               =20
[  669.519782] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  669.519866] rto: 200 (0 >> 3 + 0, 61) time: 369519 sent: 369256 pen:=
 1=20
372456 rem: 0                                                          =
                               =20
[  669.520011] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  669.520083] rto: 200 (0 >> 3 + 0, 61) time: 369520 sent: 369519 pen:=
 1=20
369919 rem: 199                                                        =
                               =20
[  669.520206] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  669.520286] rto: 200 (0 >> 3 + 0, 60) time: 369520 sent: 369519 pen:=
 1=20
369719 rem: 199                                                        =
                               =20
[  672.641672] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  672.641756] rto: 200 (0 >> 3 + 0, 63) time: 372641 sent: 372519 pen:=
 1=20
375719 rem: 78                                                         =
                               =20
[  672.642325] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  672.642407] rto: 200 (0 >> 3 + 0, 62) time: 372642 sent: 372519 pen:=
 1=20
372719 rem: 77                                                         =
                               =20
[  672.642524] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  672.642596] rto: 200 (0 >> 3 + 0, 61) time: 372642 sent: 372519 pen:=
 1=20
372719 rem: 77                                                         =
                               =20
[  675.789437] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  675.789522] rto: 200 (0 >> 3 + 0, 64) time: 375789 sent: 375519 pen:=
 1=20
378719 rem: 0                                                          =
                               =20
[  675.789657] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  675.789727] rto: 200 (0 >> 3 + 0, 64) time: 375789 sent: 375789 pen:=
 1=20
376189 rem: 200                                                        =
                               =20
[  675.813158] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  675.813242] rto: 200 (0 >> 3 + 0, 63) time: 375813 sent: 375789 pen:=
 1=20
375989 rem: 176                                                        =
                               =20
[  678.902625] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  678.902689] rto: 200 (0 >> 3 + 0, 66) time: 378902 sent: 378789 pen:=
 1=20
381989 rem: 87                                                         =
                               =20
[  678.902808] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  678.902869] rto: 200 (0 >> 3 + 0, 65) time: 378902 sent: 378789 pen:=
 1=20
378989 rem: 87                                                         =
                               =20
[  678.902967] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  678.903027] rto: 200 (0 >> 3 + 0, 64) time: 378903 sent: 378789 pen:=
 1=20
378989 rem: 86                                                         =
                               =20
[  682.086610] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  682.086673] rto: 200 (0 >> 3 + 0, 67) time: 382086 sent: 381789 pen:=
 1=20
384989 rem: 0                                                          =
                               =20
[  682.086823] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  682.086885] rto: 200 (0 >> 3 + 0, 67) time: 382086 sent: 382086 pen:=
 1=20
382486 rem: 200                                                        =
                               =20
[  682.086988] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  682.087042] rto: 200 (0 >> 3 + 0, 66) time: 382087 sent: 382086 pen:=
 1=20
382286 rem: 199                                                        =
                               =20
[  685.177400] lower bound violation: 0 code 1 sk_state 1              =
                                                                       =
                                  =20
[  685.177460] rto: 200 (0 >> 3 + 0, 69) time: 385177 sent: 385086 pen:=
 1=20
388286 rem: 109                                                        =
                               =20
[  685.177566] lower bound violation: 0 code 1 sk_state 1
[  685.177630] rto: 200 (0 >> 3 + 0, 68) time: 385177 sent: 385086 pen:=
 1=20
385286 rem: 109
[  685.177734] lower bound violation: 0 code 1 sk_state 1
[  685.177790] rto: 200 (0 >> 3 + 0, 67) time: 385177 sent: 385086 pen:=
 1=20
385286 rem: 109
[  688.339503] lower bound violation: 0 code 1 sk_state 1
[  688.339565] rto: 200 (0 >> 3 + 0, 70) time: 388339 sent: 388086 pen:=
 1=20
391286 rem: 0
[  688.339684] lower bound violation: 0 code 1 sk_state 1
[  688.339745] rto: 200 (0 >> 3 + 0, 70) time: 388339 sent: 388339 pen:=
 1=20
388739 rem: 200
[  688.339844] lower bound violation: 0 code 1 sk_state 1
[  688.339896] rto: 200 (0 >> 3 + 0, 69) time: 388339 sent: 388339 pen:=
 1=20
388539 rem: 200
[  691.925180] lower bound violation: 0 code 1 sk_state 1
[  691.925242] rto: 200 (0 >> 3 + 0, 72) time: 391925 sent: 391339 pen:=
 1=20
394539 rem: 0
[  692.010074] lower bound violation: 0 code 1 sk_state 1
[  692.010131] rto: 200 (0 >> 3 + 0, 72) time: 392009 sent: 391925 pen:=
 1=20
392325 rem: 116
[  692.096188] lower bound violation: 0 code 1 sk_state 1
[  692.096254] rto: 200 (0 >> 3 + 0, 71) time: 392096 sent: 391925 pen:=
 1=20
392126 rem: 29
[  694.474680] lower bound violation: 0 code 1 sk_state 1
[  694.474742] rto: 200 (0 >> 3 + 0, 73) time: 394474 sent: 393325 pen:=
 1=20
394925 rem: 0
[  694.475751] lower bound violation: 0 code 1 sk_state 1
[  694.475810] rto: 200 (0 >> 3 + 0, 73) time: 394475 sent: 394474 pen:=
 1=20
394874 rem: 199
[  694.475918] lower bound violation: 0 code 1 sk_state 1
[  694.475975] rto: 200 (0 >> 3 + 0, 72) time: 394475 sent: 394474 pen:=
 1=20
394674 rem: 199
[  697.572814] lower bound violation: 0 code 1 sk_state 1
[  697.572877] rto: 200 (0 >> 3 + 0, 75) time: 397572 sent: 397474 pen:=
 1=20
400674 rem: 102
[  697.572986] lower bound violation: 0 code 1 sk_state 1
[  697.573052] rto: 200 (0 >> 3 + 0, 74) time: 397573 sent: 397474 pen:=
 1=20
397674 rem: 101
[  697.573159] lower bound violation: 0 code 1 sk_state 1
[  697.573211] rto: 200 (0 >> 3 + 0, 73) time: 397573 sent: 397474 pen:=
 1=20
397674 rem: 101
[  700.728072] lower bound violation: 0 code 1 sk_state 1
[  700.728135] rto: 200 (0 >> 3 + 0, 76) time: 400728 sent: 400474 pen:=
 1=20
403674 rem: 0
[  700.734010] lower bound violation: 0 code 1 sk_state 1
[  700.734079] rto: 200 (0 >> 3 + 0, 76) time: 400734 sent: 400728 pen:=
 1=20
401128 rem: 194
[  700.734191] lower bound violation: 0 code 1 sk_state 1
[  700.734944] rto: 200 (0 >> 3 + 0, 75) time: 400734 sent: 400728 pen:=
 1=20
400928 rem: 194
[  703.779459] lower bound violation: 0 code 1 sk_state 1
[  703.779521] rto: 200 (0 >> 3 + 0, 78) time: 403779 sent: 403729 pen:=
 1=20
406929 rem: 150
[  703.779628] lower bound violation: 0 code 1 sk_state 1
[  703.779680] rto: 200 (0 >> 3 + 0, 77) time: 403779 sent: 403729 pen:=
 1=20
403929 rem: 150
[  703.779797] lower bound violation: 0 code 1 sk_state 1
[  703.779850] rto: 200 (0 >> 3 + 0, 76) time: 403779 sent: 403729 pen:=
 1=20
403929 rem: 150
