From: jamal <hadi@cyberus.ca>
Subject: Re: More tc action mess
Date: 19 Jan 2005 23:30:14 -0500
Message-ID: <1106195414.1048.34.camel@jzny.localdomain>
References: <41EDEB97.3080503@trash.net>
	 <1106140256.1049.903.camel@jzny.localdomain>  <41EEC19B.3010504@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41EEC19B.3010504@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-01-19 at 15:22, Patrick McHardy wrote:
> jamal wrote:
> 
> >On Wed, 2005-01-19 at 00:09, Patrick McHardy wrote:
> >  
> >
> >>This means we must convert all paths on which tcf_action_exec is called
> >>to use struct sk_buff ** :(
> >>    
> >>
> > 
> >
> >No, just restore the code that you took out in one of your patches
> >right above that line which reads:
> >
> >----
> >        if (skb_cloned(skb)) {
> >                if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
> >                        return -1;
> >                }
> >        }
> >----
> >
> >Depending on what you do in netfilter lately, you may wanna take out
> >the skb_cloned() call.
> >  
> >
> 
> This does not help. Netfilter calls skb_ip_make_writable if it has to
> touch the packet, if it is shared or cloned the packet will be copied.

for ipt, just restore:

if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) 
	return -ENOMEM

for the rest, the action code will handle all just fine. There will only
be one copy per serious of tramplings. This is design intent.

Note when i said i had issues with iptable targets, it has absolutely
nothing to do with this - quiet a few of iptable targets i tested work
fine; the problem was that the ones that didnt work were crashing and i
did trace to some missing checks (which would be non-issue if the
invocation was made from netfilter). I still need your help on this.
 
> Despite this, this is hardly a fix as long as the ->act function takes
> a struct sk_buff **.

Are shared skbs broken or do you see any memory leaks? These would be
worth fixing[1]. 
Give me some examples which show something is broken then we can have a
more coherent discussion. I am willing to kill ipt if it is the problem.
cheers,
jamal

[1]Yes, someday it may be worth going through all of the stack and
easing the way skbs are shuttled around so we dont need to play games;
but even i didnt dare when i was doing this code given the amount of
work and intrusiveness involved. 
