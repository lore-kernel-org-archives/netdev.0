From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next v2 2/4] cgroup: bpf: Add
 BPF_MAP_TYPE_CGROUP_ARRAY
Date: Thu, 23 Jun 2016 14:26:16 -0700
Message-ID: <20160623212616.GA90834@kafai-mba.DHCP.thefacebook.com>
References: <1466630252-3822277-1-git-send-email-kafai@fb.com>
 <1466630252-3822277-3-git-send-email-kafai@fb.com>
 <576BAF07.4020302@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <cgroups@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
	Tejun Heo <tj@kernel.org>, <kernel-team@fb.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:54975 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752352AbcFWV0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 17:26:35 -0400
Content-Disposition: inline
In-Reply-To: <576BAF07.4020302@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 23, 2016 at 11:42:31AM +0200, Daniel Borkmann wrote:
> Hi Martin,
>
> [ sorry to jump late in here, on pto currently ]
Thanks for reviewing.

> Could you describe a bit more with regards to pinning maps and how this
> should interact with cgroups? The two specialized array maps we have (tail
> calls, perf events) have fairly complicated semantics for when to clean up
> map slots (see commits c9da161c6517ba1, 3b1efb196eee45b2f0c4).
>
> How is this managed with cgroups? Once a cgroup fd is placed into a map and
> the user removes the cgroup, will this be prevented due to 'being busy', or
> will the cgroup live further as long as a program is running with a cgroup
> map entry (but the cgroup itself is not visible from user space in any way
> anymore)?
Having a cgroup ptr stored in the bpf_map will not stop the user from
removing the cgroup (by rmdir /mnt/cgroup2/tc/test_cgrp).

The cgroup ptr stored in the bpf_map holds a refcnt which answer the
second part.

The situation is similar to the netfilter usecase in
commit 38c4597e4bf ("netfilter: implement xt_cgroup cgroup2 path match")

>
> I presume it's a valid use case to pin a cgroup map, put fds into it and
> remove the pinned file expecting to continue to match on it, right? So
> lifetime is really until last prog using a cgroup map somewhere gets removed
> (even if not accessible from user space anymore, meaning no prog has fd and
> pinned file was removed).
Yes.

We are still hatching out how to set this up in production. However, the
situation is similar to removing the pinned file.
We probably will not use tc and pin a bpf_map to do that.  Instead,
one process will setup eveything (e.g. create the cgroup, pouplate the
cgroup map, load the bpf to egress) and then go away.

I don't think we need a prog fd to remove the bpf prog.

>
> I assume that using struct file here doesn't make sense (commit e03e7ee34fdd1c3)
> either, right?
No. I don't think so. We eventually need a cgroup from the 'struct file'.
