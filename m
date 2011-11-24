From: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Thu, 24 Nov 2011 08:19:39 -0500
Message-ID: <1322140779.1949.191.camel@mojatatu>
References: <20111123075433.GA7928@gondor.apana.org.au>
	<1322035942.1298.56.camel@edumazet-laptop>
	<1322052463.2039.135.camel@mojatatu>
	<1322052938.17693.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1322055858.2039.188.camel@mojatatu>  <4ECD19AC.8090505@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Lennert Buytenhek <kernel-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <4ECD19AC.8090505-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-11-23 at 08:05 -0800, John Fastabend wrote:

> > Makes sense in most cases. If you have a lot of flow setup/teardown
> > it may harm.
> 
> We could have a CONFIG option to always do locking in some
> cases if thats not too ugly.

What i mean is RCU is useful when you have a substantially 
larger reads over writes(DEL/updates). The later comes up
when you are setting up and tearing down state all the
time. Actually, I think conntrack uses rcu now - that would
be a good metric of how much useful it is since conntrack
falls under this category.

> I assume you mean something like setup_tc() which we have
> today to call into into the driver at qdisc create time. This
> happens with the RTNL held. I don't see any reason not to also
> call into the hardware on qdisc_change() I just haven't done
> it yet.

Yes, the operative piece is "also". In other words, I should be
able to run tc qdisc blah and not see the difference.
In the distant past what i have done in the case of absence of software
support is to write the "hwardware" scheduler in the kernel. If we
already have the hardware support, then there is no need for that step.
Let tc be responsible for controlling this "hardware" qdisc. It doesnt
talk to the hardware.
A user space helper app listens to things being added and deleted by
tc in the kernel and synchronizes them via a driver-specific call.
Different drivers tend to have different lower layer "hard-coded" 
ways of setting up the hardware; so you may end up with different
backends.
The challenge is synchronizing stats.

> Although I'm pretty sure we don't want to add a new ndo_ops
> ever time we have some hardware feature we want to expose.
> Assuming there are more than 1 or 2 hw features. So maybe
> we could convert to something more generic. A setup_qos()
> call that passes an skb with nl attributes.

You only need one - call it "hardware_setup" so you can do
other esoteric things with it.

> Is that what you were asking?

Something like that. I described how i did it - but thats because
I wanted to make zero changes to the kernel. It is better to have
kernel support of some sort but you dont want to do too much
otherwise you start adding a lot of shit in the kernel like
the infiniband guys. Have a user space helper when in doubt.
I almost forgot, a good example (of good work in the kernel already)
you wanna take  a look at is something Lennert (added to CC) did for
Marvel chips (i think it is called DSA). 

> One of the problems this resolves is not being able to
> call the classifier-actions until after the queue is
> already selected. At this point you can't send it to
> a higher/lower priority queue.
> 

Still blanking out - will wait for the code to comment.

cheers,
jamal
