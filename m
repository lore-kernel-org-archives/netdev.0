From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next] netns: add and use net_ns_barrier
Date: Tue, 13 Jun 2017 20:07:13 +0200
Message-ID: <20170613180713.GA10130@breakpoint.cc>
References: <20170530093812.10712-1-fw@strlen.de>
 <87y3tcj3n7.fsf@xmission.com>
 <20170601085259.GA6067@breakpoint.cc>
 <CAM_iQpXgrQcbrQsMVoomcsHtk4JffRjJ27FLRoignndAzFVkug@mail.gmail.com>
 <20170613061656.GF18283@breakpoint.cc>
 <CAM_iQpUtZZBXQNB+tWJikQNmCHBot3tp7vAsc6+Xnh5H__6++g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        netfilter-devel@vger.kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:49576 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752168AbdFMSHx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 14:07:53 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpUtZZBXQNB+tWJikQNmCHBot3tp7vAsc6+Xnh5H__6++g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Mon, Jun 12, 2017 at 11:16 PM, Florian Westphal <fw@strlen.de> wrote:
> > Cong Wang <xiyou.wangcong@gmail.com> wrote:
> >> On Thu, Jun 1, 2017 at 1:52 AM, Florian Westphal <fw@strlen.de> wrote:
> >> > Joe described it nicely, problem is that after unload we may have
> >> > conntracks that still have a nf_conn_help extension attached that
> >> > has a pointer to a structure that resided in the (unloaded) module.
> >>
> >> Why not hold a refcnt for its module?
> >
> > That would work as well.
> >
> > I'm not sure its nice to disallow rmmod of helper modules if they are
> > used by a connection however.
> 
> I am _not_ suggesting to disallow rmmod.

My point was that if you hold reference counts to the module users
will need to manually flush conntrack table (or at least manually
remove affected connections), else rmmod won't work as refcount might be
gt 0.

> > Right now you can "rmmod nf_conntrack_foo" at any time and this should
> > work just fine without first having to flush affected conntracks
> > manually.
> 
> My point is that since netns wq could invoke code of that module,
> why it doesn't hold a refcnt of that module?

*shrug*, I did not write this stuff.

Historically it wasn't needed because we just clear out the helper area
in the affected conntracks (i.e, future packets are not inspected by
the helper anymore).

When conntracks were made per-netns this problem was added as we're not
guaranteed to see all net namespace because module_exit and netns cleanup
can run concurrently.

We can still use the "old" model if we guarantee that we wait for
netns cleanup to finish (which is what this patch does).

The alternative, as you pointed out, is to take a module reference for
each conntrack that uses the helper (and put again when connection is
destroyed).

I don't really care that much except that if we go for the latter
solution users cannot "just rmmod" the module anymore but might have
to manually remove the affected connections first.

Pablo, I can rework things to do module get/put but I ask for explicit
instructions to do so (I prefer the "barrier" approach).
