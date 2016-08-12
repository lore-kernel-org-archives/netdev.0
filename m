From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH 2/2] net: sched: convert qdisc linked list to hashtable
Date: Fri, 12 Aug 2016 15:53:04 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1608121523020.22028@cbobk.fhfr.pm>
References: <alpine.LNX.2.00.1608101049260.22028@cbobk.fhfr.pm> <alpine.LNX.2.00.1608101054320.22028@cbobk.fhfr.pm> <57ADC6AA.5070506@iogearbox.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57ADC6AA.5070506@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 12 Aug 2016, Daniel Borkmann wrote:

> This results in below panic. Tested reverting this patch and it fixes
> the panic.
> 
> Did you test this also with ingress or clsact qdisc (just try adding
> it to lo dev for example) ?

Hi Daniel,

thanks for the report. Hmm, I am pretty sure clsact worked for me, but 
I'll recheck.

> What happens is the following in qdisc_match_from_root():
> 
> [  995.422187] XXX qdisc:ffff88025e4fc800 queue:ffff880262759000
> dev:ffff880261cc2000 handle:ffff0000
> [  995.422200] XXX qdisc:ffffffff81cf8100 queue:ffffffff81cf8240 dev:
> (null) handle:ffff0000
> 
> I believe this is due to dev_ingress_queue_create() assigning the
> global noop_qdisc instance as qdisc_sleeping, which later qdisc_lookup()
> uses for qdisc_match_from_root().
> 
> But everything that uses things like noop_qdisc cannot work with the
> new qdisc_match_from_root(), because qdisc_dev(root) will always trigger
> NULL pointer dereference there. Reason is because the dev is always
> NULL for noop, it's a singleton, see noop_qdisc and noop_netdev_queue
> in sch_generic.c.
> 
> Now how to fix it? Creating separate noop instances each time it's set
> would be quite a waste of memory. Even fuglier would be to hack a static
> net device struct into sch_generic.c and let noop_netdev_queue point there
> to get to the hash table. Or we just not use qdisc_dev().

How about we actually extend a little bit the TCQ_F_BUILTIN special case 
test in qdisc_match_from_root()?

After the change, the only way how qdisc_dev() could be NULL should be a 
TCQ_F_BUILTIN case, right?

I was thinking about something like the patch below (the reasong being 
that ->dev would be NULL only in cases of singletonish qdiscs) ... 
wouldn't that also fix the issue you're seeing? Have to think it through a 
little bit more ..


diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 25aada7..1c9faed 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -260,6 +260,9 @@ static struct Qdisc *qdisc_match_from_root(struct Qdisc *root, u32 handle)
 {
 	struct Qdisc *q;
 
+	if (!qdisc_dev(root))
+		return (root->handle == handle ? root : NULL);
+
 	if (!(root->flags & TCQ_F_BUILTIN) &&
 	    root->handle == handle)
 		return root;


Thanks!

-- 
Jiri Kosina
SUSE Labs
