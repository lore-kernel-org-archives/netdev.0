From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6.0-test9 : bridge freezes
Date: Mon, 15 Dec 2003 17:17:32 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031215171732.4877acd1.davem@redhat.com>
References: <Pine.LNX.4.44.0312151304350.8670-200000@sorbus2.navaho>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Hill <steve@navaho.co.uk>
In-Reply-To: <Pine.LNX.4.44.0312151304350.8670-200000@sorbus2.navaho>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 15 Dec 2003 13:15:44 +0000 (GMT)
Steve Hill <steve@navaho.co.uk> wrote:

> The memory that is leaking seems to be being allocated on line 299 on
> net/bridge/br_netfilter.c:
> 
>         if ((nf_bridge = nf_bridge_alloc(skb)) == NULL)
>                 return NF_DROP;
> 
> Only the first fragment gets freed later on.

I see.

> The patch attached fixes the problem by freeing nf_bridge when the 
> packets are defragmented, however I am sure this is not the right place 
> to do this.  Where would the skb's for the fragments usually get freed?
> 
> Bart De Schuymer suggested that they should be freed in 
> skbuff.c::skb_release_data(), but having looked at this it seems to do 
> this already.  skb_release_data() calls skb_drop_fraglist(), which does 
> kfree_skb() on each fragment, and kfree_skb calls nf_bridge_put correctly 
> so this isn't the problem.

There must be something in particular that the IPV4 fragmentation code
is doing that makes these fragment reference drops get forgotten.  Hmmm...

I just noticed that both bridge netfilter and IPV4 fragmentation make much
use of the skb->cb[] control block, this may be the true source of the
troubles.

In fact, since bridge netfilter expects pointers to be there, I'm surprised
this does not cause a crash.
