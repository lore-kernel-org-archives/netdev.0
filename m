From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH BUGFIX -rc4] Smack: Respect 'unlabeled' netlabel mode
Date: Fri, 30 May 2008 17:37:48 -0700 (PDT)
Message-ID: <806671.48689.qm@web36606.mail.mud.yahoo.com>
References: <20080531005826.GA6945@ubuntu>
Reply-To: casey@schaufler-ca.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Paul Moore <paul.moore@hp.com>,
	linux-security-module@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: "Ahmed S. Darwish" <darwish.07@gmail.com>,
	Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080531005826.GA6945@ubuntu>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- "Ahmed S. Darwish" <darwish.07@gmail.com> wrote:

> Hi Casey,
> 
> On Fri, May 30, 2008 at 04:10:37PM -0700, Casey Schaufler wrote:
> > 
> > 
> > To date the behavior of a Smack system running with nltype
> > unlabeled has been carefully undefined. 
> >
> 
> In the early days (before the 'Smack: unlabeled outgoing ambient packets'
> patch - 4bc87e62), I used '$ echo unlabeled > /smack/nltype' in my startup 
> scripts to avoid sending cipso-affected packets. When I upgraded this 
> machine's kernel, I faced the -EPERM problem mentiond above. 

Ok. I haven't done much work with nltype != CIPSO since that change.
Since that change the behavior with nltype == CIPSO appears to meet
most people's needs because:
   - there's a way to talk to non-cipso systems (use the ambient label)
   - you can talk multi-label to cipso aware systems (including yourself)

> > The way you're defining
> > it will result in a system in which only processes running with
> > the ambient label will be able to use sockets, unless I'm reading
> > the code incorrectly. 
> 
> I've tried to see the relation but failed, any help?

Unlabeled packets have to all be treated as having the same label.
That's what the ambient label is for. If you turn off cipso all
packets must be treated as if they came from ambient labeled processes.
If a process is running at some other label, and there is no rule
to allow the ambient label subject to write to that process' label
the packet can't be delivered. Thus, only ambient label processes
will be able to use sockets.

> I'm noticing the opposite though, without defining nltype=unlabeled, 
> we're forcing every smack-labeled process to send cipso-affected 
> packets (and usually no machine around understands cipso).

Except at the ambient label, which sends packets unlabeled.
Unlabeled packets get the ambient label and are delivered only
to sockets that an ambient label subject can write to.
This is the desired behavior. We don't want to deliver unlabeled
packets to sockets that can't be writen to by ambient labeled subjects.

> _Assuming_ the concept is accepted, depending on the ambient label
> may actually lead to a race condition though:
> 
> - A packet is set with the ambient label domain
> - Ambient label changes
>   - old ambient-label netlabel domain is deleted
>   - new ambient-label is set
>   - new ambient-label netlabel domain is created
> - call netlabel_sock_setattr(), uses the old ambient label, leads
>   to the -EPERM problem.
>   -- Rare, but can happen

I would consider additional restrictions on changing the
ambient label and nltype. They should not be changing on
a running system once it gets going.


> There are two possible solutions in my mind:
> 
> - Using a predefined netlabel domain to denote to unlabeled packets.
>   Defect: May collide with a user chosen label and used to break security.
>   Solution: Use a domain name that can't become a label (Hackery ?)
> 
> - I've tried first to use what was done before the 'Smack: unlabeled outgoing
> 
>   ambient packets' patch, which honored nltype=unlabeled, but ignored
> netlabel
>   completely:
>   i.e.
> 
>   int rc = 0;
>   if (secattr.flags != NETLBL_SECATTR_NONE)
>        rc = netlbl_sock_setattr(sk, &secattr);
>   return rc
> 
>   Paul, would this be right from a netlabel perspective ?

It might be that the right thing to do is remove nltype unlabeled.
It's pretty pointless with the cipso nltype dealing with unlabeled
packets by treating them as ambient.


Casey Schaufler
casey@schaufler-ca.com
