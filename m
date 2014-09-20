From: Anton Farygin <rider@altlinux.com>
Subject: Re: Fwd: [Bug 84661] New: tc filter show from iproute2 does not work
 correctly on 32bit x86
Date: Sat, 20 Sep 2014 21:54:19 +0400
Message-ID: <541DBF4B.8030002@altlinux.com>
References: <bug-84661-65011@https.bugzilla.kernel.org/>	 <541D9F9B.9040404@redhat.com> <1411231830.26859.69.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: rider@altlinux.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yangyingliang@huawei.com, rider@altlinux.org,
	netdev@vger.kernel.org,
	"Anton V. Boyarshinov" <boyarsh@altlinux.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pegasus3.altlinux.org ([194.107.17.103]:38677 "EHLO
	pegasus3.altlinux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757831AbaITSCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 14:02:15 -0400
In-Reply-To: <1411231830.26859.69.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20.09.2014 20:50, Eric Dumazet wrote:
> On Sat, 2014-09-20 at 17:39 +0200, Daniel Borkmann wrote:
>> [ Cc'ing Yang ]
>>
>> -------- Original Message --------
>> Subject: [Bug 84661] New: tc filter show from iproute2 does not work correctly on 32bit x86
>> Date: Tue, 16 Sep 2014 11:47:20 +0000
>> From: bugzilla-daemon@bugzilla.kernel.org
>> To: dborkman@redhat.com
>>
>> https://bugzilla.kernel.org/show_bug.cgi?id=84661
>>
>>               Bug ID: 84661
>>              Summary: tc filter show from iproute2 does not work correctly
>>                       on 32bit x86
>>              Product: Networking
>>              Version: 2.5
>>       Kernel Version: 3.14.17 and 3.16.1
>>             Hardware: All
>>                   OS: Linux
>>                 Tree: Mainline
>>               Status: NEW
>>             Severity: normal
>>             Priority: P1
>>            Component: Other
>>             Assignee: shemminger@linux-foundation.org
>>             Reporter: rider@altlinux.org
>>           Regression: No
>>
>> i tested this issue with kernels 3.14.x and 3.16.x. and iproute2-3.16.0
>>
>> This commit:
>> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?id=6a031f67c83aa175aedd10d4ae64750415ab57b0
>> breaking output tc filter show on 32bit systems.
>>
>> This simple script shows the difference in the work on i586 and x86_64:
>> -------------------------
>> #!/bin/sh
>> dev=$1
>> tc qdisc add dev $dev root handle 1: htb default fffe
>> tc filter add dev $dev parent 1:0 protocol ip pref 10 u32
>> tc filter add dev $dev parent 1:0 protocol ip pref 10 handle 100: u32 divisor 8
>> tc filter add dev $dev parent 1:0 protocol ip pref 10 u32 ht 800:: match ip dst
>> 10.21.10.0/21 hashkey mask 0x00000700 at 16 link 100:
>> tc filter show dev $dev
>> tc filter del dev $dev parent 1:0 protocol ip pref 10 u32 ht 800:: match ip dst
>> 10.21.10.0/21 hashkey mask 0x00000700 at 16 link 100:
>> tc qdisc del dev $dev root handle 1: htb default fffe
>> ---------------------------
>>
>> output on i586:
>>
>> #./script enp0s25
>> filter parent 1: protocol ip pref 10 u32
>> filter parent 1: protocol ip pref 10 u32 fh 100: ht divisor 8
>> filter parent 1: protocol ip pref 10 u32 fh 800: ht divisor 1
>>
>>
>> output on x86_64:
>> # ./script eth0
>> filter parent 1: protocol ip pref 10 u32
>> filter parent 1: protocol ip pref 10 u32 fh 100: ht divisor 8
>> filter parent 1: protocol ip pref 10 u32 fh 800: ht divisor 1
>> filter parent 1: protocol ip pref 10 u32 fh 800::800 order 2048 key ht 800 bkt
>> 0 link 100:
>>     match 0a150800/fffff800 at 16
>>       hash mask 00000700 at 16
>>
> I do not understand how a netem patch could change something for this
> case ?
No, Anton Boyarshinov checked this commit, and the problem is not in it.
the bug had appearedbetween the last and the first release of the 3.13 
and 3.14 kernel.
