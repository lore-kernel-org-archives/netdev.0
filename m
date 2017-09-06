From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 2/3] security: bpf: Add eBPF LSM hooks and security field
 to eBPF map
Date: Tue, 5 Sep 2017 17:39:14 -0700
Message-ID: <20170906003913.h6khoama7db4rw6e@ast-mbp>
References: <20170831205635.80256-1-chenbofeng.kernel@gmail.com>
 <20170831205635.80256-3-chenbofeng.kernel@gmail.com>
 <20170901020520.uifv6b7tvelgxumf@ast-mbp>
 <CAMOXUJnF=UoWM7xm-Uk-zyhA1N9exjtDf8Xt+_EF2Kj6YUV0OQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chenbo Feng <chenbofeng.kernel@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        linux-security-module@vger.kernel.org,
        Jeffrey Vander Stoep <jeffv@google.com>,
        netdev@vger.kernel.org, SELinux <Selinux@tycho.nsa.gov>,
        Lorenzo Colitti <lorenzo@google.com>
To: Chenbo Feng <fengc@google.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMOXUJnF=UoWM7xm-Uk-zyhA1N9exjtDf8Xt+_EF2Kj6YUV0OQ@mail.gmail.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 05, 2017 at 02:59:38PM -0700, Chenbo Feng wrote:
> On Thu, Aug 31, 2017 at 7:05 PM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
> > On Thu, Aug 31, 2017 at 01:56:34PM -0700, Chenbo Feng wrote:
> >> From: Chenbo Feng <fengc@google.com>
> >>
> >> Introduce a pointer into struct bpf_map to hold the security information
> >> about the map. The actual security struct varies based on the security
> >> models implemented. Place the LSM hooks before each of the unrestricted
> >> eBPF operations, the map_update_elem and map_delete_elem operations are
> >> checked by security_map_modify. The map_lookup_elem and map_get_next_key
> >> operations are checked by securtiy_map_read.
> >>
> >> Signed-off-by: Chenbo Feng <fengc@google.com>
> >
> > ...
> >
> >> @@ -410,6 +418,10 @@ static int map_lookup_elem(union bpf_attr *attr)
> >>       if (IS_ERR(map))
> >>               return PTR_ERR(map);
> >>
> >> +     err = security_map_read(map);
> >> +     if (err)
> >> +             return -EACCES;
> >> +
> >>       key = memdup_user(ukey, map->key_size);
> >>       if (IS_ERR(key)) {
> >>               err = PTR_ERR(key);
> >> @@ -490,6 +502,10 @@ static int map_update_elem(union bpf_attr *attr)
> >>       if (IS_ERR(map))
> >>               return PTR_ERR(map);
> >>
> >> +     err = security_map_modify(map);
> >
> > I don't feel these extra hooks are really thought through.
> > With such hook you'll disallow map_update for given map. That's it.
> > The key/values etc won't be used in such security decision.
> > In such case you don't need such hooks in update/lookup at all.
> > Only in map_creation and object_get calls where FD can be received.
> > In other words I suggest to follow standard unix practices:
> > Do permissions checks in open() and allow read/write() if FD is valid.
> > Same here. Do permission checks in prog_load/map_create/obj_pin/get
> > and that will be enough to jail bpf subsystem.
> > bpf cmds that need to be fast (like lookup and update) should not
> > have security hooks.
> >
> Thanks for pointing out this. I agree we should only do checks on
> creating and passing
> the object from one processes to another. And if we can still
> distinguish the read/write operation
> when obtaining the file fd, that would be great. But that may require
> us to add a new mode
> field into bpf_map struct and change the attribute struct when doing
> the bpf syscall. How do you
> think about this approach? Or we can do simple checks for
> bpf_obj_create and bpf_obj_use when
> creating the object and passing the object respectively but this
> solution cannot distinguish map modify and
> read.

iirc the idea to have read only maps was brought up in the past
(unfortunately no one took a stab at implementing it), but imo
that's better then relying on lsm to provide such restriction
and more secure, since even if you disable map_update via lsm,
the user can craft a program just to udpate the map from it.
For bpffs we already test for inode_permission(inode, MAY_WRITE);
during BPF_OBJ_GET command and we can extend this facility further.
Also we can allow dropping 'write' permissions from the map
(internally implemented via flag in struct bpf_map), so
update/delete operations won't be allowed.
This flag will be checked by syscall during map_update/delete
and by the verifier if such read-only map is used by the program
being loaded, so map_update/helpers won't be allowed in
such program.
Would also be good to support read-only programs as well
(progs that are read-only from kernel state point of view)
They won't be able to modify packets, maps, etc.

