From: Paul Moore <paul@paul-moore.com>
Subject: Re: [RFC PATCH 0/2] selinux: avoid nf hooks overhead when not needed
Date: Thu, 07 Apr 2016 14:55:29 -0400
Message-ID: <2239567.jkCk1gtQAE@sifl>
References: <cover.1459934322.git.pabeni@redhat.com> <CAHC9VhSZP1QxT-pQeHAW9m1xmyDsbFeA=9b8SdeWgS0RiDTOBA@mail.gmail.com> <20160406234532.GA731@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Paolo Abeni <pabeni@redhat.com>,
	linux-security-module@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <james.l.morris@oracle.com>,
	Andreas Gruenbacher <agruenba@redhat.com>,
	Stephen Smalley <sds@tycho.nsa.gov>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f67.google.com ([209.85.192.67]:33555 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932082AbcDGSzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 14:55:33 -0400
Received: by mail-qg0-f67.google.com with SMTP id 7so5324618qgj.0
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 11:55:32 -0700 (PDT)
In-Reply-To: <20160406234532.GA731@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, April 07, 2016 01:45:32 AM Florian Westphal wrote:
> Paul Moore <paul@paul-moore.com> wrote:
> > On Wed, Apr 6, 2016 at 6:14 PM, Florian Westphal <fw@strlen.de> wrote:
> > > netfilter hooks are per namespace -- so there is hook unregister when
> > > netns is destroyed.
> > 
> > Looking around, I see the global and per-namespace registration
> > functions (nf_register_hook and nf_register_net_hook, respectively),
> > but I'm looking to see if/how newly created namespace inherit
> > netfilter hooks from the init network namespace ... if you can create
> > a network namespace and dodge the SELinux hooks, that isn't a good
> > thing from a SELinux point of view, although it might be a plus
> > depending on where you view Paolo's original patches ;)
> 
> Heh :-)
> 
> If you use nf_register_net_hook, the hook is only registered in the
> namespace.
> 
> If you use nf_register_hook, the hook is put on a global list and
> registed in all existing namespaces.
> 
> New namespaces will have the hook added as well (see
> netfilter_net_init -> nf_register_hook_list in netfilter/core.c )
>
> Since nf_register_hook is used it should be impossible to get a netns
> that doesn't call these hooks.

Great, thanks.
 
> > > Do you think it makes sense to rework the patch to delay registering
> > > of the netfiler hooks until the system is in a state where they're
> > > needed, without the 'unregister' aspect?
> > 
> > I would need to see the patch to say for certain, but in principle
> > that seems perfectly reasonable and I think would satisfy both the
> > netdev and SELinux camps - good suggestion.  My main goal is to drop
> > the selinux_nf_ip_init() entirely so it can't be used as a ROP gadget.
> > 
> > We might even be able to trim the secmark_active and peerlbl_active
> > checks in the SELinux netfilter hooks (an earlier attempt at
> > optimization; contrary to popular belief, I do care about SELinux
> > performance), although that would mean that enabling the network
> > access controls would be one way ... I guess you can disregard that
> > last bit, I'm thinking aloud again.
> 
> One way is fine I think.

Yes, just disregard my second paragraph above.
 
> > > Ideally this would even be per netns -- in perfect world we would
> > > be able to make it so that a new netns are created with an empty
> > > hook list.
> > 
> > In general SELinux doesn't care about namespaces, for reasons that are
> > sorta beyond the scope of this conversation, so I would like to stick
> > to a all or nothing approach to enabling the SELinux netfilter hooks
> > across namespaces.  Perhaps we can revisit this at a later time, but
> > let's keep it simple right now.
> 
> Okay, I'd prefer to stick to your recommendation anyway wrt. to selinux
> (Casey, I read your comment regarding smack. Noted, we don't want to
> break smack either...)
> 
> I think that in this case the entire question is:
> 
> In your experience, how likely is a config where selinux is enabled BUT the
> hooks are not needed (i.e., where we hit the
> 
> if (!selinux_policycap_netpeer)
>     return NF_ACCEPT;
> 
> if (!secmark_active && !peerlbl_active)
>    return NF_ACCEPT;
> 
> tests inside the hooks)?  If such setups are uncommon we should just
> drop this idea or at least put it on the back burner until the more
> expensive netfilter hooks (conntrack, cough) are out of the way.

A few years ago I would have said that it is relatively uncommon for admins to 
enable the SELinux network access controls; it was typically just 
government/intelligence agencies who had very strict access control 
requirements and represented a small portion of SELinux users.  However, over 
the past few years I've been fielding more and more questions from admins/devs 
in the virtualization space who are interested in some of these capabilities; 
it isn't clear to me how many of these people are switching it on, but there 
is definitely more interest than I have seen in the past and the interested is 
centered around some rather common use cases.

So, to summarize, I don't know ;)

If you've got bigger sources of overhead, my opinion would be to go tackle 
those first.  Perhaps I can even find the time to work on the 
SELinux/netfilter stuff while you are off slaying the bigger dragons, no 
promises at the moment.

-- 
paul moore
www.paul-moore.com
