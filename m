From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC PATCH 0/2] selinux: avoid nf hooks overhead when not needed
Date: Thu, 7 Apr 2016 01:45:32 +0200
Message-ID: <20160406234532.GA731@breakpoint.cc>
References: <cover.1459934322.git.pabeni@redhat.com>
 <CAHC9VhS6aJdPR6xTH2-ehikS5qvj6jFbZAUtzoBXp+WC9Ugi=Q@mail.gmail.com>
 <20160406221445.GA26807@breakpoint.cc>
 <CAHC9VhSZP1QxT-pQeHAW9m1xmyDsbFeA=9b8SdeWgS0RiDTOBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, Paolo Abeni <pabeni@redhat.com>,
	linux-security-module@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <james.l.morris@oracle.com>,
	Andreas Gruenbacher <agruenba@redhat.com>,
	Stephen Smalley <sds@tycho.nsa.gov>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Paul Moore <paul@paul-moore.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHC9VhSZP1QxT-pQeHAW9m1xmyDsbFeA=9b8SdeWgS0RiDTOBA@mail.gmail.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Moore <paul@paul-moore.com> wrote:
> On Wed, Apr 6, 2016 at 6:14 PM, Florian Westphal <fw@strlen.de> wrote:
> > netfilter hooks are per namespace -- so there is hook unregister when
> > netns is destroyed.
> 
> Looking around, I see the global and per-namespace registration
> functions (nf_register_hook and nf_register_net_hook, respectively),
> but I'm looking to see if/how newly created namespace inherit
> netfilter hooks from the init network namespace ... if you can create
> a network namespace and dodge the SELinux hooks, that isn't a good
> thing from a SELinux point of view, although it might be a plus
> depending on where you view Paolo's original patches ;)

Heh :-)

If you use nf_register_net_hook, the hook is only registered in the
namespace.

If you use nf_register_hook, the hook is put on a global list and
registed in all existing namespaces.

New namespaces will have the hook added as well (see
netfilter_net_init -> nf_register_hook_list in netfilter/core.c )

Since nf_register_hook is used it should be impossible to get a netns
that doesn't call these hooks.

> > Do you think it makes sense to rework the patch to delay registering
> > of the netfiler hooks until the system is in a state where they're
> > needed, without the 'unregister' aspect?
> 
> I would need to see the patch to say for certain, but in principle
> that seems perfectly reasonable and I think would satisfy both the
> netdev and SELinux camps - good suggestion.  My main goal is to drop
> the selinux_nf_ip_init() entirely so it can't be used as a ROP gadget.
> 
> We might even be able to trim the secmark_active and peerlbl_active
> checks in the SELinux netfilter hooks (an earlier attempt at
> optimization; contrary to popular belief, I do care about SELinux
> performance), although that would mean that enabling the network
> access controls would be one way ... I guess you can disregard that
> last bit, I'm thinking aloud again.

One way is fine I think.

> > Ideally this would even be per netns -- in perfect world we would
> > be able to make it so that a new netns are created with an empty
> > hook list.
> 
> In general SELinux doesn't care about namespaces, for reasons that are
> sorta beyond the scope of this conversation, so I would like to stick
> to a all or nothing approach to enabling the SELinux netfilter hooks
> across namespaces.  Perhaps we can revisit this at a later time, but
> let's keep it simple right now.

Okay, I'd prefer to stick to your recommendation anyway wrt. to selinux
(Casey, I read your comment regarding smack. Noted, we don't want to
break smack either...)

I think that in this case the entire question is:

In your experience, how likely is a config where
selinux is enabled BUT the hooks are not needed (i.e., where we hit the

if (!selinux_policycap_netpeer)
    return NF_ACCEPT;

if (!secmark_active && !peerlbl_active)
   return NF_ACCEPT;

tests inside the hooks)?  If such setups are uncommon we should just
drop this idea or at least put it on the back burner until the more expensive
netfilter hooks (conntrack, cough) are out of the way.

Thanks,
Florian
