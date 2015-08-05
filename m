From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: rtnl_mutex deadlock?
Date: Wed, 05 Aug 2015 20:59:07 +0200
Message-ID: <55C25CFB.2060103@iogearbox.net>
References: <CA+55aFwYhdHdLUbYYAc9GgmFuVXniwAESYHuzDWjdapPC0m1Xw@mail.gmail.com>	<CAHA+R7N2fRz2zr-6MX9StqPLdNAWRiG55xidrC7reSRrVeQPcQ@mail.gmail.com>	<20150805074330.GA2084@nanopsycho.orion> <CA+55aFw1856zEq88RfqoizjeVRR9Ut-ug+VWA+mKFOS77FYpSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>,
	Network Development <netdev@vger.kernel.org>,
	herbert@gondor.apana.org.au
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58038 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471AbbHES7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 14:59:17 -0400
In-Reply-To: <CA+55aFw1856zEq88RfqoizjeVRR9Ut-ug+VWA+mKFOS77FYpSg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/05/2015 10:44 AM, Linus Torvalds wrote:
> On Wed, Aug 5, 2015 at 9:43 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>
>> Indeed. Most probably, NETLINK_CB(skb).portid got zeroed.
>>
>> Linus, are you able to reproduce this or is it a one-time issue?
>
> I don't think I'm able to reproduce this, it's happened only once so far.

Here's a theory and patch below. Herbert, Thomas, does this make any
sense to you resp. sound plausible? ;)

I'm not quite sure what's best to return from here, i.e. whether we
propagate -ENOMEM or instead retry over and over again hoping that the
rehashing completed (and no new rehashing started in the mean time) ...

The rehashing could take quite some time on large hashtables and given
we can also fail with -ENOMEM from rhashtable_insert_rehash() when we
cannot allocate a bucket table, it's probably okay to go with -ENOMEM?


[PATCH net] netlink, rhashtable: fix deadlock when grabbing rtnl_mutex

Linus reports the following deadlock on rtnl_mutex; triggered only
once so far:

[12236.694209] NetworkManager  D 0000000000013b80     0  1047      1 0x00000000
[12236.694218]  ffff88003f902640 0000000000000000 ffffffff815d15a9 0000000000000018
[12236.694224]  ffff880119538000 ffff88003f902640 ffffffff81a8ff84 00000000ffffffff
[12236.694230]  ffffffff81a8ff88 ffff880119c47f00 ffffffff815d133a ffffffff81a8ff80
[12236.694235] Call Trace:
[12236.694250]  [<ffffffff815d15a9>] ? schedule_preempt_disabled+0x9/0x10
[12236.694257]  [<ffffffff815d133a>] ? schedule+0x2a/0x70
[12236.694263]  [<ffffffff815d15a9>] ? schedule_preempt_disabled+0x9/0x10
[12236.694271]  [<ffffffff815d2c3f>] ? __mutex_lock_slowpath+0x7f/0xf0
[12236.694280]  [<ffffffff815d2cc6>] ? mutex_lock+0x16/0x30
[12236.694291]  [<ffffffff814f1f90>] ? rtnetlink_rcv+0x10/0x30
[12236.694299]  [<ffffffff8150ce3b>] ? netlink_unicast+0xfb/0x180
[12236.694309]  [<ffffffff814f5ad3>] ? rtnl_getlink+0x113/0x190
[12236.694319]  [<ffffffff814f202a>] ? rtnetlink_rcv_msg+0x7a/0x210
[12236.694331]  [<ffffffff8124565c>] ? sock_has_perm+0x5c/0x70
[12236.694339]  [<ffffffff814f1fb0>] ? rtnetlink_rcv+0x30/0x30
[12236.694346]  [<ffffffff8150d62c>] ? netlink_rcv_skb+0x9c/0xc0
[12236.694354]  [<ffffffff814f1f9f>] ? rtnetlink_rcv+0x1f/0x30
[12236.694360]  [<ffffffff8150ce3b>] ? netlink_unicast+0xfb/0x180
[12236.694367]  [<ffffffff8150d344>] ? netlink_sendmsg+0x484/0x5d0
[12236.694376]  [<ffffffff810a236f>] ? __wake_up+0x2f/0x50
[12236.694387]  [<ffffffff814cad23>] ? sock_sendmsg+0x33/0x40
[12236.694396]  [<ffffffff814cb05e>] ? ___sys_sendmsg+0x22e/0x240
[12236.694405]  [<ffffffff814cab75>] ? ___sys_recvmsg+0x135/0x1a0
[12236.694415]  [<ffffffff811a9d12>] ? eventfd_write+0x82/0x210
[12236.694423]  [<ffffffff811a0f9e>] ? fsnotify+0x32e/0x4c0
[12236.694429]  [<ffffffff8108cb70>] ? wake_up_q+0x60/0x60
[12236.694434]  [<ffffffff814cba09>] ? __sys_sendmsg+0x39/0x70
[12236.694440]  [<ffffffff815d4797>] ? entry_SYSCALL_64_fastpath+0x12/0x6a

It seems so far plausible that the recursive call into rtnetlink_rcv()
looks suspicious. One way, where this could trigger is that the senders
NETLINK_CB(skb).portid was wrongly 0 (which is rtnetlink socket), so the
rtnl_getlink() request's answer would be sent to the kernel instead to
the actual user process, thus grabbing rtnl_mutex() twice.

One theory how we could end up with a NETLINK_CB(skb).portid of 0 on a
user space process is, when we start out from netlink_sendmsg() with an
unbound portid, so that we need to do netlink_autobind().

Here, we would need to have an error of 0 returned, so that we can
continue with sending the frame and setting NETLINK_CB(skb).portid to 0
eventually. I.e. in netlink_autobind(), we need to return with -EBUSY
from netlink_insert(), so that the error code gets overwritten with 0.

In order to get to this point, the inner __netlink_insert() must return
with -EBUSY so that we reset the socket's portid to 0, and violate the 2nd
rule documented in d470e3b483dc ("[NETLINK]: Fix two socket hashing bugs."),
where it seemed to be a very similar issue that got fixed.

There's one possibility where the rhashtable backend could in-fact return
with -EBUSY. The insert is done via rhashtable_lookup_insert_key(), which
invokes __rhashtable_insert_fast(). From here, we need to trigger the
slow path with rhashtable_insert_rehash(), which can return -EBUSY in
case a rehash of the hashtable is currently already in progress.

This error propagates back to __netlink_insert() and provides us the
needed precondition. Looks like the -EBUSY was introduced first in
ccd57b1bd324 ("rhashtable: Add immediate rehash during insertion"). So,
as -EBUSY must not escape from there, we would need to remap it to a
different error code for user space. As the current rhashtable cannot
take any inserts in that case, it could be mapped to -ENOMEM.

Fixes: ccd57b1bd324 ("rhashtable: Add immediate rehash during insertion")
Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
  net/netlink/af_netlink.c | 5 +++++
  1 file changed, 5 insertions(+)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index d8e2e39..1cfd4af 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1096,6 +1096,11 @@ static int netlink_insert(struct sock *sk, u32 portid)

  	err = __netlink_insert(table, sk);
  	if (err) {
+		/* Currently, a rehashing of rhashtable might be in progress,
+		 * we however must not allow -EBUSY to escape from here.
+		 */
+		if (err == -EBUSY)
+			err = -ENOMEM;
  		if (err == -EEXIST)
  			err = -EADDRINUSE;
  		nlk_sk(sk)->portid = 0;
-- 
1.9.3
