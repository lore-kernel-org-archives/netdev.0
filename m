From: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Subject: Re: [PATCH net] bonding: fix 802.3ad aggregator reselection
Date: Thu, 30 Jun 2016 14:15:19 +0300
Message-ID: <CAKdSkDXprDpOUbKqw7+sqAj8LZ2tGC17YONmX0D1oLLUnCvRYw@mail.gmail.com>
References: <10542.1466716851@famine> <CAKdSkDVXe5jRgWU8WAvx43KvEuZvS4ak+a9qd9H4C3zy+OvkPQ@mail.gmail.com>
 <20295.1467215964@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	zhuyj <zyjzyj2000@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:33301 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929AbcF3LP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 07:15:26 -0400
Received: by mail-oi0-f45.google.com with SMTP id u201so59802804oie.0
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 04:15:21 -0700 (PDT)
In-Reply-To: <20295.1467215964@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-06-29 18:59 GMT+03:00 Jay Vosburgh <jay.vosburgh@canonical.com>:
> Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:
> [...]
>>Thanks for the patch. I have been now testing it and the reselection
>>seems to be working now in most cases, but I hit one case that seems
>>to consistently fail in my test environment.
>>
>>I've been doing most of testing with ad_select=count and this happens
>>with it. I haven't yet done extensive testing with
>>ad_select=stable/bandwidth.
>>
>>The sequence to trigger the failure seems to be:
>>
>>  Switch A (Agg ID 2)       Switch B (Agg ID 1)
>>enp5s0f0 ens5f0 ens6f0    enp5s0f1 ens5f1 ens6f1
>>    X       X      -           X      -       -     Connection works
>>(Agg ID 2 active)
>>    X       -      -           X      -       -     Connection works
>>(Agg ID 1 active)
>>    X       -      -           -      -       -     No connection (Agg
>>ID 2 active)
>
>         I tried this locally, but don't see any failure (at the end, the
> "Switch A" agg is still active with the single port).  I am starting
> with just two ports in each aggregator (instead of three), so that may
> be relevant.

When the connection problem occurs, /proc/net/bonding/bond0 always
shows the aggregator that has a link up active. Dumpcap sees at least
broadcast traffic on the port, but I haven't done extensive analysis
on that yet. All TCP connections are cut until the bond is up again
when more ports are enabled on the switch. ping doesn't work either
way.

If I start with only one link enabled on both switches or disable all
active links at once, this problem does not occur.


>         Can you enable dynamic debug for bonding and run your test
> again, and then send me the debug output (this will appear in the kernel
> log, e.g., from dmesg)?  You can enable this via
>
> # echo 'module bonding =p' > /sys/kernel/debug/dynamic_debug/control
>
>         before running the test.  The contents of
> /proc/net/bonding/bond0 (read as root, otherwise the LACP internal state
> isn't included) from each step would also be helpful.  The output will
> likely be large, so I'd suggest sending it to me directly off-list if
> it's too big.

lacp_rate=0 (slow) is used on these tests, but using lacp_rate=1
(fast) does not seem to change the behaviour. This time testing was
done with ad_select=bandwidth, so the same problem affects at least
count/bandwidth.

Here's an overview of the steps done:

  Switch A (Agg ID 2)       Switch B (Agg ID 1)
enp5s0f0 ens5f0 ens6f0    enp5s0f1 ens5f1 ens6f1
    X       X      X           X      X       X     Ok (Agg ID 2
active) - step1.txt
    X       -      -           X      X       X     Ok (Agg ID 1
active) - step2.txt
    X       -      -           X      X       -     Ok (Agg ID 1
active) - step3.txt
    X       -      -           X      -       -     Ok (Agg ID 1
active) - step4.txt
    X       -      -           -      -       -     Connection not
working (Agg ID 2 active) - step5.txt
    X       X      -           -      -       -     Ok (Agg ID 2
active) - step6.txt
    X       X      -           X      X       -     Ok (Agg ID 2
active) - step7.txt

The files are quite big, so uploaded them here:

step1: https://gist.github.com/vmlintu/195e372428ec654b4aa49f51cbe27b14
step2: https://gist.github.com/vmlintu/3f98fe68e52945c189dfeb59cf302fac
step3: https://gist.github.com/vmlintu/bb9757f3e1368593da9cded035275b1d
step4: https://gist.github.com/vmlintu/f3ed76294fb4360695e155da33f1ac04
step5: https://gist.github.com/vmlintu/a2b5a192065927c7cfd09ce547e1f240
step6: https://gist.github.com/vmlintu/650604d5a6992dc057e6d832b5c8cb4f
step7: https://gist.github.com/vmlintu/885f3e8b70873a6d02d2b732829564cc
debug.log: https://gist.github.com/vmlintu/030f2bcf4618344ec8724fdf41aef6d0

The step?.txt files have the contents of /proc/net/bonding/bond0 when
the switch ports match the configuration.


>>I'm also wondering why link down event causes change of aggregator
>>when the active aggregator has the same number of active links than
>>the new aggregator.
>
>         This shouldn't happen.  If the active aggregator is just as good
> as some other aggregator choice, it should stay with the current active.
>
>         I suspect that both of these are edge cases arising from the
> aggregators now including link down ports, which previously never
> happened.

This is something I didn't see in this test. This time I did a reboot
before testing, which might cause change in behaviour. I try to find
the steps required for this to happen.

Veli-Matti
