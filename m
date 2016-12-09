From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: netlink: GPF in sock_sndtimeo
Date: Fri, 9 Dec 2016 06:01:55 -0500
Message-ID: <20161209110155.GW22655@madcap2.tricolour.ca>
References: <20161129164859.GD26673@madcap2.tricolour.ca>
 <CAM_iQpX_KBEpL1dCBNMgZQ-VQJM9nmsVdRPVK-Aen9k0gV3f0w@mail.gmail.com>
 <20161130045207.GE26673@madcap2.tricolour.ca>
 <20161209060248.GT22655@madcap2.tricolour.ca>
 <CAM_iQpWRe0tDk=wvXONG7hamH3EtE0nJuAOF1kVKJgdpMvz2DA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-audit@redhat.com, Paul Moore <pmoore@redhat.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Johannes Berg <johannes.berg@intel.com>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAM_iQpWRe0tDk=wvXONG7hamH3EtE0nJuAOF1kVKJgdpMvz2DA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-12-08 22:57, Cong Wang wrote:
> On Thu, Dec 8, 2016 at 10:02 PM, Richard Guy Briggs <rgb@redhat.com> wrote:
> > I also tried to extend Cong Wang's idea to attempt to proactively respond to a
> > NETLINK_URELEASE on the audit_sock and reset it, but ran into a locking error
> > stack dump using mutex_lock(&audit_cmd_mutex) in the notifier callback.
> > Eliminating the lock since the sock is dead anways eliminates the error.
> >
> > Is it safe?  I'll resubmit if this looks remotely sane.  Meanwhile I'll try to
> > get the test case to compile.
> 
> It doesn't look safe, because 'audit_sock', 'audit_nlk_portid' and 'audit_pid'
> are updated as a whole and race between audit_receive_msg() and
> NETLINK_URELEASE.

This is what I expected and why I originally added the mutex lock in the
callback...  The dumps I got were bare with no wrapper identifying the
process context or specific error, so I'm at a bit of a loss how to
solve this (without thinking more about it) other than instinctively
removing the mutex.

Another approach might be to look at consolidating the three into one
identifier or derive the other two from one, or serialize their access.

> > @@ -1167,10 +1190,14 @@ static void __net_exit audit_net_exit(struct net *net)
> >  {
> >         struct audit_net *aunet = net_generic(net, audit_net_id);
> >         struct sock *sock = aunet->nlsk;
> > +
> > +       mutex_lock(&audit_cmd_mutex);
> >         if (sock == audit_sock) {
> >                 audit_pid = 0;
> > +               audit_nlk_portid = 0;
> >                 audit_sock = NULL;
> >         }
> > +       mutex_unlock(&audit_cmd_mutex);
> 
> If you decide to use NETLINK_URELEASE notifier, the above piece is no
> longer needed, the net_exit path simply releases a refcnt.

Good point.  It would have already killed it off.  So this piece is
arguably too late anyways.

- RGB

--
Richard Guy Briggs <rgb@redhat.com>
Kernel Security Engineering, Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635
