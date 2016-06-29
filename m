From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net] bonding: fix 802.3ad aggregator reselection
Date: Wed, 29 Jun 2016 08:59:24 -0700
Message-ID: <20295.1467215964@famine>
References: <10542.1466716851@famine> <CAKdSkDVXe5jRgWU8WAvx43KvEuZvS4ak+a9qd9H4C3zy+OvkPQ@mail.gmail.com>
Cc: netdev <netdev@vger.kernel.org>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	zhuyj <zyjzyj2000@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:52590 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752782AbcF2P7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 11:59:31 -0400
In-reply-to: <CAKdSkDVXe5jRgWU8WAvx43KvEuZvS4ak+a9qd9H4C3zy+OvkPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:
[...]
>Thanks for the patch. I have been now testing it and the reselection
>seems to be working now in most cases, but I hit one case that seems
>to consistently fail in my test environment.
>
>I've been doing most of testing with ad_select=count and this happens
>with it. I haven't yet done extensive testing with
>ad_select=stable/bandwidth.
>
>The sequence to trigger the failure seems to be:
>
>  Switch A (Agg ID 2)       Switch B (Agg ID 1)
>enp5s0f0 ens5f0 ens6f0    enp5s0f1 ens5f1 ens6f1
>    X       X      -           X      -       -     Connection works
>(Agg ID 2 active)
>    X       -      -           X      -       -     Connection works
>(Agg ID 1 active)
>    X       -      -           -      -       -     No connection (Agg
>ID 2 active)

	I tried this locally, but don't see any failure (at the end, the
"Switch A" agg is still active with the single port).  I am starting
with just two ports in each aggregator (instead of three), so that may
be relevant.

	Can you enable dynamic debug for bonding and run your test
again, and then send me the debug output (this will appear in the kernel
log, e.g., from dmesg)?  You can enable this via

# echo 'module bonding =p' > /sys/kernel/debug/dynamic_debug/control

	before running the test.  The contents of
/proc/net/bonding/bond0 (read as root, otherwise the LACP internal state
isn't included) from each step would also be helpful.  The output will
likely be large, so I'd suggest sending it to me directly off-list if
it's too big.

>I'm also wondering why link down event causes change of aggregator
>when the active aggregator has the same number of active links than
>the new aggregator.

	This shouldn't happen.  If the active aggregator is just as good
as some other aggregator choice, it should stay with the current active.

	I suspect that both of these are edge cases arising from the
aggregators now including link down ports, which previously never
happened.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
