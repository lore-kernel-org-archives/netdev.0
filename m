From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH] ipv4: tcp: security_sk_alloc() needed for unicast_sock
Date: Thu, 09 Aug 2012 14:53:03 -0700
Message-ID: <5024313F.1010404@schaufler-ca.com>
References: <50215A7E.8000701@linaro.org>  <1344462889.28967.328.camel@edumazet-glaptop>  <5022FD9A.4020603@schaufler-ca.com> <1695034.0lrQgQPOMT@sifl>  <1344523833.28967.996.camel@edumazet-glaptop>  <CACLa4ptkvKj2GT4ZL+msMuWOHW885Hugk8nz3hvptOoY9-totw@mail.gmail.com> <1344547743.31104.582.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Paris <eparis@parisplace.org>,
	Paul Moore <paul@paul-moore.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	lkml <linux-kernel@vger.kernel.org>,
	James Morris <james.l.morris@oracle.com>,
	selinux@tycho.nsa.gov, john.johansen@canonical.com,
	LSM <linux-security-module@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Casey Schaufler <casey@schaufler-ca.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1344547743.31104.582.camel@edumazet-glaptop>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/9/2012 2:29 PM, Eric Dumazet wrote:
> On Thu, 2012-08-09 at 16:06 -0400, Eric Paris wrote:
>> NAK.
>>
>> I personally think commit be9f4a44e7d41cee should be reverted until it
>> is fixed.  Let me explain what all I believe it broke and how.
>>
> Suggesting to revert this commit while we have known working fixes is a
> bit of strange reaction.

A couple of potential short term workarounds have been identified,
but no one is happy with them for the long term. That does not
qualify as a "working fix" in engineering terms.

> I understand you are upset, but I believe we tried to fix it.
>
>> Old callchain of the creation of the 'equivalent' socket previous to
>> the patch in question just for reference:
>>
>>     inet_ctl_sock_create
>>       sock_create_kern
>>         __sock_create
>>           pf->create (inet_create)
>>             sk_alloc
>>               sk_prot_alloc
>>                 security_sk_alloc()
>>
>>
>> This WAS working properly.  All of it. 
> Nobody denies it. But acknowledge my patch uncovered a fundamental
> issue.
>
> What kind of 'security module' can decide to let RST packets being sent
> or not, on a global scale ? (one socket for the whole machine)

The short answer is "any security module that wants to".

And before we go any further, I'm a little surprised that
SELinux doesn't do this already.

>
> smack_sk_alloc_security() uses smk_of_current() : What can be the
> meaning of smk_of_current() in the context of 'kernel' sockets...

Yes, and all of it's callers - to date - have had an appropriate
value of current. It is using the API in the way it is supposed to.
It is assuming a properly formed socket. You want to give it a
cobbled together partial socket structure without task context.
Your predecessor did not have this problem.

>
> Your patch tries to maintain this status quo.
>
> In fact I suggest the following one liner patch, unless you can really
> demonstrate what can be the meaning of providing a fake socket for these
> packets.
>
> This mess only happened because ip_append_data()/ip_push_pending_frames()
> are so complex and use an underlying socket.
>
> But this socket should not be ever used outside of its scope.
>
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 76dde25..ec410e0 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -1536,6 +1536,7 @@ void ip_send_unicast_reply(struct net *net, struct sk_buff *skb, __be32 daddr,
>  			  arg->csumoffset) = csum_fold(csum_add(nskb->csum,
>  								arg->csum));
>  		nskb->ip_summed = CHECKSUM_NONE;
> +		skb_orphan(nskb);
>  		skb_set_queue_mapping(nskb, skb_get_queue_mapping(skb));
>  		ip_push_pending_frames(sk, &fl4);
>  	}
>
>
>

