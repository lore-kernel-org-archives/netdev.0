From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [BK ChangeSet@1.1118.1.1] new module infrastructure for
  net_proto_family
Date: Wed, 23 Apr 2003 18:41:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20030423182014.07ec6140@unixmail.qualcomm.com>
References: <5.1.0.14.2.20030423134636.100e5c60@unixmail.qualcomm.com>
 <5.1.0.14.2.20030423114915.10840678@unixmail.qualcomm.com>
 <20030423192640.GD26052@conectiva.com.br>
 <5.1.0.14.2.20030423134636.100e5c60@unixmail.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: acme@conectiva.com.br, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030423.163043.41633133.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

At 04:30 PM 4/23/2003, David S. Miller wrote:
>   From: Max Krasnyansky <maxk@qualcomm.com>
>   Date: Wed, 23 Apr 2003 15:51:11 -0700
>
>   >This is just the first part, DaveM already merged the second part,
>   >that deals with struct sock 
>
>   That's exactly what surprised me. He rejected complete patch and
>   accepted something incomplete and broken.
>
>No, it was not broken, because he told me completely where he
>was going with his changes. 
Of course it was and still is. New socket is allocated without incrementing 
modules ref count in sys_accept().

>He was building infrastructure piece by piece, and that's always an acceptable 
>way to do things as long as it is explained where one is going with the changes.
Oh, I see. And I just sent a patch without any explanation. Ok. 
(you might want to reread our original discussion again).

>Your stuff was unacceptable from the start because you didn't put
>the ->owner into the protocol ops.
But you didn't tell me that. You just said that it's "an ugly hack" without
giving any other feedback.
 
->owner field in protocol ops did come up during discussion (I think Rusty brought 
that up) and I explained why it shouldn't be there. But again there was no feed back 
from you. You just ignored that thread at some point. 

btw I still don't see ->owner in protocol ops. I read archives of netdev. You guys 
didn't even talk about that.

Anyway it's not important who said what now. You chose to ignore stuff that I did, fine.
What about this though

>>struct sock *sk_alloc(int family, int priority, int zero_it, kmem_cache_t *slab)
>>{
>>- struct sock *sk;
>>- 
>>+ struct sock *sk = NULL;
>>+
>>+ if (!net_family_get(family))
>>+ goto out;
>Ok. This is wrong. Which should be clear from reading the thread that I mentioned.
>Owner of the net_proto_family is not necessarily the owner of the 'struct sock'.
>Example: af_inet module registers net_proto_family but udp module owns the socket.
>(not that IPv4 code is modular but just an example). Another example would be Bluetooth.
>We have Bluetooth core that registers Bluetooth proto_family and several modules
>that handle specific protocols (l2cap, rfcomm, etc).
>
>Also net_proto_family has pretty much nothing to do with the struct sock. The only reason 
>we would want to hold reference to the module is if the module has replaced default 
>callbacks (i.e. sk->data_ready(), etc).
>So my point is we need sk->owner field. 
>
>I'd also prefer to see sock->owner which gives more flexibility (i.e. net_proto_family can 
>be unregistered while struct socket still exist, etc). 
>net_family_get/put() makes no sense net_proto_family has only one function npf->create() 
>which is referenced only from net/socket.c. struct socket should inherit owner field from
>struct net_proto_family by default but protocol should be able to assign ownership to a 
>different module if it needs to.

Max
