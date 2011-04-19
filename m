From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: A patch you wrote some time ago (aka: "[patch 41/54] ICMP: Fix
 icmp_errors_use_inbound_ifaddr sysctl")
Date: Tue, 19 Apr 2011 09:54:11 -0700
Message-ID: <20110419165411.GO9569@sequoia.sous-sol.org>
References: <4DADBBBC.6020803@boxed.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@sous-sol.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kaber@trash.net
To: Alexander Hoogerhuis <alexh@boxed.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4DADBBBC.6020803@boxed.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Alexander Hoogerhuis (alexh@boxed.no) wrote:
> I hope you (or anyone else) can spare half a minute to have a quick
> look at a patch you wrote a few years ago:
> 
> >http://lkml.org/lkml/2007/6/8/124

I actually did not write that patch, rather added it to the -stable tree.
Patrick (CCd) wrote it.

> I've been tracking down a case of ICMP Redirects originating from
> the wrong IPs, and as far I can tell, you patch is the last to touch
> this code (net/ipv4/icmp.c:507):
> 
> > if (rt->fl.iif && net->ipv4.sysctl_icmp_errors_use_inbound_ifaddr)
> >        dev = dev_get_by_index_rcu(net, rt->fl.iif);
> >
> >if (dev)
> >        saddr = inet_select_addr(dev, 0, RT_SCOPE_LINK);
> >else
> >        saddr = 0;
> 
> In a plain world this would work, but I have come across a case that
> seems to be not handled by this.
> 
> I have two machines set up with VRRP to act as routers out of a
> subnet, and they have IPs x.x.x.13/28 and x.x.x.14/28, with VRRP
> holding on to x.x.x.1/28.
> 
> If a node in x.x.x.0/28 needs to get a ICMP redirect from x.x.x.1/28
> (to reach another subnet behind a  different gateway in x.x.x.0/28),
> then the source IP on the ICMP redirect is chosen as the primary IP
> on the interface that the packet arrived at.
> 
> This is as far as I can tell from RFCs and colleagues fine for most
> things after you're routed one hop or more, but in the case of ICMP
> redirect it means that the redirect is not adhered to by the client,
> as it will get the reidrect from x.x.x.13/28, not x.x.x.1/28.
> 
> inet_select_addr seems to be explicitly looking for the primary IP
> in all cases (./net/ipv4/devinet.c:875), and in the case of sending
> ICMP recdirect when in an VRRP setup, that would not work well. It
> should try to match the actual inbound IP.
> 
> Judging by the comments from your patch I am not sure if the source
> IP that triggers the ICMP redirect is available at this point any
> more.
> 
> The way I understand it should pick adress is this way:
> 
> >  if (rt->fl.iif && net->ipv4.sysctl_icmp_errors_use_inbound_ifaddr)
> >         dev = dev_get_by_index_rcu(net, rt->fl.iif);
> >
> > if (dev == fl.iif)
> >         saddr = iph->daddr;
> >
> > if (dev != fl.iif)
> >         saddr = inet_select_addr(dev, 0, RT_SCOPE_LINK);
> > else
> >         saddr = 0;
> 
> I.e. if we are replying to something that is from a local network
> segment, then iph->daddr would be a more correct source. My C skill
> is prehistoric so what I've written likely is far from correct, but
> the general gist is that there is a special case for replying to
> something local.
> 
> As it stands today (I'm on 2.6.35.11), ICMP redirects when using
> VRRP are broken, and I'm hoping I may have found out why. :)
> 
> mvh,
> A
> -- 
> Alexander Hoogerhuis | http://no.linkedin.com/in/alexh
> Boxed Solutions AS   | +47 908 21 485 - alexh@boxed.no
> "Given enough eyeballs, all bugs are shallow." -Eric S. Raymond
