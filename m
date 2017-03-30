From: Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: [RFC PATCH tip/master 2/3] kprobes: Allocate kretprobe instance
 if its free list is empty
Date: Thu, 30 Mar 2017 22:01:34 +0900
Message-ID: <20170330220134.448b65b9102edcf8ba1a2c81@kernel.org>
References: <149076484118.24574.7083269903420611708.stgit@devbox>
        <149076498222.24574.679546540523044200.stgit@devbox>
        <20170329063005.GA12220@gmail.com>
        <20170329172510.e012406497fd38a54d5069b3@kernel.org>
        <20170330065332.GA30148@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>,
        Ingo Molnar <mingo@redhat.com>,
        Alban Crequy <alban.crequy@gmail.com>,
        Alban Crequy <alban@kinvolk.io>,
        Alexei Starovoitov <ast@kernel.org>,
        Jonathan Corbet <corbet@lwn.net>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Omar Sandoval <osandov@fb.com>, linux-doc@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        iago@kinvolk.io, michael@kinvolk.io,
        Dorau Lukasz <lukasz.dorau@intel.com>, systemtap@sourceware.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20170330065332.GA30148@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 30 Mar 2017 08:53:32 +0200
Ingo Molnar <mingo@kernel.org> wrote:

> 
> * Masami Hiramatsu <mhiramat@kernel.org> wrote:
> 
> > > So this is something I missed while the original code was merged, but the concept 
> > > looks a bit weird: why do we do any "allocation" while a handler is executing?
> > > 
> > > That's fundamentally fragile. What's the maximum number of parallel 
> > > 'kretprobe_instance' required per kretprobe - one per CPU?
> > 
> > It depends on the place where we put the probe. If the probed function will be
> > blocked (yield to other tasks), then we need a same number of threads on
> > the system which can invoke the function. So, ultimately, it is same
> > as function_graph tracer, we need it for each thread.
> 
> So then put it into task_struct (assuming there's no kretprobe-inside-kretprobe 
> nesting allowed).

No, that is possible to put several kretprobes on same thread, e.g.
the func1() is called from func2(), user can put kretprobes for each
function at same time.
So the possible solution is to allocate new return-stack for each task_struct,
and that is what the function-graph tracer did.

Anyway, I'm considering to integrate kretprobe_instance with the ret_stack.
It will increase memory usage for kretprobes, but can provide safer way
to allocate kretprobe_instance.

> There's just no way in hell we should be calling any complex 
> kernel function from kernel probes!

OK, so let's drop this, since it may easily cause deadlock... 


> I mean, think about it, a kretprobe can be installed in a lot of places, and now 
> we want to call get_free_pages() from it?? This would add a massive amount of 
> fragility.

I thought it was safe because GFP_ATOMIC is safe at interrupt handler.

> Instrumentation must be _simple_, every patch that adds more complexity to the 
> most fundamental code path of it should raise a red flag ...
> 
> So let's make this more robust, ok?

Yeah, in that case, I think Alban's patch is enough at this point since
it gives user to tune their kretprobe events not to be missed.

Thank you,

> 
> Thanks,
> 
> 	Ingo


-- 
Masami Hiramatsu <mhiramat@kernel.org>
