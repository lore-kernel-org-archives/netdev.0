From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: HTB accuracy for high speed
Date: Thu, 21 May 2009 00:46:16 +0200
Message-ID: <4A148838.8010809@cosmosbay.com>
References: <298f5c050905150745p13dc226eia1ff50ffa8c4b300@mail.gmail.com>	 <298f5c050905150749s3597328dr8dd15adbd7a37532@mail.gmail.com>	 <20090516141430.GB3013@ami.dom.local>	 <298f5c050905180736m303f0c79ha30d3f791222fa1b@mail.gmail.com>	 <1242688479.9558.60.camel@hazard2.francoudi.com>	 <1242689267.11814.1.camel@hazard2.francoudi.com>	 <20090519110311.GA5521@ff.dom.local> <20090519140416.GA21270@francoudi.com>	 <20090519201027.GA4751@ami.dom.local> <1242857245.13519.17.camel@hazard2.francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz,
	Antonio Almeida <vexwek@gmail.com>,
	Corey Hickey <bugfood-ml@fatooh.org>
To: Vladimir Ivashchenko <hazard@francoudi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38910 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755716AbZETWqf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 18:46:35 -0400
In-Reply-To: <1242857245.13519.17.camel@hazard2.francoudi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vladimir Ivashchenko a =E9crit :
>>>> I guess you should send some logs. Your previous report seem to sh=
ow
>>> Can you give some hints on which logs you would like to see?
>> Similarly to Antonio's: ifconfigs and tc -s for qdiscs and classes a=
t
>> the beginning and at the end of testing.
>=20
> Ok, it seems that I finally found what is causing my HTB on 2.6.29 no=
t
> to reach full throughput: dst hashing on sfq with high divisor value.
>=20
> 2.6.21 esfq divisor 13 depth 4096 hash dst - 680 mbps
> 2.6.29 sfq WITHOUT "flow hash keys dst ... " (default sfq) - 680 mbps
> 2.6.29 sfq + "flow hash keys dst divisor 64" filter - 680 mbps
> 2.6.29 sfq + "flow hash keys dst divisor 256" filter - 660 mbps
> 2.6.29 sfq + "flow hash keys dst divisor 2048" filters - 460 mbps
>=20
> I'm using high sfq hash divisor in order to decrease the number of
> collisions, there are several thousands of hosts behind each of the
> classes.=20
>=20
> Any ideas why increasing the sfq divisor size results in drop of
> throughput ?
>=20
> Attached are diagnostics gathered in case of divisor 2048.
>=20


But... it appears sfq currently supports a fixed divisor of 1024

net/sched/sch_sfq.c

 IMPLEMENTATION:
 This implementation limits maximal queue length to 128;
 maximal mtu to 2^15-1; number of hash buckets to 1024.
 The only goal of this restrictions was that all data
 fit into one 4K page :-). Struct sfq_sched_data is
 organized in anti-cache manner: all the data for a bucket
 are scattered over different locations. This is not good,
 but it allowed me to put it into 4K.

 It is easy to increase these values, but not in flight.  */

#define SFQ_DEPTH   128
#define SFQ_HASH_DIVISOR    1024


Apparently Corey Hickey 2007 work on SFQ was not merged.

http://kerneltrap.org/mailarchive/linux-netdev/2007/9/28/325048


