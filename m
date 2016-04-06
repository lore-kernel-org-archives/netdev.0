From: Paul Moore <paul@paul-moore.com>
Subject: Re: [RFC PATCH 0/2] selinux: avoid nf hooks overhead when not needed
Date: Wed, 6 Apr 2016 19:15:23 -0400
Message-ID: <CAHC9VhSZP1QxT-pQeHAW9m1xmyDsbFeA=9b8SdeWgS0RiDTOBA@mail.gmail.com>
References: <cover.1459934322.git.pabeni@redhat.com>
	<CAHC9VhS6aJdPR6xTH2-ehikS5qvj6jFbZAUtzoBXp+WC9Ugi=Q@mail.gmail.com>
	<20160406221445.GA26807@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Paolo Abeni <pabeni@redhat.com>,
	linux-security-module@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <james.l.morris@oracle.com>,
	Andreas Gruenbacher <agruenba@redhat.com>,
	Stephen Smalley <sds@tycho.nsa.gov>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f196.google.com ([209.85.214.196]:35452 "EHLO
	mail-ob0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754644AbcDFXPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 19:15:25 -0400
Received: by mail-ob0-f196.google.com with SMTP id 4so4879539obi.2
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 16:15:24 -0700 (PDT)
In-Reply-To: <20160406221445.GA26807@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 6, 2016 at 6:14 PM, Florian Westphal <fw@strlen.de> wrote:
> netfilter hooks are per namespace -- so there is hook unregister when
> netns is destroyed.

Looking around, I see the global and per-namespace registration
functions (nf_register_hook and nf_register_net_hook, respectively),
but I'm looking to see if/how newly created namespace inherit
netfilter hooks from the init network namespace ... if you can create
a network namespace and dodge the SELinux hooks, that isn't a good
thing from a SELinux point of view, although it might be a plus
depending on where you view Paolo's original patches ;)

> Do you think it makes sense to rework the patch to delay registering
> of the netfiler hooks until the system is in a state where they're
> needed, without the 'unregister' aspect?

I would need to see the patch to say for certain, but in principle
that seems perfectly reasonable and I think would satisfy both the
netdev and SELinux camps - good suggestion.  My main goal is to drop
the selinux_nf_ip_init() entirely so it can't be used as a ROP gadget.

We might even be able to trim the secmark_active and peerlbl_active
checks in the SELinux netfilter hooks (an earlier attempt at
optimization; contrary to popular belief, I do care about SELinux
performance), although that would mean that enabling the network
access controls would be one way ... I guess you can disregard that
last bit, I'm thinking aloud again.

> Ideally this would even be per netns -- in perfect world we would
> be able to make it so that a new netns are created with an empty
> hook list.

In general SELinux doesn't care about namespaces, for reasons that are
sorta beyond the scope of this conversation, so I would like to stick
to a all or nothing approach to enabling the SELinux netfilter hooks
across namespaces.  Perhaps we can revisit this at a later time, but
let's keep it simple right now.

-- 
paul moore
www.paul-moore.com
