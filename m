From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 1/2] bpf: enable non-root eBPF programs
Date: Wed, 7 Oct 2015 14:20:47 -0700
Message-ID: <56158CAF.9030209@plumgrid.com>
References: <1444078101-29060-1-git-send-email-ast@plumgrid.com>
 <1444078101-29060-2-git-send-email-ast@plumgrid.com>
 <5612F639.2050305@iogearbox.net> <56131B1F.80002@plumgrid.com>
 <5613C261.4080302@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@amacapital.net>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5613C261.4080302@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/6/15 5:45 AM, Daniel Borkmann wrote:
> Should instead something similar be adapted on bpf(2) as well? Or, would
> that even be more painful for application developers shipping their stuff
> through distros in the end (where they might then decide to just setup
> everything BPF-related and then drop privs)?

I think loading as root and then dropping privs won't work in many
cases, since apps still need to access maps even after dropping privs
and today it's not possible, since cap_sys_admin is tested for every
bpf syscall.

> I'm also wondering with regards to seccomp, which could adapt to eBPF at
> some point and be used by unprivileged programs. Perhaps then, a single
> paranoia alike setting might not suit to all eBPF subsystem users. Any
> ideas?

There is no such paranoid sysctl for cBPF, so there is no reason to
add one for eBPF other than fear.
Adding multiple sysctl knobs for seccomp, socket, tracing is only
reflection of even higher fear.
What sysadmins suppose to do with such sysctl when kernel is kinda
saying 'may be something unsafe here you're on your own' ?
Also the presence of this sysctl_bpf_enable_unprivileged or any other
one doesn't help with CVEs. Any bug with security implications will
be a CVE regardless, so I think the better course of action is to
avoid introducing this sysctl.

We've discussed adding something like CAP_BPF to control it,
but then again, do we want this because of fear of bugs or because
it's actually needed. I think the design of all CAP_* is to give
unprivileged users permissions to do something beyond normal that
can potentially be harmful for other users or the whole system.
In this case it's not the case. One user can load eBPF programs
and maps up to its MEMLOCK limit and they cannot interfere with
other users or affect the host, so CAP_BPF is not necessary either.

Thoughts?
