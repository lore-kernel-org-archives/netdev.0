From: Rick Jones <rick.jones2@hp.com>
Subject: A question about deleting a network namespace while something is
 executing in another
Date: Thu, 19 Sep 2013 15:10:54 -0700
Message-ID: <523B766E.7000505@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:24019 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753713Ab3ISWK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 18:10:56 -0400
Received: from g5t0030.atlanta.hp.com (g5t0030.atlanta.hp.com [16.228.8.142])
	by g5t0008.atlanta.hp.com (Postfix) with ESMTP id EC46824063
	for <netdev@vger.kernel.org>; Thu, 19 Sep 2013 22:10:55 +0000 (UTC)
Received: from [16.103.148.51] (swa01lbdc1025-026-vl250-snat2.atlanta.hp.com [16.228.13.92])
	by g5t0030.atlanta.hp.com (Postfix) with ESMTP id B68A114188
	for <netdev@vger.kernel.org>; Thu, 19 Sep 2013 22:10:55 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been messing about (as a user) with network namespaces and 
something I call the "thing1/thing2" problem and have a question.  In a 
3.5 kernel if I do:

root@tardy:~# ip netns add thing1
root@tardy:~# ip netns add thing2
root@tardy:~# ip netns exec thing2 sleep 15 &
[1] 27247
root@tardy:~# ip netns del thing1
Cannot remove /var/run/netns/thing1: Device or resource busy
root@tardy:~#
[1]+  Done                    ip netns exec thing2 sleep 15
root@tardy:~# ip netns del thing1
root@tardy:~#

You can see that netns thing1 cannot be deleted while there is an active 
ip netns exec in thing2.

I see the same thing on a 3.8 kernel, and a 3.10 kernel.  In a 3.11.0 
kernel though I see:

~# ip netns add thing1
~# ip netns add thing2
~# ip netns exec thing2 sleep 15 &
[1] 2264
~# ip netns del thing1
~#
~# uname -a
Linux lefty 3.11.0-7-generic #13-Ubuntu SMP Tue Sep 10 20:55:38 UTC 2013 
x86_64 x86_64 x86_64 GNU/Linux

which suggests that the limitation on deleting a namespace while 
something was executing in another was removed.  Happiness and joy ensues.

However...  if I now go to a 3.11.1 kernel built from a clone of 
linux-stable I see:

~# uname -a
Linux lucy 3.11.1 #9 SMP Thu Sep 19 17:11:50 UTC 2013 x86_64 x86_64 
x86_64 GNU/Linux
~# ip netns add thing1
~# ip netns add thing2
~# ip netns exec thing2 sleep 15 &
[1] 22766
~# ip netns del thing1
Cannot remove /var/run/netns/thing1: Device or resource busy
root@qu-stbaz1-perf0001:~#
[1]+  Done                    ip netns exec thing2 sleep 15
~# ip netns del thing1


Did an enhancement get (inadvertently) reverted?  Or perhaps something 
not get added to 3.11.1 that was put into the  3.11.0-7-generic kernel 
(admittedly, I've a slightly mixed set of lineages - the 3.5, 3.8 and 
3.11.0 kernels have passed through Canonical, and the 3.10 and 3.11.1 
kernels came from linux-stable.

And here is 3.12.0rc1, from linux-stable:
~# ip netns add thing1
~# ip netns add thing2
~# ip netns exec thing2 sleep 15 &
[1] 3490
~# ip netns del thing1
Cannot remove /var/run/netns/thing1: Device or resource busy
~#
[1]+  Done                    ip netns exec thing2 sleep 15
~# ip netns del thing1
root@qu-stbaz1-perf0001:~# uname -a
Linux lucy 3.12.0-rc1 #10 SMP Thu Sep 19 21:24:36 UTC 2013 x86_64 x86_64 
x86_64 GNU/Linux

rick jones
