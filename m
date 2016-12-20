From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Mon, 19 Dec 2016 20:41:37 -0800
Message-ID: <20161220044135.GA86803@ast-mbp.thefacebook.com>
References: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
 <20161219205631.GA31242@ast-mbp.thefacebook.com>
 <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
 <20161220000254.GA58895@ast-mbp.thefacebook.com>
 <CALCETrU1_bDVLfokQ7zasHVmeq7S-R+603GEw59V_wuj4eE1hw@mail.gmail.com>
 <20161220031802.GA77838@ast-mbp.thefacebook.com>
 <CALCETrXymvAo-9zhQe=amToz_fs9XGniK2KLZv5Fxc66qcUx6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@kernel.org>, Daniel Mack <daniel@zonque.org>,
        =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
        Kees Cook <keescook@chromium.org>, Jann Horn <jann@thejh.net>,
        Tejun Heo <tj@kernel.org>, David Ahern <dsahern@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Linux API <linux-api@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrXymvAo-9zhQe=amToz_fs9XGniK2KLZv5Fxc66qcUx6A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 19, 2016 at 07:50:01PM -0800, Andy Lutomirski wrote:
> >>
> >> net.socket_create_filter = "none": no filter
> >> net.socket_create_filter = "bpf:baadf00d": bpf filter
> >
> > i'm assuming 'baadf00d' is bpf program fd expressed a text string?
> > and kernel needs to parse above? will you allow capital and lower
> > case for 'bpf:' ? and mixed case too? spaces and tabs allowed or not?
> > can program fd expressed as decimal or hex or both?
> > how do you return the error? as a text string for user space
> > to parse?
> 
> No.  The kernel does not parse it because you cannot write this to the
> file.  You set a bpf filter with ioctl and pass an fd.  If you *read*
> the file, you get the same bpf program hash that fdinfo on the bpf
> object would show -- this is for debugging and (eventually) CRIU.

my understanding that cgroup is based on kernfs and both don't support
ioctl, so you'd need quite some hacking to introduce such concepts
and buy-in from a bunch of people first.

> >> net.socket_create_filter = "iptables:foobar": some iptables thingy
> >> net.socket_create_filter = "nft:blahblahblah": some nft thingy
> >
> > iptables/nft are not applicable to 'bpf_socket_create' which
> > looks into:
> > struct bpf_sock {
> >         __u32 bound_dev_if;
> >         __u32 family;
> >         __u32 type;
> >         __u32 protocol;
> > };
> > so don't fit as an example.
> 
> The code that takes a 'struct sock' and sets up bpf_sock is
> bpf-specific and would obviously not be used for non-bpf filter.  But
> if you had a filter that was just a like of address families, that
> filter would look at struct sock and do its own thing.  iptables
> wouldn't make sense for a socket creation filter, but it would make
> perfect sense for an ingress filter.  Obviously the bpf-specific state
> object wouldn't be used, but it would still be a hook, invoked from
> the same network code, guarded by the same static key, looking at the
> same skb.

I strongly suggest to go back and read my first reply where
I think I explained well enough that something like iptables
will not able to reuse the ioctl mechanism you're proposing here,
hook ids will be different, attachment mechanism will be different too.
So your proposed cgroup ioctl is already dead as a reusable interface.

> >> net.socket_create_filter = "disallow": no sockets created period
> >> net.socket_create_filter = "address_family_list:1,2,3": allow AF 1, 2, and 3
> >
> > so you're proposing to add a bunch of hard coded logic to the kernel.
> > First to parse such text into some sort of syntax tree or list/set
> > and then have hard coded logic specifically for these two use cases?
> > While above two can be implemented as trivial bpf programs already?!
> > That goes 180% degree vs bpf philosophy. bpf is about moving
> > the specific code out of the kernel and keeping kernel generic that
> > it can solve as many use cases as possible by being programmable.
> 
> I'm not seriously proposing implementing these.  My point is that
> *bpf*, while wonderful, is not the be-all-and-end-all of kernel
> configurability, and other types of hooks might want to be hooked in
> here.

Then please let's talk about real use cases.
This daydreaming of some future llvm in the kernel that you were
bringing up during LPC doesn't help the discussion.
Just like these artificial examples.

> > ...
> >> What exactly isn't sensible about using cgroup_bpf for containers?
> >
> > my use case is close to zero overhead application network monitoring.
> 
> So if I set up a cgroup that's monitored and call it /cgroup/a and
> enable delegation and if the program running there wants to do its own
> monitoring in /cgroup/a/b (via delegation), then you really want the
> outer monitor to silently drop events coming from /cgroup/a/b?

yes. both are root and must talk to each other if they want
to co-exist. When root process is asking kernel to do X, this X has
to happen.

> Then disallow nesting.  You're welcome to not rush the decision, but
> that's not what you've done.  If 4.10 is released as is, you've made
> the decision and you're going to have a hard time changing it.

Nothing needs to be changed.

> > No. As was pointed out before only root can load BPF_PROG_TYPE_CGROUP_[SKB|SOCK]
> > type programs and only root can attach them.
> 
> Why?  It really seems to me that you expect that future namespaceable
> bpf hooks will use a totally different API.  At KS, I sat in a room
> full of people arguing about cgroup v2 and a lot of them pointed out
> that there are valid, paying use cases that want to stick cgroup v1 in
> a container, because the code that uses cgroup v1 in the container is
> called systemd and the contained OS is called RHEL (or SuSE or Ubuntu
> or Gentoo or whatever), and that code is *already written* and needs
> to be contained.

bpf in general is not namespace aware. It's global and this cgroup scoping
of bpf programs is the first of this kind. Namespacing of bpf is completely
different topic.

> The current approach to bpf hooks will bite you down the road.  David
> Ahern is already proposing using it for something that is not tracing
> at all, and someone will want that in a container, and there will be a
> problem.

vrf use case already supported by existing code.

> How about slowing down a wee bit and trying to come up with cgroup
> hook semantics that work for all of these use cases?  I think my
> proposal is quite close to workable.

you've started the topic by claiming that things are broken
and non-extensible. At the course of this thread it was explained
that the interface is extensible and not broken for the use case
it was designed for. The 'security' use case like lsm+bpf+cgroup
is not supported by the current model yet and that's what we need
to discuss in the future. So, yes, please slow down.
