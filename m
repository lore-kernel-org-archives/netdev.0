From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Sun, 19 Sep 2004 17:58:52 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C8way-0000aH-00@gondolin.me.apana.org.au>
References: <414D0CCD.90209@eurodev.net>
Cc: herbert@gondor.apana.org.au, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pablo@eurodev.net (Pablo Neira)
In-Reply-To: <414D0CCD.90209@eurodev.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pablo Neira <pablo@eurodev.net> wrote:
> 
> you are right, I missed that, but I prefer the patches attached to this 
> email. Now if netlink_broadcast_deliver function delivers correctly the 
> packet, you decrease sock refcount and function returns 1. I think that 
> I got confused because netlink_broadcast_deliver returns 0/-1.

Unfortunately it is still wrong.  You missed the exit path at the
very top.

And I think rather than adding all these new sock_put's, it's much
better to do what you mean and add a sock_hold on the new path that
you introduced.

>>Secondly, I'm dubious about the patch as a whole.  For instance, what
>>exactly is the wake_up_process() bit trying to do? Surely that process
>>would've been woken up multiple times already if its queue is full.
> 
> This is what I theorically expected, but in practice if you stress a 
> netlink socket sending a big bunch of information in a short period of 
> time from kernel space to user space, socket overruns easily. That's why 
> I wake up the user process to make it process information stored in the 
> queue. Socket doesn't overrun anymore with my patch.

Yes but your patch does a lot more than that wake_up_process.  Have you
reverted just the wake_up_process and seen a difference?

>>And what is it going to do with thread groups?
> 
> currently broadcast sockets can still overrun. I have a set of patches 
> that I'll submit as soon as I test them and I finish my boring exams.

That's not what I meant.  If you have a thread group where everybody's
got the same pid, your code will probably wake up the wrong thread.

Besides, for any netlink socket but the first for a process, they'll
all have negative pid's which have nothing to do with the real pid.
So I really think that the wake_up_process hunk is bogus.

BTW I apologise for the few bounces that you got from my mail server.
It should be fixed now.  If you're still getting bounces, please let
me know via the list.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
