From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Mon, 19 Dec 2016 17:56:24 -0800
Message-ID: <CALCETrUW2jEYmjSsOrPj+MAjkDGGUCw_rdxQh+5Er0r4ReGLnA@mail.gmail.com>
References: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
 <20161219205631.GA31242@ast-mbp.thefacebook.com> <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
 <20161220000254.GA58895@ast-mbp.thefacebook.com> <CALCETrU1_bDVLfokQ7zasHVmeq7S-R+603GEw59V_wuj4eE1hw@mail.gmail.com>
 <2dbec775-6304-e44c-19c5-fbf07877e7b1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>,
        Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Ahern <dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2dbec775-6304-e44c-19c5-fbf07877e7b1-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 19, 2016 at 5:44 PM, David Ahern <dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On 12/19/16 5:25 PM, Andy Lutomirski wrote:
>> net.socket_create_filter =3D "none": no filter
>> net.socket_create_filter =3D "bpf:baadf00d": bpf filter
>> net.socket_create_filter =3D "disallow": no sockets created period
>> net.socket_create_filter =3D "iptables:foobar": some iptables thingy
>> net.socket_create_filter =3D "nft:blahblahblah": some nft thingy
>> net.socket_create_filter =3D "address_family_list:1,2,3": allow AF 1, 2,=
 and 3
>
> Such a scheme works for the socket create filter b/c it is a very simple =
use case. It does not work for the ingress and egress which allow generic b=
pf filters.

Can you elaborate on what goes wrong?  (Obviously the
"address_family_list" example makes no sense in that context.)

>
> ...
>
>>> you're ignoring use cases I described earlier.
>>> In vrf case there is only one ifindex it needs to bind to.
>>
>> I'm totally lost.  Can you explain what this has to do with the cgroup
>> hierarchy?
>
> I think the point is that a group hierarchy makes no sense for the VRF us=
e case. What I put into iproute2 is
>
>     cgrp2/vrf/NAME
>
> where NAME is the vrf name. The filter added to it binds ipv4 and ipv6 so=
ckets to a specific device index. cgrp2/vrf is the "default" vrf and does n=
ot have a filter. A user can certainly add another layer cgrp2/vrf/NAME/NAM=
E2 but it provides no value since VRF in a VRF does not make sense.

I tend to agree.  I still think that the mechanism as it stands is
broken in other respects and should be fixed before it goes live.  I
have no desire to cause problems for the vrf use case.

But keep in mind that the vrf use case is, in Linus' tree, a bit
broken right now in its interactions with other users of the same
mechanism.  Suppose I create a container and want to trace all of its
created sockets.  I'll set up cgrp2/container and load my tracer as a
socket creation hook.  Then a container sets up
cgrp2/container/vrf/NAME (using delgation) and loads your vrf binding
filter.  Now the tracing stops working -- oops.

>
> ...
>
>>>> I like this last one, but IT'S NOT A POSSIBLE FUTURE EXTENSION.  You
>>>> have to do it now (or disable the feature for 4.10).  This is why I'm
>>>> bringing this whole thing up now.
>>>
>>> We don't have to touch user visible api here, so extensions are fine.
>>
>> Huh?  My example in the original email attaches a program in a
>> sub-hierarchy.  Are you saying that 4.11 could make that example stop
>> working?
>
> Are you suggesting sub-cgroups should not be allowed to override the filt=
er of a parent cgroup?

Yes, exactly.  I think there are two sensible behaviors:

a) sub-cgroups cannot have a filter at all of the parent has a filter.
(This is the "punt" approach -- it lets different semantics be
assigned later without breaking userspace.)

b) sub-cgroups can have a filter if a parent does, too.  The semantics
are that the sub-cgroup filter runs first and all side-effects occur.
If that filter says "reject" then ancestor filters are skipped.  If
that filter says "accept", then the ancestor filter is run and its
side-effects happen as well.  (And so on, all the way up to the root.)

--Andy
