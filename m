From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: ipsec impact on performance
Date: Wed, 2 Dec 2015 12:41:40 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBE0F39@AcuExch.aculab.com>
References: <20151201175953.GC21252@oracle.com>
 <CALx6S35uLqbuJTAFLMeT-BcyZw_fksz+7BkS=Nt7_3-nYMHF2A@mail.gmail.com>
 <20151201183720.GE21252@oracle.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CBE0ED7@AcuExch.aculab.com>
 <20151202121156.GK23178@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Tom Herbert <tom@herbertland.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>
To: 'Sowmini Varadhan' <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.189]:60103 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755059AbbLBMnJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 07:43:09 -0500
In-Reply-To: <20151202121156.GK23178@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan
> Sent: 02 December 2015 12:12
> On (12/02/15 11:56), David Laight wrote:
> > >                 Gbps  peak cpu util
> > > esp-null         1.8   71%
> > > aes-gcm-c-256    1.6   79%
> > > aes-ccm-a-128    0.7   96%
> > >
> > > That trend made me think that if we can get esp-null to be as close
> > > as possible to GSO/GRO, the rest will follow closely behind.
> >
> > That's not how I read those figures.
> > They imply to me that there is a massive cost for the actual encryption
> > (particularly for aes-ccm-a-128) - so whatever you do to the esp-null
> > case won't help.
> 
> I'm not a crypto expert, but my understanding is that the CCM mode
> is the "older" encryption algorithm, and GCM is the way of the future.
> Plus, I think the GCM mode has some type of h/w support (hence the
> lower cpu util)
> 
> I'm sure that crypto has a cost, not disputing that, but my point
> was that 1.8 -> 1.6 -> 0.7 is a curve with a much gentler slope than
> the 9 Gbps (clear traffic, GSO, GRO)
>     -> 4 Gbps (clear, no gro, gso)
>        -> 1.8 (esp-null)
> That steeper slope smells of s/w perf that we need to resolve first,
> before getting into the work of faster crypto?

That isn't the way cpu cost works.
You are getting 0.7 Gbps with ass-ccm-a-128, scale the esp-null back to
that and it would use 7/18*71 = 27% of the cpu.
So 69% of the cpu in the a-128 case is probably caused by the
encryption itself.
Even if the rest of the code cost nothing you'd not increase
above 1Gbps.

The sums for aes-gcm-c-256 are slightly better, about 15%.

Ok, things aren't quite that simple since you are probably changing
the way data flows through the system as well.

Also what/how are you measuring cpu use.
I'm not sure anything on Linux gives you a truly accurate value
when processes are running for very short periods.

On an SMP system you also get big effects when work is switched
between cpus. I've got some tests that run a lot faster if I
put all but one of the cpus into a busy-loop in userspace
(eg: while :; do :; done)!

	David
