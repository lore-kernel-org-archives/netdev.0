From: Paolo Valente <paolo.valente@unimore.it>
Subject: Re: [RFC PATCH net-next] qfq: handle the case that front slot is empty
Date: Fri, 26 Oct 2012 09:51:36 +0200
Message-ID: <58DEB62C-6237-435E-8300-8E390F101F58@unimore.it>
References: <1350965711-4390-1-git-send-email-amwang@redhat.com> <F36C0EC1-0A4C-48FB-ABF3-A89575A9287E@unimore.it> <1350982432.26308.8.camel@cr0>
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spostino.sms.unimo.it ([155.185.44.3]:39270 "EHLO
	spostino.sms.unimo.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757052Ab2JZHx0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 03:53:26 -0400
In-Reply-To: <1350982432.26308.8.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Il giorno 23/ott/2012, alle ore 10:53, Cong Wang ha scritto:

> On Tue, 2012-10-23 at 09:09 +0200, Paolo Valente wrote:
>> The crash you reported is one of the problems I tried to solve with my last fixes.
>> After those fixes I could not reproduce this crash (and other crashes) any more, but of course I am still missing something.
> 
> I am using the latest net-next, so if your patches are in net-next,
> then the problem of course still exists.
> 
>> 
>> Il giorno 23/ott/2012, alle ore 06:15, Cong Wang ha scritto:
>> 
>>> I am not sure if this patch fixes the real problem or just workarounds
>>> it. At least, after this patch I don't see the crash I reported any more.
>> 
>> It is actually a workaround: if the condition that triggers your workaround holds true, then the group data structure is already inconstent, and qfq is likely not to schedule classes correctly.
>> I will try to reproduce the crash with the steps you suggest, and try to understand what is still wrong as soon as I can.
>> 
> 
> OK, I don't pretend I understand qfq.
The problem is that I should :)
> And I can help you to test
> patches.
> 
I think I will ask for your help soon, thanks.

The cause of the failure is TCP segment offloading, which lets qfq receive packets with a much larger size than the MTU of the device.
In this respect, under qfq the default max packet size lmax for each class (2KB) is only slightly higher than the MTU. Violating the lmax constraint causes the corruption of the data structure that implements the bucket lists of the groups. In fact, the failure that you found is only one of the consequences of this corruption. I am sorry I did not discover it before, but, foolishly, I have run only UDP tests.

I am thinking about the best ways for addressing this issue.

BTW, I think that the behavior of all the other schedulers should be checked as well. For example, with segment offloading, drr must increment the deficit of a class for at most (64K/quantum) times, i.e., rounds, before it can serve the next packet of the class. The number of instructions per packet dequeue becomes therefore (64K/quantum) times higher than without segment offloading.

> Thanks!
> 
