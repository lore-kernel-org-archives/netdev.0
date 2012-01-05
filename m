From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] netfilter: Add possibility to turn off netfilters
 defrag per netns
Date: Thu, 5 Jan 2012 15:18:59 +0100
Message-ID: <20120105141859.GA8210@1984>
References: <1325664443-10320-1-git-send-email-hans.schillstrom@ericsson.com>
 <201201042156.05586.hans@schillstrom.com>
 <alpine.DEB.2.00.1201042232510.3934@blackhole.kfki.hu>
 <201201050819.21363.hans.schillstrom@ericsson.com>
 <alpine.DEB.2.00.1201050959030.5244@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1201050959030.5244@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 05, 2012 at 10:11:28AM +0100, Jozsef Kadlecsik wrote:
> OK, I see. Conntrack is per net namespace but it's enabled globally.
>  
> So at the moment I think the best solution is something like your patch 
> variant (but the condition is wrong, it should be "&& !skb->nfct"):
> 
> --- a/net/ipv4/netfilter/nf_defrag_ipv4.c
> +++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
> @@ -74,6 +74,14 @@ static unsigned int ipv4_conntrack_defrag(unsigned int
> hooknum,
> ...
> +       const struct net_device *dev = (hooknum == NF_INET_LOCAL_OUT ?
> +                                       out : in);
> +
> +       /* No defrag and not Previously seen (loopback)? */
> +       if (dev_net(dev)->ct.sysctl_notrac_defrag && skb->nfct) {
> +               /* Attach fake conntrack entry. as in NOTRACK */
> +               skb->nfct = &nf_ct_untracked_get()->ct_general;
> +               skb->nfctinfo = IP_CT_NEW;
> +               nf_conntrack_get(skb->nfct);
> +               return NF_ACCEPT;
> +       }
> ...

I prefer the sysctl option as well, the new table is too much and it
remains too specific for this.

I wonder if we can conditionally register the sysctl only if we are
inside one lxc container.

I'm telling this because this sysctl does not seem to make any sense
to me outside of it.
