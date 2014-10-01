From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 32/34] netfilter: bridge: move br_netfilter out of the
 core
Date: Wed, 1 Oct 2014 12:33:10 +0200
Message-ID: <20141001103310.GA15518@salvia>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
 <1411994363-8451-33-git-send-email-pablo@netfilter.org>
 <20140930085802.15460008@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, fw@strlen.de
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140930085802.15460008@urahara>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 30, 2014 at 08:58:02AM -0700, Stephen Hemminger wrote:
> On Mon, 29 Sep 2014 14:39:21 +0200
> Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> 
> > Jesper reported that br_netfilter always registers the hooks since
> > this is part of the bridge core. This harms performance for people that
> > don't need this.
> > 
> > This patch modularizes br_netfilter so it can be rmmod'ed, thus,
> > the hooks can be unregistered. I think the bridge netfilter should have
> > been a separated module since the beginning, Patrick agreed on that.
> > 
> > Note that this is breaking compatibility for users that expect that
> > bridge netfilter is going to be available after explicitly 'modprobe
> > bridge' or via automatic load through brctl.
> > 
> > However, the damage can be easily undone by modprobing br_netfilter.
> > The bridge core also spots a message to provide a clue to people that
> > didn't notice that this has been deprecated.
> > 
> > On top of that, the plan is that nftables will not rely on this software
> > layer, but integrate the connection tracking into the bridge layer to
> > enable stateful filtering and NAT, which is was bridge netfilter users
> > seem to require.
> > 
> > This patch still keeps the fake_dst_ops in the bridge core, since this
> > is required by when the bridge port is initialized. So we can safely
> > modprobe/rmmod br_netfilter anytime.
> > 
> > Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> > Acked-by: Florian Westphal <fw@strlen.de>
> 
> I think this is a good idea but you can't break users.
> 
> We need to figure out a way to autoload br_netfilter module on first use.

Indeed, we've been discussing several possibilities depending, short
summary:

1) Autoload br_netfilter from the configuration path, as it happens
   with many other netfilter modules. However, {ip,ip6,arp}tables are
   decoupled from br_netfilter, so we don't have an obvious way to know if
   you're using them from the bridge.

2) Florian proposed to detect this from the packet path. The idea is
   to move the bridge-nf-call sysctl entries to the bridge core, then if
   you see the first bridged packet and bridge-nf-call is set to 1
   (from sysctl or sysfs), the br_netfilter is requested via workqueue
   and the packets are dropped until the br_netfilter module is in place.
   Then, wait for some time to disable bridge-nf-call by default.

My consideration to not follow 2) was that users only need to
'modprobe br_netfilter' if they really need this. This breakage is not
forcing users to upgrade userspace binaries. Instead, it is asking for
some explicit consent from the user.

Sorry, I should have Cc you since the beginning in this discussion. It
was too late when I realized. I can live with going 2) if you think
it's the way to go.

Let us know if you have a better idea. Thanks!
