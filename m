From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/5] net: add support for noref skb->sk
Date: Thu, 21 Sep 2017 03:35:08 -0700
Message-ID: <1505990108.29839.117.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1505926196.git.pabeni@redhat.com>
         <39b55ec9584df7dfd6eb498a3d354cd2e08e3eaa.1505926196.git.pabeni@redhat.com>
         <1505929295.29839.103.camel@edumazet-glaptop3.roam.corp.google.com>
         <1505985297.2560.39.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34724 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751605AbdIUKfM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 06:35:12 -0400
Received: by mail-io0-f196.google.com with SMTP id g32so4852403ioj.1
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 03:35:11 -0700 (PDT)
In-Reply-To: <1505985297.2560.39.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-09-21 at 11:14 +0200, Paolo Abeni wrote:
> Hi,
> 
> Thank you for looking at it!
> 
> On Wed, 2017-09-20 at 10:41 -0700, Eric Dumazet wrote:
> > On Wed, 2017-09-20 at 18:54 +0200, Paolo Abeni wrote:
> > > Noref sk do not carry a socket refcount, are valid
> > > only inside the current RCU section and must be
> > > explicitly cleared before exiting such section.
> > > 
> > > They will be used in a later patch to allow early demux
> > > without sock refcounting.
> > 
> > 
> > 
> > 
> > > +/* dummy destructor used by noref sockets */
> > > +void sock_dummyfree(struct sk_buff *skb)
> > > +{
> > 
> > BUG();
> > 
> > > +}
> > > +EXPORT_SYMBOL(sock_dummyfree);
> > > +
> 
> We can call sock_dummyfree() in legitimate paths, see below, but we can
> add a:
> 
> WARN_ON_ONCE(!rcu_read_lock_held());

This wont be enough see below.

> 
> here and in  skb_clear_noref_sk(). That should help much to catch
> possible bugs.
> 
> > I do not see how you ensure we do not leave RCU section with an skb
> > destructor pointing to this sock_dummyfree()
> > 
> > This patch series looks quite dangerous to me.
> 
> The idea is to explicitly clear the sknoref references before leaving
> the RCU section. Quite alike what we currently do for dst noref, but
> here the only place where we get a noref socket is the socket early
> demux, thus the scope of this change is more limited to what we have
> with noref dst_entries.
> 
> The relevant code is in the next 2 patches; after the demux we preserve
> the sknoref only if the skb has a local destination. The UDP socket
> will then set the noref on early demux lookup, and the skb will either:
> 
> * land on the corresponding UDP socket, the receive function will steal
> the sknoref
> * be dropped by some nft/iptables target - the dummy destructor is
> called
> * forwarded by some nft/iptables target outside the input path; we
> clear the skref explicitly in such targets. 
> 
> Currently there are an handful of places affected, and we can simplify
> the code dropping the early demux result for locally terminated
> multicast sockets on a host acting as a multicast router, please see
> the comment on the next patch.
> 
> > Do we really have real applications using connected UDP sockets and
> > wanting very high pps throughput ?
> 
> The ultimate goal is to improve the unconnected UDP sockets scenario,
> we do actually have use cases for that - DNS servers and VoIP SBCs.

Unconnected UDP traffic does not use refcounting on sk _already_.

And SO_REUSEPORT already allows us to handle all the traffic we want
_already_.


Please take a look at 71563f3414e917c62acd8e0fb0edf8ed6af63e4b

This might tell you why I am so nervous about your changes.

Checking WARN_ON_ONCE(!rcu_read_lock_held());
is not enough.

rcu_read_lock()
skb->destructor = sock_dummyfree;

queue the packet into an intermediate queue.
rcu_read_unlock();

....

rcu_read_lock()
...
if (skb->sk && skb->sk->state == ...) // crash

Also you covered IPv4, but really we need to forget about IPv4 and focus
on IPv6 only. And _then_ take care of IPv4 compat.
