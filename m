From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC 0/9] snet: Security for NETwork syscalls
Date: Tue, 05 Jan 2010 08:26:15 +0100
Message-ID: <m2r5q5nhbc.fsf@ssh.synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
	<1262537872.10218.27.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1262537872.10218.27.camel@bigi> (hadi@cyberus.ca's message of
	"Sun, 03 Jan 2010 11:57:52 -0500")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Jamal,

jamal <hadi@cyberus.ca> writes:
> Hi Samir,
>
> This fills in a gap i always thought was missing from LSM's 
> boolean verdict policies. So good effort.
>
> 1)I would love to see the send/recvmsg interface complete (seems
> missing).

about the hook security_socket_sendmsg(), I added netlink attributes
SNET_A_BUFFER and SNET_A_BUFFERLEN, and get the buffer and the length
from the iov.iov_base and iov.iov_len at the security_socket_sendmsg()
so kernel part is now able to send those informations to userspace.

about sendmsg(), that's totaly different.
from what I understand, the call of the security_socket_recvmsg() is
made before the call of sock->ops->recvmsg(). As the buffer is not yet
copied until tcp_recvmsg(), no data are yet available at the
security_socket_recvmsg() hook.

I'm currently testing security_sock_rcv_skb() hook - which is inside
sk_filter() - to get skbuffs when then are arriving, and so trying to
push the buffer to userspace. In case this is not userfull, userspace
is able to use the NFQUEUE of netfilter to get skbuff, and deal
with incoming datas.
The idea in this later case is:
0. catching sshd listening on port TCP 12345, user is sam
1. receiving skbuff through NFQUEUE,
   skbuff shows it's TCP, and dport is 12345 
2. checking if we known the apps for this port
   (yes, it was catched at 0.)
3. DROP OR ACCEPT packet through NFQUEUE API regarding policy decision

the idea 'push security decision to userspace' is nothing if we don't
use all userspace APIs and tools.

> 2) If you can provide an async scheme which allows re-injection of
> policy verdicts in addition to the sync interface, i think that would be
> more valuable. I can see many apps which collect multiple states before
> making a policy decision on multiple messages (example a multipart
> message).

I didn't think about that yet. thanks
so let's start with a sync interface and mecanism, then we'll see what
we can do about this

> Is SNET_VERDICT_PENDING intended for this?

yes, SNET_VERDICT_PENDING the 'non-decision yet' state. so before
pushing the request to userspace, the verdict is set to this value.
I introduced a netlink attribute SNET_A_DELAY and a netlink command
SNET_C_DELAY, which provide the userspace the possibility increase the
timeout value for a specific request. path becomes :

kernel                                               userspace
request is PENDING timeout 5sec
push request to userspace
                           ----------->
                                        no decision is available yet
                                        DELAY the decision by 30 secs
                           <----------
increase the timeout value
for this verdict and wait

> A small glitch i noticed; you have defines in patches 8 and 9 which are
> needed by patches 6 and 7. I think the general idea should be to compile
> after adding each patch. So you may need to move some defines in earlier
> patches.

yes, currently, you have to apply all the patch in order.
for the true submission, I will introduce patch that compile at each
step. But for now I thought it's safe, because every code is in a new
source code file.

I will dig and fix Patrick's and Serge's remarks, then I will be back
with a new version.

thanks for your time Jamal
sam
