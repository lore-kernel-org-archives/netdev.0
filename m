From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] Extend netlink error codes
Date: 11 Sep 2004 17:10:35 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1094937035.2344.189.camel@jzny.localdomain>
References: <20040910225158.GO20088@postel.suug.ch>
	 <20040911155839.GN4431@wotan.suse.de>
	 <20040911162433.GC21181@postel.suug.ch>
	 <3A0D075D-0423-11D9-BBE1-000A95AD0668@errno.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Andi Kleen <ak@suse.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sam Leffler <sam@errno.com>
In-Reply-To: <3A0D075D-0423-11D9-BBE1-000A95AD0668@errno.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-09-11 at 14:48, Sam Leffler wrote:
> On Sep 11, 2004, at 9:24 AM, Thomas Graf wrote:
> 
> > * Andi Kleen <20040911155839.GN4431@wotan.suse.de> 2004-09-11 17:58
> >> IMHO it would be far better to just pass text errors
> >> in a variable length packet back.  It's a bit plan9ish,
> >> but it would work nicely here and be a bit improvement
> >> (especially for the qdiscs)
> >
> > I had the same idea and the only good way to do so would
> > be to add a char * errbuf or alike to struct netlink_opt
> > and access it via skb.sk.sk_protinfo.
> >
> > The bad side is that the for example cls and sch api don't
> > provide the skb to the implementing modules and therefore
> > they can't access the error buffer. I don't want to change
> > all netlink users because of this.
> >
> > Changing all paths back to netlink_ack to provide a struct
> > containing the errno and an additional text error buffer is
> > no option for me either.
> >
> > Correct me if I'm wrong.
> >

just reuse skb->cb[] and intepret it in rtnetlink in the case of
failures.

> A technique used for mbuf packet tags in FreeBSD is to define a 32-bit 
> cookie that uniquely identifies a module or ABI code and concatenate 
> this with the 16-bit tag number.  The ABI code is defined as the 
> date+time that the module is created, expressed as the number of 
> seconds since the epoch (e.g. the output of date -u +'%s').  Tag 
> numbers are meaningful only within the context of the module/ABI.  A 
> default/compatibility cookie is used for compatibility with previously 
> defined tag values.  This scheme effectively distributes management of 
> tags (so far there have been no collisions).

This sounds similar to the skb tags of different sorts that exist.
It does however bring out a good point into the discussion.
I think we need to identify errors by IDs - dont think we can avoid
that. The IDs could be the T in TLV; their scope is per socket level (eg
at rtnetlink); This means there are 16 bits space per socket type.
The next level to addressing is at each submodule level eg qdisc,
ipv4route, etc. Assuming we have 8 bits there that leaves upto 8 bits
per submodule for different error types. 256 error codes per submodule
liek a qdisc sounds very reasonable to me. We could reserve the last
entry for future extensions. Example:

socket: rtnetlink
submodule: qdisc (module 1)
error id: Q_NASTYTHING which is 0x10
qdisc_errors[Q_NASTYTHING] is "something really nasty just happened"

Then T = 0x110
L length(qdisc_errors[Q_NASTYTHING])
V = qdisc_errors[Q_NASTYTHING]

BTW, there was someone from IBM a while back who was talking about
having drivers send error messages via netlink; someone needs to look at
the ideas they have maybe we can borrow something.


cheers,
jamal
