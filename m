From: Michal Soltys <soltys@ziu.info>
Subject: Re: [PATCH] net/sched/sch_hfsc.c: initialize parent's cl_cfmin properly
 in init_vf()
Date: Wed, 15 Sep 2010 23:42:57 +0200
Message-ID: <4C913DE1.6040401@ziu.info>
References: <cover.1283197803.git.soltys@ziu.info>	<8100ed4475ac7a301a3d69611e97d510ea498c5d.1283197803.git.soltys@ziu.info> <20100901.143038.170100274.davem@davemloft.net> <4C910869.1050800@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, denys@visp.net.lb,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:1088 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751961Ab0IOWN0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 18:13:26 -0400
In-Reply-To: <4C910869.1050800@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10-09-15 19:54, Patrick McHardy wrote:
> Am 01.09.2010 23:30, schrieb David Miller:
>>  From: Michal Soltys<soltys@ziu.info>
>>  Date: Mon, 30 Aug 2010 23:34:10 +0200
>>
>>>  This patch fixes init_vf() function, so on each new backlog period parent's
>>>  cl_cfmin is properly updated (including further propgation towards the root),
>>>  even if the activated leaf has no upperlimit curve defined.
>>>
>>>  Signed-off-by: Michal Soltys<soltys@ziu.info>
>>
>>  Applied, thanks.
>
> For the record, the patch seems fine to me. The root cause seems to be
> an optimization I introduced (pre-git, even history.git unfortunately)
> in vttree_get_minvt() that wasn't present in the original version:
>
> static struct hfsc_class *
> vttree_get_minvt(struct hfsc_class *cl, u64 cur_time)
> {
>          /* if root-class's cfmin is bigger than cur_time nothing to do */
>          if (cl->cl_cfmin>  cur_time)
>                  return NULL;
>
> I'd prefer to remove this check since it's obviously not correct and
> might cause other problems. Michal, could you please test whether this
> patch fixes the problem as well? Thanks!

Sure, will do. Although with a tad bit more complex scenario than from 
my cover email, I think there will still be problems. For example:

     A
    / \
   B   C(u2)
  / \
D   E(u1)

C and E are constantly backlogged, D becomes active. It will add itself 
to B's vt_tree, but won't update B's cl_cfmin (without my earlier fix). 
B is already active, its myf and cfmin didn't change, so neither did f. 
And so nothing will change for A either.

Now we try a dequeue. Without your old optimization (btw I think it's a 
good shortcut, if I didn't miss anything), A will choose min vt from B 
and C, if their f <= cur_time. B's f should be at this moment 0 (D has 
no upperlimit and became active), but it remained unchanged. So we have 
the same problem as previously. This would work with a trivial hierarchy 
though, such as:

     A
    / \
   B   C(u2)

But deeper scenarios seem problematic. Of course I'll do the actual 
tests to be sure.

A bit more constrained version from my patch (to limit update_cfmin() 
calls) could be:
                 f = max(cl->cl_myf, cl->cl_cfmin);
                 if (f != cl->cl_f) {
                         cl->cl_f = f;
                         cftree_update(cl);
                         update_cfmin(cl->cl_parent);
                 } else if (go_active)
                         update_cfmin(cl->cl_parent);

