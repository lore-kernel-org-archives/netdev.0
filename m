From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Wed, 21 Oct 2015 20:34:47 +0200
Message-ID: <20151021183447.GC23554@pox.localdomain>
References: <1445280385.602530.414418777.63627F89@webmail.messagingengine.com>
 <562545AA.2080207@plumgrid.com>
 <1445284997.621186.414538017.6E35B341@webmail.messagingengine.com>
 <56255714.2070800@plumgrid.com>
 <56256BF9.1090500@iogearbox.net>
 <56258B11.9080505@plumgrid.com>
 <5625FF71.8020304@iogearbox.net>
 <56267FAF.60206@plumgrid.com>
 <87io61fjx3.fsf@x220.int.ebiederm.org>
 <5627AC79.5000704@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net, viro@ZenIV.linux.org.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:34494 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753232AbbJUSev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 14:34:51 -0400
Received: by wikq8 with SMTP id q8so106703223wik.1
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 11:34:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5627AC79.5000704@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/21/15 at 05:17pm, Daniel Borkmann wrote:
> On 10/20/2015 08:56 PM, Eric W. Biederman wrote:
> ...
> >Just FYI:  Using a device for this kind of interface is pretty
> >much a non-starter as that quickly gets you into situations where
> >things do not work in containers.  If someone gets a version of device
> >namespaces past GregKH it might be up for discussion to use character
> >devices.
> 
> Okay, you are referring to this discussion here:
> 
>   http://thread.gmane.org/gmane.linux.kernel.containers/26760
> 
> What had been mentioned earlier in this thread was to have a namespace
> pass-through facility enforced by device cgroups we have in the kernel,
> which is one out of various means used to enforce policy today by
> deployment systems such as docker, for example. But more below.
> 
> I think this all depends on the kind of expectations we have, where all
> this is going. In the original proposal, it was agreed to have the
> operation that creates a node as 'capable(CAP_SYS_ADMIN)'-only (in the
> way like most of the rest of eBPF is restricted), and based on the use
> case we distribute such objects to unprivileged applications. But I
> understand that it seems the trend lately to lift eBPF restrictions at
> some point anyway, and thus the CAP_SYS_ADMIN is suddenly irrelevant
> again. Fair enough.
> 
> Don't get me wrong, I really don't mind if it will be some version of
> this fs patch or whatever architecture else we find consensus on, I
> think this discussion is merely trying to evaluate/discuss on what seems
> to be a good fit, also in terms of future requirements and integration.
> 
> So far, during this discussion, it was proposed to modify the file system
> to a single-mount one and to stick this under /sys/kernel/bpf/. This
> will not have "real" namespace support either, but it was proposed to
> have a following structure:
> 
>   /sys/kernel/bpf/username/<optional_dirs_mkdir_by_user>/progX

This would probably work as you would typically map the ebpf map
using -v like this to give a stable path:

        docker run -v /sys/kernel/bpf/foo/maps/progX:/map proX
 
> So, the file system will have kind of a user home-directory for each user
> to isolate through permissions, if I understood correctly.
> 
> If we really want to go this route, then I think there are no big stones
> in the way for the other model either. It should look roughly drafted like
> the below.
> 
> Together with device cgroups for containers, it would allow scenarios where
> you can have:
> 
>   * eBPF (map/prog) device pass-through so a map/prog could even be shared out
>     from the initial namespace into individual ones/all (one could possibly
>     extend such maps as read-only for these consumers).
>   * eBPF device creation for unprivileged users with permissions being set
>     accordingly (as in fs case).
>   * Since cgroup controller can also do wildcards on major/minors, we could
>     make that further fine-grained.
>   * eBPF device creation can also be enforced by the cgroup controller to be
>     entirely disallowed for a specific container.
> 
> (An admin can determine the dynamically created major f.e. under /proc/devices.)

I've read the discussion passively and my take away is that, frankly,
I think the differences are somewhat minor. Both architectures can
scale to what we need. Both will do the job. I'm slightly worried about
exposing uAPI as a FS, I think that didn't work too well for sysfs. It's
pretty much a define the format once and never touch it again kind of
deal.
