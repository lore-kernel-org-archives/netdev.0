From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net] netfilter: nf_conntrack: Use net_mutex for helper
 unregistration.
Date: Sat, 7 May 2016 11:18:45 +0200
Message-ID: <20160507091845.GA6911@breakpoint.cc>
References: <1462488637-46877-1-git-send-email-joe@ovn.org>
 <20160506110325.GA2420@salvia>
 <CAPWQB7H0qdi2+rL92_O=-ku+FeqDSGEmn+d0wivk-1RSAsgeFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Florian Westphal <fw@strlen.de>
To: Joe Stringer <joe@ovn.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAPWQB7H0qdi2+rL92_O=-ku+FeqDSGEmn+d0wivk-1RSAsgeFw@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Stringer <joe@ovn.org> wrote:
> > If so, probably I can append this as comment to this function so we
> > don't forget. If we ever have .exit callbacks (I don't expect so), we
> > would need to wait for worker completion.
> 
> Sounds reasonable to me.
> 
> I see there's a bunch of other unregister locations like
> nf_nat_l3proto_clean(), nf_nat_l4proto_clean(), nf_unregister_hook()
> which might need similar treatment?

I think they are fine, hook entries are duplicated per netns so we
should not access data in a removed module.

However, we might be able to trigger the

WARN(1, "nf_unregister_net_hook: hook not found!\n");

part in nf_unregister_net_hook():

[ destroy netns -> destruction queued -> rmmod -> all hooks are
destroyed -> netns workq runs -> nf_unregister_net_hook gets called
-> hook already gone ]

For nf_nat_l3|4proto_clean I don't see a problem either, if netns
is gone all these conntracks will be zapped once the workqueue runs, even if
the iteration in those function did not see the netns anymore.

Cheers,
Florian
