From: Florian Westphal <fw-kernel@strlen.de>
Subject: Re: [PATCH] TIPC: Fix infinite loop in netlink handler
Date: Wed, 20 Jun 2007 18:12:08 +0200
Message-ID: <20070620161208.GI4383@Chamillionaire.breakpoint.cc>
References: <46784B7F.8050903@trash.net> <AF1602CB2550CE4381C0C75118A7856B0135AC94@ala-mail02.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, jon.maloy@ericsson.com,
	netdev@vger.kernel.org, per.liden@ericsson.com
To: "Stephens, Allan" <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:42594 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752134AbXFTQMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2007 12:12:21 -0400
Content-Disposition: inline
In-Reply-To: <AF1602CB2550CE4381C0C75118A7856B0135AC94@ala-mail02.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephens, Allan <allan.stephens@windriver.com> wrote:
[removed tipc-discussion list from CC]
> Patrick McHardy wrote:
> > Florian Westphal wrote:
> > > -		genlmsg_unicast(rep_buf, req_nlh->nlmsg_pid);
> > > +		genlmsg_unicast(rep_buf, NETLINK_CB(skb).pid);
> > 
> > 
> > This is the second time we're seeing this bug within a few 
> > weeks, maybe we should rename NETLINK_CB(skb).pid to dst_pid 
> > to avoid similar confusion in the future? We could even 
> > rename nlmsg_pid to nlmsg_src within the kernel, which should 
> > make it completely clear what is being refered to.
> 
> I'm assuming that Patrick's first suggestion should have read "rename
> NETLINK_CB(skb).pid to src_pid", as there is already a "dst_pid" field
> in the netlink_skb_parms structure type.

Hmm, this dst_pid got removed in commit
4e9b82693542003b028c8494e9e3c49615b91ce7.

And im actually not sure if a rename would really help things.
The problem was/is the usage of the original header value (which works just
fine if userspace plays along). So the only real solution
would be to update the nlmsg_pid value to the NETLINK_CB(skb).pid if
it is 0 before the 'doit' callback in genl_rcv_msg() -- and this seems
just the wrong thing to to. Plus, there is a snd_seq field in the info
structure passed to the callback which always has the NETLINK_CB(skb).pid.


Perhaps something like the following would be a start?

./include/linux/netlink.h:
-         __u32           nlmsg_pid;      /* Sending process port ID */
+         __u32           nlmsg_pid;      /* Sending process port ID -
+  must not be used as destination parameter with
+  genlmsg_unicast() and friends as it might be 0 meaning 'send to kernel' */

Thoughts?
