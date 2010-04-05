From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15682] New: XFRM is not updating RTAX_ADVMSS
 metric
Date: Mon, 5 Apr 2010 12:50:55 -0700
Message-ID: <20100405125055.cdc1e279.akpm@linux-foundation.org>
References: <bug-15682-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, eduardo.panisset@gmail.com,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41984 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754388Ab0DETwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 15:52:19 -0400
In-Reply-To: <bug-15682-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 2 Apr 2010 17:34:35 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=15682
> 
>            Summary: XFRM is not updating RTAX_ADVMSS metric
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.28-2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: eduardo.panisset@gmail.com
>         Regression: No
> 
> 
> I have been testing DSMIPv6 code which uses all kind of advanced
> features of XFRM framework and I believe I have found a bug related to
> update RTAX_ADVMSS route metric.
> The XFRM code on net/xfrm/xfrm_policy.c by its functions
> xfrm_init_pmtu and xfrm_bundle_ok updates RTAX_MTU route caching
> metric however I believe it must update RTAX_ADVMSS as this later is
> used by tcp connect function for adverting the MSS value on SYN
> messages.
> 
> As MSS is not being updated by XFRM the TCP SYN messages (e.g.
> originated from a internet browser)  is erroneously informing its MSS
> (without taking into account the overhead added to IP packet size by
> XFRM transformations).  One result of that is the browser gets
> "frozen" after starts a TCP connection because TCP messages sent by
> TCP server will never get to it (TCP server is sending too large
> segments to browser).
> 
> Below I describe the changes I have done (on xfrm_init_pmtu and
> xfrm_bundle_ok) and that seem to fix this problem:
> 
> xfrm_init_pmtu:
>                  .
>                  .
>                  .
> 
>         dst->metrics[RTAX_MTU-1] = pmtu; // original code, below my changes
> 
>         if (dst->xfrm->props.mode == XFRM_MODE_TUNNEL)
>                  switch (dst->xfrm->props.family)
>                  {
>                  case AF_INET:
>                  dst->metrics[RTAX_ADVMSS-1] = max_t(unsigned int,
> pmtu - sizeof(struct iphdr) - sizeof(struct tcphdr), 256);
>                  break;
> 
>                  case AF_INET6:
>                  dst->metrics[RTAX_ADVMSS-1] = max_t(unsigned int,
> pmtu - sizeof(struct ipv6hdr) - sizeof(struct tcphdr),
>                             dev_net(dst->dev)->ipv6.
> sysctl.ip6_rt_min_advmss);
>                  break;
>                  }
> 
> xfrm_bundle_ok:
> 
>                .
>                .
>                .
> 
>         dst->metrics[RTAX_MTU-1] = mtu; // original code, below my changes
> 
>         if (dst->xfrm->props.mode == XFRM_MODE_TUNNEL)
>                 switch (dst->xfrm->props.family)
>                 {
>                 case AF_INET:
>                         dst->metrics[RTAX_ADVMSS-1] = max_t(unsigned
> int, mtu - sizeof(struct iphdr) - sizeof(struct tcphdr), 256);
>                 break;
> 
>                 case AF_INET6:
>                         dst->metrics[RTAX_ADVMSS-1] = max_t(unsigned
> int, mtu - sizeof(struct ipv6hdr) - sizeof(struct tcphdr),
> 
> dev_net(dst->dev)->ipv6.sysctl.ip6_rt_min_advmss);
>                 break;
>                 }
> 

