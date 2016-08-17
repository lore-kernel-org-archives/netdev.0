From: Tejun Heo <htejun@fb.com>
Subject: Re: [RFC PATCH 3/5] bpf: add BPF_PROG_ATTACH and BPF_PROG_DETACH
 commands
Date: Wed, 17 Aug 2016 11:06:47 -0400
Message-ID: <20160817150646.GB6299@htj.duckdns.org>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
 <1471442448-1248-4-git-send-email-daniel@zonque.org>
 <20160817142047.GB4021@htj.duckdns.org>
 <95e8b773-416f-72cc-4045-dd10d94e6484@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <daniel@iogearbox.net>, <ast@fb.com>, <davem@davemloft.net>,
	<kafai@fb.com>, <fw@strlen.de>, <pablo@netfilter.org>,
	<harald@redhat.com>, <netdev@vger.kernel.org>
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:38071 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750764AbcHQPHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 11:07:21 -0400
Content-Disposition: inline
In-Reply-To: <95e8b773-416f-72cc-4045-dd10d94e6484@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, Aug 17, 2016 at 04:35:24PM +0200, Daniel Mack wrote:
> > Wouldn't it make sense to update the descendants to point to the
> > programs directly so that there's no need to traverse the tree on each
> > packet?  It's more state to maintain but I think it would make total
> > sense given that it would reduce per-packet cost.
> 
> The idea is to only look at the actual v2 cgroup a task is in, and not
> traverse in any way, to keep the per-packet cost at a minimum. That of
> course means that in a deeper level of the hierarchy, the programs are
> no longer executed and need to be reinstalled after a new cgroup is
> created. To bring this more in line with how cgroups usually work, I
> guess we should add code to copy over the bpf programs from the ancestor
> once a new cgroup is instantiated.

So, yeah, just executing the program from the exact cgroup wouldn't
work because it'd be easy for a delegatee to escape enforced policies
by simply creating subcgroups.

What I'd suggest is keeping two sets of pointers, one set for the
programs explicitly attached to the cgroup and the other for programs
which are to be executed for the cgroup.  The two pointers in the
latter set will point to the closest non-null program in its ancestry.
Note that the pointers may point to programs belonging to different
ancestors.

	A - B - C
              \ D - E

Let's say B has both ingress and egress programs and D only has
egress.  E's execution pointers should point to D's egress program and
B's ingress program.

The pointers would need to be updated

1. When a program is installed or removed.  For simplicity's sake, we
   can just walk the whole hierarchy.  If that's too expensive
   (shouldn't be), we can find out the closest ancestor where both
   programs can be determined and then walk from there.

2. When a new cgroup is created, it should inherit its execution table
   from its parent.

Thanks.

-- 
tejun
