From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH v2 -stable] Re: rib_trie / Fix inflate_threshold_root.
	Now=15 size=11 bits
Date: Sun, 5 Jul 2009 15:08:28 +0200
Message-ID: <20090705130828.GB3094@ami.dom.local>
References: <20090701063651.GA4876@ff.dom.local> <20090701072409.GA12592@ff.dom.local> <4A4B2FA8.3040007@itcare.pl> <20090701101333.GB12715@ff.dom.local> <20090701110407.GC12715@ff.dom.local> <4A4BE06F.3090608@itcare.pl> <20090702053216.GA4954@ff.dom.local> <4A4C48FD.7040002@itcare.pl> <20090702060011.GB4954@ff.dom.local> <4A4FF34E.7080001@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <robert@robur.slu.se>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:53534 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753478AbZGENIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 09:08:48 -0400
Received: by bwz25 with SMTP id 25so400653bwz.37
        for <netdev@vger.kernel.org>; Sun, 05 Jul 2009 06:08:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A4FF34E.7080001@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Take 2: Changelog spelling fixes, sorry.)

David & Robert,
below are my recommendations for -stable plus one more patch:

On Sun, Jul 05, 2009 at 02:26:54AM +0200, Pawe=B3 Staszewski wrote:
=2E..
>>>>> Jarek Poplawski pisze:
=2E..
>>>>>> So, after your findings I'm about to recommend sending to -stabl=
e
>>>>>> 3 patches from net-2.6, with additional lowering of threshold_ro=
ot
>>>>>> settings, but it would be nice if you could give it a try with
>>>>>> CONFIG_PREEMPT instead of CONFIG_PREEMPT_NONE (if it doesn't bre=
ak
>>>>>> your other apps!) It is expected to work this time...;-) Maybe a
>>>>>> bit slower.
>>>>>>
>>>>>>  =20
> Ok kernel configured with CONFIG_PREEMPT
> and all this day work without any problems (with Jarek last patch).
>
>
> So in attached file trere is fib_tirestats
> I dont see any big change of (cpu load or faster/slower =20
> routing/propagating routes from bgpd or something else) - in avg ther=
e =20
> is from 2% to 3% more of CPU load i dont know why but it is - i chang=
e
> from "preempt" to "no preempt" 3 times and check this my "mpstat -P A=
LL =20
> 1 30"
> always avg cpu load was from 2 to 3% more compared to "no preempt"
>
> Regards
> Pawe=B3 Staszewski

So after these patches from net-2.6 are tested both for PREEMPT and
PREEMPT_NONE I think they should go to -stable:

2.6.30 needs:
-------------

commit e0f7cb8c8cc6cccce28d2ce39ad8c60d23c3799f
Author: Jarek Poplawski <jarkao2@gmail.com>
Date:   Mon Jun 15 02:31:29 2009 -0700

    ipv4: Fix fib_trie rebalancing

commit 7b85576d15bf2574b0a451108f59f9ad4170dd3f
Author: Jarek Poplawski <jarkao2@gmail.com>
Date:   Thu Jun 18 00:28:51 2009 -0700

    ipv4: Fix fib_trie rebalancing, part 2

commit 008440e3ad4b72f5048d1b1f6f5ed894fdc5ad08
Author: Jarek Poplawski <jarkao2@gmail.com>
Date:   Tue Jun 30 12:47:19 2009 -0700

    ipv4: Fix fib_trie rebalancing, part 3

plus the new patch below

    ipv4: Fix fib_trie rebalancing, part 4 (root thresholds)

2.6.29 needs:
-------------

this patch from 2.6.30:
commit 3ed18d76d959e5cbfa5d70c8f7ba95476582a556
Author: Robert Olsson <robert.olsson@its.uu.se>
Date:   Thu May 21 15:20:59 2009 -0700

    ipv4: Fix oops with FIB_TRIE

plus above mentionned patches for 2.6.30 (part 1 - 4)

-----------------

David, if possible, please add to all these "Fix... part 1 - 4":

Tested-by: Pawel Staszewski <pstaszewski@itcare.pl>

This new patch below is intended only for -stable (and later for
net-next), because it doesn't meet rules of the current -rc. Anyway,
it's not critical (but it actually fixes a regression from 2.6.22).

Thanks,
Jarek P.
---------------->
ipv4: Fix fib_trie rebalancing, part 4 (root thresholds)

Pawel Staszewski wrote:
<blockquote>
Some time ago i report this:
http://bugzilla.kernel.org/show_bug.cgi?id=3D6648

and now with 2.6.29 / 2.6.29.1 / 2.6.29.3 and 2.6.30 it back
dmesg output:
oprofile: using NMI interrupt.
=46ix inflate_threshold_root. Now=3D15 size=3D11 bits
=2E..
=46ix inflate_threshold_root. Now=3D15 size=3D11 bits

cat /proc/net/fib_triestat
Basic info: size of leaf: 40 bytes, size of tnode: 56 bytes.
Main:
        Aver depth:     2.28
        Max depth:      6
        Leaves:         276539
        Prefixes:       289922
        Internal nodes: 66762
          1: 35046  2: 13824  3: 9508  4: 4897  5: 2331  6: 1149  7: 5 =
=20
9: 1  18: 1
        Pointers: 691228
Null ptrs: 347928
Total size: 35709  kB
</blockquote>

It seems, the current threshold for root resizing is too aggressive,
and it causes misleading warnings during big updates, but it might be
also responsible for memory problems, especially with non-preempt
configs, when RCU freeing is delayed long after call_rcu.

It should be also mentioned that because of non-atomic changes during
resizing/rebalancing the current lookup algorithm can miss valid leaves
so it's additional argument to shorten these activities even at a cost
of a minimally longer searching.

This patch restores values before the patch "[IPV4]: fib_trie root
node settings", commit: 965ffea43d4ebe8cd7b9fee78d651268dd7d23c5 from
v2.6.22.

Pawel's report:
<blockquote>
I dont see any big change of (cpu load or faster/slower=20
routing/propagating routes from bgpd or something else) - in avg there=20
is from 2% to 3% more of CPU load i dont know why but it is - i change
from "preempt" to "no preempt" 3 times and check this my "mpstat -P ALL=
=20
1 30"
always avg cpu load was from 2 to 3% more compared to "no preempt"
[...]
cat /proc/net/fib_triestat
Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
Main:
        Aver depth:     2.44
        Max depth:      6
        Leaves:         277814
        Prefixes:       291306
        Internal nodes: 66420
          1: 32737  2: 14850  3: 10332  4: 4871  5: 2313  6: 942  7: 37=
1  8: 3  17: 1
        Pointers: 599098
Null ptrs: 254865
Total size: 18067  kB
</blockquote>

According to this and other similar reports average depth is slightly
increased (~0.2), and root nodes are shorter (log 17 vs. 18), but
there is no visible performance decrease. So, until memory handling is
improved or added parameters for changing this individually, this
patch resets to safer defaults.

Reported-by: Pawel Staszewski <pstaszewski@itcare.pl>
Reported-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Tested-by: Pawel Staszewski <pstaszewski@itcare.pl>
---

 net/ipv4/fib_trie.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 00a54b2..63c2fa7 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -316,8 +316,8 @@ static inline void check_tnode(const struct tnode *=
tn)
=20
 static const int halve_threshold =3D 25;
 static const int inflate_threshold =3D 50;
-static const int halve_threshold_root =3D 8;
-static const int inflate_threshold_root =3D 15;
+static const int halve_threshold_root =3D 15;
+static const int inflate_threshold_root =3D 25;
=20
=20
 static void __alias_free_mem(struct rcu_head *head)
