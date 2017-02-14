From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Tue, 14 Feb 2017 09:50:20 -0300
Message-ID: <20170214125020.GA4458@kernel.org>
References: <20170214091250.57d054b2@canb.auug.org.au>
 <20170214064221.GB10242@gmail.com>
 <20170214091937.GA18546@krava>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@kernel.org>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Ingo Molnar <mingo@redhat.com>,
        Alexander Shishkin <alexander.shishkin@linux.intel.com>,
        Arnaldo Carvalho de Melo <acme@infradead.org>
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:55650 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752455AbdBNM6n (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Feb 2017 07:58:43 -0500
Content-Disposition: inline
In-Reply-To: <20170214091937.GA18546@krava>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Feb 14, 2017 at 10:19:37AM +0100, Jiri Olsa escreveu:
> On Tue, Feb 14, 2017 at 07:42:21AM +0100, Ingo Molnar wrote:
> > * Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> > > Unfortunately, the perf header files are kept separate from the kernel
> > > header files proper and are not automatically copied over :-(

> > No, that's wrong, the problem is not that headers were not shared, the problem is 
> > that a tooling interdependency was not properly tested *and* that the dependency 
> > was not properly implemented in the build system either.

> > Note that we had similar build breakages when include headers _were_ shared as 
> > well, so sharing the headers would only have worked around this particular bug and 
> > would have introduced fragility in other places...

> > The best, most robust solution in this particular case would be to fix the 
> > (tooling) build system to express the dependency, that would have shown the build 
> > failure right when the modification was done.
 
> so we have the warning now:
>   Warning: tools/include/uapi/linux/bpf.h differs from kernel
 
> do you want to change it into the build failure?

No. Differences in the copy are not always problematic, the problem here
lies elsewhere.

Please run:

  make -C tools all

To build all tools when you touch something in tools/include and/or
tools/lib/

- Arnaldo



Bored? Here is what I first wrote ;-)

Simply using the kernel original would require kernel hackers to build
all tools using that file, something we long decided not to do.

What I think Ingo meant with dependency at the build system level is to
somehow state that if file A gets changed, then tool B must be rebuilt.

Now that samples/bpf and tools/perf/ depend on tools/lib/bpf/ I _always_
build both, ditto for tools/objtool, that shares a different library
with tools/perf/, tools/lib/subcmd/:

ENTRYPOINT make -C /git/linux/tools/perf O=/tmp/build/perf && \
           rm -rf /tmp/build/perf/{.[^.]*,*} && \
           make NO_LIBELF=1 -C /git/linux/tools/perf O=/tmp/build/perf && \
           make -C /git/linux/tools/objtool O=/tmp/build/objtool && \
           make -C /git/linux O=/tmp/build/linux allmodconfig && \
           make -C /git/linux O=/tmp/build/linux headers_install && \
           make -C /git/linux O=/tmp/build/linux samples/bpf/

This is the default action for my
docker.io/acmel/linux-perf-tools-build-fedora:rawhide container.

It is published, so a:

   docker pull docker.io/acmel/linux-perf-tools-build-fedora:rawhide

And then run it before pushing things upstream would catch these kinds
of errors.

But that would possibly disrupt too much people's workflow, that is why
using the Kbuild originated tools/build/ we have to somehow express that
when a change is made in a file then a tool that uses that file needs to
be rebuilt.

Makefile rules probably would be enough, but then it would have to be
done at the tools/build/ level and all tools using shared components
would have to use it to trigger the rebuild.

- Arnaldo
