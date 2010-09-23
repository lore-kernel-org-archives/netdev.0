From: David Lamparter <equinox@diac24.net>
Subject: Re: [ABI REVIEW][PATCH 0/8] Namespace file descriptors
Date: Thu, 23 Sep 2010 18:49:44 +0200
Message-ID: <20100923164944.GA1202237@jupiter.n2.diac24.net>
References: <m1ocborgq7.fsf@fess.ebiederm.org>
 <20100923151853.GC1160234@jupiter.n2.diac24.net>
 <m11v8kh142.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>, linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Ulrich Drepper <drepper@gmail.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	Ben Greear <greearb@candelatech.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m11v8kh142.fsf@fess.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 23, 2010 at 09:32:29AM -0700, Eric W. Biederman wrote:
> > At several occasions, I was left with either some runaway daemon which
> > kept the namespace alive. To describe this a little more graphically:
> > I found no other way than doing a
> > 	md5sum /proc/*/net/if_inet6 | sort | uniq -c -w 32
> > to find out which runaway to kill to terminate the namespace.
> >
> > This makes network namespaces particularly cumbersome to use without PID
> > namespaces. While I agree that a large part of the users - namely lxc -
> > will use them together, network namespaces without pidns are very
> > interesting for routing applications implementing VRFs.
> >
> > Is it possible to add some kind of "all namespaces" list, optimally
> > giving an opportunity to open() exactly this file descriptor that you
> > get from /proc/<pid>/ns/net?
> >
> > Also, is it possible to extend that file descriptor to have an
> > "get all pids" ioctl,
> > ...or, wait, maybe have /proc/...ns/proc/<pid> symlink?
> >
> > (This obviously isn't fully thought to the end, please pick up...)
> 
> Maybe.  I can understand the pain.
> 
> Is the problem you are facing you are shutting down a vrf and you want
> to make certain nothing is using it any longer?

Hrm. There are 2 and a half problems i can describe:

1) identifying namespaces. You can walk over /proc just fine and look at
   all processes namespaces, but you don't know which are actually the
   same aside from looking at some entry like if_inet6. There is no
   identifier and no easy equality match. (As far as i can tell.)

   Bonus difficulty: your patch will allow namespaces that have no
   process attached to them anymore since they only exist as files.
   Those will be invisible to someone running through /proc. Which leads
   to:
2) enumerating namespaces. Sure you can walk through /proc, but that's
   racy and won't even work with fd-only namespaces. It might even be a
   security risk if some trojan creates, say, a VLAN on your eth0, or a
   macvlan, hides it in a network namespace and communicates through it.

2 1/2) is terminating a namespace. It's not really a problem to add a
   PID namespace when you have "uncontrollable" daemons; however you
   can't be sure whether someone else took a reference on the network
   namespace from the outside.

These all are mainly administration/management issues, not that much
regular operation. Writing routing software with VRF support works just
fine, but the sysadmin can be at somewhat of an odd end here.


-David

