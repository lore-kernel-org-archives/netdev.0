From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: Tue, 10 Feb 2004 00:49:10 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402100042590.1251@u.domain.uli>
References: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
 <20040209135843.42b5b67e.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040209135843.42b5b67e.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Mon, 9 Feb 2004, David S. Miller wrote:

> > +				if (skb->stamp.tv_sec) {
>
> Julian, do you understand what this check is for?
>
> If it is zero, this means we are being reinvoked via the delayed proxy queue.
> It means that some previously delayed response has been kicked so that we
> should respond to it right now, with no delay, no matter what.

	Of course, there is no delay for !tv_sec, just answer or
do not answer, http://www.ssi.bg/~ja/tmp/arp_proxy-2.6.2-1.diff:

---
else
if (fwd_proxy && (n = rt->u.dst.neighbour) &&
	neigh_is_valid(n))
	goto out;
---

> Otherwise you could loop delaying the thing forever.  If there is a case
> where some pneigh ARP request should be evaluated multiple times, such
> a change belongs in the pneigh_*() code not here in ipv4 arp processing.
>
> The exact path is:
>
> 1) All input packets get skb->stamp.tv_sec assigned to in net/core/dev.c at
>    the waaaay beginning of input packet processing...
>
> 2) Therefore the first time skb goes through arp_rcv() skb->tv_sec will be
>    non-zero.
>
> 3) If it is pneigh_enqueue()'d, then skb->stamp.tv_sec will be set to zero
>    therefore upon reprocessing by arp_rcv() it will be seen as zero and this
>    is how such a state is detected.

	Absolutely correct, and it is done as you said, except if I
have some bug, of course :)

> Yes, I hate all of these overloaded meanings of skb->stamp.tv_* as much as
> anyone else.
>
> This is my contribution wrt. this suggested patch today, it's your turn to
> make some commentary Julian :-)

	You have to see the flood already :)

Regards

--
Julian Anastasov <ja@ssi.bg>
