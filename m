From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: [Bug 84661] New: tc filter show from iproute2 does not
 work correctly on 32bit x86
Date: Sat, 20 Sep 2014 09:50:30 -0700
Message-ID: <1411231830.26859.69.camel@edumazet-glaptop2.roam.corp.google.com>
References: <bug-84661-65011@https.bugzilla.kernel.org/>
	 <541D9F9B.9040404@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: yangyingliang@huawei.com, rider@altlinux.org,
	netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:35030 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752868AbaITQuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 12:50:32 -0400
Received: by mail-pd0-f172.google.com with SMTP id y10so1834156pdj.31
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 09:50:31 -0700 (PDT)
In-Reply-To: <541D9F9B.9040404@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-09-20 at 17:39 +0200, Daniel Borkmann wrote:
> [ Cc'ing Yang ]
> 
> -------- Original Message --------
> Subject: [Bug 84661] New: tc filter show from iproute2 does not work correctly on 32bit x86
> Date: Tue, 16 Sep 2014 11:47:20 +0000
> From: bugzilla-daemon@bugzilla.kernel.org
> To: dborkman@redhat.com
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=84661
> 
>              Bug ID: 84661
>             Summary: tc filter show from iproute2 does not work correctly
>                      on 32bit x86
>             Product: Networking
>             Version: 2.5
>      Kernel Version: 3.14.17 and 3.16.1
>            Hardware: All
>                  OS: Linux
>                Tree: Mainline
>              Status: NEW
>            Severity: normal
>            Priority: P1
>           Component: Other
>            Assignee: shemminger@linux-foundation.org
>            Reporter: rider@altlinux.org
>          Regression: No
> 
> i tested this issue with kernels 3.14.x and 3.16.x. and iproute2-3.16.0
> 
> This commit:
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?id=6a031f67c83aa175aedd10d4ae64750415ab57b0
> breaking output tc filter show on 32bit systems.
> 
> This simple script shows the difference in the work on i586 and x86_64:
> -------------------------
> #!/bin/sh
> dev=$1
> tc qdisc add dev $dev root handle 1: htb default fffe
> tc filter add dev $dev parent 1:0 protocol ip pref 10 u32
> tc filter add dev $dev parent 1:0 protocol ip pref 10 handle 100: u32 divisor 8
> tc filter add dev $dev parent 1:0 protocol ip pref 10 u32 ht 800:: match ip dst
> 10.21.10.0/21 hashkey mask 0x00000700 at 16 link 100:
> tc filter show dev $dev
> tc filter del dev $dev parent 1:0 protocol ip pref 10 u32 ht 800:: match ip dst
> 10.21.10.0/21 hashkey mask 0x00000700 at 16 link 100:
> tc qdisc del dev $dev root handle 1: htb default fffe
> ---------------------------
> 
> output on i586:
> 
> #./script enp0s25
> filter parent 1: protocol ip pref 10 u32
> filter parent 1: protocol ip pref 10 u32 fh 100: ht divisor 8
> filter parent 1: protocol ip pref 10 u32 fh 800: ht divisor 1
> 
> 
> output on x86_64:
> # ./script eth0
> filter parent 1: protocol ip pref 10 u32
> filter parent 1: protocol ip pref 10 u32 fh 100: ht divisor 8
> filter parent 1: protocol ip pref 10 u32 fh 800: ht divisor 1
> filter parent 1: protocol ip pref 10 u32 fh 800::800 order 2048 key ht 800 bkt
> 0 link 100:
>    match 0a150800/fffff800 at 16
>      hash mask 00000700 at 16
> 

I do not understand how a netem patch could change something for this
case ?
