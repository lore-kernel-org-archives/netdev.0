From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: xdp_redirect ifindex vs port. Was: best API for
 returning/setting egress port?
Date: Thu, 27 Apr 2017 10:41:21 +0200
Message-ID: <20170427104121.32df2178@redhat.com>
References: <58F7E9F3.5090604@iogearbox.net>
        <20170420025611.GA53935@ast-mbp.thefacebook.com>
        <20170420081051.77a41aa8@redhat.com>
        <20170420171006.GA97067@ast-mbp.thefacebook.com>
        <20170425113453.5c72080f@redhat.com>
        <20170426002610.eihwmz4knbmrolfw@ast-mbp.dhcp.thefacebook.com>
        <59000EF6.1050204@gmail.com>
        <20170426111158.578b925e@redhat.com>
        <5900CC41.2070502@gmail.com>
        <c9b3ff9b-8938-3274-da29-c04f9da2a314@fb.com>
        <20170426205544.GA40859@C02RW35GFVH8>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        brouer@redhat.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56428 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967434AbdD0Il2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 04:41:28 -0400
In-Reply-To: <20170426205544.GA40859@C02RW35GFVH8>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Apr 2017 16:55:44 -0400
Andy Gospodarek <andy@greyhouse.net> wrote:

> On Wed, Apr 26, 2017 at 10:58:45AM -0700, Alexei Starovoitov wrote:
> > On 4/26/17 9:35 AM, John Fastabend wrote:  
> > >   
> > > > As Alexei also mentioned before, ifindex vs port makes no real
> > > > difference seen from the bpf program side.  It is userspace's
> > > > responsibility to add ifindex/port's to the bpf-maps, according to how
> > > > the bpf program "policy" want to "connect" these ports.  The
> > > > port-table system add one extra step, of also adding this port to the
> > > > port-table (which lives inside the kernel).
> > > >   
> > > 
> > > I'm not sure I understand the "lives inside the kernel" bit. I assumed
> > > the 'map' should be a bpf map and behave like any other bpf map.
> > > 
> > > I wanted a new map to be defined, something like this from the bpf programmer
> > > side.
> > > 
> > > struct bpf_map_def SEC("maps") port_table =
> > > 	.type = BPF_MAP_TYPE_PORT_CONNECTION,
> > > 	.key_size = sizeof(u32),
> > > 	.value_size = BPF_PORT_CONNECTION_SIZE,
> > > 	.max_entries = 256,
> > > };  
> > 
> > I like the idea.
> > We have prog_array, perf_event_array, cgroup_array map specializations.
> > This one can be new netdev_array with some new bpf_redirect-like helper
> > accessing it.
> >   
> > > > When loading the XDP program, we also need to pass along a port table
> > > > "id" this XDP program is associated with (and if it doesn't exists you
> > > > create it).  And your userspace "control-plane" application also need
> > > > to know this port table "id", when adding a new port.  
> > > 
> > > So the user space application that is loading the program also needs
> > > to handle this map. This seems correct to me. But I don't see the
> > > value in making some new port table when we already have well understood
> > > framework for maps.  
> > 
> > +1
> >   
> > > > 
> > > > The concept of having multiple port tables is key.  As this implies we
> > > > can have several simultaneous "data-planes" that is *isolated* from
> > > > each-other.  Think about how network-namespaces/containers want
> > > > isolation. A subtle thing I'm afraid to mention, is that oppose to the
> > > > ifindex model, a port table with mapping to a net_device pointer, would
> > > > allow (faster) delivery into the container's inner net_device, which
> > > > sort of violates the isolation, but I would argue it is not a problem
> > > > as this net_device pointer could only be added from a process within the
> > > > namespace.  I like this feature, but it could easily be disallowed via
> > > > port insertion-time validation.
> > > >   
> > > 
> > > I think the above optimization should be allowed. And agree multiple port
> > > tables (maps?) is needed. Again all this points to using standard maps
> > > logic in my mind. For permissions and different domains, which I think
> > > you were starting to touch on, it looks like we could extend the pinning API.
> > > At the moment it does an inode_permission(inode, MAY_WRITE) check but I
> > > presume this could be extended. None of this would be needed in v1 and
> > > could be added subsequently. read-only maps seems doable.  
> > 
> > this is great idea. Once BPF_MAP_TYPE_NETDEV_ARRAY is populated
> > the user space can make it readonly to prevent further changes.
> > 
> > From user space it can be done similar to perf_events/cgroups as well.
> > bpf_map_update_elem(&netdev_array, &port_num, &ifindex)
> > should work.
> > For bpf_map_lookup_elem() from such netdev_array we can return
> > ifindex back.
> > The bpf_map_show_fdinfo() can be customized as well to pretty print
> > ifindexes of netdevs stored in there.
> >   
> 
> I agree with both of you on all of these points.  Having the port
> redirection in a new type of map and/or array seems like the way to go.
> 
> I understood Jesper's perspecitive when thinking about a way to pass a
> port-table id down, but I think the idea that the userspace loader code
> defining the maps is going to be the one making this link is the right
> idea and handling things like ifindex changes (rather than identifiers
> that perform lookups in other tables) is going to have to be yet another
> exercise left up to the...user.  :-)
> 

I love this idea. Integrating the port table closer with the bpf-maps
infrastructure makes sense.  This gives me a place to hook the code into,
instead of (re)inventing a new infrastructure for this port table, and the
interface will be more natural from a bpf-API point of view.

When registering/attaching a XDP/bpf program, we would just send the
file-descriptor for this port-map along (like we do with the bpf_prog
FD). Plus, it own ingress-port number this program is in the port-map.

It is not clear to me, in-which-data-structure on the kernel-side we
store this reference to the port-map and ingress-port. As today we only
have the "raw" struct bpf_prog pointer. I see several options:

1. Create a new xdp_prog struct that contains existing bpf_prog,
a port-map pointer and ingress-port. (IMHO easiest solution)

2. Just create a new pointer to port-map and store it in driver rx-ring
struct (like existing bpf_prog), but this create a race-challenge
replacing (cmpxchg) the program (or perhaps it's not a problem as it
runs under rcu and RTNL-lock).

3. Extend bpf_prog to store this port-map and ingress-port, and have a
fast-way to access it.  I assume it will be accessible via
bpf_prog->bpf_prog_aux->used_maps[X] but it will be too slow for XDP.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
