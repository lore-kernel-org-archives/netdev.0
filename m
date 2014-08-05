From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 80201] New: general protection fault: 0000 [#1] SMP
 (while using HTB)
Date: Tue, 05 Aug 2014 12:59:58 +0200
Message-ID: <1407236398.3178.79.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140714084733.0b4aeeef@haswell>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f182.google.com ([74.125.82.182]:49702 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754046AbaHELAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 07:00:05 -0400
Received: by mail-we0-f182.google.com with SMTP id k48so801326wev.13
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2014 04:00:01 -0700 (PDT)
In-Reply-To: <20140714084733.0b4aeeef@haswell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-07-14 at 08:47 -0700, Stephen Hemminger wrote:
> 
> Begin forwarded message:
> 
> Date: Mon, 14 Jul 2014 04:12:45 -0700
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "stephen@networkplumber.org" <stephen@networkplumber.org>
> Subject: [Bug 80201] New: general protection fault: 0000 [#1] SMP (while using HTB)
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=80201
> 
>             Bug ID: 80201
>            Summary: general protection fault: 0000 [#1] SMP (while using
>                     HTB)
>            Product: Networking
>            Version: 2.5
>     Kernel Version: Linux 3.10.41-1.el6.elrepo.x86_64
>           Hardware: x86-64
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: shemminger@linux-foundation.org
>           Reporter: cenek.zach@gmail.com
>         Regression: No
> 
> Created attachment 142971
>   --> https://bugzilla.kernel.org/attachment.cgi?id=142971&action=edit
> Kernel GPF stack trace
> 
> Encountered GPF under normal circumstances - no heavy load (CPU, IO, net). 
> 
> HTB configuration is very simple: 1 HTB class with SFQ qdisc and filter on
> source port 80:
> 
> tc qdisc add dev eth0 root handle 1: htb default 30
> tc class add dev eth0 parent 1: classid 1:1 htb rate $LIMIT burst 1500k cburst
> 1500k
> tc qdisc add dev eth0 parent 1:1 handle 10: sfq perturb 10
> tc filter add dev eth0 protocol ip parent 1:0 prio 1 u32 match ip sport 80
> 0xffff flowid 1:1
> 
> Relevant part of vmcore-dmesg.txt attached.
> 

Hmm... the bug seems to be triggered in SFQ, as 'perturb 10' uses a
timer.

When sfq_rehash() is called, root qdisc lock is properly held, but
sfq_reset() might be called without root qdisc lock being held, via 

htb_put() -> htb_destroy_class() -> qdisc_destroy()


race added in commit 225d9b89c937633dfeec502741a174fe0bab5b9f
("sch_sfq: rehash queues in perturb timer")

Not sure how to solve this.

A del_timer_sync() added in sfq_reset() might dead lock, and a
del_timer() wont be enough.
