From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC 0/9] snet: Security for NETwork syscalls
Date: Sun, 10 Jan 2010 11:20:38 -0500
Message-ID: <1263140438.11273.29.camel@bigi>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
	 <1262537872.10218.27.camel@bigi>  <m2r5q5nhbc.fsf@ssh.synack.fr>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Samir Bellabes <sam@synack.fr>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <m2r5q5nhbc.fsf@ssh.synack.fr>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Samir,
Apologies for the latency. Just caught up with the discussion.

On Tue, 2010-01-05 at 08:26 +0100, Samir Bellabes wrote:
> Hello Jamal,
> 
> jamal <hadi@cyberus.ca> writes:

> about the hook security_socket_sendmsg(), I added netlink attributes
> SNET_A_BUFFER and SNET_A_BUFFERLEN, and get the buffer and the length
> from the iov.iov_base and iov.iov_len at the security_socket_sendmsg()
> so kernel part is now able to send those informations to userspace.

This looks reasonable. Playing around with it will provide better
insight.

> about sendmsg(), that's totaly different.

I think you meant recvmsg

> from what I understand, the call of the security_socket_recvmsg() is
> made before the call of sock->ops->recvmsg(). As the buffer is not yet
> copied until tcp_recvmsg(), no data are yet available at the
> security_socket_recvmsg() hook.
> 

This is not true for all socket domains. Example, not true for unix or
tipc etc. In any case, I think it should be feasible to do the copy
earlier for udp/tcp/icmp and make it optional to turn on this
(early-copy) feature. 

> I'm currently testing security_sock_rcv_skb() hook - which is inside
> sk_filter() - to get skbuffs when then are arriving, and so trying to
> push the buffer to userspace. In case this is not userfull, userspace
> is able to use the NFQUEUE of netfilter to get skbuff, and deal
> with incoming datas.
> The idea in this later case is:
> 0. catching sshd listening on port TCP 12345, user is sam
> 1. receiving skbuff through NFQUEUE,
>    skbuff shows it's TCP, and dport is 12345 
> 2. checking if we known the apps for this port
>    (yes, it was catched at 0.)
> 3. DROP OR ACCEPT packet through NFQUEUE API regarding policy decision
> 
> the idea 'push security decision to userspace' is nothing if we don't
> use all userspace APIs and tools.
> 

I would rather have one unified interface instead of one from nfqueue
and another from your work. Besides, nfqueue works with a very limited
socket domains. It will be a lot easier to use the security hooks
instead.
I dont think it is wrong to replicate the nfqueue type approach for your
case.

> > 2) If you can provide an async scheme which allows re-injection of
> > policy verdicts in addition to the sync interface, i think that would be
> > more valuable. I can see many apps which collect multiple states before
> > making a policy decision on multiple messages (example a multipart
> > message).
> 
> I didn't think about that yet. thanks
> so let's start with a sync interface and mecanism, then we'll see what
> we can do about this

Could you not just replicate nfqueu approach?

> > Is SNET_VERDICT_PENDING intended for this?
> 
> yes, SNET_VERDICT_PENDING the 'non-decision yet' state. so before
> pushing the request to userspace, the verdict is set to this value.
> I introduced a netlink attribute SNET_A_DELAY and a netlink command
> SNET_C_DELAY, which provide the userspace the possibility increase the
> timeout value for a specific request. path becomes :
> 
> kernel                                               userspace
> request is PENDING timeout 5sec
> push request to userspace
>                            ----------->
>                                         no decision is available yet
>                                         DELAY the decision by 30 secs
>                            <----------
> increase the timeout value
> for this verdict and wait

This is still a synchronous approach with some workaround. It may be
sufficient but you have other problems in cases you cant sleep in;

For async, something along the nfqueue approach or ipsec/xfrm ACQUIRE
approach where state is maintained in the kernel, you shoot the data to
user space and terminate the code path; later on, the data is
re-injected, you lookup the state and continue processing would do.
Given that someone already pointed out that you will have problems
with some code paths because you cant sleep, i believe an async approach
will solve at least that particular issue.

cheers,
jamal



