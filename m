From: David Ahern <dsahern@gmail.com>
Subject: Re: Repeatable inet6_dump_fib crash in stock 4.12.0-rc4+
Date: Sun, 25 Jun 2017 15:59:04 -0600
Message-ID: <b7dfa73c-49bf-5f29-bf20-655c5b344208@gmail.com>
References: <94bcc041-6402-d0ce-b9cf-3b46aa622f34@candelatech.com>
 <CAM_iQpXM3G=J0tw=n1_mKno=i41Kmoxb00+nDyBWofWskj5P_A@mail.gmail.com>
 <7e0c97fa-cd6e-ed0f-bf99-0e4af40fbd2f@gmail.com>
 <1497043557.736.94.camel@edumazet-glaptop3.roam.corp.google.com>
 <9cb61ef0-37c0-8f35-bb5c-e3d8e63cbe2f@candelatech.com>
 <CAM_iQpV8u=aqn-AjeRw8CKQ=0Q6_gBvCCaYi2v3pJbYNL2WhJw@mail.gmail.com>
 <3230b360-528b-0ae0-8731-7906e57ee993@gmail.com>
 <4b65e262-e727-010a-ce1f-eb45fcef8e42@candelatech.com>
 <8630b942-2684-2f21-fdb9-8474aba71528@gmail.com>
 <09a00004-da54-dc8f-5806-9576bbf577c7@candelatech.com>
 <20170620180515.GB6104@unicorn.suse.cz>
 <46695455-c476-fa5c-f272-b8864898dd28@candelatech.com>
 <e026e624-fd52-9a3d-c7c4-e30d82a34520@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------0964E8B94CFFB3D7BF50EF59"
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>,
        Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36458 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751349AbdFYWNv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2017 18:13:51 -0400
Received: by mail-pf0-f181.google.com with SMTP id q86so46376469pfl.3
        for <netdev@vger.kernel.org>; Sun, 25 Jun 2017 15:13:51 -0700 (PDT)
In-Reply-To: <e026e624-fd52-9a3d-c7c4-e30d82a34520@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------0964E8B94CFFB3D7BF50EF59
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit

On 6/20/17 9:03 PM, David Ahern wrote:
> On 6/20/17 5:41 PM, Ben Greear wrote:
>> On 06/20/2017 11:05 AM, Michal Kubecek wrote:
>>> On Tue, Jun 20, 2017 at 07:12:27AM -0700, Ben Greear wrote:
>>>> On 06/14/2017 03:25 PM, David Ahern wrote:
>>>>> On 6/14/17 4:23 PM, Ben Greear wrote:
>>>>>> On 06/13/2017 07:27 PM, David Ahern wrote:
>>>>>>
>>>>>>> Let's try a targeted debug patch. See attached
>>>>>>
>>>>>> I had to change it to pr_err so it would go to our serial console
>>>>>> since the system locked hard on crash,
>>>>>> and that appears to be enough to change the timing where we can no
>>>>>> longer
>>>>>> reproduce the problem.
>>>>>
>>>>>
>>>>> ok, let's figure out which one is doing that. There are 3 debug
>>>>> statements. I suspect fib6_del_route is the one setting the state to
>>>>> FWS_U. Can you remove the debug prints in fib6_repair_tree and
>>>>> fib6_walk_continue and try again?
>>>>
>>>> We cannot reproduce with just that one printf in the kernel either.  It
>>>> must change the timing too much to trigger the bug.
>>>
>>> You might try trace_printk() which should have less impact (don't forget
>>> to enable /proc/sys/kernel/ftrace_dump_on_oops).
>>
>> We cannot reproduce with trace_printk() either.
> 
> I think that suggests the walker state is set to FWS_U in
> fib6_del_route, and it is the FWS_U case in fib6_walk_continue that
> triggers the fault -- the null parent (pn = fn->parent). So we have the
> 2 areas of code that are interacting.
> 
> I'm on a road trip through the end of this week with little time to
> focus on this problem. I'll get back to you another suggestion when I can.
> 

Remove all other changes and try the attached. The fault should not
happen so you need to watch dmesg / console output.

--------------0964E8B94CFFB3D7BF50EF59
Content-Type: text/plain; charset=UTF-8; x-mac-type="0"; x-mac-creator="0";
 name="ip6-walker-panic.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="ip6-walker-panic.patch"

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index deea901746c8..245941e9db8a 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -372,12 +372,13 @@ static int fib6_dump_table(struct fib6_table *table, struct sk_buff *skb,
 
 		read_lock_bh(&table->tb6_lock);
 		res = fib6_walk(net, w);
-		read_unlock_bh(&table->tb6_lock);
 		if (res > 0) {
 			cb->args[4] = 1;
 			cb->args[5] = w->root->fn_sernum;
 		}
+		read_unlock_bh(&table->tb6_lock);
 	} else {
+		read_lock_bh(&table->tb6_lock);
 		if (cb->args[5] != w->root->fn_sernum) {
 			/* Begin at the root if the tree changed */
 			cb->args[5] = w->root->fn_sernum;
@@ -387,7 +388,6 @@ static int fib6_dump_table(struct fib6_table *table, struct sk_buff *skb,
 		} else
 			w->skip = 0;
 
-		read_lock_bh(&table->tb6_lock);
 		res = fib6_walk_continue(w);
 		read_unlock_bh(&table->tb6_lock);
 		if (res <= 0) {
@@ -1422,7 +1422,6 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
 
 	/* Unlink it */
 	*rtp = rt->dst.rt6_next;
-	rt->rt6i_node = NULL;
 	net->ipv6.rt6_stats->fib_rt_entries--;
 	net->ipv6.rt6_stats->fib_discarded_routes++;
 
@@ -1447,12 +1446,24 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
 		if (w->state == FWS_C && w->leaf == rt) {
 			RT6_TRACE("walker %p adjusted by delroute\n", w);
 			w->leaf = rt->dst.rt6_next;
-			if (!w->leaf)
-				w->state = FWS_U;
+			if (!w->leaf) {
+				if (!w->node->parent) {
+pr_warn("fib6_del_route: setting walker node to null while deleting route: "
+	"dst %pI6c/%d src %pI6c/%d dev %s siblings %d\n",
+	&rt->rt6i_dst.addr, rt->rt6i_dst.plen, &rt->rt6i_src.addr, rt->rt6i_src.plen,
+	rt->dst.dev ? rt->dst.dev->name : "<not set>", rt->rt6i_nsiblings);
+
+if (rt->rt6i_node == w->node)
+	pr_warn("fib6_del_route: walker node matches deleted route\n");
+					w->node = NULL;
+				} else
+					w->state = FWS_U;
+			}
 		}
 	}
 	read_unlock(&net->ipv6.fib6_walker_lock);
 
+	rt->rt6i_node = NULL;
 	rt->dst.rt6_next = NULL;
 
 	/* If it was last route, expunge its radix tree node */

--------------0964E8B94CFFB3D7BF50EF59--
