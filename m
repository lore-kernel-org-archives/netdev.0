From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Mon, 20 Sep 2004 07:20:34 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040919212033.GA9254@gondor.apana.org.au>
References: <E1C8way-0000aH-00@gondolin.me.apana.org.au> <414DF05E.7020601@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
Content-Disposition: inline
In-Reply-To: <414DF05E.7020601@eurodev.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Sep 19, 2004 at 10:47:26PM +0200, Pablo Neira wrote:
> 
> if netlink_broadcast_deliver returns 0, you decrease sock_put. On the 
> other hand if it returns 1, refcount will be decreased by the workqueue 
> handler or after calling the callback. I don't see that exit path.

I'm talking about the bits inside ifdef NL_EMULATE_DEV.
 
> yes, it's true that all those sock_put pollutes the source code, I like 
> your idea of add a sock_hold, please could you have a look at the patch 
> attached? it's basically your patch plus netlink_broadcast_deliver 
> revised return value. If you are ok with it, let me know.

It's OK apart from the fact that you missed the bits inside NL_EMULATE_DEV
again.
 
> Yes, it works as well so we could remove it, but I got some extra 
> throughput with the wake_up_process call if I send something up to 500 
> consecutive messages from kernel to user space. For more than 1000 I 
> notice that throughput is similar without wake_up_process, I'll study 
> the performance without wake_up_process if it's not a good idea using it 
> as you think.

I'm totally happy with the idea of improving the performance of netlink
applications.  However, let's do it properly rather than adding random
wake_up calls.

> >That's not what I meant.  If you have a thread group where everybody's
> >got the same pid, your code will probably wake up the wrong thread.
> 
> no, my patch doesn't wake up the user process with broadcast sockets, 
> snipped from broadcast_deliver:

You didn't understand me.  You're waking up a process based on its pid.
With thread groups this is simply broken.
 
> >Besides, for any netlink socket but the first for a process, they'll
> >all have negative pid's which have nothing to do with the real pid.
> >So I really think that the wake_up_process hunk is bogus.
> 
> same reply as above, we don't wake up the user process with broadcast 
> sockets.

I know, that's exactly the reason why it's bogus.  You're waking things
up on a completely arbitrary basis.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
