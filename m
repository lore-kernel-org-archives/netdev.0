From: jamal <hadi@cyberus.ca>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Thu, 07 Jun 2007 08:16:16 -0400
Message-ID: <1181218576.4064.40.camel@localhost>
References: <OF4ACB16BB.A5DB2CC2-ON652572F3.002CD2F1-652572F3.002FDC45@in.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Gagan Arneja <gaagaan@gmail.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:9902 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561AbXFGMQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 08:16:20 -0400
Received: by py-out-1112.google.com with SMTP id a29so804731pyi
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2007 05:16:19 -0700 (PDT)
In-Reply-To: <OF4ACB16BB.A5DB2CC2-ON652572F3.002CD2F1-652572F3.002FDC45@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

KK,

On Thu, 2007-07-06 at 14:12 +0530, Krishna Kumar2 wrote:
> I have run only once instead of
> taking any averages, so there could be some spurts/drops.

Would be nice to run three sets - but i think even one would be
sufficiently revealing.
 
> These results are based on the test script that I sent earlier today. I
> removed the results for UDP 32 procs 512 and 4096 buffer cases since
> the BW was coming >line speed (infact it was showing 1500Mb/s and
> 4900Mb/s respectively for both the ORG and these bits). 

I expect UDP to overwhelm the receiver. So the receiver needs a lot more
tuning (like increased rcv socket buffer sizes to keep up, IMO).

But yes, the above is an odd result - Rick any insight into this?

> I am not sure
> how it is coming this high, but netperf4 is the only way to correctly
> measure multiple process combined BW. Another thing to do is to disable
> pure performance fixes in E1000 (eg changing THRESHOLD to 128 and
> some other changes like Erratum workaround or MSI, etc) which are
> independent of this functionality. Then a more accurate performance
> result is possible when comparing org vs batch code, without mixing in
> unrelated performance fixes which skews the results (either positively
> or negatively :).
> 

I agree that THRESHOLD change needs to be the same for a fair
comparison. Note however, it is definetely a tuning parameter which is a
fundamental aspect of this batching exercise (historically this was
added to e1000 because i found it useful in my 2006 batch experiments).
When all the dust settles we should be able to pick a value that is
optimal.
Would it be useful if i made this a boot/module parameter? It should
have been actually.

The erratum changes - I am not so sure; the ->prep_xmit() is a
fundamental aspect and it needs to run lockless; the erratum forces us
to run with a lock. In any case, I dont think that affects your chip.

> Each iteration consists of running buffer sizes 8, 32, 128, 512, 4096.

It seems to me any runs with buffer less than 512B are unable to fill
the pipe - so will not really benefit (will probably do with nagling).
However, the < 512 B should show equivalent results before and after the
changes.
You can try to turn off _BTX feature in the driver and see if they are
the same. If they are not, then the suspect change will be easy to find.
When i turned off the _BTX changes i saw no difference with pktgen.
But that is a different code path.

> Summary : Average BW (whatever meaning that has) improved 0.65%, while
>                  Service Demand deteriorated 11.86%

Sorry, been many moons since i last played with netperf; what does "service
demand" mean?

cheers,
jamal

