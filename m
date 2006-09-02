From: netdev-owner@vger.kernel.org
Subject: Re: TCP send/ack lockstep problem
Date: Sat, 2 Sep 2006 12:26:17 +0200
Message-ID: <20060902102617.GB5567@kiste.smurf.noris.de>
References: <20060902055317.GA5567@kiste.smurf.noris.de> <E1GJOls-0008Jv-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="TRYliJ5NKNqkz5bu"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smurf.noris.de ([192.109.102.42]:54223 "EHLO smurf.noris.de")
	by vger.kernel.org with ESMTP id S1750987AbWIBK2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2006 06:28:03 -0400
Received: from kiste.smurf.noris.de ([192.109.102.35] ident=mail)
	by smurf.noris.de with smtp (Exim 4.60)
	(envelope-from <smurf@smurf.noris.de>)
	id 1GJSil-0001bW-CT
	for netdev@vger.kernel.org; Sat, 02 Sep 2006 12:27:29 +0200
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1GJOls-0008Jv-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--TRYliJ5NKNqkz5bu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

found it.

This is the tcpdump, for your edification.

Note that many packets have "push" set for no good reason,
which generally indicates dropped packets if we're doing a bulk
transfer. But all packets that are visible in the dump reached their
destination..!

The culprit turns out to be the traffic shaper, which had a
subtly-broken configuration and thus shaped that particular
traffic with a scythe instead of a razor.

A way to attach tcpdump so that those dropped packets get reported
(with an appropriate indication) would probably be helpful.

Anyway, this is not a packet that was dropped on the wire.
So why set the Push flag? TCP *knows* it couldn' send the thing.

09:16:40.652962 IP (tos 0x0, ttl  53, id 16206, offset 0, flags [DF], proto: TCP (6), length: 60) 62.193.238.120.58818 > 192.109.102.42.3306: S, cksum 0x4ef3 (correct), 692009621:692009621(0) win 5840 <mss 1460,sackOK,timestamp 840173019 0,nop,wscale 2>
09:16:40.653030 IP (tos 0x34, ttl  64, id 0, offset 0, flags [DF], proto: TCP (6), length: 60) 192.109.102.42.3306 > 62.193.238.120.58818: S, cksum 0xf277 (correct), 3232139371:3232139371(0) ack 692009622 win 5696 <mss 1100,sackOK,timestamp 218564681 840173019,nop,wscale 2>
09:16:40.705214 IP (tos 0x0, ttl  53, id 16207, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58818 > 192.109.102.42.3306: ., cksum 0x302f (correct), 1:1(0) ack 1 win 1460 <nop,nop,timestamp 840173071 218564681>
09:16:40.716501 IP (tos 0x38, ttl  64, id 32802, offset 0, flags [DF], proto: TCP (6), length: 127) 192.109.102.42.3306 > 62.193.238.120.58818: P 1:76(75) ack 1 win 1424 <nop,nop,timestamp 218564687 840173071>
09:16:40.754853 IP (tos 0x0, ttl  53, id 16208, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58818 > 192.109.102.42.3306: ., cksum 0x2fac (correct), 1:1(0) ack 76 win 1460 <nop,nop,timestamp 840173121 218564687>
09:16:40.758899 IP (tos 0x0, ttl  53, id 16209, offset 0, flags [DF], proto: TCP (6), length: 116) 62.193.238.120.58818 > 192.109.102.42.3306: P 1:65(64) ack 76 win 1460 <nop,nop,timestamp 840173124 218564687>
09:16:40.759877 IP (tos 0x34, ttl  64, id 32803, offset 0, flags [DF], proto: TCP (6), length: 52) 192.109.102.42.3306 > 62.193.238.120.58818: ., cksum 0x2f88 (correct), 76:76(0) ack 65 win 1424 <nop,nop,timestamp 218564692 840173124>
09:16:40.768414 IP (tos 0x34, ttl  64, id 32804, offset 0, flags [DF], proto: TCP (6), length: 63) 192.109.102.42.3306 > 62.193.238.120.58818: P, cksum 0x2870 (correct), 76:87(11) ack 65 win 1424 <nop,nop,timestamp 218564693 840173124>
09:16:40.805883 IP (tos 0x0, ttl  53, id 16210, offset 0, flags [DF], proto: TCP (6), length: 73) 62.193.238.120.58818 > 192.109.102.42.3306: P, cksum 0xd2f7 (correct), 65:86(21) ack 87 win 1460 <nop,nop,timestamp 840173172 218564693>
09:16:40.808077 IP (tos 0x38, ttl  64, id 32805, offset 0, flags [DF], proto: TCP (6), length: 140) 192.109.102.42.3306 > 62.193.238.120.58818: P 87:175(88) ack 86 win 1424 <nop,nop,timestamp 218564697 840173172>
09:16:40.847493 IP (tos 0x0, ttl  53, id 16211, offset 0, flags [DF], proto: TCP (6), length: 83) 62.193.238.120.58818 > 192.109.102.42.3306: P 86:117(31) ack 175 win 1460 <nop,nop,timestamp 840173213 218564697>
09:16:40.855500 IP (tos 0x38, ttl  64, id 32806, offset 0, flags [DF], proto: TCP (6), length: 124) 192.109.102.42.3306 > 62.193.238.120.58818: P 175:247(72) ack 117 win 1424 <nop,nop,timestamp 218564701 840173213>
09:16:40.855701 IP (tos 0x34, ttl  64, id 32807, offset 0, flags [DF], proto: TCP (6), length: 52) 192.109.102.42.3306 > 62.193.238.120.58818: F, cksum 0x2e46 (correct), 247:247(0) ack 117 win 1424 <nop,nop,timestamp 218564701 840173213>
09:16:40.896780 IP (tos 0x0, ttl  53, id 16212, offset 0, flags [DF], proto: TCP (6), length: 57) 62.193.238.120.58818 > 192.109.102.42.3306: P, cksum 0x2be4 (correct), 117:122(5) ack 247 win 1460 <nop,nop,timestamp 840173263 218564701>
09:16:40.896811 IP (tos 0x34, ttl  64, id 0, offset 0, flags [DF], proto: TCP (6), length: 40) 192.109.102.42.3306 > 62.193.238.120.58818: R, cksum 0x1f59 (correct), 3232139618:3232139618(0) win 0
09:16:40.897032 IP (tos 0x0, ttl  53, id 16213, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58818 > 192.109.102.42.3306: F, cksum 0x2deb (correct), 122:122(0) ack 247 win 1460 <nop,nop,timestamp 840173263 218564701>
09:16:40.897058 IP (tos 0x34, ttl  64, id 0, offset 0, flags [DF], proto: TCP (6), length: 40) 192.109.102.42.3306 > 62.193.238.120.58818: R, cksum 0x1f59 (correct), 3232139618:3232139618(0) win 0
09:16:40.898497 IP (tos 0x0, ttl  53, id 16214, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58818 > 192.109.102.42.3306: ., cksum 0x2de8 (correct), 123:123(0) ack 248 win 1460 <nop,nop,timestamp 840173265 218564701>
09:16:40.898517 IP (tos 0x34, ttl  64, id 0, offset 0, flags [DF], proto: TCP (6), length: 40) 192.109.102.42.3306 > 62.193.238.120.58818: R, cksum 0x1f58 (correct), 3232139619:3232139619(0) win 0
09:16:48.515549 IP (tos 0x0, ttl  53, id 35709, offset 0, flags [DF], proto: TCP (6), length: 60) 62.193.238.120.58819 > 192.109.102.42.3306: S, cksum 0xbb47 (correct), 685289454:685289454(0) win 5840 <mss 1460,sackOK,timestamp 840180883 0,nop,wscale 2>
09:16:48.515601 IP (tos 0x34, ttl  64, id 0, offset 0, flags [DF], proto: TCP (6), length: 60) 192.109.102.42.3306 > 62.193.238.120.58819: S, cksum 0x824a (correct), 3248316644:3248316644(0) ack 685289455 win 5696 <mss 1100,sackOK,timestamp 218565467 840180883,nop,wscale 2>
09:16:48.551765 IP (tos 0x0, ttl  53, id 35710, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0xc011 (correct), 1:1(0) ack 1 win 1460 <nop,nop,timestamp 840180919 218565467>
09:16:48.555452 IP (tos 0x38, ttl  64, id 27578, offset 0, flags [DF], proto: TCP (6), length: 127) 192.109.102.42.3306 > 62.193.238.120.58819: P 1:76(75) ack 1 win 1424 <nop,nop,timestamp 218565471 840180919>
09:16:48.593656 IP (tos 0x0, ttl  53, id 35711, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0xbf98 (correct), 1:1(0) ack 76 win 1460 <nop,nop,timestamp 840180961 218565471>
09:16:48.609191 IP (tos 0x0, ttl  53, id 35712, offset 0, flags [DF], proto: TCP (6), length: 116) 62.193.238.120.58819 > 192.109.102.42.3306: P 1:65(64) ack 76 win 1460 <nop,nop,timestamp 840180976 218565471>
09:16:48.609232 IP (tos 0x34, ttl  64, id 27579, offset 0, flags [DF], proto: TCP (6), length: 52) 192.109.102.42.3306 > 62.193.238.120.58819: ., cksum 0xbf67 (correct), 76:76(0) ack 65 win 1424 <nop,nop,timestamp 218565477 840180976>
09:16:48.609877 IP (tos 0x34, ttl  64, id 27580, offset 0, flags [DF], proto: TCP (6), length: 63) 192.109.102.42.3306 > 62.193.238.120.58819: P, cksum 0xb850 (correct), 76:87(11) ack 65 win 1424 <nop,nop,timestamp 218565477 840180976>
09:16:48.648585 IP (tos 0x0, ttl  53, id 35713, offset 0, flags [DF], proto: TCP (6), length: 73) 62.193.238.120.58819 > 192.109.102.42.3306: P, cksum 0x62e0 (correct), 65:86(21) ack 87 win 1460 <nop,nop,timestamp 840181016 218565477>
09:16:48.649414 IP (tos 0x38, ttl  64, id 27581, offset 0, flags [DF], proto: TCP (6), length: 140) 192.109.102.42.3306 > 62.193.238.120.58819: P 87:175(88) ack 86 win 1424 <nop,nop,timestamp 218565481 840181016>
09:16:48.687511 IP (tos 0x0, ttl  53, id 35714, offset 0, flags [DF], proto: TCP (6), length: 83) 62.193.238.120.58819 > 192.109.102.42.3306: P 86:117(31) ack 175 win 1460 <nop,nop,timestamp 840181054 218565481>
09:16:48.710072 IP (tos 0x38, ttl  64, id 27582, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 175:1591(1416) ack 117 win 1424 <nop,nop,timestamp 218565487 840181054>
09:16:48.710128 IP (tos 0x38, ttl  64, id 27583, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 1591:3007(1416) ack 117 win 1424 <nop,nop,timestamp 218565487 840181054>
09:16:48.787304 IP (tos 0x0, ttl  53, id 35715, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0xad38 (correct), 117:117(0) ack 3007 win 2908 <nop,nop,timestamp 840181154 218565487>
09:16:48.787359 IP (tos 0x38, ttl  64, id 27584, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: P 3007:4423(1416) ack 117 win 1424 <nop,nop,timestamp 218565494 840181154>
09:16:48.787399 IP (tos 0x38, ttl  64, id 27585, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 4423:5839(1416) ack 117 win 1424 <nop,nop,timestamp 218565494 840181154>
09:16:48.864470 IP (tos 0x0, ttl  53, id 35716, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0x9c2b (correct), 117:117(0) ack 5839 win 4356 <nop,nop,timestamp 840181232 218565494>
09:16:48.943359 IP (tos 0x38, ttl  64, id 27586, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 5839:7255(1416) ack 117 win 1424 <nop,nop,timestamp 218565494 840181154>
09:16:49.040085 IP (tos 0x0, ttl  53, id 35717, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0x931f (correct), 117:117(0) ack 7255 win 5080 <nop,nop,timestamp 840181408 218565494>
09:16:49.040123 IP (tos 0x38, ttl  64, id 27591, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: P 7255:8671(1416) ack 117 win 1424 <nop,nop,timestamp 218565520 840181408>
09:16:49.097249 IP (tos 0x0, ttl  53, id 35718, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0x8a70 (correct), 117:117(0) ack 8671 win 5804 <nop,nop,timestamp 840181465 218565520>
09:16:49.097279 IP (tos 0x38, ttl  64, id 27592, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 8671:10087(1416) ack 117 win 1424 <nop,nop,timestamp 218565525 840181465>
09:16:49.154694 IP (tos 0x0, ttl  53, id 35719, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0x81d6 (correct), 117:117(0) ack 10087 win 6528 <nop,nop,timestamp 840181522 218565525>
09:16:49.313454 IP (tos 0x38, ttl  64, id 27593, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: P 10087:11503(1416) ack 117 win 1424 <nop,nop,timestamp 218565531 840181522>
09:16:49.370720 IP (tos 0x0, ttl  53, id 35720, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0x789c (correct), 117:117(0) ack 11503 win 7252 <nop,nop,timestamp 840181738 218565531>
09:16:49.370752 IP (tos 0x38, ttl  64, id 27596, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 11503:12919(1416) ack 117 win 1424 <nop,nop,timestamp 218565553 840181738>
09:16:49.428640 IP (tos 0x0, ttl  53, id 35721, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0x6ff0 (correct), 117:117(0) ack 12919 win 7976 <nop,nop,timestamp 840181796 218565553>
09:16:49.573523 IP (tos 0x38, ttl  64, id 27597, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 12919:14335(1416) ack 117 win 1424 <nop,nop,timestamp 218565558 840181796>
09:16:49.630167 IP (tos 0x0, ttl  53, id 35722, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0x66c5 (correct), 117:117(0) ack 14335 win 8700 <nop,nop,timestamp 840181998 218565558>
09:16:49.630203 IP (tos 0x38, ttl  64, id 27598, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 14335:15751(1416) ack 117 win 1424 <nop,nop,timestamp 218565579 840181998>
09:16:49.687564 IP (tos 0x0, ttl  53, id 35723, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0x5e1b (correct), 117:117(0) ack 15751 win 9424 <nop,nop,timestamp 840182055 218565579>
09:16:49.753575 IP (tos 0x38, ttl  64, id 27599, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: P 15751:17167(1416) ack 117 win 1424 <nop,nop,timestamp 218565579 840181998>
09:16:49.811513 IP (tos 0x0, ttl  53, id 35724, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0x5543 (correct), 117:117(0) ack 17167 win 10148 <nop,nop,timestamp 840182179 218565579>
09:16:49.811598 IP (tos 0x38, ttl  64, id 27601, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 17167:18583(1416) ack 117 win 1424 <nop,nop,timestamp 218565597 840182179>
09:16:49.868417 IP (tos 0x0, ttl  53, id 35725, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0x4c9c (correct), 117:117(0) ack 18583 win 10872 <nop,nop,timestamp 840182236 218565597>
09:16:49.868462 IP (tos 0x38, ttl  64, id 27602, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 18583:19999(1416) ack 117 win 1424 <nop,nop,timestamp 218565602 840182236>
09:16:49.943108 IP (tos 0x0, ttl  53, id 35726, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0x43f1 (correct), 117:117(0) ack 19999 win 11596 <nop,nop,timestamp 840182310 218565602>
09:16:50.073661 IP (tos 0x38, ttl  64, id 27603, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: P 19999:21415(1416) ack 117 win 1424 <nop,nop,timestamp 218565610 840182310>
09:16:50.130798 IP (tos 0x0, ttl  53, id 35727, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0x3ad1 (correct), 117:117(0) ack 21415 win 12320 <nop,nop,timestamp 840182498 218565610>
09:16:50.130838 IP (tos 0x38, ttl  64, id 27605, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 21415:22831(1416) ack 117 win 1424 <nop,nop,timestamp 218565629 840182498>
09:16:50.188530 IP (tos 0x0, ttl  53, id 35728, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0x3228 (correct), 117:117(0) ack 22831 win 13044 <nop,nop,timestamp 840182556 218565629>
09:16:50.593813 IP (tos 0x38, ttl  64, id 27610, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: P 22831:24247(1416) ack 117 win 1424 <nop,nop,timestamp 218565675 840182556>
09:16:50.650912 IP (tos 0x0, ttl  53, id 35729, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0x27d0 (correct), 117:117(0) ack 24247 win 13768 <nop,nop,timestamp 840183018 218565675>
09:16:50.650950 IP (tos 0x38, ttl  64, id 27611, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: P 24247:25663(1416) ack 117 win 1424 <nop,nop,timestamp 218565681 840183018>
09:16:50.707879 IP (tos 0x0, ttl  53, id 35730, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0x1f34 (correct), 117:117(0) ack 25663 win 14492 <nop,nop,timestamp 840183076 218565681>
09:16:50.707922 IP (tos 0x38, ttl  64, id 27612, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 25663:27079(1416) ack 117 win 1424 <nop,nop,timestamp 218565686 840183076>
09:16:50.707976 IP (tos 0x38, ttl  64, id 27613, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 27079:28495(1416) ack 117 win 1424 <nop,nop,timestamp 218565686 840183076>
09:16:50.766258 IP (tos 0x0, ttl  53, id 35731, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0x169a (correct), 117:117(0) ack 27079 win 15216 <nop,nop,timestamp 840183133 218565686>
09:16:50.785441 IP (tos 0x0, ttl  53, id 35732, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0x0e2a (correct), 117:117(0) ack 28495 win 15940 <nop,nop,timestamp 840183153 218565686>
09:16:50.843874 IP (tos 0x38, ttl  64, id 27614, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: P 28495:29911(1416) ack 117 win 1424 <nop,nop,timestamp 218565692 840183133>
09:16:50.901226 IP (tos 0x0, ttl  53, id 35733, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0x07d6 (correct), 117:117(0) ack 29911 win 16022 <nop,nop,timestamp 840183269 218565692>
09:16:50.901278 IP (tos 0x38, ttl  64, id 27618, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 29911:31327(1416) ack 117 win 1424 <nop,nop,timestamp 218565706 840183269>
09:16:50.958938 IP (tos 0x0, ttl  53, id 35734, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0x0207 (correct), 117:117(0) ack 31327 win 16022 <nop,nop,timestamp 840183326 218565706>
09:16:50.958999 IP (tos 0x38, ttl  64, id 27619, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 31327:32743(1416) ack 117 win 1424 <nop,nop,timestamp 218565711 840183326>
09:16:51.043153 IP (tos 0x0, ttl  53, id 35735, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0xfc25 (correct), 117:117(0) ack 32743 win 16022 <nop,nop,timestamp 840183410 218565711>
09:16:51.063929 IP (tos 0x38, ttl  64, id 27620, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: P 32743:34159(1416) ack 117 win 1424 <nop,nop,timestamp 218565720 840183410>
09:16:51.121504 IP (tos 0x0, ttl  53, id 35736, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0xf644 (correct), 117:117(0) ack 34159 win 16022 <nop,nop,timestamp 840183490 218565720>
09:16:51.121539 IP (tos 0x38, ttl  64, id 27622, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 34159:35575(1416) ack 117 win 1424 <nop,nop,timestamp 218565728 840183490>
09:16:51.179198 IP (tos 0x0, ttl  53, id 35737, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0xf07b (correct), 117:117(0) ack 35575 win 16022 <nop,nop,timestamp 840183547 218565728>
09:16:51.484056 IP (tos 0x38, ttl  64, id 27625, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: P 35575:36991(1416) ack 117 win 1424 <nop,nop,timestamp 218565764 840183547>
09:16:51.540391 IP (tos 0x0, ttl  53, id 35738, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0xe966 (correct), 117:117(0) ack 36991 win 16022 <nop,nop,timestamp 840183908 218565764>
09:16:51.540434 IP (tos 0x38, ttl  64, id 27626, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: P 36991:38407(1416) ack 117 win 1424 <nop,nop,timestamp 218565770 840183908>
09:16:51.598030 IP (tos 0x0, ttl  53, id 35739, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0xe39f (correct), 117:117(0) ack 38407 win 16022 <nop,nop,timestamp 840183965 218565770>
09:16:51.598067 IP (tos 0x38, ttl  64, id 27627, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 38407:39823(1416) ack 117 win 1424 <nop,nop,timestamp 218565775 840183965>
09:16:51.655911 IP (tos 0x0, ttl  53, id 35740, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0xddd7 (correct), 117:117(0) ack 39823 win 16022 <nop,nop,timestamp 840184024 218565775>
09:16:51.764117 IP (tos 0x38, ttl  64, id 27628, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 39823:41239(1416) ack 117 win 1424 <nop,nop,timestamp 218565775 840183965>
09:16:51.821213 IP (tos 0x0, ttl  53, id 35741, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0xd7aa (correct), 117:117(0) ack 41239 win 16022 <nop,nop,timestamp 840184189 218565775>
09:16:51.821264 IP (tos 0x38, ttl  64, id 27633, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: P 41239:42655(1416) ack 117 win 1424 <nop,nop,timestamp 218565798 840184189>
09:16:51.882068 IP (tos 0x0, ttl  53, id 35742, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0xd1d2 (correct), 117:117(0) ack 42655 win 16022 <nop,nop,timestamp 840184246 218565798>
09:16:51.994179 IP (tos 0x38, ttl  64, id 27634, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 42655:44071(1416) ack 117 win 1424 <nop,nop,timestamp 218565804 840184246>
09:16:52.056520 IP (tos 0x0, ttl  53, id 35743, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0xcb92 (correct), 117:117(0) ack 44071 win 16022 <nop,nop,timestamp 840184424 218565804>
09:16:52.056553 IP (tos 0x38, ttl  64, id 27635, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 44071:45487(1416) ack 117 win 1424 <nop,nop,timestamp 218565821 840184424>
09:16:52.114169 IP (tos 0x0, ttl  53, id 35744, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0xc5c0 (correct), 117:117(0) ack 45487 win 16022 <nop,nop,timestamp 840184481 218565821>
09:16:52.233273 IP (tos 0x38, ttl  64, id 27636, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: P 45487:46903(1416) ack 117 win 1424 <nop,nop,timestamp 218565821 840184424>
09:16:52.291636 IP (tos 0x0, ttl  53, id 35745, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0xbf85 (correct), 117:117(0) ack 46903 win 16022 <nop,nop,timestamp 840184660 218565821>
09:16:52.291668 IP (tos 0x38, ttl  64, id 27638, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 46903:48319(1416) ack 117 win 1424 <nop,nop,timestamp 218565845 840184660>
09:16:52.351670 IP (tos 0x0, ttl  53, id 35746, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0xb9aa (correct), 117:117(0) ack 48319 win 16022 <nop,nop,timestamp 840184719 218565845>
09:16:52.494312 IP (tos 0x38, ttl  64, id 27639, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 48319:49735(1416) ack 117 win 1424 <nop,nop,timestamp 218565851 840184719>
09:16:52.568254 IP (tos 0x0, ttl  53, id 35747, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0xb343 (correct), 117:117(0) ack 49735 win 16022 <nop,nop,timestamp 840184936 218565851>
09:16:52.568290 IP (tos 0x38, ttl  64, id 27640, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: P 49735:51151(1416) ack 117 win 1424 <nop,nop,timestamp 218565872 840184936>
09:16:52.625890 IP (tos 0x0, ttl  53, id 35748, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0xad6d (correct), 117:117(0) ack 51151 win 16022 <nop,nop,timestamp 840184993 218565872>
09:16:52.724383 IP (tos 0x38, ttl  64, id 27641, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 51151:52567(1416) ack 117 win 1424 <nop,nop,timestamp 218565872 840184936>
09:16:52.782390 IP (tos 0x0, ttl  53, id 35749, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0xa748 (correct), 117:117(0) ack 52567 win 16022 <nop,nop,timestamp 840185150 218565872>
09:16:52.782457 IP (tos 0x38, ttl  64, id 27643, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 52567:53983(1416) ack 117 win 1424 <nop,nop,timestamp 218565894 840185150>
09:16:52.841705 IP (tos 0x0, ttl  53, id 35750, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0xa16f (correct), 117:117(0) ack 53983 win 16022 <nop,nop,timestamp 840185209 218565894>
09:16:52.962564 IP (tos 0x38, ttl  64, id 27644, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: P 53983:55399(1416) ack 117 win 1424 <nop,nop,timestamp 218565900 840185209>
09:16:53.021342 IP (tos 0x0, ttl  53, id 35751, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0x9b2d (correct), 117:117(0) ack 55399 win 16022 <nop,nop,timestamp 840185389 218565900>
09:16:53.021399 IP (tos 0x38, ttl  64, id 27645, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.58819: . 55399:56815(1416) ack 117 win 1424 <nop,nop,timestamp 218565918 840185389>
09:16:53.100714 IP (tos 0x0, ttl  53, id 35752, offset 0, flags [DF], proto: TCP (6), length: 52) 62.193.238.120.58819 > 192.109.102.42.3306: ., cksum 0x9544 (correct), 117:117(0) ack 56815 win 16022 <nop,nop,timestamp 840185468 218565918>
[...]

-- 
Matthias Urlichs   |   {M:U} IT Design @ m-u-it.de   |  smurf@smurf.noris.de

--TRYliJ5NKNqkz5bu
Content-Type: message/external-body; access-type=x-mutt-deleted;
	expiration="Sat, 2 Sep 2006 12:27:14 +0200"; length=4372

Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="slow.strace"


--TRYliJ5NKNqkz5bu
Content-Type: message/external-body; access-type=x-mutt-deleted;
	expiration="Sat, 2 Sep 2006 12:27:14 +0200"; length=24820

Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="slow.tcpdump"


--TRYliJ5NKNqkz5bu--

-- 
VGER BF report: U 0.500006
