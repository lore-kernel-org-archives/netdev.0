From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCHv3 linux-next] hrtimer: Add notifier when clock_was_set
 was called
Date: Tue, 20 Aug 2013 09:56:26 +0800
Message-ID: <5212CCCA.4090907@windriver.com>
References: <1375866296-15079-1-git-send-email-fan.du@windriver.com> <1375866296-15079-2-git-send-email-fan.du@windriver.com> <52021177.6020306@redhat.com> <520213F2.5090401@windriver.com> <520214C6.6000307@redhat.com> <520B4552.2000607@windriver.com> <alpine.DEB.2.02.1308181102230.4089@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Daniel Borkmann <dborkman@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:62700 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254Ab3HTB4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 21:56:42 -0400
In-Reply-To: <alpine.DEB.2.02.1308181102230.4089@ionos.tec.linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B408=E6=9C=8818=E6=97=A5 17:05, Thomas Gleixner wrote:
> On Wed, 14 Aug 2013, Fan Du wrote:
>
>>  From e3929d4fdfad5b40fd8cad0e217597670d1aef54 Mon Sep 17 00:00:00 2=
001
>> From: Fan Du<fan.du@windriver.com>
>> Date: Wed, 14 Aug 2013 16:39:23 +0800
>> Subject: [PATCHv3 linux-next] hrtimer: Add notifier when clock_was_s=
et was
>> called
>>
>> When clock_was_set is called in case of system wall time change
>> or host resume from suspend state, use this notifier for places
>> where interested in this action, e.g Ipsec SA lifetime management.
>
> Sigh. These notifiers have been proposed in the past and we always
> rejected them. Why do you need this? There should be nothing except
> the core timekeeping code which needs to know about clock_was_set.
>
> Can you please explain what kind of users you have in mind and WHY
> they need to know about it.

Hi, Thomas


Thanks for your patience. Please let me take a few seconds try to
explain this.

Current xfrm layers has *one* hrtimer to guard Ipsec keys timeout,
The timeout could be measured in either of below two ways:

  (1) The timer is started once the keys is created, but this
      key is not necessary actually used right now. In detail,
      record the get_seconds() when this key is created.

  (2) Starting the timer when this key is actually used, e.g when
      an IP packet need to be encrypted. In details, recored the
      get_seconds() when this key is first used.

So in the hrtimer handler, the code get current get_seconds, and
check against with what saved in (1)or(2), and notify the timeout
up to user land.

So the pitfall is using one hrtimer for two timeout events,
most importantly using get_seconds to check timeout, once system
clock is changed by user intentionally, the key timeout could
misbehave wildly.

A refractor has been proposed to get rid of depending on system wall
clock by cleaning up the hrtimer handler. Unfortunately David frowned
on it in (3), and suggest once system clock is changed, adjust the
timeout of the key.


(3): http://www.spinics.net/lists/netdev/msg245169.html


> Thanks,
>
> 	tglx
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
