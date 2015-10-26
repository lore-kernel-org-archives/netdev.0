From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: Linux 4.2.4
Date: Mon, 26 Oct 2015 09:58:32 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1510260945510.17014@blackhole.kfki.hu>
References: <20151023003306.GA25388@kroah.com> <562C83FD.6010402@wiesinger.com> <20151025082547.GA22300@kroah.com> <20151025090308.GA17656@1wt.eu> <562CA13C.90500@wiesinger.com> <20151025094634.GA6832@1wt.eu> <562CB396.2080509@wiesinger.com>
 <alpine.DEB.2.10.1510252032420.14141@blackhole.kfki.hu> <562D36D9.9060504@wiesinger.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Willy Tarreau <w@1wt.eu>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org,
	Greg KH <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org, stable@vger.kernel.org, lwn@lwn.net,
	Jiri Slaby <jslaby@suse.cz>
To: Gerhard Wiesinger <lists@wiesinger.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <562D36D9.9060504@wiesinger.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 25 Oct 2015, Gerhard Wiesinger wrote:

> On 25.10.2015 20:46, Jozsef Kadlecsik wrote:
> > Hi,
> > 
> > On Sun, 25 Oct 2015, Gerhard Wiesinger wrote:
> > 
> > > On 25.10.2015 10:46, Willy Tarreau wrote:
> > > > ipset *triggered* the problem. The whole stack dump would tell more.
> > > OK, find the stack traces in the bug report:
> > > https://bugzilla.redhat.com/show_bug.cgi?id=1272645
> > > 
> > > Kernel 4.1.10 triggered also a kernel dump when playing with ipset
> > > commands
> > > and IPv6, details in the bug report  ....
> > It seems to me it is an architecture-specific alignment issue. I don't
> > have a Cortex-A7 ARM hardware and qemu doesn't seem to support it either,
> > so I'm unable to reproduce it (ipset passes all my tests on my hardware,
> > including more complex ones than what breaks here). My first wild guess is
> > that the dynamic array of the element structure is not aligned properly.
> > Could you give a try to the next patch?
> > 
> > diff --git a/net/netfilter/ipset/ip_set_hash_gen.h
> > b/net/netfilter/ipset/ip_set_hash_gen.h
> > index afe905c..1cf357d 100644
> > --- a/net/netfilter/ipset/ip_set_hash_gen.h
> > +++ b/net/netfilter/ipset/ip_set_hash_gen.h
> > @@ -1211,6 +1211,9 @@ static const struct ip_set_type_variant mtype_variant
> > = {
> >   	.same_set = mtype_same_set,
> >   };
> >   +#define IP_SET_BASE_ALIGN(dtype)	\
> > +	ALIGN(sizeof(struct dtype), __alignof__(struct dtype))
> > +
> >   #ifdef IP_SET_EMIT_CREATE
> >   static int
> >   IPSET_TOKEN(HTYPE, _create)(struct net *net, struct ip_set *set,
> > @@ -1319,12 +1322,12 @@ IPSET_TOKEN(HTYPE, _create)(struct net *net, struct
> > ip_set *set,
> >   #endif
> >   		set->variant = &IPSET_TOKEN(HTYPE, 4_variant);
> >   		set->dsize = ip_set_elem_len(set, tb,
> > -				sizeof(struct IPSET_TOKEN(HTYPE, 4_elem)));
> > +				IP_SET_BASE_ALIGN(IPSET_TOKEN(HTYPE,
> > 4_elem)));
> >   #ifndef IP_SET_PROTO_UNDEF
> >   	} else {
> >   		set->variant = &IPSET_TOKEN(HTYPE, 6_variant);
> >   		set->dsize = ip_set_elem_len(set, tb,
> > -				sizeof(struct IPSET_TOKEN(HTYPE, 6_elem)));
> > +				IP_SET_BASE_ALIGN(IPSET_TOKEN(HTYPE,
> > 6_elem)));
> >   	}
> >   #endif
> >   	if (tb[IPSET_ATTR_TIMEOUT]) {
> > 
> > If that does not solve it, then could you help to narrow down the issue?
> > Does the bug still appear if your remove the counter extension of the set?
> > 
> 
> Patch applied well, compiling ...
> 
> Interesting, that it didn't happen before. Device is in production for 
> more than 2 month without any issue.

You mean the device was stable with the earlier kernels, but starting with 
4.2.3 (and back to 4.1.10) you have got problems, don't you?
 
> Also any idea regarding the second isssue? Or do you think it has the 
> same root cause?

Looking at your RedHat bugzilla report, the "nf_conntrack: table full, 
dropping packet" and "Alignment trap: not handling instruction" are two 
unrelated issues and the second one is triggered by the unaligned counter 
extension acccess in ipset, I'm investigating. I can't think of any reason 
how those issues could be related to each other.

> Greetings from Vienna, Austria :-)

Quite near to my place :-) 

> BTW: You can get the Banana Pi R1 for example at:
> http://www.aliexpress.com/item/BPI-R1-Set-1-R1-Board-Clear-Case-5dB-Antenna-Power-Adapter-Banana-PI-R1-Smart/32362127917.html
> I can really recommend it as a router. Power consumption is as less as 3W.
> Price is also IMHO very good.

Cool mini gear, indeed!

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
