From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [TCP bug, regression] stuck distcc connections in latest -git
Date: Thu, 24 Jul 2008 10:27:30 +0200
Message-ID: <20080724082730.GA29046@elte.hu>
References: <20080724063242.GA9051@elte.hu> <E1KLvds-0001Mc-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: w@1wt.eu, davem@davemloft.net, davidn@davidnewall.com,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stefanr@s5r6.in-berlin.de, rjw@sisk.pl
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:43614 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751436AbYGXI2l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 04:28:41 -0400
Content-Disposition: inline
In-Reply-To: <E1KLvds-0001Mc-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Ingo Molnar <mingo@elte.hu> wrote:
> > 
> > here's a longer log from the server, with sequences, flags, etc:
> 
> Sorry but which is the server, phoenix?

yeah.

> > 08:28:48.029057 IP (tos 0x0, ttl 64, id 27412, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x8316 (correct), 2272574194:2272574194(0) ack 234561256 win 65535
> > 08:30:48.049167 IP (tos 0x0, ttl 64, id 14022, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234561256:234561792(536) ack 2272574194 win 5840
> > 08:30:48.049223 IP (tos 0x0, ttl 64, id 27413, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x80fe (correct), 2272574194:2272574194(0) ack 234561792 win 65535
> > 08:30:48.049341 IP (tos 0x0, ttl 64, id 14023, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234626648:234627184(536) ack 2272574194 win 5840
> > 08:30:48.049348 IP (tos 0x0, ttl 64, id 14024, offset 0, flags [DF], proto TCP (6), length 183) dione.39201 > phoenix.distcc: . 234627184:234627327(143) ack 2272574194 win 5840
> > 08:30:48.049354 IP (tos 0x0, ttl 64, id 27414, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x80fe (correct), 2272574194:2272574194(0) ack 234561792 win 65535
> > 08:30:48.049359 IP (tos 0x0, ttl 64, id 27415, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x80fe (correct), 2272574194:2272574194(0) ack 234561792 win 65535
> 
> No further traffic is generated for this connection?

you mean besides the periodic 2 minute stuff? Correct.

> For a problem like this, you really need to dump on both sides to get 
> the full picture.  Otherwise it's difficult to tell why we have a gap 
> after 234561792 which is never filled in by dione.

well, i dumped on both sides and posted the result (in my first mail), 
didnt i?

> BTW any reason why you appear to have SACK off?

default distro setup, Fedora 9 and Fedora 8. No extra tweaking that i'm 
aware of.

Fortunately this is my lucky day and i just triggered an half-incident, 
a "half hang". The connection was stuck for about 40 minutes - and 2 
minutes after i started tracing it on both sides it got unstuck. If the 
stall is shorter than that i'd normally not notice it. (except for a 
drop in testing throughput)

Server (phoenix) and client (dione) dumps attached.

Note, these hung TCP problems started after i upgraded the server's 
kernel to the big networking merge. Somewhere in the 24 hours preceding 
my first report:

    Date: Tue, 22 Jul 2008 13:21:33 +0200

I upgrade the server's kernel daily, so the regression window is pretty 
accurate. So the prime suspect is one of these 1232 commits:

| commit db6d8c7a4027b48d797b369a53f8470aaeed7063
| Merge: 3a53337... fb65a7c...
| Author: Linus Torvalds <torvalds@linux-foundation.org>
| Date:   Sun Jul 20 17:43:29 2008 -0700
|
|    Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
|
|    * git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6: (1232 commits)

i.e.:

  last known good kernel is:             v2.6.26-3465-g5b664cb
  first known broken kernel is:          v2.6.26-4811-gdb6d8c7
  last tested (still broken) kernel is:  v2.6.26-6077-gc010b2f

Still not reproducible enough to bisect it.

Thanks,

	Ingo

------------------>
[traced on the client, dione]

10:03:23.590481 IP (tos 0x0, ttl 64, id 46098, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xb6ce), 1979565914:1979566450(536) ack 2260258133 win 5840
10:03:23.590593 IP (tos 0x0, ttl 64, id 19850, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5a6b (correct), 2260258133:2260258133(0) ack 1979566450 win 65535
10:03:23.590605 IP (tos 0x0, ttl 64, id 46099, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x2bd1), 1979631449:1979631985(536) ack 2260258133 win 5840
10:03:23.590693 IP (tos 0x0, ttl 64, id 19851, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5a6b (correct), 2260258133:2260258133(0) ack 1979566450 win 65535
10:05:23.590442 IP (tos 0x0, ttl 64, id 46100, offset 0, flags [DF], proto TCP (6), length 183) dione.40344 > phoenix.distcc: ., cksum 0x16cc (incorrect (-> 0xc006), 1979566450:1979566593(143) ack 2260258133 win 5840
10:05:23.590580 IP (tos 0x0, ttl 64, id 19852, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x59dc (correct), 2260258133:2260258133(0) ack 1979566593 win 65535
10:05:23.590605 IP (tos 0x0, ttl 64, id 46101, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xa38a), 1979566593:1979567129(536) ack 2260258133 win 5840
10:05:23.590608 IP (tos 0x0, ttl 64, id 46102, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x7d22), 1979567129:1979567665(536) ack 2260258133 win 5840
10:05:23.590879 IP (tos 0x0, ttl 64, id 19853, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5a6b (correct), 2260258133:2260258133(0) ack 1979631985 win 65535
10:05:23.590976 IP (tos 0x0, ttl 64, id 46103, offset 0, flags [DF], proto TCP (6), length 1648) dione.40344 > phoenix.distcc: ., cksum 0x1c85 (incorrect (-> 0x2436), 1979631985:1979633593(1608) ack 2260258133 win 5840
10:05:23.590982 IP (tos 0x0, ttl 64, id 19854, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5a6b (correct), 2260258133:2260258133(0) ack 1979631985 win 65535
10:05:23.590986 IP (tos 0x0, ttl 64, id 46106, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x0eb7), 1979633593:1979634129(536) ack 2260258133 win 5840
10:05:23.591079 IP (tos 0x0, ttl 64, id 19855, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5853 (correct), 2260258133:2260258133(0) ack 1979632521 win 65535
10:05:23.591087 IP (tos 0x0, ttl 64, id 46107, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x3e75), 1979634129:1979634665(536) ack 2260258133 win 5840
10:05:23.591090 IP (tos 0x0, ttl 64, id 19856, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x563b (correct), 2260258133:2260258133(0) ack 1979633057 win 65535
10:05:23.591094 IP (tos 0x0, ttl 64, id 46108, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x48d3), 1979634665:1979635737(1072) ack 2260258133 win 5840
10:05:23.591098 IP (tos 0x0, ttl 64, id 19857, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5423 (correct), 2260258133:2260258133(0) ack 1979633593 win 65535
10:05:23.591103 IP (tos 0x0, ttl 64, id 46110, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xe7b1), 1979635737:1979636809(1072) ack 2260258133 win 5840
10:05:23.591107 IP (tos 0x0, ttl 64, id 19858, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x520b (correct), 2260258133:2260258133(0) ack 1979634129 win 65535
10:05:23.591111 IP (tos 0x0, ttl 64, id 46112, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x5fa7), 1979636809:1979637881(1072) ack 2260258133 win 5840
10:05:23.591179 IP (tos 0x0, ttl 64, id 19859, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4ff3 (correct), 2260258133:2260258133(0) ack 1979634665 win 65535
10:05:23.591186 IP (tos 0x0, ttl 64, id 46114, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x8a24), 1979637881:1979638953(1072) ack 2260258133 win 5840
10:05:23.591190 IP (tos 0x0, ttl 64, id 19860, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4ddb (correct), 2260258133:2260258133(0) ack 1979635201 win 65535
10:05:23.591194 IP (tos 0x0, ttl 64, id 46116, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x0da7), 1979638953:1979640025(1072) ack 2260258133 win 5840
10:05:23.591198 IP (tos 0x0, ttl 64, id 19861, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4bc3 (correct), 2260258133:2260258133(0) ack 1979635737 win 65535
10:05:23.591202 IP (tos 0x0, ttl 64, id 46118, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x7008), 1979640025:1979641097(1072) ack 2260258133 win 5840
10:05:23.591206 IP (tos 0x0, ttl 64, id 19862, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x49ab (correct), 2260258133:2260258133(0) ack 1979636273 win 65535
10:05:23.591210 IP (tos 0x0, ttl 64, id 46120, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x9591), 1979641097:1979642169(1072) ack 2260258133 win 5840
10:05:23.591214 IP (tos 0x0, ttl 64, id 19863, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4793 (correct), 2260258133:2260258133(0) ack 1979636809 win 65535
10:05:23.591219 IP (tos 0x0, ttl 64, id 46122, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x3377), 1979642169:1979643241(1072) ack 2260258133 win 5840
10:05:23.591222 IP (tos 0x0, ttl 64, id 19864, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x457b (correct), 2260258133:2260258133(0) ack 1979637345 win 65535
10:05:23.591228 IP (tos 0x0, ttl 64, id 46124, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xf421), 1979643241:1979644313(1072) ack 2260258133 win 5840
10:05:23.591232 IP (tos 0x0, ttl 64, id 19865, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4363 (correct), 2260258133:2260258133(0) ack 1979637881 win 65535
10:05:23.591236 IP (tos 0x0, ttl 64, id 46126, offset 0, flags [DF], proto TCP (6), length 433) dione.40344 > phoenix.distcc: ., cksum 0x17c6 (incorrect (-> 0x4f0c), 1979644313:1979644706(393) ack 2260258133 win 5840
10:05:23.591239 IP (tos 0x0, ttl 64, id 46127, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xd389), 1979644706:1979645242(536) ack 2260258133 win 5840
10:05:23.591254 IP (tos 0x0, ttl 64, id 19866, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x414b (correct), 2260258133:2260258133(0) ack 1979638417 win 65535
10:05:23.591257 IP (tos 0x0, ttl 64, id 46128, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x10ea), 1979645242:1979646314(1072) ack 2260258133 win 5840
10:05:23.591259 IP (tos 0x0, ttl 64, id 19867, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3f33 (correct), 2260258133:2260258133(0) ack 1979638953 win 65535
10:05:23.591262 IP (tos 0x0, ttl 64, id 46130, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x7867), 1979646314:1979647386(1072) ack 2260258133 win 5840
10:05:23.591264 IP (tos 0x0, ttl 64, id 19868, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3d1b (correct), 2260258133:2260258133(0) ack 1979639489 win 65535
10:05:23.591267 IP (tos 0x0, ttl 64, id 46132, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x0843), 1979647386:1979648458(1072) ack 2260258133 win 5840
10:05:23.591269 IP (tos 0x0, ttl 64, id 19869, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3b03 (correct), 2260258133:2260258133(0) ack 1979640025 win 65535
10:05:23.591272 IP (tos 0x0, ttl 64, id 46134, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x3bd3), 1979648458:1979649530(1072) ack 2260258133 win 5840
10:05:23.591274 IP (tos 0x0, ttl 64, id 19870, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x38eb (correct), 2260258133:2260258133(0) ack 1979640561 win 65535
10:05:23.591276 IP (tos 0x0, ttl 64, id 46136, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xe070), 1979649530:1979650602(1072) ack 2260258133 win 5840
10:05:23.591330 IP (tos 0x0, ttl 64, id 19871, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x36d3 (correct), 2260258133:2260258133(0) ack 1979641097 win 65535
10:05:23.591333 IP (tos 0x0, ttl 64, id 46138, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xc112), 1979650602:1979651674(1072) ack 2260258133 win 5840
10:05:23.591336 IP (tos 0x0, ttl 64, id 19872, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x34bb (correct), 2260258133:2260258133(0) ack 1979641633 win 65535
10:05:23.591338 IP (tos 0x0, ttl 64, id 46140, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x49a1), 1979651674:1979652746(1072) ack 2260258133 win 5840
10:05:23.591341 IP (tos 0x0, ttl 64, id 19873, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x32a3 (correct), 2260258133:2260258133(0) ack 1979642169 win 65535
10:05:23.591343 IP (tos 0x0, ttl 64, id 46142, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xd0d1), 1979652746:1979653818(1072) ack 2260258133 win 5840
10:05:23.591345 IP (tos 0x0, ttl 64, id 19874, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x308b (correct), 2260258133:2260258133(0) ack 1979642705 win 65535
10:05:23.591348 IP (tos 0x0, ttl 64, id 46144, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x835e), 1979653818:1979654890(1072) ack 2260258133 win 5840
10:05:23.591350 IP (tos 0x0, ttl 64, id 19875, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x2e73 (correct), 2260258133:2260258133(0) ack 1979643241 win 65535
10:05:23.591352 IP (tos 0x0, ttl 64, id 46146, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xffb0), 1979654890:1979655962(1072) ack 2260258133 win 5840
10:05:23.591354 IP (tos 0x0, ttl 64, id 19876, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x2c5b (correct), 2260258133:2260258133(0) ack 1979643777 win 65535
10:05:23.591357 IP (tos 0x0, ttl 64, id 46148, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x4b8d), 1979655962:1979656498(536) ack 2260258133 win 5840
10:05:23.591359 IP (tos 0x0, ttl 64, id 19877, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x2a43 (correct), 2260258133:2260258133(0) ack 1979644313 win 65535
10:05:23.591361 IP (tos 0x0, ttl 64, id 46149, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x7825), 1979656498:1979657034(536) ack 2260258133 win 5840
10:05:23.591362 IP (tos 0x0, ttl 64, id 19878, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x28ba (correct), 2260258133:2260258133(0) ack 1979644706 win 65535
10:05:23.591364 IP (tos 0x0, ttl 64, id 46150, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xdf49), 1979657034:1979658106(1072) ack 2260258133 win 5840
10:05:23.591367 IP (tos 0x0, ttl 64, id 19879, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x26a2 (correct), 2260258133:2260258133(0) ack 1979645242 win 65535
10:05:23.591369 IP (tos 0x0, ttl 64, id 46152, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xcd06), 1979658106:1979658642(536) ack 2260258133 win 5840
10:05:23.591371 IP (tos 0x0, ttl 64, id 19880, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x248a (correct), 2260258133:2260258133(0) ack 1979645778 win 65535
10:05:23.591373 IP (tos 0x0, ttl 64, id 46153, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xf71e), 1979658642:1979659178(536) ack 2260258133 win 5840
10:05:23.591374 IP (tos 0x0, ttl 64, id 19881, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x2272 (correct), 2260258133:2260258133(0) ack 1979646314 win 65535
10:05:23.591377 IP (tos 0x0, ttl 64, id 46154, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x2b14), 1979659178:1979659714(536) ack 2260258133 win 5840
10:05:23.591378 IP (tos 0x0, ttl 64, id 19882, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x205a (correct), 2260258133:2260258133(0) ack 1979646850 win 65535
10:05:23.591381 IP (tos 0x0, ttl 64, id 46155, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xb4b3), 1979659714:1979660250(536) ack 2260258133 win 5840
10:05:23.591382 IP (tos 0x0, ttl 64, id 19883, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1e42 (correct), 2260258133:2260258133(0) ack 1979647386 win 65535
10:05:23.591384 IP (tos 0x0, ttl 64, id 46156, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xfe09), 1979660250:1979661322(1072) ack 2260258133 win 5840
10:05:23.591387 IP (tos 0x0, ttl 64, id 19884, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1c2a (correct), 2260258133:2260258133(0) ack 1979647922 win 65535
10:05:23.591389 IP (tos 0x0, ttl 64, id 46158, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x0961), 1979661322:1979661858(536) ack 2260258133 win 5840
10:05:23.591391 IP (tos 0x0, ttl 64, id 19885, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1a12 (correct), 2260258133:2260258133(0) ack 1979648458 win 65535
10:05:23.591392 IP (tos 0x0, ttl 64, id 46159, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xacb2), 1979661858:1979662394(536) ack 2260258133 win 5840
10:05:23.591427 IP (tos 0x0, ttl 64, id 19886, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x17fa (correct), 2260258133:2260258133(0) ack 1979648994 win 65535
10:05:23.591431 IP (tos 0x0, ttl 64, id 46160, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x0efd), 1979662394:1979662930(536) ack 2260258133 win 5840
10:05:23.591433 IP (tos 0x0, ttl 64, id 19887, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x15e2 (correct), 2260258133:2260258133(0) ack 1979649530 win 65535
10:05:23.591434 IP (tos 0x0, ttl 64, id 46161, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x79a1), 1979662930:1979663466(536) ack 2260258133 win 5840
10:05:23.591436 IP (tos 0x0, ttl 64, id 19888, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x13ca (correct), 2260258133:2260258133(0) ack 1979650066 win 65535
10:05:23.591438 IP (tos 0x0, ttl 64, id 46162, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xc709), 1979663466:1979664002(536) ack 2260258133 win 5840
10:05:23.591440 IP (tos 0x0, ttl 64, id 19889, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x11b2 (correct), 2260258133:2260258133(0) ack 1979650602 win 65535
10:05:23.591442 IP (tos 0x0, ttl 64, id 46163, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x6bcf), 1979664002:1979664538(536) ack 2260258133 win 5840
10:05:23.591443 IP (tos 0x0, ttl 64, id 19890, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0f9a (correct), 2260258133:2260258133(0) ack 1979651138 win 65535
10:05:23.591446 IP (tos 0x0, ttl 64, id 46164, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xc469), 1979664538:1979665610(1072) ack 2260258133 win 5840
10:05:23.591448 IP (tos 0x0, ttl 64, id 19891, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0d82 (correct), 2260258133:2260258133(0) ack 1979651674 win 65535
10:05:23.591450 IP (tos 0x0, ttl 64, id 46166, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xbd17), 1979665610:1979666146(536) ack 2260258133 win 5840
10:05:23.591452 IP (tos 0x0, ttl 64, id 19892, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0b6a (correct), 2260258133:2260258133(0) ack 1979652210 win 65535
10:05:23.591455 IP (tos 0x0, ttl 64, id 46167, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x5899), 1979666146:1979666682(536) ack 2260258133 win 5840
10:05:23.591456 IP (tos 0x0, ttl 64, id 19893, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0952 (correct), 2260258133:2260258133(0) ack 1979652746 win 65535
10:05:23.591458 IP (tos 0x0, ttl 64, id 46168, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xd662), 1979666682:1979667218(536) ack 2260258133 win 5840
10:05:23.591460 IP (tos 0x0, ttl 64, id 19894, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x073a (correct), 2260258133:2260258133(0) ack 1979653282 win 65535
10:05:23.591462 IP (tos 0x0, ttl 64, id 46169, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xc61f), 1979667218:1979667754(536) ack 2260258133 win 5840
10:05:23.591478 IP (tos 0x0, ttl 64, id 19895, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0522 (correct), 2260258133:2260258133(0) ack 1979653818 win 65535
10:05:23.591481 IP (tos 0x0, ttl 64, id 46170, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x85e0), 1979667754:1979668290(536) ack 2260258133 win 5840
10:05:23.591483 IP (tos 0x0, ttl 64, id 19896, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x030a (correct), 2260258133:2260258133(0) ack 1979654354 win 65535
10:05:23.591486 IP (tos 0x0, ttl 64, id 46171, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xaa37), 1979668290:1979668826(536) ack 2260258133 win 5840
10:05:23.591487 IP (tos 0x0, ttl 64, id 19897, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x00f2 (correct), 2260258133:2260258133(0) ack 1979654890 win 65535
10:05:23.591489 IP (tos 0x0, ttl 64, id 46172, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x01c9), 1979668826:1979669362(536) ack 2260258133 win 5840
10:05:23.591491 IP (tos 0x0, ttl 64, id 19898, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xfed9 (correct), 2260258133:2260258133(0) ack 1979655426 win 65535
10:05:23.591494 IP (tos 0x0, ttl 64, id 46173, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xe9d9), 1979669362:1979669898(536) ack 2260258133 win 5840
10:05:23.591497 IP (tos 0x0, ttl 64, id 19899, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xfcc1 (correct), 2260258133:2260258133(0) ack 1979655962 win 65535
10:05:23.591499 IP (tos 0x0, ttl 64, id 46174, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xea9c), 1979669898:1979670434(536) ack 2260258133 win 5840
10:05:23.591528 IP (tos 0x0, ttl 64, id 19900, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xfaa9 (correct), 2260258133:2260258133(0) ack 1979656498 win 65535
10:05:23.591531 IP (tos 0x0, ttl 64, id 46175, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xeb5e), 1979670434:1979670970(536) ack 2260258133 win 5840
10:05:23.591533 IP (tos 0x0, ttl 64, id 19901, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf891 (correct), 2260258133:2260258133(0) ack 1979657034 win 65535
10:05:23.591535 IP (tos 0x0, ttl 64, id 46176, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x80a0), 1979670970:1979671506(536) ack 2260258133 win 5840
10:05:23.591536 IP (tos 0x0, ttl 64, id 19902, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf679 (correct), 2260258133:2260258133(0) ack 1979657570 win 65535
10:05:23.591539 IP (tos 0x0, ttl 64, id 46177, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x8520), 1979671506:1979672042(536) ack 2260258133 win 5840
10:05:23.591540 IP (tos 0x0, ttl 64, id 19903, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf461 (correct), 2260258133:2260258133(0) ack 1979658106 win 65535
10:05:23.591543 IP (tos 0x0, ttl 64, id 46178, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x52db), 1979672042:1979672578(536) ack 2260258133 win 5840
10:05:23.591544 IP (tos 0x0, ttl 64, id 19904, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf249 (correct), 2260258133:2260258133(0) ack 1979658642 win 65535
10:05:23.591546 IP (tos 0x0, ttl 64, id 46179, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x2fce), 1979672578:1979673650(1072) ack 2260258133 win 5840
10:05:23.591549 IP (tos 0x0, ttl 64, id 19905, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf031 (correct), 2260258133:2260258133(0) ack 1979659178 win 65535
10:05:23.591551 IP (tos 0x0, ttl 64, id 46181, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x7537), 1979673650:1979674186(536) ack 2260258133 win 5840
10:05:23.591553 IP (tos 0x0, ttl 64, id 19906, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xee19 (correct), 2260258133:2260258133(0) ack 1979659714 win 65535
10:05:23.591555 IP (tos 0x0, ttl 64, id 46182, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x5a7a), 1979674186:1979674722(536) ack 2260258133 win 5840
10:05:23.591556 IP (tos 0x0, ttl 64, id 19907, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xec01 (correct), 2260258133:2260258133(0) ack 1979660250 win 65535
10:05:23.591558 IP (tos 0x0, ttl 64, id 46183, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x8257), 1979674722:1979675258(536) ack 2260258133 win 5840
10:05:23.591578 IP (tos 0x0, ttl 64, id 19908, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe9e9 (correct), 2260258133:2260258133(0) ack 1979660786 win 65535
10:05:23.591582 IP (tos 0x0, ttl 64, id 46184, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x0c07), 1979675258:1979675794(536) ack 2260258133 win 5840
10:05:23.591583 IP (tos 0x0, ttl 64, id 19909, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe7d1 (correct), 2260258133:2260258133(0) ack 1979661322 win 65535
10:05:23.591586 IP (tos 0x0, ttl 64, id 46185, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x4cec), 1979675794:1979676330(536) ack 2260258133 win 5840
10:05:23.591587 IP (tos 0x0, ttl 64, id 19910, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe5b9 (correct), 2260258133:2260258133(0) ack 1979661858 win 65535
10:05:23.591589 IP (tos 0x0, ttl 64, id 46186, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x3599), 1979676330:1979676866(536) ack 2260258133 win 5840
10:05:23.591590 IP (tos 0x0, ttl 64, id 19911, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe3a1 (correct), 2260258133:2260258133(0) ack 1979662394 win 65535
10:05:23.591592 IP (tos 0x0, ttl 64, id 46187, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x8a1b), 1979676866:1979677402(536) ack 2260258133 win 5840
10:05:23.591593 IP (tos 0x0, ttl 64, id 19912, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe189 (correct), 2260258133:2260258133(0) ack 1979662930 win 65535
10:05:23.591596 IP (tos 0x0, ttl 64, id 46188, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x2335), 1979677402:1979677938(536) ack 2260258133 win 5840
10:05:23.591597 IP (tos 0x0, ttl 64, id 19913, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xdf71 (correct), 2260258133:2260258133(0) ack 1979663466 win 65535
10:05:23.591599 IP (tos 0x0, ttl 64, id 46189, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x2c5e), 1979677938:1979678474(536) ack 2260258133 win 5840
10:05:23.591601 IP (tos 0x0, ttl 64, id 19914, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xdd59 (correct), 2260258133:2260258133(0) ack 1979664002 win 65535
10:05:23.591604 IP (tos 0x0, ttl 64, id 46190, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xaa8b), 1979678474:1979679010(536) ack 2260258133 win 5840
10:05:23.591607 IP (tos 0x0, ttl 64, id 19915, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xdb41 (correct), 2260258133:2260258133(0) ack 1979664538 win 65535
10:05:23.591609 IP (tos 0x0, ttl 64, id 46191, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xd126), 1979679010:1979679546(536) ack 2260258133 win 5840
10:05:23.591611 IP (tos 0x0, ttl 64, id 19916, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xd929 (correct), 2260258133:2260258133(0) ack 1979665074 win 65535
10:05:23.591614 IP (tos 0x0, ttl 64, id 46192, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xba76), 1979679546:1979680082(536) ack 2260258133 win 5840
10:05:23.591615 IP (tos 0x0, ttl 64, id 19917, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xd711 (correct), 2260258133:2260258133(0) ack 1979665610 win 65535
10:05:23.591617 IP (tos 0x0, ttl 64, id 46193, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x774f), 1979680082:1979680618(536) ack 2260258133 win 5840
10:05:23.591678 IP (tos 0x0, ttl 64, id 19918, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xd4f9 (correct), 2260258133:2260258133(0) ack 1979666146 win 65535
10:05:23.591681 IP (tos 0x0, ttl 64, id 46194, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x603a), 1979680618:1979681154(536) ack 2260258133 win 5840
10:05:23.591683 IP (tos 0x0, ttl 64, id 19919, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xd2e1 (correct), 2260258133:2260258133(0) ack 1979666682 win 65535
10:05:23.591686 IP (tos 0x0, ttl 64, id 46195, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x544a), 1979681154:1979681690(536) ack 2260258133 win 5840
10:05:23.591687 IP (tos 0x0, ttl 64, id 19920, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xd0c9 (correct), 2260258133:2260258133(0) ack 1979667218 win 65535
10:05:23.591689 IP (tos 0x0, ttl 64, id 46196, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xc45b), 1979681690:1979682226(536) ack 2260258133 win 5840
10:05:23.591690 IP (tos 0x0, ttl 64, id 19921, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xceb1 (correct), 2260258133:2260258133(0) ack 1979667754 win 65535
10:05:23.591693 IP (tos 0x0, ttl 64, id 46197, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xf8bc), 1979682226:1979682762(536) ack 2260258133 win 5840
10:05:23.591694 IP (tos 0x0, ttl 64, id 19922, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xcc99 (correct), 2260258133:2260258133(0) ack 1979668290 win 65535
10:05:23.591696 IP (tos 0x0, ttl 64, id 46198, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xf997), 1979682762:1979683298(536) ack 2260258133 win 5840
10:05:23.591697 IP (tos 0x0, ttl 64, id 19923, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xca81 (correct), 2260258133:2260258133(0) ack 1979668826 win 65535
10:05:23.591699 IP (tos 0x0, ttl 64, id 46199, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x4b6b), 1979683298:1979683834(536) ack 2260258133 win 5840
10:05:23.591701 IP (tos 0x0, ttl 64, id 19924, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xc869 (correct), 2260258133:2260258133(0) ack 1979669362 win 65535
10:05:23.591703 IP (tos 0x0, ttl 64, id 46200, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x9b8b), 1979683834:1979684370(536) ack 2260258133 win 5840
10:05:23.591704 IP (tos 0x0, ttl 64, id 19925, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xc651 (correct), 2260258133:2260258133(0) ack 1979669898 win 65535
10:05:23.591707 IP (tos 0x0, ttl 64, id 46201, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xd84e), 1979684370:1979684906(536) ack 2260258133 win 5840
10:05:23.591708 IP (tos 0x0, ttl 64, id 19926, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xc439 (correct), 2260258133:2260258133(0) ack 1979670434 win 65535
10:05:23.591710 IP (tos 0x0, ttl 64, id 46202, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x2b48), 1979684906:1979685442(536) ack 2260258133 win 5840
10:05:23.591712 IP (tos 0x0, ttl 64, id 19927, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xc221 (correct), 2260258133:2260258133(0) ack 1979670970 win 65535
10:05:23.591713 IP (tos 0x0, ttl 64, id 46203, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x5916), 1979685442:1979685978(536) ack 2260258133 win 5840
10:05:23.591715 IP (tos 0x0, ttl 64, id 19928, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xc009 (correct), 2260258133:2260258133(0) ack 1979671506 win 65535
10:05:23.591717 IP (tos 0x0, ttl 64, id 46204, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xbe9a), 1979685978:1979686514(536) ack 2260258133 win 5840
10:05:23.591719 IP (tos 0x0, ttl 64, id 19929, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xbdf1 (correct), 2260258133:2260258133(0) ack 1979672042 win 65535
10:05:23.591721 IP (tos 0x0, ttl 64, id 46205, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xb3b0), 1979686514:1979687050(536) ack 2260258133 win 5840
10:05:23.591722 IP (tos 0x0, ttl 64, id 19930, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xbbd9 (correct), 2260258133:2260258133(0) ack 1979672578 win 65535
10:05:23.591724 IP (tos 0x0, ttl 64, id 46206, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xa518), 1979687050:1979688122(1072) ack 2260258133 win 5840
10:05:23.591726 IP (tos 0x0, ttl 64, id 19931, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xb9c1 (correct), 2260258133:2260258133(0) ack 1979673114 win 65535
10:05:23.591729 IP (tos 0x0, ttl 64, id 46208, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x247f), 1979688122:1979688658(536) ack 2260258133 win 5840
10:05:23.591730 IP (tos 0x0, ttl 64, id 19932, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xb7a9 (correct), 2260258133:2260258133(0) ack 1979673650 win 65535
10:05:23.591732 IP (tos 0x0, ttl 64, id 46209, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xdc70), 1979688658:1979689194(536) ack 2260258133 win 5840
10:05:23.591734 IP (tos 0x0, ttl 64, id 19933, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xb591 (correct), 2260258133:2260258133(0) ack 1979674186 win 65535
10:05:23.591736 IP (tos 0x0, ttl 64, id 46210, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xc420), 1979689194:1979689730(536) ack 2260258133 win 5840
10:05:23.591739 IP (tos 0x0, ttl 64, id 19934, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xb379 (correct), 2260258133:2260258133(0) ack 1979674722 win 65535
10:05:23.591741 IP (tos 0x0, ttl 64, id 46211, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x6b75), 1979689730:1979690266(536) ack 2260258133 win 5840
10:05:23.591743 IP (tos 0x0, ttl 64, id 19935, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xb161 (correct), 2260258133:2260258133(0) ack 1979675258 win 65535
10:05:23.591745 IP (tos 0x0, ttl 64, id 46212, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x9f8c), 1979690266:1979690802(536) ack 2260258133 win 5840
10:05:23.591746 IP (tos 0x0, ttl 64, id 19936, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xaf49 (correct), 2260258133:2260258133(0) ack 1979675794 win 65535
10:05:23.591748 IP (tos 0x0, ttl 64, id 46213, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xf695), 1979690802:1979691338(536) ack 2260258133 win 5840
10:05:23.591752 IP (tos 0x0, ttl 64, id 19937, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xad31 (correct), 2260258133:2260258133(0) ack 1979676330 win 65535
10:05:23.591755 IP (tos 0x0, ttl 64, id 46214, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x0f0f), 1979691338:1979691874(536) ack 2260258133 win 5840
10:05:23.591777 IP (tos 0x0, ttl 64, id 19938, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xab19 (correct), 2260258133:2260258133(0) ack 1979676866 win 65535
10:05:23.591780 IP (tos 0x0, ttl 64, id 46215, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x3612), 1979691874:1979692410(536) ack 2260258133 win 5840
10:05:23.591782 IP (tos 0x0, ttl 64, id 19939, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xa901 (correct), 2260258133:2260258133(0) ack 1979677402 win 65535
10:05:23.591784 IP (tos 0x0, ttl 64, id 46216, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xe8f0), 1979692410:1979692946(536) ack 2260258133 win 5840
10:05:23.591786 IP (tos 0x0, ttl 64, id 19940, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xa6e9 (correct), 2260258133:2260258133(0) ack 1979677938 win 65535
10:05:23.591788 IP (tos 0x0, ttl 64, id 46217, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x7b58), 1979692946:1979693482(536) ack 2260258133 win 5840
10:05:23.591789 IP (tos 0x0, ttl 64, id 19941, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xa4d1 (correct), 2260258133:2260258133(0) ack 1979678474 win 65535
10:05:23.591791 IP (tos 0x0, ttl 64, id 46218, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x4dcc), 1979693482:1979694018(536) ack 2260258133 win 5840
10:05:23.591792 IP (tos 0x0, ttl 64, id 19942, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xa2b9 (correct), 2260258133:2260258133(0) ack 1979679010 win 65535
10:05:23.591794 IP (tos 0x0, ttl 64, id 46219, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xe1c4), 1979694018:1979694554(536) ack 2260258133 win 5840
10:05:23.591796 IP (tos 0x0, ttl 64, id 19943, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xa0a1 (correct), 2260258133:2260258133(0) ack 1979679546 win 65535
10:05:23.591798 IP (tos 0x0, ttl 64, id 46220, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xba54), 1979694554:1979695090(536) ack 2260258133 win 5840
10:05:23.591800 IP (tos 0x0, ttl 64, id 19944, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x9e89 (correct), 2260258133:2260258133(0) ack 1979680082 win 65535
10:05:23.591802 IP (tos 0x0, ttl 64, id 46221, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xf5a2), 1979695090:1979695626(536) ack 2260258133 win 5840
10:05:23.591803 IP (tos 0x0, ttl 64, id 19945, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x9c71 (correct), 2260258133:2260258133(0) ack 1979680618 win 65535
10:05:23.591805 IP (tos 0x0, ttl 64, id 46222, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x490c), 1979695626:1979696162(536) ack 2260258133 win 5840
10:05:23.591807 IP (tos 0x0, ttl 64, id 19946, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x9a59 (correct), 2260258133:2260258133(0) ack 1979681154 win 65535
10:05:23.591811 IP (tos 0x0, ttl 64, id 46223, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x5eac), 1979696162:1979696698(536) ack 2260258133 win 5840
10:05:23.591812 IP (tos 0x0, ttl 64, id 19947, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x9841 (correct), 2260258133:2260258133(0) ack 1979681690 win 65535
10:05:23.591814 IP (tos 0x0, ttl 64, id 46224, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x08a7), 1979696698:1979697234(536) ack 2260258133 win 5840
10:05:23.591816 IP (tos 0x0, ttl 64, id 19948, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x9629 (correct), 2260258133:2260258133(0) ack 1979682226 win 65535
10:05:23.591818 IP (tos 0x0, ttl 64, id 46225, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x6d23), 1979697234:1979697770(536) ack 2260258133 win 5840
10:05:23.591819 IP (tos 0x0, ttl 64, id 19949, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x9411 (correct), 2260258133:2260258133(0) ack 1979682762 win 65535
10:05:23.591821 IP (tos 0x0, ttl 64, id 46226, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xc833), 1979697770:1979698306(536) ack 2260258133 win 5840
10:05:23.591823 IP (tos 0x0, ttl 64, id 19950, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x91f9 (correct), 2260258133:2260258133(0) ack 1979683298 win 65535
10:05:23.591825 IP (tos 0x0, ttl 64, id 46227, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x78e9), 1979698306:1979698842(536) ack 2260258133 win 5840
10:05:23.591827 IP (tos 0x0, ttl 64, id 19951, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8fe1 (correct), 2260258133:2260258133(0) ack 1979683834 win 65535
10:05:23.591829 IP (tos 0x0, ttl 64, id 46228, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xc1db), 1979698842:1979699378(536) ack 2260258133 win 5840
10:05:23.591831 IP (tos 0x0, ttl 64, id 19952, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8dc9 (correct), 2260258133:2260258133(0) ack 1979684370 win 65535
10:05:23.591833 IP (tos 0x0, ttl 64, id 46229, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xcd2a), 1979699378:1979699914(536) ack 2260258133 win 5840
10:05:23.591834 IP (tos 0x0, ttl 64, id 19953, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8bb1 (correct), 2260258133:2260258133(0) ack 1979684906 win 65535
10:05:23.591836 IP (tos 0x0, ttl 64, id 46230, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x347f), 1979699914:1979700450(536) ack 2260258133 win 5840
10:05:23.591839 IP (tos 0x0, ttl 64, id 19954, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8999 (correct), 2260258133:2260258133(0) ack 1979685442 win 65535
10:05:23.591842 IP (tos 0x0, ttl 64, id 19955, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8781 (correct), 2260258133:2260258133(0) ack 1979685978 win 65535
10:05:23.591846 IP (tos 0x0, ttl 64, id 19956, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8569 (correct), 2260258133:2260258133(0) ack 1979686514 win 65535
10:05:23.591851 IP (tos 0x0, ttl 64, id 19957, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8351 (correct), 2260258133:2260258133(0) ack 1979687050 win 65535
10:05:23.591929 IP (tos 0x0, ttl 64, id 19962, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x78d9 (correct), 2260258133:2260258133(0) ack 1979689730 win 65535
10:05:23.591932 IP (tos 0x0, ttl 64, id 46240, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x0a1e), 1979705274:1979705810(536) ack 2260258133 win 5840
10:05:23.591934 IP (tos 0x0, ttl 64, id 19963, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x76c1 (correct), 2260258133:2260258133(0) ack 1979690266 win 65535
10:05:23.591936 IP (tos 0x0, ttl 64, id 46241, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x6f73), 1979705810:1979706346(536) ack 2260258133 win 5840
10:05:23.591938 IP (tos 0x0, ttl 64, id 19964, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x74a9 (correct), 2260258133:2260258133(0) ack 1979690802 win 65535
10:05:23.591940 IP (tos 0x0, ttl 64, id 46242, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xd5d3), 1979706346:1979706882(536) ack 2260258133 win 5840
10:05:23.591941 IP (tos 0x0, ttl 64, id 19965, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x7291 (correct), 2260258133:2260258133(0) ack 1979691338 win 65535
10:05:23.591943 IP (tos 0x0, ttl 64, id 46243, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x46e8), 1979706882:1979707418(536) ack 2260258133 win 5840
10:05:23.591944 IP (tos 0x0, ttl 64, id 19966, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x7079 (correct), 2260258133:2260258133(0) ack 1979691874 win 65535
10:05:23.591946 IP (tos 0x0, ttl 64, id 46244, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xc9ee), 1979707418:1979707954(536) ack 2260258133 win 5840
10:05:23.591948 IP (tos 0x0, ttl 64, id 19967, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x6e61 (correct), 2260258133:2260258133(0) ack 1979692410 win 65535
10:05:23.591950 IP (tos 0x0, ttl 64, id 46245, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x1cc0), 1979707954:1979708490(536) ack 2260258133 win 5840
10:05:23.591951 IP (tos 0x0, ttl 64, id 19968, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x6c49 (correct), 2260258133:2260258133(0) ack 1979692946 win 65535
10:05:23.592525 IP (tos 0x0, ttl 64, id 19969, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x6a31 (correct), 2260258133:2260258133(0) ack 1979693482 win 65535
10:05:23.592528 IP (tos 0x0, ttl 64, id 46247, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x5666), 1979709026:1979709562(536) ack 2260258133 win 5840
10:05:23.592530 IP (tos 0x0, ttl 64, id 19970, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x6819 (correct), 2260258133:2260258133(0) ack 1979694018 win 65535
10:05:23.592532 IP (tos 0x0, ttl 64, id 46248, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: P, cksum 0x1855 (incorrect (-> 0x8fb5), 1979709562:1979710098(536) ack 2260258133 win 5840
10:05:23.592533 IP (tos 0x0, ttl 64, id 19971, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x6601 (correct), 2260258133:2260258133(0) ack 1979694554 win 65535
10:05:23.592536 IP (tos 0x0, ttl 64, id 46249, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xbea5), 1979710098:1979710634(536) ack 2260258133 win 5840
10:05:23.592538 IP (tos 0x0, ttl 64, id 19972, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x63e9 (correct), 2260258133:2260258133(0) ack 1979695090 win 65535
10:05:23.592540 IP (tos 0x0, ttl 64, id 46250, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x4592), 1979710634:1979711170(536) ack 2260258133 win 5840
10:05:23.592541 IP (tos 0x0, ttl 64, id 19973, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x61d1 (correct), 2260258133:2260258133(0) ack 1979695626 win 65535
10:05:23.592543 IP (tos 0x0, ttl 64, id 46251, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x850b), 1979711170:1979711706(536) ack 2260258133 win 5840
10:05:23.592544 IP (tos 0x0, ttl 64, id 19974, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5fb9 (correct), 2260258133:2260258133(0) ack 1979696162 win 65535
10:05:23.592546 IP (tos 0x0, ttl 64, id 46252, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xb083), 1979711706:1979712242(536) ack 2260258133 win 5840
10:05:23.592547 IP (tos 0x0, ttl 64, id 19975, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5da1 (correct), 2260258133:2260258133(0) ack 1979696698 win 65535
10:05:23.592549 IP (tos 0x0, ttl 64, id 46253, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x2a6c), 1979712242:1979712778(536) ack 2260258133 win 5840
10:05:23.592551 IP (tos 0x0, ttl 64, id 19976, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5b89 (correct), 2260258133:2260258133(0) ack 1979697234 win 65535
10:05:23.592553 IP (tos 0x0, ttl 64, id 46254, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x48bc), 1979712778:1979713314(536) ack 2260258133 win 5840
10:05:23.592554 IP (tos 0x0, ttl 64, id 19977, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5971 (correct), 2260258133:2260258133(0) ack 1979697770 win 65535
10:05:23.592557 IP (tos 0x0, ttl 64, id 46255, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x12b7), 1979713314:1979713850(536) ack 2260258133 win 5840
10:05:23.592558 IP (tos 0x0, ttl 64, id 19978, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5759 (correct), 2260258133:2260258133(0) ack 1979698306 win 65535
10:05:23.592561 IP (tos 0x0, ttl 64, id 46256, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x94da), 1979713850:1979714386(536) ack 2260258133 win 5840
10:05:23.592562 IP (tos 0x0, ttl 64, id 19979, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5541 (correct), 2260258133:2260258133(0) ack 1979698842 win 65535
10:05:23.592564 IP (tos 0x0, ttl 64, id 46257, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x7562), 1979714386:1979714922(536) ack 2260258133 win 5840
10:05:23.592565 IP (tos 0x0, ttl 64, id 19980, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5329 (correct), 2260258133:2260258133(0) ack 1979699378 win 65535
10:05:23.592568 IP (tos 0x0, ttl 64, id 46258, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x7053), 1979714922:1979715458(536) ack 2260258133 win 5840
10:05:23.592569 IP (tos 0x0, ttl 64, id 19981, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5111 (correct), 2260258133:2260258133(0) ack 1979699914 win 65535
10:05:23.592571 IP (tos 0x0, ttl 64, id 46259, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x227a), 1979715458:1979715994(536) ack 2260258133 win 5840
10:05:23.592572 IP (tos 0x0, ttl 64, id 19982, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4ef9 (correct), 2260258133:2260258133(0) ack 1979700450 win 65535
10:05:23.592574 IP (tos 0x0, ttl 64, id 46260, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x6540), 1979715994:1979717066(1072) ack 2260258133 win 5840
10:05:23.592576 IP (tos 0x0, ttl 64, id 19983, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4ce1 (correct), 2260258133:2260258133(0) ack 1979700986 win 65535
10:05:23.592579 IP (tos 0x0, ttl 64, id 46262, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xb7e1), 1979717066:1979717602(536) ack 2260258133 win 5840
10:05:23.592580 IP (tos 0x0, ttl 64, id 19984, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4ac9 (correct), 2260258133:2260258133(0) ack 1979701522 win 65535
10:05:23.592583 IP (tos 0x0, ttl 64, id 46263, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xa084), 1979717602:1979718138(536) ack 2260258133 win 5840
10:05:23.592585 IP (tos 0x0, ttl 64, id 19985, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x48b1 (correct), 2260258133:2260258133(0) ack 1979702058 win 65535
10:05:23.592587 IP (tos 0x0, ttl 64, id 46264, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x364b), 1979718138:1979718674(536) ack 2260258133 win 5840
10:05:23.592589 IP (tos 0x0, ttl 64, id 19986, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4699 (correct), 2260258133:2260258133(0) ack 1979702594 win 65535
10:05:23.592591 IP (tos 0x0, ttl 64, id 46265, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x3872), 1979718674:1979719210(536) ack 2260258133 win 5840
10:05:23.592592 IP (tos 0x0, ttl 64, id 19987, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4481 (correct), 2260258133:2260258133(0) ack 1979703130 win 65535
10:05:23.592595 IP (tos 0x0, ttl 64, id 46266, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x2200), 1979719210:1979719746(536) ack 2260258133 win 5840
10:05:23.592596 IP (tos 0x0, ttl 64, id 19988, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4269 (correct), 2260258133:2260258133(0) ack 1979703666 win 65535
10:05:23.592598 IP (tos 0x0, ttl 64, id 46267, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x0837), 1979719746:1979720282(536) ack 2260258133 win 5840
10:05:23.592599 IP (tos 0x0, ttl 64, id 19989, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3e39 (correct), 2260258133:2260258133(0) ack 1979704738 win 65535
10:05:23.592601 IP (tos 0x0, ttl 64, id 46268, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xd07f), 1979720282:1979721354(1072) ack 2260258133 win 5840
10:05:23.592604 IP (tos 0x0, ttl 64, id 19990, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3a09 (correct), 2260258133:2260258133(0) ack 1979705810 win 65535
10:05:23.592606 IP (tos 0x0, ttl 64, id 46270, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x3c59), 1979721354:1979722426(1072) ack 2260258133 win 5840
10:05:23.592608 IP (tos 0x0, ttl 64, id 19991, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x35d9 (correct), 2260258133:2260258133(0) ack 1979706882 win 65535
10:05:23.592611 IP (tos 0x0, ttl 64, id 46272, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x6f49), 1979722426:1979723498(1072) ack 2260258133 win 5840
10:05:23.592613 IP (tos 0x0, ttl 64, id 19992, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x31a9 (correct), 2260258133:2260258133(0) ack 1979707954 win 65535
10:05:23.592615 IP (tos 0x0, ttl 64, id 46274, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xf4f1), 1979723498:1979724570(1072) ack 2260258133 win 5840
10:05:23.592628 IP (tos 0x0, ttl 64, id 19993, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x2d79 (correct), 2260258133:2260258133(0) ack 1979709026 win 65535
10:05:23.592631 IP (tos 0x0, ttl 64, id 46276, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xcdd6), 1979724570:1979725642(1072) ack 2260258133 win 5840
10:05:23.592633 IP (tos 0x0, ttl 64, id 19994, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x2949 (correct), 2260258133:2260258133(0) ack 1979710098 win 65535
10:05:23.592635 IP (tos 0x0, ttl 64, id 46278, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x2b34), 1979725642:1979726714(1072) ack 2260258133 win 5840
10:05:23.592637 IP (tos 0x0, ttl 64, id 19995, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x2519 (correct), 2260258133:2260258133(0) ack 1979711170 win 65535
10:05:23.592639 IP (tos 0x0, ttl 64, id 46280, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x5e7b), 1979726714:1979727786(1072) ack 2260258133 win 5840
10:05:23.592641 IP (tos 0x0, ttl 64, id 19996, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x20e9 (correct), 2260258133:2260258133(0) ack 1979712242 win 65535
10:05:23.592643 IP (tos 0x0, ttl 64, id 46282, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x20e4), 1979727786:1979728858(1072) ack 2260258133 win 5840
10:05:23.592645 IP (tos 0x0, ttl 64, id 19997, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1cb9 (correct), 2260258133:2260258133(0) ack 1979713314 win 65535
10:05:23.592648 IP (tos 0x0, ttl 64, id 46284, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x4d20), 1979728858:1979729930(1072) ack 2260258133 win 5840
10:05:23.592650 IP (tos 0x0, ttl 64, id 19998, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1889 (correct), 2260258133:2260258133(0) ack 1979714386 win 65535
10:05:23.592652 IP (tos 0x0, ttl 64, id 46286, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x4346), 1979729930:1979731002(1072) ack 2260258133 win 5840
10:05:23.592654 IP (tos 0x0, ttl 64, id 19999, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1459 (correct), 2260258133:2260258133(0) ack 1979715458 win 65535
10:05:23.592656 IP (tos 0x0, ttl 64, id 46288, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xfadd), 1979731002:1979732074(1072) ack 2260258133 win 5840
10:05:23.592660 IP (tos 0x0, ttl 64, id 20000, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1029 (correct), 2260258133:2260258133(0) ack 1979716530 win 65535
10:05:23.592663 IP (tos 0x0, ttl 64, id 46290, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x622e), 1979732074:1979733146(1072) ack 2260258133 win 5840
10:05:23.592675 IP (tos 0x0, ttl 64, id 20001, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0bf9 (correct), 2260258133:2260258133(0) ack 1979717602 win 65535
10:05:23.592678 IP (tos 0x0, ttl 64, id 46292, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x87ff), 1979733146:1979734218(1072) ack 2260258133 win 5840
10:05:23.592681 IP (tos 0x0, ttl 64, id 20002, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x07c9 (correct), 2260258133:2260258133(0) ack 1979718674 win 65535
10:05:23.592683 IP (tos 0x0, ttl 64, id 46294, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x8c01), 1979734218:1979735290(1072) ack 2260258133 win 5840
10:05:23.592685 IP (tos 0x0, ttl 64, id 20003, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0399 (correct), 2260258133:2260258133(0) ack 1979719746 win 65535
10:05:23.592687 IP (tos 0x0, ttl 64, id 46296, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xc229), 1979735290:1979736362(1072) ack 2260258133 win 5840
10:05:23.592726 IP (tos 0x0, ttl 64, id 20004, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xff68 (correct), 2260258133:2260258133(0) ack 1979720818 win 65535
10:05:23.592729 IP (tos 0x0, ttl 64, id 46298, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x3c79), 1979736362:1979737434(1072) ack 2260258133 win 5840
10:05:23.592731 IP (tos 0x0, ttl 64, id 20005, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xfb38 (correct), 2260258133:2260258133(0) ack 1979721890 win 65535
10:05:23.592734 IP (tos 0x0, ttl 64, id 46300, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x4d00), 1979737434:1979738506(1072) ack 2260258133 win 5840
10:05:23.592736 IP (tos 0x0, ttl 64, id 20006, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf708 (correct), 2260258133:2260258133(0) ack 1979722962 win 65535
10:05:23.592738 IP (tos 0x0, ttl 64, id 46302, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xc88b), 1979738506:1979739578(1072) ack 2260258133 win 5840
10:05:23.592740 IP (tos 0x0, ttl 64, id 20007, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf2d8 (correct), 2260258133:2260258133(0) ack 1979724034 win 65535
10:05:23.592743 IP (tos 0x0, ttl 64, id 46304, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x252a), 1979739578:1979740650(1072) ack 2260258133 win 5840
10:05:23.592776 IP (tos 0x0, ttl 64, id 20008, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xeea8 (correct), 2260258133:2260258133(0) ack 1979725106 win 65535
10:05:23.592780 IP (tos 0x0, ttl 64, id 46306, offset 0, flags [DF], proto TCP (6), length 1648) dione.40344 > phoenix.distcc: ., cksum 0x1c85 (incorrect (-> 0xe96f), 1979740650:1979742258(1608) ack 2260258133 win 5840
10:05:23.592782 IP (tos 0x0, ttl 64, id 20009, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xea78 (correct), 2260258133:2260258133(0) ack 1979726178 win 65535
10:05:23.592784 IP (tos 0x0, ttl 64, id 46309, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x41ec), 1979742258:1979742794(536) ack 2260258133 win 5840
10:05:23.592786 IP (tos 0x0, ttl 64, id 46310, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x7642), 1979742794:1979743330(536) ack 2260258133 win 5840
10:05:23.592787 IP (tos 0x0, ttl 64, id 20010, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe648 (correct), 2260258133:2260258133(0) ack 1979727250 win 65535
10:05:23.592790 IP (tos 0x0, ttl 64, id 46311, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x7309), 1979743330:1979744402(1072) ack 2260258133 win 5840
10:05:23.592792 IP (tos 0x0, ttl 64, id 20011, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe218 (correct), 2260258133:2260258133(0) ack 1979728322 win 65535
10:05:23.592795 IP (tos 0x0, ttl 64, id 46313, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xde30), 1979744402:1979745474(1072) ack 2260258133 win 5840
10:05:23.592825 IP (tos 0x0, ttl 64, id 20012, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xdde8 (correct), 2260258133:2260258133(0) ack 1979729394 win 65535
10:05:23.592829 IP (tos 0x0, ttl 64, id 46315, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xd0c5), 1979745474:1979746546(1072) ack 2260258133 win 5840
10:05:23.592831 IP (tos 0x0, ttl 64, id 20013, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xd9b8 (correct), 2260258133:2260258133(0) ack 1979730466 win 65535
10:05:23.592834 IP (tos 0x0, ttl 64, id 46317, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x0bde), 1979746546:1979747618(1072) ack 2260258133 win 5840
10:05:23.592836 IP (tos 0x0, ttl 64, id 20014, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xd588 (correct), 2260258133:2260258133(0) ack 1979731538 win 65535
10:05:23.592839 IP (tos 0x0, ttl 64, id 46319, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xbf84), 1979747618:1979748690(1072) ack 2260258133 win 5840
10:05:23.592875 IP (tos 0x0, ttl 64, id 20015, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xd158 (correct), 2260258133:2260258133(0) ack 1979732610 win 65535
10:05:23.592879 IP (tos 0x0, ttl 64, id 46321, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xf352), 1979748690:1979749762(1072) ack 2260258133 win 5840
10:05:23.592881 IP (tos 0x0, ttl 64, id 20016, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xcd28 (correct), 2260258133:2260258133(0) ack 1979733682 win 65535
10:05:23.592884 IP (tos 0x0, ttl 64, id 46323, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x4bd9), 1979749762:1979750834(1072) ack 2260258133 win 5840
10:05:23.592886 IP (tos 0x0, ttl 64, id 20017, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xc8f8 (correct), 2260258133:2260258133(0) ack 1979734754 win 65535
10:05:23.592889 IP (tos 0x0, ttl 64, id 46325, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x5806), 1979750834:1979751906(1072) ack 2260258133 win 5840
10:05:23.592926 IP (tos 0x0, ttl 64, id 20018, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xc4c8 (correct), 2260258133:2260258133(0) ack 1979735826 win 65535
10:05:23.592930 IP (tos 0x0, ttl 64, id 46327, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x2dda), 1979751906:1979752978(1072) ack 2260258133 win 5840
10:05:23.592932 IP (tos 0x0, ttl 64, id 20019, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xc098 (correct), 2260258133:2260258133(0) ack 1979736898 win 65535
10:05:23.592935 IP (tos 0x0, ttl 64, id 46329, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x0534), 1979752978:1979754050(1072) ack 2260258133 win 5840
10:05:23.592938 IP (tos 0x0, ttl 64, id 20020, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xbc68 (correct), 2260258133:2260258133(0) ack 1979737970 win 65535
10:05:23.592940 IP (tos 0x0, ttl 64, id 46331, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xe89d), 1979754050:1979755122(1072) ack 2260258133 win 5840
10:05:23.592975 IP (tos 0x0, ttl 64, id 20021, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xb838 (correct), 2260258133:2260258133(0) ack 1979739042 win 65535
10:05:23.592978 IP (tos 0x0, ttl 64, id 46333, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x58cb), 1979755122:1979756194(1072) ack 2260258133 win 5840
10:05:23.592980 IP (tos 0x0, ttl 64, id 20022, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xb408 (correct), 2260258133:2260258133(0) ack 1979740114 win 65535
10:05:23.592983 IP (tos 0x0, ttl 64, id 46335, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x5bf2), 1979756194:1979757266(1072) ack 2260258133 win 5840
10:05:23.592985 IP (tos 0x0, ttl 64, id 20023, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xafd8 (correct), 2260258133:2260258133(0) ack 1979741186 win 65535
10:05:23.592988 IP (tos 0x0, ttl 64, id 46337, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x4592), 1979757266:1979758338(1072) ack 2260258133 win 5840
10:05:23.592990 IP (tos 0x0, ttl 64, id 20024, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xaba8 (correct), 2260258133:2260258133(0) ack 1979742258 win 65535
10:05:23.592993 IP (tos 0x0, ttl 64, id 46339, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x6c1b), 1979758338:1979759410(1072) ack 2260258133 win 5840
10:05:23.592996 IP (tos 0x0, ttl 64, id 20025, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xa778 (correct), 2260258133:2260258133(0) ack 1979743330 win 65535
10:05:23.592999 IP (tos 0x0, ttl 64, id 46341, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x1f54), 1979759410:1979760482(1072) ack 2260258133 win 5840
10:05:23.593025 IP (tos 0x0, ttl 64, id 20026, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xa348 (correct), 2260258133:2260258133(0) ack 1979744402 win 65535
10:05:23.593028 IP (tos 0x0, ttl 64, id 46343, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xdab7), 1979760482:1979761554(1072) ack 2260258133 win 5840
10:05:23.593031 IP (tos 0x0, ttl 64, id 20027, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x9f18 (correct), 2260258133:2260258133(0) ack 1979745474 win 65535
10:05:23.593033 IP (tos 0x0, ttl 64, id 46345, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x45d7), 1979761554:1979762626(1072) ack 2260258133 win 5840
10:05:23.593075 IP (tos 0x0, ttl 64, id 20028, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x9ae8 (correct), 2260258133:2260258133(0) ack 1979746546 win 65535
10:05:23.593078 IP (tos 0x0, ttl 64, id 46347, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xd943), 1979762626:1979763698(1072) ack 2260258133 win 5840
10:05:23.593081 IP (tos 0x0, ttl 64, id 20029, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x96b8 (correct), 2260258133:2260258133(0) ack 1979747618 win 65535
10:05:23.593083 IP (tos 0x0, ttl 64, id 46349, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x93b7), 1979763698:1979764770(1072) ack 2260258133 win 5840
10:05:23.593126 IP (tos 0x0, ttl 64, id 20030, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x9288 (correct), 2260258133:2260258133(0) ack 1979748690 win 65535
10:05:23.593129 IP (tos 0x0, ttl 64, id 46351, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xcddd), 1979764770:1979765842(1072) ack 2260258133 win 5840
10:05:23.593131 IP (tos 0x0, ttl 64, id 20031, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8e58 (correct), 2260258133:2260258133(0) ack 1979749762 win 65535
10:05:23.593133 IP (tos 0x0, ttl 64, id 46353, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x4597), 1979765842:1979766914(1072) ack 2260258133 win 5840
10:05:23.593136 IP (tos 0x0, ttl 64, id 20032, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8a28 (correct), 2260258133:2260258133(0) ack 1979750834 win 65535
10:05:23.593138 IP (tos 0x0, ttl 64, id 46355, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x7032), 1979766914:1979767986(1072) ack 2260258133 win 5840
10:05:23.593140 IP (tos 0x0, ttl 64, id 20033, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x85f8 (correct), 2260258133:2260258133(0) ack 1979751906 win 65535
10:05:23.593142 IP (tos 0x0, ttl 64, id 46357, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xe4c4), 1979767986:1979769058(1072) ack 2260258133 win 5840
10:05:23.593144 IP (tos 0x0, ttl 64, id 20034, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x81c8 (correct), 2260258133:2260258133(0) ack 1979752978 win 65535
10:05:23.593146 IP (tos 0x0, ttl 64, id 46359, offset 0, flags [DF], proto TCP (6), length 1648) dione.40344 > phoenix.distcc: ., cksum 0x1c85 (incorrect (-> 0x3453), 1979769058:1979770666(1608) ack 2260258133 win 5840
10:05:23.593175 IP (tos 0x0, ttl 64, id 20035, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x7d98 (correct), 2260258133:2260258133(0) ack 1979754050 win 65535
10:05:23.593178 IP (tos 0x0, ttl 64, id 46362, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x63e6), 1979770666:1979771738(1072) ack 2260258133 win 5840
10:05:23.593180 IP (tos 0x0, ttl 64, id 20036, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x7968 (correct), 2260258133:2260258133(0) ack 1979755122 win 65535
10:05:23.593182 IP (tos 0x0, ttl 64, id 46364, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xdfe0), 1979771738:1979772810(1072) ack 2260258133 win 5840
10:05:23.593184 IP (tos 0x0, ttl 64, id 20037, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x7538 (correct), 2260258133:2260258133(0) ack 1979756194 win 65535
10:05:23.593186 IP (tos 0x0, ttl 64, id 46366, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x02c0), 1979772810:1979773882(1072) ack 2260258133 win 5840
10:05:23.593224 IP (tos 0x0, ttl 64, id 20038, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x7108 (correct), 2260258133:2260258133(0) ack 1979757266 win 65535
10:05:23.593228 IP (tos 0x0, ttl 64, id 46368, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x993d), 1979773882:1979774954(1072) ack 2260258133 win 5840
10:05:23.593230 IP (tos 0x0, ttl 64, id 20039, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x6cd8 (correct), 2260258133:2260258133(0) ack 1979758338 win 65535
10:05:23.593232 IP (tos 0x0, ttl 64, id 46370, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x3a5f), 1979774954:1979775490(536) ack 2260258133 win 5840
10:05:23.593234 IP (tos 0x0, ttl 64, id 46371, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x8d5f), 1979775490:1979776026(536) ack 2260258133 win 5840
10:05:23.593236 IP (tos 0x0, ttl 64, id 20040, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x68a8 (correct), 2260258133:2260258133(0) ack 1979759410 win 65535
10:05:23.593238 IP (tos 0x0, ttl 64, id 46372, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x3d19), 1979776026:1979777098(1072) ack 2260258133 win 5840
10:05:23.593241 IP (tos 0x0, ttl 64, id 20041, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x6478 (correct), 2260258133:2260258133(0) ack 1979760482 win 65535
10:05:23.593243 IP (tos 0x0, ttl 64, id 46374, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x30aa), 1979777098:1979778170(1072) ack 2260258133 win 5840
10:05:23.593276 IP (tos 0x0, ttl 64, id 20042, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x6048 (correct), 2260258133:2260258133(0) ack 1979761554 win 65535
10:05:23.593279 IP (tos 0x0, ttl 64, id 46376, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x45a2), 1979778170:1979779242(1072) ack 2260258133 win 5840
10:05:23.593282 IP (tos 0x0, ttl 64, id 20043, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5c18 (correct), 2260258133:2260258133(0) ack 1979762626 win 65535
10:05:23.593284 IP (tos 0x0, ttl 64, id 46378, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x24fe), 1979779242:1979780314(1072) ack 2260258133 win 5840
10:05:23.593286 IP (tos 0x0, ttl 64, id 20044, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x57e8 (correct), 2260258133:2260258133(0) ack 1979763698 win 65535
10:05:23.593289 IP (tos 0x0, ttl 64, id 46380, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x747e), 1979780314:1979781386(1072) ack 2260258133 win 5840
10:05:23.593324 IP (tos 0x0, ttl 64, id 20045, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x53b8 (correct), 2260258133:2260258133(0) ack 1979764770 win 65535
10:05:23.593327 IP (tos 0x0, ttl 64, id 46382, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x7b2c), 1979781386:1979782458(1072) ack 2260258133 win 5840
10:05:23.593329 IP (tos 0x0, ttl 64, id 20046, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4f88 (correct), 2260258133:2260258133(0) ack 1979765842 win 65535
10:05:23.593332 IP (tos 0x0, ttl 64, id 46384, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xe8d3), 1979782458:1979783530(1072) ack 2260258133 win 5840
10:05:23.593334 IP (tos 0x0, ttl 64, id 20047, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4b58 (correct), 2260258133:2260258133(0) ack 1979766914 win 65535
10:05:23.593336 IP (tos 0x0, ttl 64, id 46386, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x007d), 1979783530:1979784602(1072) ack 2260258133 win 5840
10:05:23.593375 IP (tos 0x0, ttl 64, id 20048, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4728 (correct), 2260258133:2260258133(0) ack 1979767986 win 65535
10:05:23.593378 IP (tos 0x0, ttl 64, id 46388, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xb086), 1979784602:1979785674(1072) ack 2260258133 win 5840
10:05:23.593380 IP (tos 0x0, ttl 64, id 20049, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x42f8 (correct), 2260258133:2260258133(0) ack 1979769058 win 65535
10:05:23.593382 IP (tos 0x0, ttl 64, id 46390, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xaf52), 1979785674:1979786746(1072) ack 2260258133 win 5840
10:05:23.593384 IP (tos 0x0, ttl 64, id 20050, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3ec8 (correct), 2260258133:2260258133(0) ack 1979770130 win 65535
10:05:23.593387 IP (tos 0x0, ttl 64, id 46392, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x0e0b), 1979786746:1979787818(1072) ack 2260258133 win 5840
10:05:23.593388 IP (tos 0x0, ttl 64, id 20051, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3a98 (correct), 2260258133:2260258133(0) ack 1979771202 win 65535
10:05:23.593391 IP (tos 0x0, ttl 64, id 46394, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x7680), 1979787818:1979788890(1072) ack 2260258133 win 5840
10:05:23.593425 IP (tos 0x0, ttl 64, id 20052, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3668 (correct), 2260258133:2260258133(0) ack 1979772274 win 65535
10:05:23.593429 IP (tos 0x0, ttl 64, id 46396, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x329f), 1979788890:1979789962(1072) ack 2260258133 win 5840
10:05:23.593431 IP (tos 0x0, ttl 64, id 20053, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3238 (correct), 2260258133:2260258133(0) ack 1979773346 win 65535
10:05:23.593434 IP (tos 0x0, ttl 64, id 46398, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x1cf9), 1979789962:1979791034(1072) ack 2260258133 win 5840
10:05:23.593436 IP (tos 0x0, ttl 64, id 20054, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x2e08 (correct), 2260258133:2260258133(0) ack 1979774418 win 65535
10:05:23.593438 IP (tos 0x0, ttl 64, id 46400, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x19f5), 1979791034:1979792106(1072) ack 2260258133 win 5840
10:05:23.593475 IP (tos 0x0, ttl 64, id 20055, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x29d8 (correct), 2260258133:2260258133(0) ack 1979775490 win 65535
10:05:23.593478 IP (tos 0x0, ttl 64, id 46402, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xb0fd), 1979792106:1979793178(1072) ack 2260258133 win 5840
10:05:23.593480 IP (tos 0x0, ttl 64, id 20056, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x25a8 (correct), 2260258133:2260258133(0) ack 1979776562 win 65535
10:05:23.593483 IP (tos 0x0, ttl 64, id 46404, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xb5e2), 1979793178:1979794250(1072) ack 2260258133 win 5840
10:05:23.593485 IP (tos 0x0, ttl 64, id 20057, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x2178 (correct), 2260258133:2260258133(0) ack 1979777634 win 65535
10:05:23.593487 IP (tos 0x0, ttl 64, id 46406, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xe950), 1979794250:1979795322(1072) ack 2260258133 win 5840
10:05:23.593524 IP (tos 0x0, ttl 64, id 20058, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1d48 (correct), 2260258133:2260258133(0) ack 1979778706 win 65535
10:05:23.593527 IP (tos 0x0, ttl 64, id 46408, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x9434), 1979795322:1979796394(1072) ack 2260258133 win 5840
10:05:23.593529 IP (tos 0x0, ttl 64, id 20059, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1918 (correct), 2260258133:2260258133(0) ack 1979779778 win 65535
10:05:23.593533 IP (tos 0x0, ttl 64, id 46410, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xb348), 1979796394:1979797466(1072) ack 2260258133 win 5840
10:05:23.593535 IP (tos 0x0, ttl 64, id 20060, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x14e8 (correct), 2260258133:2260258133(0) ack 1979780850 win 65535
10:05:23.593537 IP (tos 0x0, ttl 64, id 46412, offset 0, flags [DF], proto TCP (6), length 1648) dione.40344 > phoenix.distcc: ., cksum 0x1c85 (incorrect (-> 0xeb0a), 1979797466:1979799074(1608) ack 2260258133 win 5840
10:05:23.593539 IP (tos 0x0, ttl 64, id 20061, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x10b8 (correct), 2260258133:2260258133(0) ack 1979781922 win 65535
10:05:23.593542 IP (tos 0x0, ttl 64, id 46415, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x6ed1), 1979799074:1979800146(1072) ack 2260258133 win 5840
10:05:23.593574 IP (tos 0x0, ttl 64, id 20062, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0c88 (correct), 2260258133:2260258133(0) ack 1979782994 win 65535
10:05:23.593577 IP (tos 0x0, ttl 64, id 46417, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xed63), 1979800146:1979801218(1072) ack 2260258133 win 5840
10:05:23.593580 IP (tos 0x0, ttl 64, id 20063, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0858 (correct), 2260258133:2260258133(0) ack 1979784066 win 65535
10:05:23.593583 IP (tos 0x0, ttl 64, id 46419, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x2fc8), 1979801218:1979802290(1072) ack 2260258133 win 5840
10:05:23.593585 IP (tos 0x0, ttl 64, id 20064, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0428 (correct), 2260258133:2260258133(0) ack 1979785138 win 65535
10:05:23.593588 IP (tos 0x0, ttl 64, id 46421, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xbdec), 1979802290:1979803362(1072) ack 2260258133 win 5840
10:05:23.593625 IP (tos 0x0, ttl 64, id 20065, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xfff7 (correct), 2260258133:2260258133(0) ack 1979786210 win 65535
10:05:23.593629 IP (tos 0x0, ttl 64, id 46423, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x8d89), 1979803362:1979804434(1072) ack 2260258133 win 5840
10:05:23.593631 IP (tos 0x0, ttl 64, id 20066, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xfbc7 (correct), 2260258133:2260258133(0) ack 1979787282 win 65535
10:05:23.593634 IP (tos 0x0, ttl 64, id 46425, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xf8a1), 1979804434:1979805506(1072) ack 2260258133 win 5840
10:05:23.593636 IP (tos 0x0, ttl 64, id 20067, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf797 (correct), 2260258133:2260258133(0) ack 1979788354 win 65535
10:05:23.593639 IP (tos 0x0, ttl 64, id 46427, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xe481), 1979805506:1979806578(1072) ack 2260258133 win 5840
10:05:23.593674 IP (tos 0x0, ttl 64, id 20068, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf367 (correct), 2260258133:2260258133(0) ack 1979789426 win 65535
10:05:23.593677 IP (tos 0x0, ttl 64, id 46429, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xcd5e), 1979806578:1979807650(1072) ack 2260258133 win 5840
10:05:23.593680 IP (tos 0x0, ttl 64, id 20069, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xef37 (correct), 2260258133:2260258133(0) ack 1979790498 win 65535
10:05:23.593682 IP (tos 0x0, ttl 64, id 46431, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: P, cksum 0x1855 (incorrect (-> 0x2e6b), 1979807650:1979808186(536) ack 2260258133 win 5840
10:05:23.593684 IP (tos 0x0, ttl 64, id 46432, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x614f), 1979808186:1979808722(536) ack 2260258133 win 5840
10:05:23.593687 IP (tos 0x0, ttl 64, id 20070, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xeb07 (correct), 2260258133:2260258133(0) ack 1979791570 win 65535
10:05:23.593690 IP (tos 0x0, ttl 64, id 46433, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xcf1f), 1979808722:1979809794(1072) ack 2260258133 win 5840
10:05:23.593692 IP (tos 0x0, ttl 64, id 20071, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe6d7 (correct), 2260258133:2260258133(0) ack 1979792642 win 65535
10:05:23.593695 IP (tos 0x0, ttl 64, id 46435, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x77bb), 1979809794:1979810866(1072) ack 2260258133 win 5840
10:05:23.593724 IP (tos 0x0, ttl 64, id 20072, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe2a7 (correct), 2260258133:2260258133(0) ack 1979793714 win 65535
10:05:23.593727 IP (tos 0x0, ttl 64, id 46437, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x6107), 1979810866:1979811938(1072) ack 2260258133 win 5840
10:05:23.593730 IP (tos 0x0, ttl 64, id 20073, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xde77 (correct), 2260258133:2260258133(0) ack 1979794786 win 65535
10:05:23.593733 IP (tos 0x0, ttl 64, id 46439, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x241a), 1979811938:1979813010(1072) ack 2260258133 win 5840
10:05:23.593735 IP (tos 0x0, ttl 64, id 20074, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xda47 (correct), 2260258133:2260258133(0) ack 1979795858 win 65535
10:05:23.593738 IP (tos 0x0, ttl 64, id 46441, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x388b), 1979813010:1979814082(1072) ack 2260258133 win 5840
10:05:23.593774 IP (tos 0x0, ttl 64, id 20075, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xd617 (correct), 2260258133:2260258133(0) ack 1979796930 win 65535
10:05:23.593778 IP (tos 0x0, ttl 64, id 46443, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x077a), 1979814082:1979815154(1072) ack 2260258133 win 5840
10:05:23.593780 IP (tos 0x0, ttl 64, id 20076, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xd1e7 (correct), 2260258133:2260258133(0) ack 1979798002 win 65535
10:05:23.593783 IP (tos 0x0, ttl 64, id 46445, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x272d), 1979815154:1979816226(1072) ack 2260258133 win 5840
10:05:23.593785 IP (tos 0x0, ttl 64, id 20077, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xcdb7 (correct), 2260258133:2260258133(0) ack 1979799074 win 65535
10:05:23.593788 IP (tos 0x0, ttl 64, id 46447, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x5108), 1979816226:1979817298(1072) ack 2260258133 win 5840
10:05:23.593790 IP (tos 0x0, ttl 64, id 20078, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xc987 (correct), 2260258133:2260258133(0) ack 1979800146 win 65535
10:05:23.593792 IP (tos 0x0, ttl 64, id 46449, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x496c), 1979817298:1979818370(1072) ack 2260258133 win 5840
10:05:23.593824 IP (tos 0x0, ttl 64, id 20079, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xc557 (correct), 2260258133:2260258133(0) ack 1979801218 win 65535
10:05:23.593827 IP (tos 0x0, ttl 64, id 46451, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x8a17), 1979818370:1979819442(1072) ack 2260258133 win 5840
10:05:23.593829 IP (tos 0x0, ttl 64, id 20080, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xc127 (correct), 2260258133:2260258133(0) ack 1979802290 win 65535
10:05:23.593832 IP (tos 0x0, ttl 64, id 46453, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xa11a), 1979819442:1979820514(1072) ack 2260258133 win 5840
10:05:23.593835 IP (tos 0x0, ttl 64, id 20081, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xbcf7 (correct), 2260258133:2260258133(0) ack 1979803362 win 65535
10:05:23.593837 IP (tos 0x0, ttl 64, id 46455, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x2ef0), 1979820514:1979821586(1072) ack 2260258133 win 5840
10:05:23.593874 IP (tos 0x0, ttl 64, id 20082, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xb8c7 (correct), 2260258133:2260258133(0) ack 1979804434 win 65535
10:05:23.593877 IP (tos 0x0, ttl 64, id 46457, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x8153), 1979821586:1979822658(1072) ack 2260258133 win 5840
10:05:23.593879 IP (tos 0x0, ttl 64, id 20083, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xb497 (correct), 2260258133:2260258133(0) ack 1979805506 win 65535
10:05:23.593882 IP (tos 0x0, ttl 64, id 46459, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xb26b), 1979822658:1979823730(1072) ack 2260258133 win 5840
10:05:23.593884 IP (tos 0x0, ttl 64, id 20084, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xb067 (correct), 2260258133:2260258133(0) ack 1979806578 win 65535
10:05:23.593886 IP (tos 0x0, ttl 64, id 46461, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x3cdc), 1979823730:1979824802(1072) ack 2260258133 win 5840
10:05:23.593924 IP (tos 0x0, ttl 64, id 20085, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xac37 (correct), 2260258133:2260258133(0) ack 1979807650 win 65535
10:05:23.593927 IP (tos 0x0, ttl 64, id 46463, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xeb21), 1979824802:1979825874(1072) ack 2260258133 win 5840
10:05:23.593929 IP (tos 0x0, ttl 64, id 20086, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xa807 (correct), 2260258133:2260258133(0) ack 1979808722 win 65535
10:05:23.593931 IP (tos 0x0, ttl 64, id 46465, offset 0, flags [DF], proto TCP (6), length 1648) dione.40344 > phoenix.distcc: ., cksum 0x1c85 (incorrect (-> 0x58c9), 1979825874:1979827482(1608) ack 2260258133 win 5840
10:05:23.593973 IP (tos 0x0, ttl 64, id 20087, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xa3d7 (correct), 2260258133:2260258133(0) ack 1979809794 win 65535
10:05:23.593976 IP (tos 0x0, ttl 64, id 46468, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x1cd2), 1979827482:1979828554(1072) ack 2260258133 win 5840
10:05:23.593978 IP (tos 0x0, ttl 64, id 20088, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x9fa7 (correct), 2260258133:2260258133(0) ack 1979810866 win 65535
10:05:23.593981 IP (tos 0x0, ttl 64, id 46470, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x437a), 1979828554:1979829626(1072) ack 2260258133 win 5840
10:05:23.593982 IP (tos 0x0, ttl 64, id 20089, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x9b77 (correct), 2260258133:2260258133(0) ack 1979811938 win 65535
10:05:23.593985 IP (tos 0x0, ttl 64, id 46472, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xe4cc), 1979829626:1979830698(1072) ack 2260258133 win 5840
10:05:23.593987 IP (tos 0x0, ttl 64, id 20090, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x9747 (correct), 2260258133:2260258133(0) ack 1979813010 win 65535
10:05:23.593989 IP (tos 0x0, ttl 64, id 46474, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xf8ec), 1979830698:1979831770(1072) ack 2260258133 win 5840
10:05:23.593991 IP (tos 0x0, ttl 64, id 20091, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x9317 (correct), 2260258133:2260258133(0) ack 1979814082 win 65535
10:05:23.593993 IP (tos 0x0, ttl 64, id 46476, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x590e), 1979831770:1979832842(1072) ack 2260258133 win 5840
10:05:23.593995 IP (tos 0x0, ttl 64, id 20092, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8ee7 (correct), 2260258133:2260258133(0) ack 1979815154 win 65535
10:05:23.593997 IP (tos 0x0, ttl 64, id 46478, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x4a1d), 1979832842:1979833914(1072) ack 2260258133 win 5840
10:05:23.594023 IP (tos 0x0, ttl 64, id 20093, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8ab7 (correct), 2260258133:2260258133(0) ack 1979816226 win 65535
10:05:23.594027 IP (tos 0x0, ttl 64, id 46480, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xad03), 1979833914:1979834986(1072) ack 2260258133 win 5840
10:05:23.594074 IP (tos 0x0, ttl 64, id 20094, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8687 (correct), 2260258133:2260258133(0) ack 1979817298 win 65535
10:05:23.594077 IP (tos 0x0, ttl 64, id 46482, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x1787), 1979834986:1979836058(1072) ack 2260258133 win 5840
10:05:23.594080 IP (tos 0x0, ttl 64, id 20095, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8257 (correct), 2260258133:2260258133(0) ack 1979818370 win 65535
10:05:23.594082 IP (tos 0x0, ttl 64, id 46484, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x3108), 1979836058:1979837130(1072) ack 2260258133 win 5840
10:05:23.594084 IP (tos 0x0, ttl 64, id 20096, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x7e27 (correct), 2260258133:2260258133(0) ack 1979819442 win 65535
10:05:23.594087 IP (tos 0x0, ttl 64, id 46486, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xe5bf), 1979837130:1979838202(1072) ack 2260258133 win 5840
10:05:23.594089 IP (tos 0x0, ttl 64, id 20097, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x79f7 (correct), 2260258133:2260258133(0) ack 1979820514 win 65535
10:05:23.594091 IP (tos 0x0, ttl 64, id 46488, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x4a5e), 1979838202:1979839274(1072) ack 2260258133 win 5840
10:05:23.594093 IP (tos 0x0, ttl 64, id 20098, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x75c7 (correct), 2260258133:2260258133(0) ack 1979821586 win 65535
10:05:23.594095 IP (tos 0x0, ttl 64, id 46490, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x0bc1), 1979839274:1979840346(1072) ack 2260258133 win 5840
10:05:23.594096 IP (tos 0x0, ttl 64, id 20099, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x7197 (correct), 2260258133:2260258133(0) ack 1979822658 win 65535
10:05:23.594098 IP (tos 0x0, ttl 64, id 46492, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xab2d), 1979840346:1979840882(536) ack 2260258133 win 5840
10:05:23.594100 IP (tos 0x0, ttl 64, id 46493, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x56a2), 1979840882:1979841418(536) ack 2260258133 win 5840
10:05:23.594124 IP (tos 0x0, ttl 64, id 20100, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x6d67 (correct), 2260258133:2260258133(0) ack 1979823730 win 65535
10:05:23.594126 IP (tos 0x0, ttl 64, id 46494, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xe6a5), 1979841418:1979842490(1072) ack 2260258133 win 5840
10:05:23.594128 IP (tos 0x0, ttl 64, id 20101, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x6937 (correct), 2260258133:2260258133(0) ack 1979824802 win 65535
10:05:23.594130 IP (tos 0x0, ttl 64, id 46496, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xa8be), 1979842490:1979843562(1072) ack 2260258133 win 5840
10:05:23.594174 IP (tos 0x0, ttl 64, id 20102, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x6507 (correct), 2260258133:2260258133(0) ack 1979825874 win 65535
10:05:23.594177 IP (tos 0x0, ttl 64, id 46498, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xdd94), 1979843562:1979844634(1072) ack 2260258133 win 5840
10:05:23.594180 IP (tos 0x0, ttl 64, id 20103, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x60d7 (correct), 2260258133:2260258133(0) ack 1979826946 win 65535
10:05:23.594182 IP (tos 0x0, ttl 64, id 46500, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xc674), 1979844634:1979845706(1072) ack 2260258133 win 5840
10:05:23.594184 IP (tos 0x0, ttl 64, id 20104, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5ca7 (correct), 2260258133:2260258133(0) ack 1979828018 win 65535
10:05:23.594187 IP (tos 0x0, ttl 64, id 46502, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x3f94), 1979845706:1979846778(1072) ack 2260258133 win 5840
10:05:23.594188 IP (tos 0x0, ttl 64, id 20105, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5877 (correct), 2260258133:2260258133(0) ack 1979829090 win 65535
10:05:23.594191 IP (tos 0x0, ttl 64, id 46504, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x89a4), 1979846778:1979847850(1072) ack 2260258133 win 5840
10:05:23.594223 IP (tos 0x0, ttl 64, id 20106, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5447 (correct), 2260258133:2260258133(0) ack 1979830162 win 65535
10:05:23.594226 IP (tos 0x0, ttl 64, id 46506, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x6d13), 1979847850:1979848922(1072) ack 2260258133 win 5840
10:05:23.594228 IP (tos 0x0, ttl 64, id 20107, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5017 (correct), 2260258133:2260258133(0) ack 1979831234 win 65535
10:05:23.594231 IP (tos 0x0, ttl 64, id 46508, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x439e), 1979848922:1979849994(1072) ack 2260258133 win 5840
10:05:23.594274 IP (tos 0x0, ttl 64, id 20108, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4be7 (correct), 2260258133:2260258133(0) ack 1979832306 win 65535
10:05:23.594277 IP (tos 0x0, ttl 64, id 46510, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x155e), 1979849994:1979851066(1072) ack 2260258133 win 5840
10:05:23.594279 IP (tos 0x0, ttl 64, id 20109, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x47b7 (correct), 2260258133:2260258133(0) ack 1979833378 win 65535
10:05:23.594282 IP (tos 0x0, ttl 64, id 46512, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x5933), 1979851066:1979852138(1072) ack 2260258133 win 5840
10:05:23.594284 IP (tos 0x0, ttl 64, id 20110, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4387 (correct), 2260258133:2260258133(0) ack 1979834450 win 65535
10:05:23.594287 IP (tos 0x0, ttl 64, id 46514, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x43e1), 1979852138:1979853210(1072) ack 2260258133 win 5840
10:05:23.594289 IP (tos 0x0, ttl 64, id 20111, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3f57 (correct), 2260258133:2260258133(0) ack 1979835522 win 65535
10:05:23.594292 IP (tos 0x0, ttl 64, id 46516, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x15cd), 1979853210:1979854282(1072) ack 2260258133 win 5840
10:05:23.594323 IP (tos 0x0, ttl 64, id 20112, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3b27 (correct), 2260258133:2260258133(0) ack 1979836594 win 65535
10:05:23.594326 IP (tos 0x0, ttl 64, id 46518, offset 0, flags [DF], proto TCP (6), length 1648) dione.40344 > phoenix.distcc: ., cksum 0x1c85 (incorrect (-> 0x8bdd), 1979854282:1979855890(1608) ack 2260258133 win 5840
10:05:23.594329 IP (tos 0x0, ttl 64, id 20113, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x36f7 (correct), 2260258133:2260258133(0) ack 1979837666 win 65535
10:05:23.594331 IP (tos 0x0, ttl 64, id 46521, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x1397), 1979855890:1979856962(1072) ack 2260258133 win 5840
10:05:23.594333 IP (tos 0x0, ttl 64, id 20114, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x32c7 (correct), 2260258133:2260258133(0) ack 1979838738 win 65535
10:05:23.594336 IP (tos 0x0, ttl 64, id 46523, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xb2f5), 1979856962:1979858034(1072) ack 2260258133 win 5840
10:05:23.594373 IP (tos 0x0, ttl 64, id 20115, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x2e97 (correct), 2260258133:2260258133(0) ack 1979839810 win 65535
10:05:23.594376 IP (tos 0x0, ttl 64, id 46525, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x432e), 1979858034:1979859106(1072) ack 2260258133 win 5840
10:05:23.594379 IP (tos 0x0, ttl 64, id 20116, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x2a67 (correct), 2260258133:2260258133(0) ack 1979840882 win 65535
10:05:23.594381 IP (tos 0x0, ttl 64, id 46527, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x03cf), 1979859106:1979860178(1072) ack 2260258133 win 5840
10:05:23.594384 IP (tos 0x0, ttl 64, id 20117, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x2637 (correct), 2260258133:2260258133(0) ack 1979841954 win 65535
10:05:23.594387 IP (tos 0x0, ttl 64, id 46529, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x2c9b), 1979860178:1979861250(1072) ack 2260258133 win 5840
10:05:23.594389 IP (tos 0x0, ttl 64, id 20118, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x2207 (correct), 2260258133:2260258133(0) ack 1979843026 win 65535
10:05:23.594391 IP (tos 0x0, ttl 64, id 46531, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x0c0d), 1979861250:1979862322(1072) ack 2260258133 win 5840
10:05:23.594424 IP (tos 0x0, ttl 64, id 20119, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1dd7 (correct), 2260258133:2260258133(0) ack 1979844098 win 65535
10:05:23.594427 IP (tos 0x0, ttl 64, id 46533, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x390e), 1979862322:1979863394(1072) ack 2260258133 win 5840
10:05:23.594429 IP (tos 0x0, ttl 64, id 20120, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x19a7 (correct), 2260258133:2260258133(0) ack 1979845170 win 65535
10:05:23.594432 IP (tos 0x0, ttl 64, id 46535, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x995c), 1979863394:1979864466(1072) ack 2260258133 win 5840
10:05:23.594434 IP (tos 0x0, ttl 64, id 20121, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1577 (correct), 2260258133:2260258133(0) ack 1979846242 win 65535
10:05:23.594436 IP (tos 0x0, ttl 64, id 46537, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x9612), 1979864466:1979865538(1072) ack 2260258133 win 5840
10:05:23.594440 IP (tos 0x0, ttl 64, id 20122, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1147 (correct), 2260258133:2260258133(0) ack 1979847314 win 65535
10:05:23.594472 IP (tos 0x0, ttl 64, id 20123, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0d17 (correct), 2260258133:2260258133(0) ack 1979848386 win 65535
10:05:23.594476 IP (tos 0x0, ttl 64, id 46541, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xd7c5), 1979866610:1979867682(1072) ack 2260258133 win 5840
10:05:23.594478 IP (tos 0x0, ttl 64, id 20124, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x08e7 (correct), 2260258133:2260258133(0) ack 1979849458 win 65535
10:05:23.594480 IP (tos 0x0, ttl 64, id 46543, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xdd22), 1979867682:1979868754(1072) ack 2260258133 win 5840
10:05:23.594522 IP (tos 0x0, ttl 64, id 20125, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x04b7 (correct), 2260258133:2260258133(0) ack 1979850530 win 65535
10:05:23.594526 IP (tos 0x0, ttl 64, id 46545, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x7538), 1979868754:1979869826(1072) ack 2260258133 win 5840
10:05:23.594528 IP (tos 0x0, ttl 64, id 20126, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0087 (correct), 2260258133:2260258133(0) ack 1979851602 win 65535
10:05:23.594530 IP (tos 0x0, ttl 64, id 46547, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x765a), 1979869826:1979870898(1072) ack 2260258133 win 5840
10:05:23.594532 IP (tos 0x0, ttl 64, id 20127, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xfc56 (correct), 2260258133:2260258133(0) ack 1979852674 win 65535
10:05:23.594535 IP (tos 0x0, ttl 64, id 46549, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x690b), 1979870898:1979871970(1072) ack 2260258133 win 5840
10:05:23.594537 IP (tos 0x0, ttl 64, id 20128, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf826 (correct), 2260258133:2260258133(0) ack 1979853746 win 65535
10:05:23.594540 IP (tos 0x0, ttl 64, id 46551, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xfa9b), 1979871970:1979873042(1072) ack 2260258133 win 5840
10:05:23.594572 IP (tos 0x0, ttl 64, id 20129, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf3f6 (correct), 2260258133:2260258133(0) ack 1979854818 win 65535
10:05:23.594576 IP (tos 0x0, ttl 64, id 46553, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x7701), 1979873042:1979873578(536) ack 2260258133 win 5840
10:05:23.594578 IP (tos 0x0, ttl 64, id 46554, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x69d8), 1979873578:1979874114(536) ack 2260258133 win 5840
10:05:23.594579 IP (tos 0x0, ttl 64, id 20130, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xefc6 (correct), 2260258133:2260258133(0) ack 1979855890 win 65535
10:05:23.594581 IP (tos 0x0, ttl 64, id 46555, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x206c), 1979874114:1979875186(1072) ack 2260258133 win 5840
10:05:23.594623 IP (tos 0x0, ttl 64, id 20133, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe336 (correct), 2260258133:2260258133(0) ack 1979859106 win 65535
10:05:23.594626 IP (tos 0x0, ttl 64, id 46561, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xb6bf), 1979877330:1979878402(1072) ack 2260258133 win 5840
10:05:23.594628 IP (tos 0x0, ttl 64, id 20134, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe11e (correct), 2260258133:2260258133(0) ack 1979859642 win 65535
10:05:23.594631 IP (tos 0x0, ttl 64, id 46563, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x3264), 1979878402:1979878938(536) ack 2260258133 win 5840
10:05:23.594632 IP (tos 0x0, ttl 64, id 20135, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xdf06 (correct), 2260258133:2260258133(0) ack 1979860178 win 65535
10:05:23.594635 IP (tos 0x0, ttl 64, id 20136, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xdcee (correct), 2260258133:2260258133(0) ack 1979860714 win 65535
10:05:23.594639 IP (tos 0x0, ttl 64, id 20137, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xdad6 (correct), 2260258133:2260258133(0) ack 1979861250 win 65535
10:05:23.594672 IP (tos 0x0, ttl 64, id 20138, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xd8be (correct), 2260258133:2260258133(0) ack 1979861786 win 65535
10:05:23.594675 IP (tos 0x0, ttl 64, id 46567, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x2b6f), 1979880546:1979881618(1072) ack 2260258133 win 5840
10:05:23.594678 IP (tos 0x0, ttl 64, id 20139, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xd6a6 (correct), 2260258133:2260258133(0) ack 1979862322 win 65535
10:05:23.594680 IP (tos 0x0, ttl 64, id 46569, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x7579), 1979881618:1979882154(536) ack 2260258133 win 5840
10:05:23.594681 IP (tos 0x0, ttl 64, id 20140, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xd48e (correct), 2260258133:2260258133(0) ack 1979862858 win 65535
10:05:23.594683 IP (tos 0x0, ttl 64, id 46570, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xa70b), 1979882154:1979882690(536) ack 2260258133 win 5840
10:05:23.594685 IP (tos 0x0, ttl 64, id 20141, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xd276 (correct), 2260258133:2260258133(0) ack 1979863394 win 65535
10:05:23.594688 IP (tos 0x0, ttl 64, id 20142, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xd05e (correct), 2260258133:2260258133(0) ack 1979863930 win 65535
10:05:23.594692 IP (tos 0x0, ttl 64, id 20143, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xce46 (correct), 2260258133:2260258133(0) ack 1979864466 win 65535
10:05:23.594773 IP (tos 0x0, ttl 64, id 20148, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xc3ce (correct), 2260258133:2260258133(0) ack 1979867146 win 65535
10:05:23.594776 IP (tos 0x0, ttl 64, id 46578, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xa8f1), 1979886442:1979886978(536) ack 2260258133 win 5840
10:05:23.594778 IP (tos 0x0, ttl 64, id 20149, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xc1b6 (correct), 2260258133:2260258133(0) ack 1979867682 win 65535
10:05:23.594780 IP (tos 0x0, ttl 64, id 46579, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xa1ee), 1979886978:1979887514(536) ack 2260258133 win 5840
10:05:23.594781 IP (tos 0x0, ttl 64, id 20150, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xbf9e (correct), 2260258133:2260258133(0) ack 1979868218 win 65535
10:05:23.594783 IP (tos 0x0, ttl 64, id 46580, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x3a3c), 1979887514:1979888050(536) ack 2260258133 win 5840
10:05:23.594784 IP (tos 0x0, ttl 64, id 20151, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xbd86 (correct), 2260258133:2260258133(0) ack 1979868754 win 65535
10:05:23.594786 IP (tos 0x0, ttl 64, id 46581, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xa327), 1979888050:1979888586(536) ack 2260258133 win 5840
10:05:23.594787 IP (tos 0x0, ttl 64, id 20152, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xbb6e (correct), 2260258133:2260258133(0) ack 1979869290 win 65535
10:05:23.594790 IP (tos 0x0, ttl 64, id 46582, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x5d36), 1979888586:1979889122(536) ack 2260258133 win 5840
10:05:23.594791 IP (tos 0x0, ttl 64, id 20153, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xb956 (correct), 2260258133:2260258133(0) ack 1979869826 win 65535
10:05:23.594794 IP (tos 0x0, ttl 64, id 46583, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x251b), 1979889122:1979889658(536) ack 2260258133 win 5840
10:05:23.594795 IP (tos 0x0, ttl 64, id 20154, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xb73e (correct), 2260258133:2260258133(0) ack 1979870362 win 65535
10:05:23.594800 IP (tos 0x0, ttl 64, id 20155, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xb526 (correct), 2260258133:2260258133(0) ack 1979870898 win 65535
10:05:23.594872 IP (tos 0x0, ttl 64, id 20163, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xa466 (correct), 2260258133:2260258133(0) ack 1979875186 win 65535
10:05:23.594876 IP (tos 0x0, ttl 64, id 46593, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x5709), 1979894482:1979895018(536) ack 2260258133 win 5840
10:05:23.594877 IP (tos 0x0, ttl 64, id 20164, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xa24e (correct), 2260258133:2260258133(0) ack 1979875722 win 65535
10:05:23.594879 IP (tos 0x0, ttl 64, id 46594, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xf8b5), 1979895018:1979896090(1072) ack 2260258133 win 5840
10:05:23.594881 IP (tos 0x0, ttl 64, id 20165, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xa036 (correct), 2260258133:2260258133(0) ack 1979876258 win 65535
10:05:23.594883 IP (tos 0x0, ttl 64, id 46596, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x556c), 1979896090:1979896626(536) ack 2260258133 win 5840
10:05:23.594885 IP (tos 0x0, ttl 64, id 20166, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x9e1e (correct), 2260258133:2260258133(0) ack 1979876794 win 65535
10:05:23.594887 IP (tos 0x0, ttl 64, id 46597, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x2a3c), 1979896626:1979897162(536) ack 2260258133 win 5840
10:05:23.594888 IP (tos 0x0, ttl 64, id 20167, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x9c06 (correct), 2260258133:2260258133(0) ack 1979877330 win 65535
10:05:23.594890 IP (tos 0x0, ttl 64, id 46598, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xac70), 1979897162:1979897698(536) ack 2260258133 win 5840
10:05:23.594892 IP (tos 0x0, ttl 64, id 20168, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x99ee (correct), 2260258133:2260258133(0) ack 1979877866 win 65535
10:05:23.594972 IP (tos 0x0, ttl 64, id 20177, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8716 (correct), 2260258133:2260258133(0) ack 1979882690 win 65535
10:05:23.594975 IP (tos 0x0, ttl 64, id 46608, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xa874), 1979902522:1979903058(536) ack 2260258133 win 5840
10:05:23.594977 IP (tos 0x0, ttl 64, id 20178, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x84fe (correct), 2260258133:2260258133(0) ack 1979883226 win 65535
10:05:23.594979 IP (tos 0x0, ttl 64, id 46609, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x89bb), 1979903058:1979903594(536) ack 2260258133 win 5840
10:05:23.594980 IP (tos 0x0, ttl 64, id 20179, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x82e6 (correct), 2260258133:2260258133(0) ack 1979883762 win 65535
10:05:23.594982 IP (tos 0x0, ttl 64, id 46610, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xc089), 1979903594:1979904130(536) ack 2260258133 win 5840
10:05:23.594983 IP (tos 0x0, ttl 64, id 20180, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x80ce (correct), 2260258133:2260258133(0) ack 1979884298 win 65535
10:05:23.594985 IP (tos 0x0, ttl 64, id 46611, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xac95), 1979904130:1979904666(536) ack 2260258133 win 5840
10:05:23.594986 IP (tos 0x0, ttl 64, id 20181, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x7eb6 (correct), 2260258133:2260258133(0) ack 1979884834 win 65535
10:05:23.594988 IP (tos 0x0, ttl 64, id 46612, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xe0f2), 1979904666:1979905202(536) ack 2260258133 win 5840
10:05:23.594989 IP (tos 0x0, ttl 64, id 20182, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x7c9e (correct), 2260258133:2260258133(0) ack 1979885370 win 65535
10:05:23.594992 IP (tos 0x0, ttl 64, id 46613, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x29de), 1979905202:1979905738(536) ack 2260258133 win 5840
10:05:23.594993 IP (tos 0x0, ttl 64, id 20183, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x7a86 (correct), 2260258133:2260258133(0) ack 1979885906 win 65535
10:05:23.594994 IP (tos 0x0, ttl 64, id 46614, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: P, cksum 0x1855 (incorrect (-> 0xc40d), 1979905738:1979906274(536) ack 2260258133 win 5840
10:05:23.595072 IP (tos 0x0, ttl 64, id 20197, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5d36 (correct), 2260258133:2260258133(0) ack 1979893410 win 65535
10:05:23.595075 IP (tos 0x0, ttl 64, id 46629, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xdfe4), 1979913778:1979914314(536) ack 2260258133 win 5840
10:05:23.595076 IP (tos 0x0, ttl 64, id 20198, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5b1e (correct), 2260258133:2260258133(0) ack 1979893946 win 65535
10:05:23.595079 IP (tos 0x0, ttl 64, id 46630, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x6597), 1979914314:1979914850(536) ack 2260258133 win 5840
10:05:23.595080 IP (tos 0x0, ttl 64, id 20199, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5906 (correct), 2260258133:2260258133(0) ack 1979894482 win 65535
10:05:23.595082 IP (tos 0x0, ttl 64, id 46631, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x6740), 1979914850:1979915386(536) ack 2260258133 win 5840
10:05:23.595083 IP (tos 0x0, ttl 64, id 20200, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x56ee (correct), 2260258133:2260258133(0) ack 1979895018 win 65535
10:05:23.595085 IP (tos 0x0, ttl 64, id 46632, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x3dbb), 1979915386:1979915922(536) ack 2260258133 win 5840
10:05:23.595087 IP (tos 0x0, ttl 64, id 20201, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x54d6 (correct), 2260258133:2260258133(0) ack 1979895554 win 65535
10:05:23.595172 IP (tos 0x0, ttl 64, id 20211, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3fe6 (correct), 2260258133:2260258133(0) ack 1979900914 win 65535
10:05:23.595175 IP (tos 0x0, ttl 64, id 46643, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x1324), 1979921282:1979921818(536) ack 2260258133 win 5840
10:05:23.595176 IP (tos 0x0, ttl 64, id 20212, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3dce (correct), 2260258133:2260258133(0) ack 1979901450 win 65535
10:05:23.595178 IP (tos 0x0, ttl 64, id 46644, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xfa30), 1979921818:1979922354(536) ack 2260258133 win 5840
10:05:23.595179 IP (tos 0x0, ttl 64, id 20213, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3bb6 (correct), 2260258133:2260258133(0) ack 1979901986 win 65535
10:05:23.595182 IP (tos 0x0, ttl 64, id 46645, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xc91b), 1979922354:1979922890(536) ack 2260258133 win 5840
10:05:23.595183 IP (tos 0x0, ttl 64, id 20214, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x399e (correct), 2260258133:2260258133(0) ack 1979902522 win 65535
10:05:23.595185 IP (tos 0x0, ttl 64, id 46646, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x2721), 1979922890:1979923426(536) ack 2260258133 win 5840
10:05:23.595186 IP (tos 0x0, ttl 64, id 20215, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3786 (correct), 2260258133:2260258133(0) ack 1979903058 win 65535
10:05:23.595188 IP (tos 0x0, ttl 64, id 46647, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x0b03), 1979923426:1979923962(536) ack 2260258133 win 5840
10:05:23.595190 IP (tos 0x0, ttl 64, id 20216, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x356e (correct), 2260258133:2260258133(0) ack 1979903594 win 65535
10:05:23.595192 IP (tos 0x0, ttl 64, id 46648, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xdf6d), 1979923962:1979925034(1072) ack 2260258133 win 5840
10:05:23.595194 IP (tos 0x0, ttl 64, id 20217, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3356 (correct), 2260258133:2260258133(0) ack 1979904130 win 65535
10:05:23.595197 IP (tos 0x0, ttl 64, id 20218, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x313e (correct), 2260258133:2260258133(0) ack 1979904666 win 65535
10:05:23.595322 IP (tos 0x0, ttl 64, id 20236, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0b8e (correct), 2260258133:2260258133(0) ack 1979914314 win 65535
10:05:23.595325 IP (tos 0x0, ttl 64, id 46669, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xd48b), 1979935218:1979935754(536) ack 2260258133 win 5840
10:05:23.595326 IP (tos 0x0, ttl 64, id 20237, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0976 (correct), 2260258133:2260258133(0) ack 1979914850 win 65535
10:05:23.595328 IP (tos 0x0, ttl 64, id 46670, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xf8c9), 1979935754:1979936290(536) ack 2260258133 win 5840
10:05:23.595329 IP (tos 0x0, ttl 64, id 20238, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x075e (correct), 2260258133:2260258133(0) ack 1979915386 win 65535
10:05:23.595331 IP (tos 0x0, ttl 64, id 46671, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xa441), 1979936290:1979936826(536) ack 2260258133 win 5840
10:05:23.595332 IP (tos 0x0, ttl 64, id 20239, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0546 (correct), 2260258133:2260258133(0) ack 1979915922 win 65535
10:05:23.595334 IP (tos 0x0, ttl 64, id 46672, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x6bf7), 1979936826:1979937362(536) ack 2260258133 win 5840
10:05:23.595336 IP (tos 0x0, ttl 64, id 20240, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x032e (correct), 2260258133:2260258133(0) ack 1979916458 win 65535
10:05:23.595338 IP (tos 0x0, ttl 64, id 46673, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xd6c7), 1979937362:1979937898(536) ack 2260258133 win 5840
10:05:23.595339 IP (tos 0x0, ttl 64, id 20241, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0116 (correct), 2260258133:2260258133(0) ack 1979916994 win 65535
10:05:23.595341 IP (tos 0x0, ttl 64, id 46674, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x8dbd), 1979937898:1979938434(536) ack 2260258133 win 5840
10:05:23.595342 IP (tos 0x0, ttl 64, id 20242, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xfefd (correct), 2260258133:2260258133(0) ack 1979917530 win 65535
10:05:23.595344 IP (tos 0x0, ttl 64, id 46675, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x6059), 1979938434:1979938970(536) ack 2260258133 win 5840
10:05:23.595348 IP (tos 0x0, ttl 64, id 20243, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xfce5 (correct), 2260258133:2260258133(0) ack 1979918066 win 65535
10:05:23.595421 IP (tos 0x0, ttl 64, id 20259, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xdb65 (correct), 2260258133:2260258133(0) ack 1979926642 win 65535
10:05:23.595424 IP (tos 0x0, ttl 64, id 46693, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x9c32), 1979948082:1979948618(536) ack 2260258133 win 5840
10:05:23.595426 IP (tos 0x0, ttl 64, id 20260, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xd94d (correct), 2260258133:2260258133(0) ack 1979927178 win 65535
10:05:23.595428 IP (tos 0x0, ttl 64, id 46694, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xe158), 1979948618:1979949154(536) ack 2260258133 win 5840
10:05:23.595429 IP (tos 0x0, ttl 64, id 20261, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xd735 (correct), 2260258133:2260258133(0) ack 1979927714 win 65535
10:05:23.595432 IP (tos 0x0, ttl 64, id 20262, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xd51d (correct), 2260258133:2260258133(0) ack 1979928250 win 65535
10:05:23.595522 IP (tos 0x0, ttl 64, id 20273, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xbe15 (correct), 2260258133:2260258133(0) ack 1979934146 win 65535
10:05:23.595525 IP (tos 0x0, ttl 64, id 46708, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x97a3), 1979956122:1979956658(536) ack 2260258133 win 5840
10:05:23.595527 IP (tos 0x0, ttl 64, id 20274, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xbbfd (correct), 2260258133:2260258133(0) ack 1979934682 win 65535
10:05:23.595529 IP (tos 0x0, ttl 64, id 46709, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xb57c), 1979956658:1979957194(536) ack 2260258133 win 5840
10:05:23.595530 IP (tos 0x0, ttl 64, id 20275, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xb9e5 (correct), 2260258133:2260258133(0) ack 1979935218 win 65535
10:05:23.595532 IP (tos 0x0, ttl 64, id 46710, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x117e), 1979957194:1979957730(536) ack 2260258133 win 5840
10:05:23.595533 IP (tos 0x0, ttl 64, id 20276, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xb7cd (correct), 2260258133:2260258133(0) ack 1979935754 win 65535
10:05:23.595535 IP (tos 0x0, ttl 64, id 46711, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x49fb), 1979957730:1979958266(536) ack 2260258133 win 5840
10:05:23.595536 IP (tos 0x0, ttl 64, id 20277, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xb5b5 (correct), 2260258133:2260258133(0) ack 1979936290 win 65535
10:05:23.595538 IP (tos 0x0, ttl 64, id 46712, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x0f52), 1979958266:1979958802(536) ack 2260258133 win 5840
10:05:23.595539 IP (tos 0x0, ttl 64, id 20278, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xb39d (correct), 2260258133:2260258133(0) ack 1979936826 win 65535
10:05:23.595541 IP (tos 0x0, ttl 64, id 46713, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x3b33), 1979958802:1979959338(536) ack 2260258133 win 5840
10:05:23.595542 IP (tos 0x0, ttl 64, id 20279, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xb185 (correct), 2260258133:2260258133(0) ack 1979937362 win 65535
10:05:23.595544 IP (tos 0x0, ttl 64, id 46714, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xe889), 1979959338:1979959874(536) ack 2260258133 win 5840
10:05:23.595672 IP (tos 0x0, ttl 64, id 20304, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x7d2d (correct), 2260258133:2260258133(0) ack 1979950762 win 65535
10:05:23.595675 IP (tos 0x0, ttl 64, id 46740, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xd20c), 1979973274:1979973810(536) ack 2260258133 win 5840
10:05:23.595676 IP (tos 0x0, ttl 64, id 20305, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x7b15 (correct), 2260258133:2260258133(0) ack 1979951298 win 65535
10:05:23.595678 IP (tos 0x0, ttl 64, id 46741, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x66f2), 1979973810:1979974346(536) ack 2260258133 win 5840
10:05:23.595680 IP (tos 0x0, ttl 64, id 20306, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x78fd (correct), 2260258133:2260258133(0) ack 1979951834 win 65535
10:05:23.595681 IP (tos 0x0, ttl 64, id 46742, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x754d), 1979974346:1979974882(536) ack 2260258133 win 5840
10:05:23.595683 IP (tos 0x0, ttl 64, id 20307, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x76e5 (correct), 2260258133:2260258133(0) ack 1979952370 win 65535
10:05:23.595685 IP (tos 0x0, ttl 64, id 46743, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x51b5), 1979974882:1979975418(536) ack 2260258133 win 5840
10:05:23.595686 IP (tos 0x0, ttl 64, id 20308, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x74cd (correct), 2260258133:2260258133(0) ack 1979952906 win 65535
10:05:23.595688 IP (tos 0x0, ttl 64, id 46744, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x0fb0), 1979975418:1979975954(536) ack 2260258133 win 5840
10:05:23.595689 IP (tos 0x0, ttl 64, id 20309, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x72b5 (correct), 2260258133:2260258133(0) ack 1979953442 win 65535
10:05:23.595691 IP (tos 0x0, ttl 64, id 46745, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x672e), 1979975954:1979976490(536) ack 2260258133 win 5840
10:05:23.595692 IP (tos 0x0, ttl 64, id 20310, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x709d (correct), 2260258133:2260258133(0) ack 1979953978 win 65535
10:05:23.595694 IP (tos 0x0, ttl 64, id 46746, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x3fed), 1979976490:1979977026(536) ack 2260258133 win 5840
10:05:23.595771 IP (tos 0x0, ttl 64, id 20319, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5dc5 (correct), 2260258133:2260258133(0) ack 1979958802 win 65535
10:05:23.595774 IP (tos 0x0, ttl 64, id 46755, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xbf38), 1979981314:1979981850(536) ack 2260258133 win 5840
10:05:23.595776 IP (tos 0x0, ttl 64, id 20320, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5bad (correct), 2260258133:2260258133(0) ack 1979959338 win 65535
10:05:23.595778 IP (tos 0x0, ttl 64, id 46756, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x2a02), 1979981850:1979982922(1072) ack 2260258133 win 5840
10:05:23.595780 IP (tos 0x0, ttl 64, id 20321, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5995 (correct), 2260258133:2260258133(0) ack 1979959874 win 65535
10:05:23.595782 IP (tos 0x0, ttl 64, id 46758, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x491b), 1979982922:1979983458(536) ack 2260258133 win 5840
10:05:23.595783 IP (tos 0x0, ttl 64, id 20322, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x577d (correct), 2260258133:2260258133(0) ack 1979960410 win 65535
10:05:23.595785 IP (tos 0x0, ttl 64, id 46759, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xc55f), 1979983458:1979983994(536) ack 2260258133 win 5840
10:05:23.595786 IP (tos 0x0, ttl 64, id 20323, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5565 (correct), 2260258133:2260258133(0) ack 1979960946 win 65535
10:05:23.595788 IP (tos 0x0, ttl 64, id 46760, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x3150), 1979983994:1979984530(536) ack 2260258133 win 5840
10:05:23.595789 IP (tos 0x0, ttl 64, id 20324, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x534d (correct), 2260258133:2260258133(0) ack 1979961482 win 65535
10:05:23.595792 IP (tos 0x0, ttl 64, id 46761, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xe5d0), 1979984530:1979985066(536) ack 2260258133 win 5840
10:05:23.595792 IP (tos 0x0, ttl 64, id 20325, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5135 (correct), 2260258133:2260258133(0) ack 1979962018 win 65535
10:05:23.595795 IP (tos 0x0, ttl 64, id 20326, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4f1d (correct), 2260258133:2260258133(0) ack 1979962554 win 65535
10:05:23.595921 IP (tos 0x0, ttl 64, id 20352, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x18ad (correct), 2260258133:2260258133(0) ack 1979976490 win 65535
10:05:23.595925 IP (tos 0x0, ttl 64, id 46790, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xf4e9), 1980000074:1980000610(536) ack 2260258133 win 5840
10:05:23.595926 IP (tos 0x0, ttl 64, id 20353, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1695 (correct), 2260258133:2260258133(0) ack 1979977026 win 65535
10:05:23.595928 IP (tos 0x0, ttl 64, id 46791, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x67f3), 1980000610:1980001146(536) ack 2260258133 win 5840
10:05:23.595929 IP (tos 0x0, ttl 64, id 20354, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x147d (correct), 2260258133:2260258133(0) ack 1979977562 win 65535
10:05:23.595931 IP (tos 0x0, ttl 64, id 46792, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xa26b), 1980001146:1980001682(536) ack 2260258133 win 5840
10:05:23.595932 IP (tos 0x0, ttl 64, id 20355, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1265 (correct), 2260258133:2260258133(0) ack 1979978098 win 65535
10:05:23.595934 IP (tos 0x0, ttl 64, id 46793, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x5a2a), 1980001682:1980002218(536) ack 2260258133 win 5840
10:05:23.596020 IP (tos 0x0, ttl 64, id 20356, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x104d (correct), 2260258133:2260258133(0) ack 1979978634 win 65535
10:05:23.596023 IP (tos 0x0, ttl 64, id 46794, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x1d1d), 1980002218:1980002754(536) ack 2260258133 win 5840
10:05:23.596024 IP (tos 0x0, ttl 64, id 20357, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0e35 (correct), 2260258133:2260258133(0) ack 1979979170 win 65535
10:05:23.596027 IP (tos 0x0, ttl 64, id 46795, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x1d95), 1980002754:1980003290(536) ack 2260258133 win 5840
10:05:23.596028 IP (tos 0x0, ttl 64, id 20358, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0c1d (correct), 2260258133:2260258133(0) ack 1979979706 win 65535
10:05:23.596030 IP (tos 0x0, ttl 64, id 46796, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xf42a), 1980003290:1980003826(536) ack 2260258133 win 5840
10:05:23.596031 IP (tos 0x0, ttl 64, id 20359, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0a05 (correct), 2260258133:2260258133(0) ack 1979980242 win 65535
10:05:23.596033 IP (tos 0x0, ttl 64, id 46797, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xb9ca), 1980003826:1980004362(536) ack 2260258133 win 5840
10:05:23.596034 IP (tos 0x0, ttl 64, id 20360, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x07ed (correct), 2260258133:2260258133(0) ack 1979980778 win 65535
10:05:23.596036 IP (tos 0x0, ttl 64, id 46798, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xd6a9), 1980004362:1980004898(536) ack 2260258133 win 5840
10:05:23.596037 IP (tos 0x0, ttl 64, id 20361, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x05d5 (correct), 2260258133:2260258133(0) ack 1979981314 win 65535
10:05:23.596039 IP (tos 0x0, ttl 64, id 46799, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x2078), 1980004898:1980005434(536) ack 2260258133 win 5840
10:05:23.596040 IP (tos 0x0, ttl 64, id 20362, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x03bd (correct), 2260258133:2260258133(0) ack 1979981850 win 65535
10:05:23.596042 IP (tos 0x0, ttl 64, id 46800, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x8bd3), 1980005434:1980005970(536) ack 2260258133 win 5840
10:05:23.596043 IP (tos 0x0, ttl 64, id 20363, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x01a5 (correct), 2260258133:2260258133(0) ack 1979982386 win 65535
10:05:23.596045 IP (tos 0x0, ttl 64, id 46801, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x4d3a), 1980005970:1980006506(536) ack 2260258133 win 5840
10:05:23.596047 IP (tos 0x0, ttl 64, id 20364, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xff8c (correct), 2260258133:2260258133(0) ack 1979982922 win 65535
10:05:23.596048 IP (tos 0x0, ttl 64, id 46802, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x4531), 1980006506:1980007042(536) ack 2260258133 win 5840
10:05:23.596050 IP (tos 0x0, ttl 64, id 20365, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xfd74 (correct), 2260258133:2260258133(0) ack 1979983458 win 65535
10:05:23.596053 IP (tos 0x0, ttl 64, id 46803, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x4bb3), 1980007042:1980007578(536) ack 2260258133 win 5840
10:05:23.596054 IP (tos 0x0, ttl 64, id 20366, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xfb5c (correct), 2260258133:2260258133(0) ack 1979983994 win 65535
10:05:23.596055 IP (tos 0x0, ttl 64, id 46804, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x500e), 1980007578:1980008114(536) ack 2260258133 win 5840
10:05:23.596056 IP (tos 0x0, ttl 64, id 20367, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf944 (correct), 2260258133:2260258133(0) ack 1979984530 win 65535
10:05:23.596059 IP (tos 0x0, ttl 64, id 20368, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf72c (correct), 2260258133:2260258133(0) ack 1979985066 win 65535
10:05:23.596119 IP (tos 0x0, ttl 64, id 20383, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xd7c4 (correct), 2260258133:2260258133(0) ack 1979993106 win 65535
10:05:23.596171 IP (tos 0x0, ttl 64, id 20390, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xc91c (correct), 2260258133:2260258133(0) ack 1979996858 win 65535
10:05:23.596174 IP (tos 0x0, ttl 64, id 46829, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x6077), 1980020978:1980021514(536) ack 2260258133 win 5840
10:05:23.596175 IP (tos 0x0, ttl 64, id 20391, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xc704 (correct), 2260258133:2260258133(0) ack 1979997394 win 65535
10:05:23.596177 IP (tos 0x0, ttl 64, id 46830, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x51e6), 1980021514:1980022050(536) ack 2260258133 win 5840
10:05:23.596178 IP (tos 0x0, ttl 64, id 20392, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xc4ec (correct), 2260258133:2260258133(0) ack 1979997930 win 65535
10:05:23.596180 IP (tos 0x0, ttl 64, id 46831, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0xc561), 1980022050:1980022586(536) ack 2260258133 win 5840
10:05:23.596270 IP (tos 0x0, ttl 64, id 20406, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8c64 (correct), 2260258133:2260258133(0) ack 1980012402 win 65535
10:05:23.596273 IP (tos 0x0, ttl 64, id 46858, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: P, cksum 0x1855 (incorrect (-> 0x85df), 1980036522:1980037058(536) ack 2260258133 win 5840
10:05:23.596275 IP (tos 0x0, ttl 64, id 46859, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x6dc3), 1980037058:1980037594(536) ack 2260258133 win 5840
10:05:23.596276 IP (tos 0x0, ttl 64, id 20407, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8834 (correct), 2260258133:2260258133(0) ack 1980013474 win 65535
10:05:23.596280 IP (tos 0x0, ttl 64, id 20408, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8404 (correct), 2260258133:2260258133(0) ack 1980014546 win 65535
10:05:23.596285 IP (tos 0x0, ttl 64, id 20409, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x7fd4 (correct), 2260258133:2260258133(0) ack 1980015618 win 65535
10:05:23.596289 IP (tos 0x0, ttl 64, id 20410, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x7ba4 (correct), 2260258133:2260258133(0) ack 1980016690 win 65535
10:05:23.596370 IP (tos 0x0, ttl 64, id 20417, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5e54 (correct), 2260258133:2260258133(0) ack 1980024194 win 65535
10:05:23.596374 IP (tos 0x0, ttl 64, id 46880, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x57d6), 1980048314:1980049386(1072) ack 2260258133 win 5840
10:05:23.596375 IP (tos 0x0, ttl 64, id 20418, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5a24 (correct), 2260258133:2260258133(0) ack 1980025266 win 65535
10:05:23.596378 IP (tos 0x0, ttl 64, id 46882, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x623a), 1980049386:1980050458(1072) ack 2260258133 win 5840
10:05:23.596379 IP (tos 0x0, ttl 64, id 20419, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x55f4 (correct), 2260258133:2260258133(0) ack 1980026338 win 65535
10:05:23.596381 IP (tos 0x0, ttl 64, id 46884, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x1968), 1980050458:1980051530(1072) ack 2260258133 win 5840
10:05:23.596383 IP (tos 0x0, ttl 64, id 20420, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x51c4 (correct), 2260258133:2260258133(0) ack 1980027410 win 65535
10:05:23.596385 IP (tos 0x0, ttl 64, id 46886, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xc14a), 1980051530:1980052602(1072) ack 2260258133 win 5840
10:05:23.596387 IP (tos 0x0, ttl 64, id 20421, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4d94 (correct), 2260258133:2260258133(0) ack 1980028482 win 65535
10:05:23.596967 IP (tos 0x0, ttl 64, id 20422, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4964 (correct), 2260258133:2260258133(0) ack 1980029554 win 65535
10:05:23.596971 IP (tos 0x0, ttl 64, id 46890, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x840c), 1980053674:1980054746(1072) ack 2260258133 win 5840
10:05:23.596973 IP (tos 0x0, ttl 64, id 20423, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4534 (correct), 2260258133:2260258133(0) ack 1980030626 win 65535
10:05:23.596975 IP (tos 0x0, ttl 64, id 46892, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x08ba), 1980054746:1980055818(1072) ack 2260258133 win 5840
10:05:23.596976 IP (tos 0x0, ttl 64, id 20424, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4104 (correct), 2260258133:2260258133(0) ack 1980031698 win 65535
10:05:23.596979 IP (tos 0x0, ttl 64, id 46894, offset 0, flags [DF], proto TCP (6), length 1648) dione.40344 > phoenix.distcc: ., cksum 0x1c85 (incorrect (-> 0x8154), 1980055818:1980057426(1608) ack 2260258133 win 5840
10:05:23.597019 IP (tos 0x0, ttl 64, id 20425, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3cd4 (correct), 2260258133:2260258133(0) ack 1980032770 win 65535
10:05:23.597022 IP (tos 0x0, ttl 64, id 46897, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xcb5d), 1980057426:1980058498(1072) ack 2260258133 win 5840
10:05:23.597023 IP (tos 0x0, ttl 64, id 20426, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x38a4 (correct), 2260258133:2260258133(0) ack 1980033842 win 65535
10:05:23.597026 IP (tos 0x0, ttl 64, id 46899, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x33dc), 1980058498:1980059570(1072) ack 2260258133 win 5840
10:05:23.597028 IP (tos 0x0, ttl 64, id 20427, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3474 (correct), 2260258133:2260258133(0) ack 1980034914 win 65535
10:05:23.597030 IP (tos 0x0, ttl 64, id 46901, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xf8b2), 1980059570:1980060642(1072) ack 2260258133 win 5840
10:05:23.597032 IP (tos 0x0, ttl 64, id 20428, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3044 (correct), 2260258133:2260258133(0) ack 1980035986 win 65535
10:05:23.597034 IP (tos 0x0, ttl 64, id 46903, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x1d20), 1980060642:1980061714(1072) ack 2260258133 win 5840
10:05:23.597036 IP (tos 0x0, ttl 64, id 20429, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x2c14 (correct), 2260258133:2260258133(0) ack 1980037058 win 65535
10:05:23.597039 IP (tos 0x0, ttl 64, id 46905, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xdc53), 1980061714:1980062786(1072) ack 2260258133 win 5840
10:05:23.597040 IP (tos 0x0, ttl 64, id 20430, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x27e4 (correct), 2260258133:2260258133(0) ack 1980038130 win 65535
10:05:23.597043 IP (tos 0x0, ttl 64, id 46907, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x3785), 1980062786:1980063858(1072) ack 2260258133 win 5840
10:05:23.597044 IP (tos 0x0, ttl 64, id 20431, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x23b4 (correct), 2260258133:2260258133(0) ack 1980039202 win 65535
10:05:23.597047 IP (tos 0x0, ttl 64, id 46909, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xa5b8), 1980063858:1980064930(1072) ack 2260258133 win 5840
10:05:23.597049 IP (tos 0x0, ttl 64, id 20432, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1f84 (correct), 2260258133:2260258133(0) ack 1980040274 win 65535
10:05:23.597051 IP (tos 0x0, ttl 64, id 46911, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x4b61), 1980064930:1980066002(1072) ack 2260258133 win 5840
10:05:23.597053 IP (tos 0x0, ttl 64, id 20433, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1b54 (correct), 2260258133:2260258133(0) ack 1980041346 win 65535
10:05:23.597055 IP (tos 0x0, ttl 64, id 46913, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xb61b), 1980066002:1980067074(1072) ack 2260258133 win 5840
10:05:23.597057 IP (tos 0x0, ttl 64, id 20434, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1724 (correct), 2260258133:2260258133(0) ack 1980042418 win 65535
10:05:23.597059 IP (tos 0x0, ttl 64, id 46915, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xabf9), 1980067074:1980068146(1072) ack 2260258133 win 5840
10:05:23.597061 IP (tos 0x0, ttl 64, id 20435, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x12f4 (correct), 2260258133:2260258133(0) ack 1980043490 win 65535
10:05:23.597063 IP (tos 0x0, ttl 64, id 46917, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x2116), 1980068146:1980069218(1072) ack 2260258133 win 5840
10:05:23.597065 IP (tos 0x0, ttl 64, id 20436, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0ec4 (correct), 2260258133:2260258133(0) ack 1980044562 win 65535
10:05:23.597067 IP (tos 0x0, ttl 64, id 46919, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x5c77), 1980069218:1980069754(536) ack 2260258133 win 5840
10:05:23.597068 IP (tos 0x0, ttl 64, id 46920, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: ., cksum 0x1855 (incorrect (-> 0x8107), 1980069754:1980070290(536) ack 2260258133 win 5840
10:05:23.597070 IP (tos 0x0, ttl 64, id 20437, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0a94 (correct), 2260258133:2260258133(0) ack 1980045634 win 65535
10:05:23.597072 IP (tos 0x0, ttl 64, id 46921, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x1c56), 1980070290:1980071362(1072) ack 2260258133 win 5840
10:05:23.597074 IP (tos 0x0, ttl 64, id 20438, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0664 (correct), 2260258133:2260258133(0) ack 1980046706 win 65535
10:05:23.597076 IP (tos 0x0, ttl 64, id 46923, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x571c), 1980071362:1980072434(1072) ack 2260258133 win 5840
10:05:23.597078 IP (tos 0x0, ttl 64, id 20439, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0234 (correct), 2260258133:2260258133(0) ack 1980047778 win 65535
10:05:23.597080 IP (tos 0x0, ttl 64, id 46925, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x312a), 1980072434:1980073506(1072) ack 2260258133 win 5840
10:05:23.597081 IP (tos 0x0, ttl 64, id 20440, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xfe03 (correct), 2260258133:2260258133(0) ack 1980048850 win 65535
10:05:23.597084 IP (tos 0x0, ttl 64, id 46927, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x7272), 1980073506:1980074578(1072) ack 2260258133 win 5840
10:05:23.597086 IP (tos 0x0, ttl 64, id 20441, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf9d3 (correct), 2260258133:2260258133(0) ack 1980049922 win 65535
10:05:23.597089 IP (tos 0x0, ttl 64, id 46929, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x9aa9), 1980074578:1980075650(1072) ack 2260258133 win 5840
10:05:23.597092 IP (tos 0x0, ttl 64, id 20442, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf5a3 (correct), 2260258133:2260258133(0) ack 1980050994 win 65535
10:05:23.597095 IP (tos 0x0, ttl 64, id 46931, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x3ee6), 1980075650:1980076722(1072) ack 2260258133 win 5840
10:05:23.597118 IP (tos 0x0, ttl 64, id 20443, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf173 (correct), 2260258133:2260258133(0) ack 1980052066 win 65535
10:05:23.597121 IP (tos 0x0, ttl 64, id 46933, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xe496), 1980076722:1980077794(1072) ack 2260258133 win 5840
10:05:23.597124 IP (tos 0x0, ttl 64, id 20444, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xed43 (correct), 2260258133:2260258133(0) ack 1980053138 win 65535
10:05:23.597126 IP (tos 0x0, ttl 64, id 46935, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xaea4), 1980077794:1980078866(1072) ack 2260258133 win 5840
10:05:23.597128 IP (tos 0x0, ttl 64, id 20445, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe913 (correct), 2260258133:2260258133(0) ack 1980054210 win 65535
10:05:23.597130 IP (tos 0x0, ttl 64, id 46937, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xf86a), 1980078866:1980079938(1072) ack 2260258133 win 5840
10:05:23.597132 IP (tos 0x0, ttl 64, id 20446, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe4e3 (correct), 2260258133:2260258133(0) ack 1980055282 win 65535
10:05:23.597134 IP (tos 0x0, ttl 64, id 46939, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0x68f9), 1980079938:1980081010(1072) ack 2260258133 win 5840
10:05:23.597136 IP (tos 0x0, ttl 64, id 20447, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe0b3 (correct), 2260258133:2260258133(0) ack 1980056354 win 65535
10:05:23.597138 IP (tos 0x0, ttl 64, id 46941, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xb1a1), 1980081010:1980082082(1072) ack 2260258133 win 5840
10:05:23.597140 IP (tos 0x0, ttl 64, id 20448, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xdc83 (correct), 2260258133:2260258133(0) ack 1980057426 win 65535
10:05:23.597142 IP (tos 0x0, ttl 64, id 46943, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xbc8a), 1980082082:1980083154(1072) ack 2260258133 win 5840
10:05:23.597144 IP (tos 0x0, ttl 64, id 20449, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xd853 (correct), 2260258133:2260258133(0) ack 1980058498 win 65535
10:05:23.597146 IP (tos 0x0, ttl 64, id 46945, offset 0, flags [DF], proto TCP (6), length 1112) dione.40344 > phoenix.distcc: ., cksum 0x1a6d (incorrect (-> 0xc6cf), 1980083154:1980084226(1072) ack 2260258133 win 5840
10:05:23.597148 IP (tos 0x0, ttl 64, id 20450, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xd423 (correct), 2260258133:2260258133(0) ack 1980059570 win 65535
10:05:23.597150 IP (tos 0x0, ttl 64, id 46947, offset 0, flags [DF], proto TCP (6), length 1648) dione.40344 > phoenix.distcc: ., cksum 0x1c85 (incorrect (-> 0x5cfb), 1980084226:1980085834(1608) ack 2260258133 win 5840
10:05:23.597151 IP (tos 0x0, ttl 64, id 20451, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xcff3 (correct), 2260258133:2260258133(0) ack 1980060642 win 65535
10:05:23.597153 IP (tos 0x0, ttl 64, id 46950, offset 0, flags [DF], proto TCP (6), length 351) dione.40344 > phoenix.distcc: P, cksum 0x1774 (incorrect (-> 0xe29c), 1980085834:1980086145(311) ack 2260258133 win 5840
10:05:23.597167 IP (tos 0x0, ttl 64, id 20452, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xcbc3 (correct), 2260258133:2260258133(0) ack 1980061714 win 65535
10:05:23.597169 IP (tos 0x0, ttl 64, id 20453, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xc793 (correct), 2260258133:2260258133(0) ack 1980062786 win 65535
10:05:23.597219 IP (tos 0x0, ttl 64, id 20454, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xc363 (correct), 2260258133:2260258133(0) ack 1980063858 win 65535
10:05:23.597222 IP (tos 0x0, ttl 64, id 20455, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xbf33 (correct), 2260258133:2260258133(0) ack 1980064930 win 65535
10:05:23.597223 IP (tos 0x0, ttl 64, id 20456, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xbb03 (correct), 2260258133:2260258133(0) ack 1980066002 win 65535
10:05:23.597225 IP (tos 0x0, ttl 64, id 20457, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xb6d3 (correct), 2260258133:2260258133(0) ack 1980067074 win 65535
10:05:23.597226 IP (tos 0x0, ttl 64, id 20458, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xb2a3 (correct), 2260258133:2260258133(0) ack 1980068146 win 65535
10:05:23.597268 IP (tos 0x0, ttl 64, id 20459, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xae73 (correct), 2260258133:2260258133(0) ack 1980069218 win 65535
10:05:23.597270 IP (tos 0x0, ttl 64, id 20460, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xaa43 (correct), 2260258133:2260258133(0) ack 1980070290 win 65535
10:05:23.597272 IP (tos 0x0, ttl 64, id 20461, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xa613 (correct), 2260258133:2260258133(0) ack 1980071362 win 65535
10:05:23.597318 IP (tos 0x0, ttl 64, id 20462, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xa1e3 (correct), 2260258133:2260258133(0) ack 1980072434 win 65535
10:05:23.597320 IP (tos 0x0, ttl 64, id 20463, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x9db3 (correct), 2260258133:2260258133(0) ack 1980073506 win 65535
10:05:23.597321 IP (tos 0x0, ttl 64, id 20464, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x9983 (correct), 2260258133:2260258133(0) ack 1980074578 win 65535
10:05:23.597367 IP (tos 0x0, ttl 64, id 20465, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x9553 (correct), 2260258133:2260258133(0) ack 1980075650 win 65535
10:05:23.597369 IP (tos 0x0, ttl 64, id 20466, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x9123 (correct), 2260258133:2260258133(0) ack 1980076722 win 65535
10:05:23.597371 IP (tos 0x0, ttl 64, id 20467, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8cf3 (correct), 2260258133:2260258133(0) ack 1980077794 win 65535
10:05:23.597372 IP (tos 0x0, ttl 64, id 20468, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x88c3 (correct), 2260258133:2260258133(0) ack 1980078866 win 65535
10:05:23.597418 IP (tos 0x0, ttl 64, id 20469, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8493 (correct), 2260258133:2260258133(0) ack 1980079938 win 65535
10:05:23.597420 IP (tos 0x0, ttl 64, id 20470, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8063 (correct), 2260258133:2260258133(0) ack 1980081010 win 65535
10:05:23.597421 IP (tos 0x0, ttl 64, id 20471, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x7c33 (correct), 2260258133:2260258133(0) ack 1980082082 win 65535
10:05:23.597468 IP (tos 0x0, ttl 64, id 20472, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x7803 (correct), 2260258133:2260258133(0) ack 1980083154 win 65535
10:05:23.597470 IP (tos 0x0, ttl 64, id 20473, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x73d3 (correct), 2260258133:2260258133(0) ack 1980084226 win 65535
10:05:23.597471 IP (tos 0x0, ttl 64, id 20474, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x6fa3 (correct), 2260258133:2260258133(0) ack 1980085298 win 65535
10:05:23.597473 IP (tos 0x0, ttl 64, id 20475, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x6c54 (correct), 2260258133:2260258133(0) ack 1980086145 win 65535
10:05:23.998379 IP (tos 0x0, ttl 64, id 20476, offset 0, flags [DF], proto TCP (6), length 1500) phoenix.distcc > dione.40344: ., cksum 0xdb6a (correct), 2260258133:2260259593(1460) ack 1980086145 win 65535
10:05:23.998388 IP (tos 0x0, ttl 64, id 46951, offset 0, flags [DF], proto TCP (6), length 40) dione.40344 > phoenix.distcc: ., cksum 0x4468 (correct), 1980086145:1980086145(0) ack 2260259593 win 8760
10:05:23.998391 IP (tos 0x0, ttl 64, id 20477, offset 0, flags [DF], proto TCP (6), length 1500) phoenix.distcc > dione.40344: ., cksum 0xc6e2 (correct), 2260259593:2260261053(1460) ack 1980086145 win 65535
10:05:23.998394 IP (tos 0x0, ttl 64, id 46952, offset 0, flags [DF], proto TCP (6), length 40) dione.40344 > phoenix.distcc: ., cksum 0x334c (correct), 1980086145:1980086145(0) ack 2260261053 win 11680
10:05:23.998477 IP (tos 0x0, ttl 64, id 20478, offset 0, flags [DF], proto TCP (6), length 1500) phoenix.distcc > dione.40344: ., cksum 0x52a0 (correct), 2260261053:2260262513(1460) ack 1980086145 win 65535
10:05:23.998484 IP (tos 0x0, ttl 64, id 46953, offset 0, flags [DF], proto TCP (6), length 40) dione.40344 > phoenix.distcc: ., cksum 0x2230 (correct), 1980086145:1980086145(0) ack 2260262513 win 14600
10:05:23.998486 IP (tos 0x0, ttl 64, id 20479, offset 0, flags [DF], proto TCP (6), length 1500) phoenix.distcc > dione.40344: ., cksum 0x577f (correct), 2260262513:2260263973(1460) ack 1980086145 win 65535
10:05:23.998489 IP (tos 0x0, ttl 64, id 46954, offset 0, flags [DF], proto TCP (6), length 40) dione.40344 > phoenix.distcc: ., cksum 0x1114 (correct), 1980086145:1980086145(0) ack 2260263973 win 17520
10:05:23.998528 IP (tos 0x0, ttl 64, id 20480, offset 0, flags [DF], proto TCP (6), length 1500) phoenix.distcc > dione.40344: ., cksum 0x3212 (correct), 2260263973:2260265433(1460) ack 1980086145 win 65535
10:05:23.998532 IP (tos 0x0, ttl 64, id 46955, offset 0, flags [DF], proto TCP (6), length 40) dione.40344 > phoenix.distcc: ., cksum 0xfff7 (correct), 1980086145:1980086145(0) ack 2260265433 win 20440
10:05:23.998534 IP (tos 0x0, ttl 64, id 20481, offset 0, flags [DF], proto TCP (6), length 1500) phoenix.distcc > dione.40344: ., cksum 0x0f43 (correct), 2260265433:2260266893(1460) ack 1980086145 win 65535
10:05:23.998537 IP (tos 0x0, ttl 64, id 46956, offset 0, flags [DF], proto TCP (6), length 40) dione.40344 > phoenix.distcc: ., cksum 0xeedb (correct), 1980086145:1980086145(0) ack 2260266893 win 23360
10:05:23.998578 IP (tos 0x0, ttl 64, id 20482, offset 0, flags [DF], proto TCP (6), length 1500) phoenix.distcc > dione.40344: ., cksum 0xb97b (correct), 2260266893:2260268353(1460) ack 1980086145 win 65535
10:05:23.998582 IP (tos 0x0, ttl 64, id 46957, offset 0, flags [DF], proto TCP (6), length 40) dione.40344 > phoenix.distcc: ., cksum 0xddbf (correct), 1980086145:1980086145(0) ack 2260268353 win 26280
10:05:23.998586 IP (tos 0x0, ttl 64, id 20483, offset 0, flags [DF], proto TCP (6), length 1500) phoenix.distcc > dione.40344: P, cksum 0x0297 (correct), 2260268353:2260269813(1460) ack 1980086145 win 65535
10:05:23.998588 IP (tos 0x0, ttl 64, id 46958, offset 0, flags [DF], proto TCP (6), length 40) dione.40344 > phoenix.distcc: ., cksum 0xcca3 (correct), 1980086145:1980086145(0) ack 2260269813 win 29200
10:05:23.998590 IP (tos 0x0, ttl 64, id 20484, offset 0, flags [DF], proto TCP (6), length 924) phoenix.distcc > dione.40344: P, cksum 0x67c5 (correct), 2260269813:2260270697(884) ack 1980086145 win 65535
10:05:23.998599 IP (tos 0x0, ttl 64, id 46959, offset 0, flags [DF], proto TCP (6), length 40) dione.40344 > phoenix.distcc: ., cksum 0xbdc7 (correct), 1980086145:1980086145(0) ack 2260270697 win 32120
10:05:23.998645 IP (tos 0x0, ttl 64, id 46960, offset 0, flags [DF], proto TCP (6), length 40) dione.40344 > phoenix.distcc: F, cksum 0xbdc6 (correct), 1980086145:1980086145(0) ack 2260270697 win 32120
10:05:23.999025 IP (tos 0x0, ttl 64, id 20485, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: F, cksum 0x3b3e (correct), 2260270697:2260270697(0) ack 1980086146 win 65535
10:05:23.999030 IP (tos 0x0, ttl 64, id 46961, offset 0, flags [DF], proto TCP (6), length 40) dione.40344 > phoenix.distcc: ., cksum 0xbdc5 (correct), 1980086146:1980086146(0) ack 2260270698 win 32120

[traced on the server, phoenix]

10:03:24.304962 IP (tos 0x0, ttl 64, id 46098, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979565914:1979566450(536) ack 2260258133 win 5840
10:03:24.304989 IP (tos 0x0, ttl 64, id 19850, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5a6b (correct), 2260258133:2260258133(0) ack 1979566450 win 65535
10:03:24.305063 IP (tos 0x0, ttl 64, id 46099, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979631449:1979631985(536) ack 2260258133 win 5840
10:03:24.305076 IP (tos 0x0, ttl 64, id 19851, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5a6b (correct), 2260258133:2260258133(0) ack 1979566450 win 65535
10:05:24.324738 IP (tos 0x0, ttl 64, id 46100, offset 0, flags [DF], proto TCP (6), length 183) dione.40344 > phoenix.distcc: . 1979566450:1979566593(143) ack 2260258133 win 5840
10:05:24.324789 IP (tos 0x0, ttl 64, id 19852, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x59dc (correct), 2260258133:2260258133(0) ack 1979566593 win 65535
10:05:24.324910 IP (tos 0x0, ttl 64, id 46101, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979566593:1979567129(536) ack 2260258133 win 5840
10:05:24.324918 IP (tos 0x0, ttl 64, id 46102, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979567129:1979567665(536) ack 2260258133 win 5840
10:05:24.325121 IP (tos 0x0, ttl 64, id 19853, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5a6b (correct), 2260258133:2260258133(0) ack 1979631985 win 65535
10:05:24.325131 IP (tos 0x0, ttl 64, id 19854, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5a6b (correct), 2260258133:2260258133(0) ack 1979631985 win 65535
10:05:24.325282 IP (tos 0x0, ttl 64, id 46103, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979631985:1979632521(536) ack 2260258133 win 5840
10:05:24.325291 IP (tos 0x0, ttl 64, id 19855, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5853 (correct), 2260258133:2260258133(0) ack 1979632521 win 65535
10:05:24.325293 IP (tos 0x0, ttl 64, id 46104, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979632521:1979633057(536) ack 2260258133 win 5840
10:05:24.325300 IP (tos 0x0, ttl 64, id 19856, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x563b (correct), 2260258133:2260258133(0) ack 1979633057 win 65535
10:05:24.325301 IP (tos 0x0, ttl 64, id 46105, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979633057:1979633593(536) ack 2260258133 win 5840
10:05:24.325307 IP (tos 0x0, ttl 64, id 19857, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5423 (correct), 2260258133:2260258133(0) ack 1979633593 win 65535
10:05:24.325308 IP (tos 0x0, ttl 64, id 46106, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979633593:1979634129(536) ack 2260258133 win 5840
10:05:24.325315 IP (tos 0x0, ttl 64, id 19858, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x520b (correct), 2260258133:2260258133(0) ack 1979634129 win 65535
10:05:24.325386 IP (tos 0x0, ttl 64, id 46107, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979634129:1979634665(536) ack 2260258133 win 5840
10:05:24.325398 IP (tos 0x0, ttl 64, id 19859, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4ff3 (correct), 2260258133:2260258133(0) ack 1979634665 win 65535
10:05:24.325399 IP (tos 0x0, ttl 64, id 46108, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979634665:1979635201(536) ack 2260258133 win 5840
10:05:24.325407 IP (tos 0x0, ttl 64, id 19860, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4ddb (correct), 2260258133:2260258133(0) ack 1979635201 win 65535
10:05:24.325409 IP (tos 0x0, ttl 64, id 46109, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979635201:1979635737(536) ack 2260258133 win 5840
10:05:24.325415 IP (tos 0x0, ttl 64, id 19861, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4bc3 (correct), 2260258133:2260258133(0) ack 1979635737 win 65535
10:05:24.325422 IP (tos 0x0, ttl 64, id 46110, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979635737:1979636273(536) ack 2260258133 win 5840
10:05:24.325428 IP (tos 0x0, ttl 64, id 19862, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x49ab (correct), 2260258133:2260258133(0) ack 1979636273 win 65535
10:05:24.325429 IP (tos 0x0, ttl 64, id 46111, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979636273:1979636809(536) ack 2260258133 win 5840
10:05:24.325434 IP (tos 0x0, ttl 64, id 19863, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4793 (correct), 2260258133:2260258133(0) ack 1979636809 win 65535
10:05:24.325435 IP (tos 0x0, ttl 64, id 46112, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979636809:1979637345(536) ack 2260258133 win 5840
10:05:24.325437 IP (tos 0x0, ttl 64, id 46113, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979637345:1979637881(536) ack 2260258133 win 5840
10:05:24.325444 IP (tos 0x0, ttl 64, id 19864, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x457b (correct), 2260258133:2260258133(0) ack 1979637345 win 65535
10:05:24.325449 IP (tos 0x0, ttl 64, id 19865, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4363 (correct), 2260258133:2260258133(0) ack 1979637881 win 65535
10:05:24.325491 IP (tos 0x0, ttl 64, id 46114, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979637881:1979638417(536) ack 2260258133 win 5840
10:05:24.325498 IP (tos 0x0, ttl 64, id 46115, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979638417:1979638953(536) ack 2260258133 win 5840
10:05:24.325502 IP (tos 0x0, ttl 64, id 19866, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x414b (correct), 2260258133:2260258133(0) ack 1979638417 win 65535
10:05:24.325506 IP (tos 0x0, ttl 64, id 46116, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979638953:1979639489(536) ack 2260258133 win 5840
10:05:24.325508 IP (tos 0x0, ttl 64, id 19867, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3f33 (correct), 2260258133:2260258133(0) ack 1979638953 win 65535
10:05:24.325517 IP (tos 0x0, ttl 64, id 19868, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3d1b (correct), 2260258133:2260258133(0) ack 1979639489 win 65535
10:05:24.325519 IP (tos 0x0, ttl 64, id 46117, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979639489:1979640025(536) ack 2260258133 win 5840
10:05:24.325525 IP (tos 0x0, ttl 64, id 19869, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3b03 (correct), 2260258133:2260258133(0) ack 1979640025 win 65535
10:05:24.325526 IP (tos 0x0, ttl 64, id 46118, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979640025:1979640561(536) ack 2260258133 win 5840
10:05:24.325531 IP (tos 0x0, ttl 64, id 19870, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x38eb (correct), 2260258133:2260258133(0) ack 1979640561 win 65535
10:05:24.325532 IP (tos 0x0, ttl 64, id 46119, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979640561:1979641097(536) ack 2260258133 win 5840
10:05:24.325540 IP (tos 0x0, ttl 64, id 19871, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x36d3 (correct), 2260258133:2260258133(0) ack 1979641097 win 65535
10:05:24.325548 IP (tos 0x0, ttl 64, id 46120, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979641097:1979641633(536) ack 2260258133 win 5840
10:05:24.325554 IP (tos 0x0, ttl 64, id 46121, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979641633:1979642169(536) ack 2260258133 win 5840
10:05:24.325559 IP (tos 0x0, ttl 64, id 19872, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x34bb (correct), 2260258133:2260258133(0) ack 1979641633 win 65535
10:05:24.325560 IP (tos 0x0, ttl 64, id 46122, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979642169:1979642705(536) ack 2260258133 win 5840
10:05:24.325563 IP (tos 0x0, ttl 64, id 46123, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979642705:1979643241(536) ack 2260258133 win 5840
10:05:24.325564 IP (tos 0x0, ttl 64, id 19873, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x32a3 (correct), 2260258133:2260258133(0) ack 1979642169 win 65535
10:05:24.325570 IP (tos 0x0, ttl 64, id 19874, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x308b (correct), 2260258133:2260258133(0) ack 1979642705 win 65535
10:05:24.325574 IP (tos 0x0, ttl 64, id 19875, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x2e73 (correct), 2260258133:2260258133(0) ack 1979643241 win 65535
10:05:24.325577 IP (tos 0x0, ttl 64, id 46124, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979643241:1979643777(536) ack 2260258133 win 5840
10:05:24.325585 IP (tos 0x0, ttl 64, id 19876, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x2c5b (correct), 2260258133:2260258133(0) ack 1979643777 win 65535
10:05:24.325587 IP (tos 0x0, ttl 64, id 46125, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979643777:1979644313(536) ack 2260258133 win 5840
10:05:24.325591 IP (tos 0x0, ttl 64, id 46126, offset 0, flags [DF], proto TCP (6), length 433) dione.40344 > phoenix.distcc: . 1979644313:1979644706(393) ack 2260258133 win 5840
10:05:24.325592 IP (tos 0x0, ttl 64, id 19877, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x2a43 (correct), 2260258133:2260258133(0) ack 1979644313 win 65535
10:05:24.325593 IP (tos 0x0, ttl 64, id 46127, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979644706:1979645242(536) ack 2260258133 win 5840
10:05:24.325599 IP (tos 0x0, ttl 64, id 19878, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x28ba (correct), 2260258133:2260258133(0) ack 1979644706 win 65535
10:05:24.325603 IP (tos 0x0, ttl 64, id 19879, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x26a2 (correct), 2260258133:2260258133(0) ack 1979645242 win 65535
10:05:24.325607 IP (tos 0x0, ttl 64, id 46128, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979645242:1979645778(536) ack 2260258133 win 5840
10:05:24.325615 IP (tos 0x0, ttl 64, id 19880, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x248a (correct), 2260258133:2260258133(0) ack 1979645778 win 65535
10:05:24.325617 IP (tos 0x0, ttl 64, id 46129, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979645778:1979646314(536) ack 2260258133 win 5840
10:05:24.325619 IP (tos 0x0, ttl 64, id 46130, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979646314:1979646850(536) ack 2260258133 win 5840
10:05:24.325622 IP (tos 0x0, ttl 64, id 46131, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979646850:1979647386(536) ack 2260258133 win 5840
10:05:24.325627 IP (tos 0x0, ttl 64, id 19881, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x2272 (correct), 2260258133:2260258133(0) ack 1979646314 win 65535
10:05:24.325630 IP (tos 0x0, ttl 64, id 46132, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979647386:1979647922(536) ack 2260258133 win 5840
10:05:24.325632 IP (tos 0x0, ttl 64, id 19882, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x205a (correct), 2260258133:2260258133(0) ack 1979646850 win 65535
10:05:24.325637 IP (tos 0x0, ttl 64, id 19883, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1e42 (correct), 2260258133:2260258133(0) ack 1979647386 win 65535
10:05:24.325635 IP (tos 0x0, ttl 64, id 46133, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979647922:1979648458(536) ack 2260258133 win 5840
10:05:24.325641 IP (tos 0x0, ttl 64, id 19884, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1c2a (correct), 2260258133:2260258133(0) ack 1979647922 win 65535
10:05:24.325647 IP (tos 0x0, ttl 64, id 19885, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1a12 (correct), 2260258133:2260258133(0) ack 1979648458 win 65535
10:05:24.325654 IP (tos 0x0, ttl 64, id 46134, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979648458:1979648994(536) ack 2260258133 win 5840
10:05:24.325660 IP (tos 0x0, ttl 64, id 19886, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x17fa (correct), 2260258133:2260258133(0) ack 1979648994 win 65535
10:05:24.325661 IP (tos 0x0, ttl 64, id 46135, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979648994:1979649530(536) ack 2260258133 win 5840
10:05:24.325666 IP (tos 0x0, ttl 64, id 19887, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x15e2 (correct), 2260258133:2260258133(0) ack 1979649530 win 65535
10:05:24.325668 IP (tos 0x0, ttl 64, id 46136, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979649530:1979650066(536) ack 2260258133 win 5840
10:05:24.325671 IP (tos 0x0, ttl 64, id 46137, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979650066:1979650602(536) ack 2260258133 win 5840
10:05:24.325676 IP (tos 0x0, ttl 64, id 19888, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x13ca (correct), 2260258133:2260258133(0) ack 1979650066 win 65535
10:05:24.325680 IP (tos 0x0, ttl 64, id 46138, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979650602:1979651138(536) ack 2260258133 win 5840
10:05:24.325681 IP (tos 0x0, ttl 64, id 19889, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x11b2 (correct), 2260258133:2260258133(0) ack 1979650602 win 65535
10:05:24.325690 IP (tos 0x0, ttl 64, id 19890, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0f9a (correct), 2260258133:2260258133(0) ack 1979651138 win 65535
10:05:24.325692 IP (tos 0x0, ttl 64, id 46139, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979651138:1979651674(536) ack 2260258133 win 5840
10:05:24.325698 IP (tos 0x0, ttl 64, id 19891, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0d82 (correct), 2260258133:2260258133(0) ack 1979651674 win 65535
10:05:24.325700 IP (tos 0x0, ttl 64, id 46140, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979651674:1979652210(536) ack 2260258133 win 5840
10:05:24.325702 IP (tos 0x0, ttl 64, id 46141, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979652210:1979652746(536) ack 2260258133 win 5840
10:05:24.325706 IP (tos 0x0, ttl 64, id 46142, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979652746:1979653282(536) ack 2260258133 win 5840
10:05:24.325706 IP (tos 0x0, ttl 64, id 19892, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0b6a (correct), 2260258133:2260258133(0) ack 1979652210 win 65535
10:05:24.325711 IP (tos 0x0, ttl 64, id 19893, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0952 (correct), 2260258133:2260258133(0) ack 1979652746 win 65535
10:05:24.325714 IP (tos 0x0, ttl 64, id 19894, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x073a (correct), 2260258133:2260258133(0) ack 1979653282 win 65535
10:05:24.325722 IP (tos 0x0, ttl 64, id 46143, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979653282:1979653818(536) ack 2260258133 win 5840
10:05:24.325728 IP (tos 0x0, ttl 64, id 19895, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0522 (correct), 2260258133:2260258133(0) ack 1979653818 win 65535
10:05:24.325730 IP (tos 0x0, ttl 64, id 46144, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979653818:1979654354(536) ack 2260258133 win 5840
10:05:24.325734 IP (tos 0x0, ttl 64, id 46145, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979654354:1979654890(536) ack 2260258133 win 5840
10:05:24.325736 IP (tos 0x0, ttl 64, id 46146, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979654890:1979655426(536) ack 2260258133 win 5840
10:05:24.325737 IP (tos 0x0, ttl 64, id 19896, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x030a (correct), 2260258133:2260258133(0) ack 1979654354 win 65535
10:05:24.325742 IP (tos 0x0, ttl 64, id 19897, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x00f2 (correct), 2260258133:2260258133(0) ack 1979654890 win 65535
10:05:24.325745 IP (tos 0x0, ttl 64, id 46147, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979655426:1979655962(536) ack 2260258133 win 5840
10:05:24.325746 IP (tos 0x0, ttl 64, id 19898, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xfed9 (correct), 2260258133:2260258133(0) ack 1979655426 win 65535
10:05:24.325756 IP (tos 0x0, ttl 64, id 19899, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xfcc1 (correct), 2260258133:2260258133(0) ack 1979655962 win 65535
10:05:24.325758 IP (tos 0x0, ttl 64, id 46148, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979655962:1979656498(536) ack 2260258133 win 5840
10:05:24.325762 IP (tos 0x0, ttl 64, id 46149, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979656498:1979657034(536) ack 2260258133 win 5840
10:05:24.325764 IP (tos 0x0, ttl 64, id 46150, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979657034:1979657570(536) ack 2260258133 win 5840
10:05:24.325765 IP (tos 0x0, ttl 64, id 19900, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xfaa9 (correct), 2260258133:2260258133(0) ack 1979656498 win 65535
10:05:24.325770 IP (tos 0x0, ttl 64, id 19901, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf891 (correct), 2260258133:2260258133(0) ack 1979657034 win 65535
10:05:24.325775 IP (tos 0x0, ttl 64, id 19902, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf679 (correct), 2260258133:2260258133(0) ack 1979657570 win 65535
10:05:24.325781 IP (tos 0x0, ttl 64, id 46151, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979657570:1979658106(536) ack 2260258133 win 5840
10:05:24.325787 IP (tos 0x0, ttl 64, id 19903, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf461 (correct), 2260258133:2260258133(0) ack 1979658106 win 65535
10:05:24.325789 IP (tos 0x0, ttl 64, id 46152, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979658106:1979658642(536) ack 2260258133 win 5840
10:05:24.325791 IP (tos 0x0, ttl 64, id 46153, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979658642:1979659178(536) ack 2260258133 win 5840
10:05:24.325794 IP (tos 0x0, ttl 64, id 46154, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979659178:1979659714(536) ack 2260258133 win 5840
10:05:24.325795 IP (tos 0x0, ttl 64, id 19904, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf249 (correct), 2260258133:2260258133(0) ack 1979658642 win 65535
10:05:24.325796 IP (tos 0x0, ttl 64, id 46155, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979659714:1979660250(536) ack 2260258133 win 5840
10:05:24.325800 IP (tos 0x0, ttl 64, id 19905, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf031 (correct), 2260258133:2260258133(0) ack 1979659178 win 65535
10:05:24.325806 IP (tos 0x0, ttl 64, id 19906, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xee19 (correct), 2260258133:2260258133(0) ack 1979659714 win 65535
10:05:24.325811 IP (tos 0x0, ttl 64, id 19907, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xec01 (correct), 2260258133:2260258133(0) ack 1979660250 win 65535
10:05:24.325814 IP (tos 0x0, ttl 64, id 46156, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979660250:1979660786(536) ack 2260258133 win 5840
10:05:24.325823 IP (tos 0x0, ttl 64, id 19908, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe9e9 (correct), 2260258133:2260258133(0) ack 1979660786 win 65535
10:05:24.325824 IP (tos 0x0, ttl 64, id 46157, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979660786:1979661322(536) ack 2260258133 win 5840
10:05:24.325830 IP (tos 0x0, ttl 64, id 19909, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe7d1 (correct), 2260258133:2260258133(0) ack 1979661322 win 65535
10:05:24.325831 IP (tos 0x0, ttl 64, id 46158, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979661322:1979661858(536) ack 2260258133 win 5840
10:05:24.325833 IP (tos 0x0, ttl 64, id 46159, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979661858:1979662394(536) ack 2260258133 win 5840
10:05:24.325837 IP (tos 0x0, ttl 64, id 46160, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979662394:1979662930(536) ack 2260258133 win 5840
10:05:24.325838 IP (tos 0x0, ttl 64, id 19910, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe5b9 (correct), 2260258133:2260258133(0) ack 1979661858 win 65535
10:05:24.325839 IP (tos 0x0, ttl 64, id 46161, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979662930:1979663466(536) ack 2260258133 win 5840
10:05:24.325841 IP (tos 0x0, ttl 64, id 46162, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979663466:1979664002(536) ack 2260258133 win 5840
10:05:24.325844 IP (tos 0x0, ttl 64, id 19911, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe3a1 (correct), 2260258133:2260258133(0) ack 1979662394 win 65535
10:05:24.325845 IP (tos 0x0, ttl 64, id 46163, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979664002:1979664538(536) ack 2260258133 win 5840
10:05:24.325847 IP (tos 0x0, ttl 64, id 46164, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979664538:1979665074(536) ack 2260258133 win 5840
10:05:24.325850 IP (tos 0x0, ttl 64, id 19912, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe189 (correct), 2260258133:2260258133(0) ack 1979662930 win 65535
10:05:24.326731 IP (tos 0x0, ttl 64, id 46217, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979692946:1979693482(536) ack 2260258133 win 5840
10:05:24.326739 IP (tos 0x0, ttl 64, id 46218, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979693482:1979694018(536) ack 2260258133 win 5840
10:05:24.326741 IP (tos 0x0, ttl 64, id 46219, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979694018:1979694554(536) ack 2260258133 win 5840
10:05:24.326743 IP (tos 0x0, ttl 64, id 46220, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979694554:1979695090(536) ack 2260258133 win 5840
10:05:24.326745 IP (tos 0x0, ttl 64, id 46221, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979695090:1979695626(536) ack 2260258133 win 5840
10:05:24.326746 IP (tos 0x0, ttl 64, id 19969, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x6a31 (correct), 2260258133:2260258133(0) ack 1979693482 win 65535
10:05:24.326746 IP (tos 0x0, ttl 64, id 46222, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979695626:1979696162(536) ack 2260258133 win 5840
10:05:24.326749 IP (tos 0x0, ttl 64, id 46223, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979696162:1979696698(536) ack 2260258133 win 5840
10:05:24.326751 IP (tos 0x0, ttl 64, id 19970, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x6819 (correct), 2260258133:2260258133(0) ack 1979694018 win 65535
10:05:24.326753 IP (tos 0x0, ttl 64, id 46224, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979696698:1979697234(536) ack 2260258133 win 5840
10:05:24.326756 IP (tos 0x0, ttl 64, id 46225, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979697234:1979697770(536) ack 2260258133 win 5840
10:05:24.326757 IP (tos 0x0, ttl 64, id 19971, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x6601 (correct), 2260258133:2260258133(0) ack 1979694554 win 65535
10:05:24.326760 IP (tos 0x0, ttl 64, id 46226, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979697770:1979698306(536) ack 2260258133 win 5840
10:05:24.326763 IP (tos 0x0, ttl 64, id 19972, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x63e9 (correct), 2260258133:2260258133(0) ack 1979695090 win 65535
10:05:24.326764 IP (tos 0x0, ttl 64, id 46227, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979698306:1979698842(536) ack 2260258133 win 5840
10:05:24.326767 IP (tos 0x0, ttl 64, id 46228, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979698842:1979699378(536) ack 2260258133 win 5840
10:05:24.326768 IP (tos 0x0, ttl 64, id 19973, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x61d1 (correct), 2260258133:2260258133(0) ack 1979695626 win 65535
10:05:24.326771 IP (tos 0x0, ttl 64, id 46229, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979699378:1979699914(536) ack 2260258133 win 5840
10:05:24.326772 IP (tos 0x0, ttl 64, id 19974, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5fb9 (correct), 2260258133:2260258133(0) ack 1979696162 win 65535
10:05:24.326775 IP (tos 0x0, ttl 64, id 46230, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979699914:1979700450(536) ack 2260258133 win 5840
10:05:24.326778 IP (tos 0x0, ttl 64, id 19975, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5da1 (correct), 2260258133:2260258133(0) ack 1979696698 win 65535
10:05:24.326780 IP (tos 0x0, ttl 64, id 46231, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979700450:1979700986(536) ack 2260258133 win 5840
10:05:24.326783 IP (tos 0x0, ttl 64, id 19976, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5b89 (correct), 2260258133:2260258133(0) ack 1979697234 win 65535
10:05:24.326783 IP (tos 0x0, ttl 64, id 46232, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979700986:1979701522(536) ack 2260258133 win 5840
10:05:24.326787 IP (tos 0x0, ttl 64, id 46233, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979701522:1979702058(536) ack 2260258133 win 5840
10:05:24.326789 IP (tos 0x0, ttl 64, id 19977, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5971 (correct), 2260258133:2260258133(0) ack 1979697770 win 65535
10:05:24.326791 IP (tos 0x0, ttl 64, id 46234, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979702058:1979702594(536) ack 2260258133 win 5840
10:05:24.326793 IP (tos 0x0, ttl 64, id 19978, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5759 (correct), 2260258133:2260258133(0) ack 1979698306 win 65535
10:05:24.326795 IP (tos 0x0, ttl 64, id 46235, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979702594:1979703130(536) ack 2260258133 win 5840
10:05:24.326798 IP (tos 0x0, ttl 64, id 19979, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5541 (correct), 2260258133:2260258133(0) ack 1979698842 win 65535
10:05:24.326798 IP (tos 0x0, ttl 64, id 46236, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979703130:1979703666(536) ack 2260258133 win 5840
10:05:24.326802 IP (tos 0x0, ttl 64, id 46237, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979703666:1979704202(536) ack 2260258133 win 5840
10:05:24.326803 IP (tos 0x0, ttl 64, id 19980, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5329 (correct), 2260258133:2260258133(0) ack 1979699378 win 65535
10:05:24.326805 IP (tos 0x0, ttl 64, id 46238, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979704202:1979704738(536) ack 2260258133 win 5840
10:05:24.326808 IP (tos 0x0, ttl 64, id 19981, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5111 (correct), 2260258133:2260258133(0) ack 1979699914 win 65535
10:05:24.326810 IP (tos 0x0, ttl 64, id 46239, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979704738:1979705274(536) ack 2260258133 win 5840
10:05:24.326813 IP (tos 0x0, ttl 64, id 19982, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4ef9 (correct), 2260258133:2260258133(0) ack 1979700450 win 65535
10:05:24.326815 IP (tos 0x0, ttl 64, id 46240, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979705274:1979705810(536) ack 2260258133 win 5840
10:05:24.326818 IP (tos 0x0, ttl 64, id 19983, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4ce1 (correct), 2260258133:2260258133(0) ack 1979700986 win 65535
10:05:24.326817 IP (tos 0x0, ttl 64, id 46241, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979705810:1979706346(536) ack 2260258133 win 5840
10:05:24.326822 IP (tos 0x0, ttl 64, id 46242, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979706346:1979706882(536) ack 2260258133 win 5840
10:05:24.326823 IP (tos 0x0, ttl 64, id 19984, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4ac9 (correct), 2260258133:2260258133(0) ack 1979701522 win 65535
10:05:24.326826 IP (tos 0x0, ttl 64, id 46243, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979706882:1979707418(536) ack 2260258133 win 5840
10:05:24.326828 IP (tos 0x0, ttl 64, id 19985, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x48b1 (correct), 2260258133:2260258133(0) ack 1979702058 win 65535
10:05:24.326831 IP (tos 0x0, ttl 64, id 46244, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979707418:1979707954(536) ack 2260258133 win 5840
10:05:24.326833 IP (tos 0x0, ttl 64, id 19986, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4699 (correct), 2260258133:2260258133(0) ack 1979702594 win 65535
10:05:24.326836 IP (tos 0x0, ttl 64, id 46245, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979707954:1979708490(536) ack 2260258133 win 5840
10:05:24.326838 IP (tos 0x0, ttl 64, id 19987, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4481 (correct), 2260258133:2260258133(0) ack 1979703130 win 65535
10:05:24.326842 IP (tos 0x0, ttl 64, id 46246, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979708490:1979709026(536) ack 2260258133 win 5840
10:05:24.326844 IP (tos 0x0, ttl 64, id 19988, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4269 (correct), 2260258133:2260258133(0) ack 1979703666 win 65535
10:05:24.326847 IP (tos 0x0, ttl 64, id 46247, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979709026:1979709562(536) ack 2260258133 win 5840
10:05:24.326851 IP (tos 0x0, ttl 64, id 46248, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: P 1979709562:1979710098(536) ack 2260258133 win 5840
10:05:24.326852 IP (tos 0x0, ttl 64, id 19989, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3e39 (correct), 2260258133:2260258133(0) ack 1979704738 win 65535
10:05:24.326853 IP (tos 0x0, ttl 64, id 46249, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979710098:1979710634(536) ack 2260258133 win 5840
10:05:24.326856 IP (tos 0x0, ttl 64, id 46250, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979710634:1979711170(536) ack 2260258133 win 5840
10:05:24.326858 IP (tos 0x0, ttl 64, id 19990, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3a09 (correct), 2260258133:2260258133(0) ack 1979705810 win 65535
10:05:24.326860 IP (tos 0x0, ttl 64, id 46251, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979711170:1979711706(536) ack 2260258133 win 5840
10:05:24.326864 IP (tos 0x0, ttl 64, id 19991, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x35d9 (correct), 2260258133:2260258133(0) ack 1979706882 win 65535
10:05:24.326865 IP (tos 0x0, ttl 64, id 46252, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979711706:1979712242(536) ack 2260258133 win 5840
10:05:24.326868 IP (tos 0x0, ttl 64, id 46253, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979712242:1979712778(536) ack 2260258133 win 5840
10:05:24.326871 IP (tos 0x0, ttl 64, id 19992, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x31a9 (correct), 2260258133:2260258133(0) ack 1979707954 win 65535
10:05:24.326872 IP (tos 0x0, ttl 64, id 46254, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979712778:1979713314(536) ack 2260258133 win 5840
10:05:24.326875 IP (tos 0x0, ttl 64, id 46255, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979713314:1979713850(536) ack 2260258133 win 5840
10:05:24.326877 IP (tos 0x0, ttl 64, id 19993, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x2d79 (correct), 2260258133:2260258133(0) ack 1979709026 win 65535
10:05:24.326880 IP (tos 0x0, ttl 64, id 46256, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979713850:1979714386(536) ack 2260258133 win 5840
10:05:24.326884 IP (tos 0x0, ttl 64, id 19994, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x2949 (correct), 2260258133:2260258133(0) ack 1979710098 win 65535
10:05:24.326885 IP (tos 0x0, ttl 64, id 46257, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979714386:1979714922(536) ack 2260258133 win 5840
10:05:24.326887 IP (tos 0x0, ttl 64, id 46258, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979714922:1979715458(536) ack 2260258133 win 5840
10:05:24.326890 IP (tos 0x0, ttl 64, id 19995, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x2519 (correct), 2260258133:2260258133(0) ack 1979711170 win 65535
10:05:24.326891 IP (tos 0x0, ttl 64, id 46259, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979715458:1979715994(536) ack 2260258133 win 5840
10:05:24.326894 IP (tos 0x0, ttl 64, id 46260, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979715994:1979716530(536) ack 2260258133 win 5840
10:05:24.326896 IP (tos 0x0, ttl 64, id 19996, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x20e9 (correct), 2260258133:2260258133(0) ack 1979712242 win 65535
10:05:24.326898 IP (tos 0x0, ttl 64, id 46261, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979716530:1979717066(536) ack 2260258133 win 5840
10:05:24.326903 IP (tos 0x0, ttl 64, id 19997, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1cb9 (correct), 2260258133:2260258133(0) ack 1979713314 win 65535
10:05:24.326909 IP (tos 0x0, ttl 64, id 19998, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1889 (correct), 2260258133:2260258133(0) ack 1979714386 win 65535
10:05:24.326914 IP (tos 0x0, ttl 64, id 19999, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1459 (correct), 2260258133:2260258133(0) ack 1979715458 win 65535
10:05:24.326919 IP (tos 0x0, ttl 64, id 20000, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1029 (correct), 2260258133:2260258133(0) ack 1979716530 win 65535
10:05:24.326921 IP (tos 0x0, ttl 64, id 46262, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979717066:1979717602(536) ack 2260258133 win 5840
10:05:24.326929 IP (tos 0x0, ttl 64, id 20001, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0bf9 (correct), 2260258133:2260258133(0) ack 1979717602 win 65535
10:05:24.326931 IP (tos 0x0, ttl 64, id 46263, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979717602:1979718138(536) ack 2260258133 win 5840
10:05:24.326933 IP (tos 0x0, ttl 64, id 46264, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979718138:1979718674(536) ack 2260258133 win 5840
10:05:24.326938 IP (tos 0x0, ttl 64, id 20002, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x07c9 (correct), 2260258133:2260258133(0) ack 1979718674 win 65535
10:05:24.326939 IP (tos 0x0, ttl 64, id 46265, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979718674:1979719210(536) ack 2260258133 win 5840
10:05:24.326941 IP (tos 0x0, ttl 64, id 46266, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979719210:1979719746(536) ack 2260258133 win 5840
10:05:24.326945 IP (tos 0x0, ttl 64, id 20003, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0399 (correct), 2260258133:2260258133(0) ack 1979719746 win 65535
10:05:24.326946 IP (tos 0x0, ttl 64, id 46267, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979719746:1979720282(536) ack 2260258133 win 5840
10:05:24.326948 IP (tos 0x0, ttl 64, id 46268, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979720282:1979720818(536) ack 2260258133 win 5840
10:05:24.326953 IP (tos 0x0, ttl 64, id 20004, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xff68 (correct), 2260258133:2260258133(0) ack 1979720818 win 65535
10:05:24.326954 IP (tos 0x0, ttl 64, id 46269, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979720818:1979721354(536) ack 2260258133 win 5840
10:05:24.326956 IP (tos 0x0, ttl 64, id 46270, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979721354:1979721890(536) ack 2260258133 win 5840
10:05:24.326960 IP (tos 0x0, ttl 64, id 20005, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xfb38 (correct), 2260258133:2260258133(0) ack 1979721890 win 65535
10:05:24.326961 IP (tos 0x0, ttl 64, id 46271, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979721890:1979722426(536) ack 2260258133 win 5840
10:05:24.326990 IP (tos 0x0, ttl 64, id 46272, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979722426:1979722962(536) ack 2260258133 win 5840
10:05:24.326993 IP (tos 0x0, ttl 64, id 20006, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf708 (correct), 2260258133:2260258133(0) ack 1979722962 win 65535
10:05:24.327035 IP (tos 0x0, ttl 64, id 46281, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979727250:1979727786(536) ack 2260258133 win 5840
10:05:24.327076 IP (tos 0x0, ttl 64, id 46286, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979729930:1979730466(536) ack 2260258133 win 5840
10:05:24.327091 IP (tos 0x0, ttl 64, id 46288, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979731002:1979731538(536) ack 2260258133 win 5840
10:05:24.327151 IP (tos 0x0, ttl 64, id 46296, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979735290:1979735826(536) ack 2260258133 win 5840
10:05:24.327229 IP (tos 0x0, ttl 64, id 46306, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979740650:1979741186(536) ack 2260258133 win 5840
10:05:24.327306 IP (tos 0x0, ttl 64, id 20028, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x9ae8 (correct), 2260258133:2260258133(0) ack 1979746546 win 65535
10:05:24.327337 IP (tos 0x0, ttl 64, id 46320, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979748154:1979748690(536) ack 2260258133 win 5840
10:05:24.327362 IP (tos 0x0, ttl 64, id 20032, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8a28 (correct), 2260258133:2260258133(0) ack 1979750834 win 65535
10:05:24.327375 IP (tos 0x0, ttl 64, id 20033, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x85f8 (correct), 2260258133:2260258133(0) ack 1979751906 win 65535
10:05:24.327386 IP (tos 0x0, ttl 64, id 20034, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x81c8 (correct), 2260258133:2260258133(0) ack 1979752978 win 65535
10:05:24.327410 IP (tos 0x0, ttl 64, id 20035, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x7d98 (correct), 2260258133:2260258133(0) ack 1979754050 win 65535
10:05:24.327436 IP (tos 0x0, ttl 64, id 20037, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x7538 (correct), 2260258133:2260258133(0) ack 1979756194 win 65535
10:05:24.327473 IP (tos 0x0, ttl 64, id 46339, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979758338:1979758874(536) ack 2260258133 win 5840
10:05:24.327497 IP (tos 0x0, ttl 64, id 20041, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x6478 (correct), 2260258133:2260258133(0) ack 1979760482 win 65535
10:05:24.327517 IP (tos 0x0, ttl 64, id 20042, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x6048 (correct), 2260258133:2260258133(0) ack 1979761554 win 65535
10:05:24.327528 IP (tos 0x0, ttl 64, id 20043, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x5c18 (correct), 2260258133:2260258133(0) ack 1979762626 win 65535
10:05:24.327539 IP (tos 0x0, ttl 64, id 20044, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x57e8 (correct), 2260258133:2260258133(0) ack 1979763698 win 65535
10:05:24.327556 IP (tos 0x0, ttl 64, id 20045, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x53b8 (correct), 2260258133:2260258133(0) ack 1979764770 win 65535
10:05:24.327606 IP (tos 0x0, ttl 64, id 46357, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979767986:1979768522(536) ack 2260258133 win 5840
10:05:24.327649 IP (tos 0x0, ttl 64, id 20051, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3a98 (correct), 2260258133:2260258133(0) ack 1979771202 win 65535
10:05:24.327694 IP (tos 0x0, ttl 64, id 46369, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979774418:1979774954(536) ack 2260258133 win 5840
10:05:24.327754 IP (tos 0x0, ttl 64, id 20058, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1d48 (correct), 2260258133:2260258133(0) ack 1979778706 win 65535
10:05:24.327765 IP (tos 0x0, ttl 64, id 20059, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1918 (correct), 2260258133:2260258133(0) ack 1979779778 win 65535
10:05:24.327780 IP (tos 0x0, ttl 64, id 20060, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x14e8 (correct), 2260258133:2260258133(0) ack 1979780850 win 65535
10:05:24.327794 IP (tos 0x0, ttl 64, id 20061, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x10b8 (correct), 2260258133:2260258133(0) ack 1979781922 win 65535
10:05:24.327816 IP (tos 0x0, ttl 64, id 20062, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0c88 (correct), 2260258133:2260258133(0) ack 1979782994 win 65535
10:05:24.327842 IP (tos 0x0, ttl 64, id 20064, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0428 (correct), 2260258133:2260258133(0) ack 1979785138 win 65535
10:05:24.327863 IP (tos 0x0, ttl 64, id 20065, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xfff7 (correct), 2260258133:2260258133(0) ack 1979786210 win 65535
10:05:24.327874 IP (tos 0x0, ttl 64, id 20066, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xfbc7 (correct), 2260258133:2260258133(0) ack 1979787282 win 65535
10:05:24.327890 IP (tos 0x0, ttl 64, id 20067, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf797 (correct), 2260258133:2260258133(0) ack 1979788354 win 65535
10:05:24.327914 IP (tos 0x0, ttl 64, id 20068, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf367 (correct), 2260258133:2260258133(0) ack 1979789426 win 65535
10:05:24.327921 IP (tos 0x0, ttl 64, id 20069, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xef37 (correct), 2260258133:2260258133(0) ack 1979790498 win 65535
10:05:24.327934 IP (tos 0x0, ttl 64, id 20070, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xeb07 (correct), 2260258133:2260258133(0) ack 1979791570 win 65535
10:05:24.327947 IP (tos 0x0, ttl 64, id 20071, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe6d7 (correct), 2260258133:2260258133(0) ack 1979792642 win 65535
10:05:24.327972 IP (tos 0x0, ttl 64, id 20072, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe2a7 (correct), 2260258133:2260258133(0) ack 1979793714 win 65535
10:05:24.328005 IP (tos 0x0, ttl 64, id 46410, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979796394:1979796930(536) ack 2260258133 win 5840
10:05:24.328039 IP (tos 0x0, ttl 64, id 20077, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xcdb7 (correct), 2260258133:2260258133(0) ack 1979799074 win 65535
10:05:24.328086 IP (tos 0x0, ttl 64, id 46422, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979802826:1979803362(536) ack 2260258133 win 5840
10:05:24.328122 IP (tos 0x0, ttl 64, id 20083, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xb497 (correct), 2260258133:2260258133(0) ack 1979805506 win 65535
10:05:24.328135 IP (tos 0x0, ttl 64, id 20084, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xb067 (correct), 2260258133:2260258133(0) ack 1979806578 win 65535
10:05:24.328151 IP (tos 0x0, ttl 64, id 20085, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xac37 (correct), 2260258133:2260258133(0) ack 1979807650 win 65535
10:05:24.328164 IP (tos 0x0, ttl 64, id 20086, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xa807 (correct), 2260258133:2260258133(0) ack 1979808722 win 65535
10:05:24.328185 IP (tos 0x0, ttl 64, id 46434, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979809258:1979809794(536) ack 2260258133 win 5840
10:05:24.328197 IP (tos 0x0, ttl 64, id 20087, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xa3d7 (correct), 2260258133:2260258133(0) ack 1979809794 win 65535
10:05:24.328204 IP (tos 0x0, ttl 64, id 20088, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x9fa7 (correct), 2260258133:2260258133(0) ack 1979810866 win 65535
10:05:24.328248 IP (tos 0x0, ttl 64, id 46444, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979814618:1979815154(536) ack 2260258133 win 5840
10:05:24.328293 IP (tos 0x0, ttl 64, id 20094, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8687 (correct), 2260258133:2260258133(0) ack 1979817298 win 65535
10:05:24.328352 IP (tos 0x0, ttl 64, id 46458, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979822122:1979822658(536) ack 2260258133 win 5840
10:05:24.328396 IP (tos 0x0, ttl 64, id 46464, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979825338:1979825874(536) ack 2260258133 win 5840
10:05:24.328426 IP (tos 0x0, ttl 64, id 20103, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x60d7 (correct), 2260258133:2260258133(0) ack 1979826946 win 65535
10:05:24.328459 IP (tos 0x0, ttl 64, id 46472, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979829626:1979830162(536) ack 2260258133 win 5840
10:05:24.328524 IP (tos 0x0, ttl 64, id 20110, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4387 (correct), 2260258133:2260258133(0) ack 1979834450 win 65535
10:05:24.328535 IP (tos 0x0, ttl 64, id 46482, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979834986:1979835522(536) ack 2260258133 win 5840
10:05:24.328569 IP (tos 0x0, ttl 64, id 20113, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x36f7 (correct), 2260258133:2260258133(0) ack 1979837666 win 65535
10:05:24.328626 IP (tos 0x0, ttl 64, id 46494, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979841418:1979841954(536) ack 2260258133 win 5840
10:05:24.328684 IP (tos 0x0, ttl 64, id 20121, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1577 (correct), 2260258133:2260258133(0) ack 1979846242 win 65535
10:05:24.328710 IP (tos 0x0, ttl 64, id 46506, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979847850:1979848386(536) ack 2260258133 win 5840
10:05:24.328743 IP (tos 0x0, ttl 64, id 46510, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979849994:1979850530(536) ack 2260258133 win 5840
10:05:24.328755 IP (tos 0x0, ttl 64, id 20125, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x04b7 (correct), 2260258133:2260258133(0) ack 1979850530 win 65535
10:05:24.328836 IP (tos 0x0, ttl 64, id 46523, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979856962:1979857498(536) ack 2260258133 win 5840
10:05:24.328862 IP (tos 0x0, ttl 64, id 20133, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe336 (correct), 2260258133:2260258133(0) ack 1979859106 win 65535
10:05:24.328978 IP (tos 0x0, ttl 64, id 46541, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1979866610:1979867146(536) ack 2260258133 win 5840
10:05:24.329135 IP (tos 0x0, ttl 64, id 20168, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x99ee (correct), 2260258133:2260258133(0) ack 1979877866 win 65535
10:05:24.331208 IP (tos 0x0, ttl 64, id 46844, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980029018:1980029554(536) ack 2260258133 win 5840
10:05:24.331216 IP (tos 0x0, ttl 64, id 46845, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980029554:1980030090(536) ack 2260258133 win 5840
10:05:24.331218 IP (tos 0x0, ttl 64, id 46846, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980030090:1980030626(536) ack 2260258133 win 5840
10:05:24.331220 IP (tos 0x0, ttl 64, id 46847, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980030626:1980031162(536) ack 2260258133 win 5840
10:05:24.331222 IP (tos 0x0, ttl 64, id 46848, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980031162:1980031698(536) ack 2260258133 win 5840
10:05:24.331221 IP (tos 0x0, ttl 64, id 20422, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4964 (correct), 2260258133:2260258133(0) ack 1980029554 win 65535
10:05:24.331223 IP (tos 0x0, ttl 64, id 46849, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980031698:1980032234(536) ack 2260258133 win 5840
10:05:24.331225 IP (tos 0x0, ttl 64, id 46850, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980032234:1980032770(536) ack 2260258133 win 5840
10:05:24.331229 IP (tos 0x0, ttl 64, id 20423, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4534 (correct), 2260258133:2260258133(0) ack 1980030626 win 65535
10:05:24.331229 IP (tos 0x0, ttl 64, id 46851, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980032770:1980033306(536) ack 2260258133 win 5840
10:05:24.331232 IP (tos 0x0, ttl 64, id 46852, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980033306:1980033842(536) ack 2260258133 win 5840
10:05:24.331236 IP (tos 0x0, ttl 64, id 46853, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980033842:1980034378(536) ack 2260258133 win 5840
10:05:24.331236 IP (tos 0x0, ttl 64, id 20424, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x4104 (correct), 2260258133:2260258133(0) ack 1980031698 win 65535
10:05:24.331238 IP (tos 0x0, ttl 64, id 46854, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980034378:1980034914(536) ack 2260258133 win 5840
10:05:24.331240 IP (tos 0x0, ttl 64, id 46855, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980034914:1980035450(536) ack 2260258133 win 5840
10:05:24.331242 IP (tos 0x0, ttl 64, id 20425, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3cd4 (correct), 2260258133:2260258133(0) ack 1980032770 win 65535
10:05:24.331244 IP (tos 0x0, ttl 64, id 46856, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980035450:1980035986(536) ack 2260258133 win 5840
10:05:24.331248 IP (tos 0x0, ttl 64, id 20426, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x38a4 (correct), 2260258133:2260258133(0) ack 1980033842 win 65535
10:05:24.331249 IP (tos 0x0, ttl 64, id 46857, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980035986:1980036522(536) ack 2260258133 win 5840
10:05:24.331251 IP (tos 0x0, ttl 64, id 46858, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: P 1980036522:1980037058(536) ack 2260258133 win 5840
10:05:24.331254 IP (tos 0x0, ttl 64, id 20427, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3474 (correct), 2260258133:2260258133(0) ack 1980034914 win 65535
10:05:24.331255 IP (tos 0x0, ttl 64, id 46859, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980037058:1980037594(536) ack 2260258133 win 5840
10:05:24.331258 IP (tos 0x0, ttl 64, id 46860, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980037594:1980038130(536) ack 2260258133 win 5840
10:05:24.331262 IP (tos 0x0, ttl 64, id 46861, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980038130:1980038666(536) ack 2260258133 win 5840
10:05:24.331262 IP (tos 0x0, ttl 64, id 20428, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x3044 (correct), 2260258133:2260258133(0) ack 1980035986 win 65535
10:05:24.331264 IP (tos 0x0, ttl 64, id 46862, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980038666:1980039202(536) ack 2260258133 win 5840
10:05:24.331266 IP (tos 0x0, ttl 64, id 46863, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980039202:1980039738(536) ack 2260258133 win 5840
10:05:24.331268 IP (tos 0x0, ttl 64, id 20429, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x2c14 (correct), 2260258133:2260258133(0) ack 1980037058 win 65535
10:05:24.331270 IP (tos 0x0, ttl 64, id 46864, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980039738:1980040274(536) ack 2260258133 win 5840
10:05:24.331275 IP (tos 0x0, ttl 64, id 46865, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980040274:1980040810(536) ack 2260258133 win 5840
10:05:24.331274 IP (tos 0x0, ttl 64, id 20430, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x27e4 (correct), 2260258133:2260258133(0) ack 1980038130 win 65535
10:05:24.331277 IP (tos 0x0, ttl 64, id 46866, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980040810:1980041346(536) ack 2260258133 win 5840
10:05:24.331281 IP (tos 0x0, ttl 64, id 20431, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x23b4 (correct), 2260258133:2260258133(0) ack 1980039202 win 65535
10:05:24.331282 IP (tos 0x0, ttl 64, id 46867, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980041346:1980041882(536) ack 2260258133 win 5840
10:05:24.331284 IP (tos 0x0, ttl 64, id 46868, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980041882:1980042418(536) ack 2260258133 win 5840
10:05:24.331288 IP (tos 0x0, ttl 64, id 46869, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980042418:1980042954(536) ack 2260258133 win 5840
10:05:24.331288 IP (tos 0x0, ttl 64, id 20432, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1f84 (correct), 2260258133:2260258133(0) ack 1980040274 win 65535
10:05:24.331290 IP (tos 0x0, ttl 64, id 46870, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980042954:1980043490(536) ack 2260258133 win 5840
10:05:24.331295 IP (tos 0x0, ttl 64, id 46871, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980043490:1980044026(536) ack 2260258133 win 5840
10:05:24.331294 IP (tos 0x0, ttl 64, id 20433, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1b54 (correct), 2260258133:2260258133(0) ack 1980041346 win 65535
10:05:24.331297 IP (tos 0x0, ttl 64, id 46872, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980044026:1980044562(536) ack 2260258133 win 5840
10:05:24.331301 IP (tos 0x0, ttl 64, id 46873, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980044562:1980045098(536) ack 2260258133 win 5840
10:05:24.331301 IP (tos 0x0, ttl 64, id 20434, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x1724 (correct), 2260258133:2260258133(0) ack 1980042418 win 65535
10:05:24.331303 IP (tos 0x0, ttl 64, id 46874, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980045098:1980045634(536) ack 2260258133 win 5840
10:05:24.331308 IP (tos 0x0, ttl 64, id 20435, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x12f4 (correct), 2260258133:2260258133(0) ack 1980043490 win 65535
10:05:24.331305 IP (tos 0x0, ttl 64, id 46875, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980045634:1980046170(536) ack 2260258133 win 5840
10:05:24.331311 IP (tos 0x0, ttl 64, id 46876, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980046170:1980046706(536) ack 2260258133 win 5840
10:05:24.331314 IP (tos 0x0, ttl 64, id 20436, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0ec4 (correct), 2260258133:2260258133(0) ack 1980044562 win 65535
10:05:24.331315 IP (tos 0x0, ttl 64, id 46877, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980046706:1980047242(536) ack 2260258133 win 5840
10:05:24.331317 IP (tos 0x0, ttl 64, id 46878, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980047242:1980047778(536) ack 2260258133 win 5840
10:05:24.331319 IP (tos 0x0, ttl 64, id 46879, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980047778:1980048314(536) ack 2260258133 win 5840
10:05:24.331320 IP (tos 0x0, ttl 64, id 20437, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0a94 (correct), 2260258133:2260258133(0) ack 1980045634 win 65535
10:05:24.331323 IP (tos 0x0, ttl 64, id 46880, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980048314:1980048850(536) ack 2260258133 win 5840
10:05:24.331326 IP (tos 0x0, ttl 64, id 20438, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0664 (correct), 2260258133:2260258133(0) ack 1980046706 win 65535
10:05:24.331327 IP (tos 0x0, ttl 64, id 46881, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980048850:1980049386(536) ack 2260258133 win 5840
10:05:24.331330 IP (tos 0x0, ttl 64, id 46882, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980049386:1980049922(536) ack 2260258133 win 5840
10:05:24.331333 IP (tos 0x0, ttl 64, id 20439, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x0234 (correct), 2260258133:2260258133(0) ack 1980047778 win 65535
10:05:24.331334 IP (tos 0x0, ttl 64, id 46883, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980049922:1980050458(536) ack 2260258133 win 5840
10:05:24.331339 IP (tos 0x0, ttl 64, id 46884, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980050458:1980050994(536) ack 2260258133 win 5840
10:05:24.331340 IP (tos 0x0, ttl 64, id 20440, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xfe03 (correct), 2260258133:2260258133(0) ack 1980048850 win 65535
10:05:24.331341 IP (tos 0x0, ttl 64, id 46885, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980050994:1980051530(536) ack 2260258133 win 5840
10:05:24.331344 IP (tos 0x0, ttl 64, id 46886, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980051530:1980052066(536) ack 2260258133 win 5840
10:05:24.331346 IP (tos 0x0, ttl 64, id 20441, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf9d3 (correct), 2260258133:2260258133(0) ack 1980049922 win 65535
10:05:24.331348 IP (tos 0x0, ttl 64, id 46887, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980052066:1980052602(536) ack 2260258133 win 5840
10:05:24.331352 IP (tos 0x0, ttl 64, id 20442, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf5a3 (correct), 2260258133:2260258133(0) ack 1980050994 win 65535
10:05:24.331353 IP (tos 0x0, ttl 64, id 46888, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980052602:1980053138(536) ack 2260258133 win 5840
10:05:24.331355 IP (tos 0x0, ttl 64, id 46889, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980053138:1980053674(536) ack 2260258133 win 5840
10:05:24.331359 IP (tos 0x0, ttl 64, id 20443, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xf173 (correct), 2260258133:2260258133(0) ack 1980052066 win 65535
10:05:24.331359 IP (tos 0x0, ttl 64, id 46890, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980053674:1980054210(536) ack 2260258133 win 5840
10:05:24.331361 IP (tos 0x0, ttl 64, id 46891, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980054210:1980054746(536) ack 2260258133 win 5840
10:05:24.331365 IP (tos 0x0, ttl 64, id 20444, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xed43 (correct), 2260258133:2260258133(0) ack 1980053138 win 65535
10:05:24.331366 IP (tos 0x0, ttl 64, id 46892, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980054746:1980055282(536) ack 2260258133 win 5840
10:05:24.331368 IP (tos 0x0, ttl 64, id 46893, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980055282:1980055818(536) ack 2260258133 win 5840
10:05:24.331372 IP (tos 0x0, ttl 64, id 20445, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe913 (correct), 2260258133:2260258133(0) ack 1980054210 win 65535
10:05:24.331372 IP (tos 0x0, ttl 64, id 46894, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980055818:1980056354(536) ack 2260258133 win 5840
10:05:24.331375 IP (tos 0x0, ttl 64, id 46895, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980056354:1980056890(536) ack 2260258133 win 5840
10:05:24.331379 IP (tos 0x0, ttl 64, id 46896, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980056890:1980057426(536) ack 2260258133 win 5840
10:05:24.331379 IP (tos 0x0, ttl 64, id 20446, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe4e3 (correct), 2260258133:2260258133(0) ack 1980055282 win 65535
10:05:24.331381 IP (tos 0x0, ttl 64, id 46897, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980057426:1980057962(536) ack 2260258133 win 5840
10:05:24.331385 IP (tos 0x0, ttl 64, id 20447, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xe0b3 (correct), 2260258133:2260258133(0) ack 1980056354 win 65535
10:05:24.331386 IP (tos 0x0, ttl 64, id 46898, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980057962:1980058498(536) ack 2260258133 win 5840
10:05:24.331388 IP (tos 0x0, ttl 64, id 46899, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980058498:1980059034(536) ack 2260258133 win 5840
10:05:24.331390 IP (tos 0x0, ttl 64, id 46900, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980059034:1980059570(536) ack 2260258133 win 5840
10:05:24.331392 IP (tos 0x0, ttl 64, id 20448, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xdc83 (correct), 2260258133:2260258133(0) ack 1980057426 win 65535
10:05:24.331394 IP (tos 0x0, ttl 64, id 46901, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980059570:1980060106(536) ack 2260258133 win 5840
10:05:24.331399 IP (tos 0x0, ttl 64, id 20449, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xd853 (correct), 2260258133:2260258133(0) ack 1980058498 win 65535
10:05:24.331405 IP (tos 0x0, ttl 64, id 20450, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xd423 (correct), 2260258133:2260258133(0) ack 1980059570 win 65535
10:05:24.331411 IP (tos 0x0, ttl 64, id 20451, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xcff3 (correct), 2260258133:2260258133(0) ack 1980060642 win 65535
10:05:24.331524 IP (tos 0x0, ttl 64, id 20460, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xaa43 (correct), 2260258133:2260258133(0) ack 1980070290 win 65535
10:05:24.331531 IP (tos 0x0, ttl 64, id 20461, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xa613 (correct), 2260258133:2260258133(0) ack 1980071362 win 65535
10:05:24.331537 IP (tos 0x0, ttl 64, id 20462, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0xa1e3 (correct), 2260258133:2260258133(0) ack 1980072434 win 65535
10:05:24.331548 IP (tos 0x0, ttl 64, id 20463, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x9db3 (correct), 2260258133:2260258133(0) ack 1980073506 win 65535
10:05:24.331574 IP (tos 0x0, ttl 64, id 46929, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980074578:1980075114(536) ack 2260258133 win 5840
10:05:24.331586 IP (tos 0x0, ttl 64, id 46931, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980075650:1980076186(536) ack 2260258133 win 5840
10:05:24.331639 IP (tos 0x0, ttl 64, id 20469, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8493 (correct), 2260258133:2260258133(0) ack 1980079938 win 65535
10:05:24.331647 IP (tos 0x0, ttl 64, id 46939, offset 0, flags [DF], proto TCP (6), length 576) dione.40344 > phoenix.distcc: . 1980079938:1980080474(536) ack 2260258133 win 5840
10:05:24.331657 IP (tos 0x0, ttl 64, id 20470, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x8063 (correct), 2260258133:2260258133(0) ack 1980081010 win 65535
10:05:24.331678 IP (tos 0x0, ttl 64, id 20471, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x7c33 (correct), 2260258133:2260258133(0) ack 1980082082 win 65535
10:05:24.331688 IP (tos 0x0, ttl 64, id 20472, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: ., cksum 0x7803 (correct), 2260258133:2260258133(0) ack 1980083154 win 65535
10:05:24.732609 IP (tos 0x0, ttl 64, id 20476, offset 0, flags [DF], proto TCP (6), length 2960) phoenix.distcc > dione.40344: . 2260258133:2260261053(2920) ack 1980086145 win 65535
10:05:24.732740 IP (tos 0x0, ttl 64, id 46951, offset 0, flags [DF], proto TCP (6), length 40) dione.40344 > phoenix.distcc: ., cksum 0x4468 (correct), 1980086145:1980086145(0) ack 2260259593 win 8760
10:05:24.732753 IP (tos 0x0, ttl 64, id 20478, offset 0, flags [DF], proto TCP (6), length 2960) phoenix.distcc > dione.40344: . 2260261053:2260263973(2920) ack 1980086145 win 65535
10:05:24.732756 IP (tos 0x0, ttl 64, id 46952, offset 0, flags [DF], proto TCP (6), length 40) dione.40344 > phoenix.distcc: ., cksum 0x334c (correct), 1980086145:1980086145(0) ack 2260261053 win 11680
10:05:24.732761 IP (tos 0x0, ttl 64, id 20480, offset 0, flags [DF], proto TCP (6), length 2960) phoenix.distcc > dione.40344: . 2260263973:2260266893(2920) ack 1980086145 win 65535
10:05:24.732835 IP (tos 0x0, ttl 64, id 46953, offset 0, flags [DF], proto TCP (6), length 40) dione.40344 > phoenix.distcc: ., cksum 0x2230 (correct), 1980086145:1980086145(0) ack 2260262513 win 14600
10:05:24.732841 IP (tos 0x0, ttl 64, id 20482, offset 0, flags [DF], proto TCP (6), length 2960) phoenix.distcc > dione.40344: P 2260266893:2260269813(2920) ack 1980086145 win 65535
10:05:24.732843 IP (tos 0x0, ttl 64, id 46954, offset 0, flags [DF], proto TCP (6), length 40) dione.40344 > phoenix.distcc: ., cksum 0x1114 (correct), 1980086145:1980086145(0) ack 2260263973 win 17520
10:05:24.732848 IP (tos 0x0, ttl 64, id 20484, offset 0, flags [DF], proto TCP (6), length 924) phoenix.distcc > dione.40344: P 2260269813:2260270697(884) ack 1980086145 win 65535
10:05:24.732885 IP (tos 0x0, ttl 64, id 46955, offset 0, flags [DF], proto TCP (6), length 40) dione.40344 > phoenix.distcc: ., cksum 0xfff7 (correct), 1980086145:1980086145(0) ack 2260265433 win 20440
10:05:24.732889 IP (tos 0x0, ttl 64, id 46956, offset 0, flags [DF], proto TCP (6), length 40) dione.40344 > phoenix.distcc: ., cksum 0xeedb (correct), 1980086145:1980086145(0) ack 2260266893 win 23360
10:05:24.732933 IP (tos 0x0, ttl 64, id 46957, offset 0, flags [DF], proto TCP (6), length 40) dione.40344 > phoenix.distcc: ., cksum 0xddbf (correct), 1980086145:1980086145(0) ack 2260268353 win 26280
10:05:24.732937 IP (tos 0x0, ttl 64, id 46958, offset 0, flags [DF], proto TCP (6), length 40) dione.40344 > phoenix.distcc: ., cksum 0xcca3 (correct), 1980086145:1980086145(0) ack 2260269813 win 29200
10:05:24.732952 IP (tos 0x0, ttl 64, id 46959, offset 0, flags [DF], proto TCP (6), length 40) dione.40344 > phoenix.distcc: ., cksum 0xbdc7 (correct), 1980086145:1980086145(0) ack 2260270697 win 32120
10:05:24.732996 IP (tos 0x0, ttl 64, id 46960, offset 0, flags [DF], proto TCP (6), length 40) dione.40344 > phoenix.distcc: F, cksum 0xbdc6 (correct), 1980086145:1980086145(0) ack 2260270697 win 32120
10:05:24.733318 IP (tos 0x0, ttl 64, id 20485, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.40344: F, cksum 0x3b3e (correct), 2260270697:2260270697(0) ack 1980086146 win 65535
10:05:24.733389 IP (tos 0x0, ttl 64, id 46961, offset 0, flags [DF], proto TCP (6), length 40) dione.40344 > phoenix.distcc: ., cksum 0xbdc5 (correct), 1980086146:1980086146(0) ack 2260270698 win 32120
