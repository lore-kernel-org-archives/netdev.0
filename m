From: jamal <hadi@cyberus.ca>
Subject: Re: More tc action mess
Date: 20 Jan 2005 08:44:23 -0500
Message-ID: <1106228663.1041.94.camel@jzny.localdomain>
References: <41EDEB97.3080503@trash.net>
	 <1106140256.1049.903.camel@jzny.localdomain>  <41EEC19B.3010504@trash.net>
	 <1106195414.1048.34.camel@jzny.localdomain>  <41EF5091.9040402@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41EF5091.9040402@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-01-20 at 01:32, Patrick McHardy wrote:

> It seems to be more clever than I initially realized :) 

Praise be to the people behind pskb_expand (Alexey and Dave). Amen.

> But it does need
> some fixing for ipt. The ->act function takes a struct sk_buff **, which
> implies the skb might get replaced, but tcf_action_exec only takes a struct
> sk_buff * and doesn't own the skb. 
> So if the skb is replaced in the action the owner ends up with a pointer to 
> freed memory. pskb_expand_head is not
> enough to stop netfilter from copying, at ingress the the skb might be
> nonlinear, in which case it is copied. On egress it seems fine.

The whole idea behind the psk_expand is to _copy_ the data while
preserving the skb head i.e anyone in the path before the expand
continues to see the old data (tcpdump for example or copied packets via
mirror in the preceeding actions etc) and anyone after the expand sees
the new data ;->. Thats the punch line. So there is no problem with
tcf_action_exec() way of life.
I have some very simple environmental rules which say
"thou shalt call skb_expand in the case someone else is referencing the
skb". Unfortunately since i have no control over netfilter, its safer to
just expand everytime. I added the check for skb cloned after i saw the
changes for make_writeable(?) going in. But it may be too dangerous an
assumption. 
I thought netfilter already freed after copying - unless this has
changed since about 2.6.5 when i last studied things, there should be no
memory leak.
Can you get non-linear skbs on ingress? Recall, this is right after
packet comes off the NIC. I dont see them at the moment until some
clever NIC appears in the market.

> >Give me some examples which show something is broken then we can have a
> >more coherent discussion. I am willing to kill ipt if it is the problem.
> >
> Instead of killing ipt we could teach netfilter to be smarter about this.
> If the data that needs to be mangled is in the non-linear range we could
> just linearize the skb. 

I have no issue incuring a penalty when using ipt. Its unfortunate, but
fine. I cant see any memory leak if copying includes freeing in
netfilter already (and in particular that the new scheme seemed to be
using expand as well). If that is changed in netilter, restoring it
would probably be a good idea.
One thing that would be really useful is to be able to tell netfilter
its ok to mangle the packet without copying it. Or vice versa receive a
signal from it to say "packet has been mangled" so actions can trample
some more on it.

> Additionally we should change act_api to only pass
> single skb pointers around, to avoid all confusion and possible trouble.

tou mean exec() call? I would prefer not to do this. My brain has
already sweated enough to make sure that this works and performance is
good. 

> This seems a lot better than changing almost entire net/sched to pass
> double pointers around :)

While i did entertain this thought before submitting the code, and
infact that was the avenue i started at, i was pretty sure Dave+Alexey
would never have accepted the code (and for a very good reason too) ;->
So nobody ever saw the code ;->

cheers,
jamal
