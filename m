From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: tcp: security_sk_alloc() needed for unicast_sock
Date: Thu, 09 Aug 2012 19:46:13 +0200
Message-ID: <1344534373.31104.34.camel@edumazet-glaptop>
References: <50215A7E.8000701@linaro.org> <1695034.0lrQgQPOMT@sifl>
	 <1344523833.28967.996.camel@edumazet-glaptop> <5799181.tjlnF0gIh2@sifl>
	 <1344526608.28967.1092.camel@edumazet-glaptop>
	 <CACLa4ptTfMzvhYk7_DaUJd-9u406FXf2CUHjn1mQrPDa4fFW4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paul Moore <paul@paul-moore.com>,
	David Miller <davem@davemloft.net>,
	Casey Schaufler <casey@schaufler-ca.com>,
	John Stultz <johnstul@us.ibm.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	lkml <linux-kernel@vger.kernel.org>,
	James Morris <james.l.morris@oracle.com>,
	selinux@tycho.nsa.gov, john.johansen@canonical.com,
	LSM <linux-security-module@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Paris <eparis@parisplace.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <CACLa4ptTfMzvhYk7_DaUJd-9u406FXf2CUHjn1mQrPDa4fFW4w@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-08-09 at 12:05 -0400, Eric Paris wrote:
> On Thu, Aug 9, 2012 at 11:36 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Thu, 2012-08-09 at 11:07 -0400, Paul Moore wrote:
> >
> >> Is is possible to do the call to security_sk_alloc() in the ip_init() function
> >> or does the per-cpu nature of the socket make this a pain?
> >>
> >
> > Its a pain, if we want NUMA affinity.
> >
> > Here, each cpu should get memory from its closest node.
> 
> I really really don't like it.  I won't say NAK, but it is the first
> and only place in the kernel where I believe we allocate an object and
> don't allocate the security blob until some random later point in
> time.

...

>   If it is such a performance issue to have the security blob in
> the same numa node, isn't adding a number of branches and putting this
> function call on every output at least as bad?  Aren't we discouraged
> from GFP_ATOMIC?  In __init we can use GFP_KERNEL.

What a big deal. Its done _once_ time per cpu, and this is so small blob
of memory you'll have to show us one single failure out of one million
boots.

If the security_sk_alloc() fails, we dont care. We are about sending a
RESET or ACK packet. They can be lost by the network, or even skb
allocation can fail. Nobody ever noticed and complained.

Every time we accept() a new socket (and call security_sk_alloc()), its
done under soft irq, thus GFP_ATOMIC, and you didn't complain yet, while
a socket needs about 2 Kbytes of memory...

> 
> This still doesn't fix these sockets entirely.  We now have the
> security blob allocated, but it was never set to something useful.
> Paul, are you looking into this?  This is a bandaide, not a fix....
> 

Please do so, on a followup patch, dont pretend I must fix all this
stuff.


