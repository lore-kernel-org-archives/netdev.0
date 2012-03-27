From: Ben Greear <greearb@candelatech.com>
Subject: Re: RCU lock bug in 3.0.21 (bisected to: 682cb56a, fix NULL dereferences
 in check_peer_redir)
Date: Tue, 27 Mar 2012 09:47:38 -0700
Message-ID: <4F71EF2A.8020507@candelatech.com>
References: <4F70E308.7070908@candelatech.com>  <20120326.174945.1186427809261872546.davem@davemloft.net>  <4F70E560.3020102@candelatech.com>  <4F70F688.6050108@candelatech.com> <1332805148.3547.14.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52228 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181Ab2C0QxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 12:53:03 -0400
In-Reply-To: <1332805148.3547.14.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/2012 04:39 PM, Eric Dumazet wrote:
> On Mon, 2012-03-26 at 16:06 -0700, Ben Greear wrote:
>> On 03/26/2012 02:53 PM, Ben Greear wrote:
>>> On 03/26/2012 02:49 PM, David Miller wrote:
>>>>
>>>> Looks like all of those strange undiagnosable reported Dave Jones
>>>> has been feeding us. Something in one part of the kernel leaves
>>>> a lock held, and this shows up as a warning elsewhere.
>>>
>>> Every (initial) bug printout fingers ipv6 and the 'ip' tool on my system.
>>
>> I added a patch to convert rcu_read_lock/unlock to macros so
>> that I could automatically grab the call site (_THIS_IP_)
>> and pass it into the lockdep framework instead of the (useless)
>> _THIS_IP_ in the old rcu_read_lock method which at best seems to
>> only indicate which module the issue relates to...
>
> Hi Ben
>
> Is this problem also appears with current tree ?
> (This could be a problem with the backport, as it was full of
> dependencies)
>
> Also, if you use a patch to better track rcu_read_lock()/unlock(), you
> could add new macros as well to track that a particular unlock() matches
> one given lock(). (maybe returning the rcu_preempt_depth at
> rcu_read_lock() time , but maybe a more absolute ref would be better)
>
> So we could have a warning if an unlock() doesnt match the lock()
>
> inet6_dump_fib () was already a suspect but we could not find why.


Ok, I tried the patch below, and got the result farther down.  Is this
what you were thinking of?  (The lockdep warning about rcu lock still
held happened immediately after this..so it appears the depth mis-match
does represent this problem...


[greearb@fs3 linux-3.0.dev.y]$ git diff
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 0f9b37a..ae3c7c9 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -366,6 +366,7 @@ static int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
         struct hlist_node *node;
         struct hlist_head *head;
         int res = 0;
+       int depth = current->lockdep_depth;

         s_h = cb->args[0];
         s_e = cb->args[1];
@@ -410,6 +411,8 @@ next:
         }
  out:
         rcu_read_unlock();
+       WARN(depth != current->lockdep_depth, "depth: %i  lockdep-depth: %i\n",
+            depth, current->lockdep_depth);
         cb->args[1] = e;
         cb->args[0] = h;



------------[ cut here ]------------
WARNING: at /home/greearb/git/linux-3.0.dev.y/net/ipv6/ip6_fib.c:415 inet6_dump_fib+0x25c/0x292 [ipv6]()
Hardware name: To be filled by O.E.M.
depth: 1  lockdep-depth: 2
Modules linked in: 8021q garp stp llc fuse macvlan pktgen coretemp hwmon sunrpc ipv6 uinput arc4 ath9k snd_hda_codec_realtek mac80211 snd_hda_intel 
snd_hda_codec snd_hwdep snd_seq ath9k_common ath9k_hw snd_seq_device snd_pcm ath snd_timer e1000e cfg80211 snd mei(C) ppdev microcode i2c_i801 iTCO_wdt 
soundcore serio_raw pcspkr snd_page_alloc iTCO_vendor_support parport_pc parport i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
Pid: 6563, comm: ip Tainted: G         C  3.0.25+ #16
Call Trace:
  [<ffffffff81046866>] warn_slowpath_common+0x80/0x98
  [<ffffffff81046912>] warn_slowpath_fmt+0x41/0x43
  [<ffffffffa0251a3a>] inet6_dump_fib+0x25c/0x292 [ipv6]
  [<ffffffff813af450>] netlink_dump+0x5b/0x19b
  [<ffffffff81385da2>] ? consume_skb+0x28/0x2a
  [<ffffffff813af7bf>] netlink_recvmsg+0x1c7/0x2f8
  [<ffffffff8137c6cf>] __sock_recvmsg_nosec+0x65/0x6e
  [<ffffffff8137dde0>] __sock_recvmsg+0x49/0x54
  [<ffffffff8137e349>] sock_recvmsg+0xa6/0xbf
  [<ffffffff81072bf8>] ? lock_release_non_nested+0x9d/0x227
  [<ffffffff810ca002>] ? might_fault+0x4e/0x9e
  [<ffffffff810ca04b>] ? might_fault+0x97/0x9e
  [<ffffffff81387cae>] ? copy_from_user+0x2a/0x2c
  [<ffffffff810ca002>] ? might_fault+0x4e/0x9e
  [<ffffffff81388080>] ? verify_iovec+0x4f/0xa3
  [<ffffffff8137e0c4>] __sys_recvmsg+0x147/0x21e
  [<ffffffff81063868>] ? up_read+0x1e/0x36
  [<ffffffff810fc9fb>] ? fcheck_files+0xb7/0xee
  [<ffffffff810fcb30>] ? fget_light+0x3b/0xbc
  [<ffffffff8137e8a0>] sys_recvmsg+0x3d/0x5b
  [<ffffffff81450e92>] system_call_fastpath+0x16/0x1b
---[ end trace 5232c09c4fb31d15 ]---



-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
