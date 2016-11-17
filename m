From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [PATCH nf-next,RFC] netfilter: nft_meta: add cgroup version 2
 support
Date: Thu, 17 Nov 2016 12:02:06 +0100
Message-ID: <20161117110206.GA3165@salvia>
References: <1479114761-19534-1-git-send-email-pablo@netfilter.org>
 <e4e0bc59-5a97-118b-2d4e-af12c2055e7e@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, htejun-b10kYP2dOMg@public.gmane.org,
        cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <e4e0bc59-5a97-118b-2d4e-af12c2055e7e-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Daniel,

On Mon, Nov 14, 2016 at 11:10:04AM +0100, Daniel Mack wrote:
[...]
> On 11/14/2016 10:12 AM, Pablo Neira Ayuso wrote:
> > Add cgroup version 2 support to nf_tables.
> > 
> > This extension allows us to fetch the cgroup i-node number from the
> > cgroup socket data, place it in a register, then match it against any
> > value specified by user. This approach scales up nicely since it
> > integrates well in the existing nf_tables map infrastructure.
> > 
> > Contrary to what iptables cgroup v2 match does, this patch doesn't use
> > cgroup_is_descendant() because this call cannot guarantee that the cgroup
> > hierarchy is honored in anyway given that the cgroup v2 field becomes yet
> > another packet selector that you can use to build your filtering policy.
> > 
> > Actually, using the i-node approach, it should be easy to build a policy
> > that honors the hierarchy if you need this, eg.
> > 
> > 	meta cgroup2 vmap { "/A/B" : jump b-cgroup-chain,
> > 			    "/A/C" : jump c-cgroup-chain,
> > 			    "/A" : jump a-cgroup-chain }
> > 
> > then, the b-cgroup-chain looks like:
> > 
> > 	jump a-cgroup-chain
> > 	... # specific policy b-cgroup-chain goes here
> > 
> > similarly, the c-cgroup-chain looks like:
> > 
> > 	jump a-cgroup-chain
> > 	... # specific policy c-cgroup-chain goes here
> > 
> > So both B and C would evaluate A's ruleset. Note that cgroup A would
> > also jump to the root cgroup chain policy.
> > 
> > Anyway, this cgroup i-node approach provides way more flexibility since
> > it is up to the sysadmin to decide if he wants to honor the hierarchy or
> > simply define a fast path to skip any further classification.
> 
> I don't think this can work. The problem is that inodes in cgroupfs are
> dynamically allocated when a cgroup is created, so the sysadmin cannot
> install the jump rules before that. Worse yet, inode numbers in pseudo
> filesystems are recycled, so if a cgroup goes away and a new one is
> created, the latter may well end up having the same inode than the old
> one.
>
> As cgroupfs decoupled from netfilter tables, this will lead to
> major chaos in the field.

Do you really want tight coupling? Look:

 # mkdir /tmp/x
 # mount -t cgroup2 none /tmp/x
 # mkdir /tmp/x/x
 # echo 0 > /tmp/x/x/cgroup.procs
 # iptables -I INPUT -m cgroup --path "/"
 # iptables -I INPUT -m cgroup --path "/x"
 # rmdir /tmp/x/x/
 rmdir: failed to remove '/tmp/x/x/': Device or resource busy

As soon as there is a filtering policy in iptables, you cannot update
cgroups. However, if you adopt a decoupled approach, you can update
both sides anytime.

Following the decoupled approach: If the cgroup is gone, the filtering
policy would not match anymore. You only have to subscribe to events
and perform an incremental updates to tear down the side of the
filtering policy that you don't need anymore. If a new cgroup is
created, you load the filtering policy for the new cgroup and then add
processes to that cgroup. You only have to follow the right sequence
to avoid problems.

> Note that this was different with the netclass controller in v1 that
> would assign a user-controlled numeric value to each cgroup, so both
> sides were in the control of the sysadmin. It is also different with the
> path matching logic for v2 which does a full path string comparison.
> That's potentially expensive, it does lead to predictable runtime behavior.
> 
> One way forward here would be to assign a atomically increasing 64-bit
> sequence number to each cgroup and expose that. I've recently talked to
> Tejun about that. While that won't solve the predictability issue, it
> would at least make it practically impossible to have re-used IDs.

OK, so we need to make sure the ID is unique, an incremental ID should
be fine. Probably the idr logic can be replaced by this new ID.  The
tuple [ directory-name, id ] should be enough to uniquely identify a
cgroup so it may be 32-bits after all, unless you think chances that
we get the same directory-name and id is high, then avoid wraparounds
via 64-bits.

> Anyway - I think it would be great to have an alternative to the v2 path
> matching here, but of course this patch does not solve the ingress issue
> we've been discussing. It is still impossible to reliably determine the
> cgroup of a local receiver at the time when the netfilter rules are
> processed, even for unicast packets.

This is right if we rely on early demux, however we have explicit
socket lookups in netfilter that we can reuse, see
nf_sk_lookup_slow_v{4,6}() in nf-next. This would actually allow us to
filter very early for the vast majority of usecases, using any
combination of selectors, not only focusing this specifically on
cgroups. This infrastructure supports UDP and TCP which is good start.

The problem is specifically the many-cast socket path. Actually, if
one single listener is available and the udp_hash2 chain is not too
long we already get the destination via early_demux, so that path is
already covered. The problem is the many-cast usecase with long chains
(this we could trigger a longer lookup only from netfilter, only for
people willing to filter packets) and the two-or-more many-cast socket
listener destinations for UDP. Do you really need accounting for the
many-cast case too?

Attaching several socket destinations to skbuff is a tricky, as we
would need new specific infrastructure, something like a socket
container object that keeps a list of destination sockets, all of them
holding a reference to these socket which may be expensive. Another
option is a specific many-cast input hook following the
__udp4_lib_mcast_deliver() path. Any solution for many-cast filtering
is going to be expensive.
