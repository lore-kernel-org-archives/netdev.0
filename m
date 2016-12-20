From: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Tue, 20 Dec 2016 11:21:17 +0100
Message-ID: <bdc18fe4-f90d-49f0-d0a6-a28f87335df2@zonque.org>
References: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
 <20161219205631.GA31242@ast-mbp.thefacebook.com>
 <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
 <20161220000254.GA58895@ast-mbp.thefacebook.com>
 <CALCETrU1_bDVLfokQ7zasHVmeq7S-R+603GEw59V_wuj4eE1hw@mail.gmail.com>
 <20161220031802.GA77838@ast-mbp.thefacebook.com>
 <CALCETrXymvAo-9zhQe=amToz_fs9XGniK2KLZv5Fxc66qcUx6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>,
        Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, David Ahern <dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrXymvAo-9zhQe=amToz_fs9XGniK2KLZv5Fxc66qcUx6A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On 12/20/2016 04:50 AM, Andy Lutomirski wrote:
> On Mon, Dec 19, 2016 at 7:18 PM, Alexei Starovoitov
> <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> On Mon, Dec 19, 2016 at 04:25:32PM -0800, Andy Lutomirski wrote:
>>> I think we're still talking past each other.  A big part of the point
>>> of changing it is that none of this is specific to bpf.  You could (in
>>
>> the hooks and context passed into the program is very much bpf specific.
>> That's what I've been trying to convey all along.
> 
> You mean BPF_CGROUP_RUN_PROG_INET_SOCK(sk)?  There is nothing bpf
> specfic about the hook except that the name of this macro has "BPF" in
> it.  There is nothing whatsoever that's bpf-specific about the context
> -- sk is not bpf-specific at all.
> 
> The only thing bpf-specific about it is that it currently only invokes
> bpf programs.  That could easily change.

I'm not sure if I follow. The code as it currently stands only supports
attaching bpf programs to cgroups which have been created using
BPF_PROG_LOAD. If cgroups would support other program types in the
future, then they would need to be stored in different data types
anyway, and the bpf syscall multiplexer would be the wrong entry point
to access them anyway.

Whether we add bpf-specific code to the cgroup file parsers or
cgroup-specific code to the bpf layer does not make much of a semantic
difference, does it? As a matter of fact, my very first implementation
of this patch set implemented a cgroup controller that would allow
writing strings like "ingress 5" to its control file, where 5 is the fd
number that came out of BPF_PROG_LOAD. The main reason we decided to
ditch that was that echoing fd numbers into a text file seemed way worse
than going through a proper syscall layer with it, and ioctls are
unavailable on pseudo-fs.

The idea was rather to allow attaching bpf programs to other things than
just cgroups as well, which is why we called the member of 'union
bpf_attr' 'target_fd', and a cgroup is just one type a target here.

>> i'm assuming 'baadf00d' is bpf program fd expressed a text string?
>> and kernel needs to parse above? will you allow capital and lower
>> case for 'bpf:' ? and mixed case too? spaces and tabs allowed or not?
>> can program fd expressed as decimal or hex or both?
>> how do you return the error? as a text string for user space
>> to parse?
> 
> No.  The kernel does not parse it because you cannot write this to the
> file.  You set a bpf filter with ioctl and pass an fd.

An ioctl on what file, exactly?

> If you *read*
> the file, you get the same bpf program hash that fdinfo on the bpf
> object would show -- this is for debugging and (eventually) CRIU.

We need a debugging facility at some point, I agree to that. As the code
currently stands, that would rather need to go into the bpf(2) syscall
though, as setting a program through bpf(2) and reading it through
cgroupfs is really nasty.

>> so you're proposing to add a bunch of hard coded logic to the kernel.
>> First to parse such text into some sort of syntax tree or list/set
>> and then have hard coded logic specifically for these two use cases?
>> While above two can be implemented as trivial bpf programs already?!
>> That goes 180% degree vs bpf philosophy. bpf is about moving
>> the specific code out of the kernel and keeping kernel generic that
>> it can solve as many use cases as possible by being programmable.
> 
> I'm not seriously proposing implementing these.  My point is that
> *bpf*, while wonderful, is not the be-all-and-end-all of kernel
> configurability, and other types of hooks might want to be hooked in
> here.

Sure, but nobody claimed it to be that be-all-and-end-all thing. It's
just one thing that a cgroup is now able to accommodate, and because
that new feature is specific to bpf, we decided to hook up the uapi to
the bpf syscall.

> So if I set up a cgroup that's monitored and call it /cgroup/a and
> enable delegation and if the program running there wants to do its own
> monitoring in /cgroup/a/b (via delegation), then you really want the
> outer monitor to silently drop events coming from /cgroup/a/b?

That's a fair point, and we've discussed it as well. The issue is, as
Alexei already pointed out, that we do not want to traverse the tree up
to the root for nested cgroups due to the runtime costs in the
networking fast-path. After all, we're running the bpf program for each
packet in flight. Hence, we opted for the approach to only look at the
leaf node for now, with the ability to open it up further in the future
using flags during attach etc.

> The current approach to bpf hooks will bite you down the road.  David
> Ahern is already proposing using it for something that is not tracing
> at all, and someone will want that in a container, and there will be a
> problem.

Hmm, I thought we've sorted out the concerns about that by making sure
that we

a) lock-down the API sufficiently so it doesn't cause any security
issues in its current form, and

b) make it possible to extend the functionality in the future by adding
flags to the command struct etc.

And I hoped we achieved that after discussing it for so long.

> How about slowing down a wee bit and trying to come up with cgroup
> hook semantics that work for all of these use cases?

I'm all for discussing things, but I don't this was done in a rush.

I do agree though that adding functionality to cgroups that is not
limited to resource control is a delicate thing to do, which is why I
cc'ed cgroups@ in my patches. I should have also added linux-api@ I
guess, sorry I missed that.

> I think my proposal is quite close to workable.

So let's talk about how to proceed. I've seen different bits of your
proposal in different mails, and I think a summary of it would help the
discussion.


Thanks,
Daniel
