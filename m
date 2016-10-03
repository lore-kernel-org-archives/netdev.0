From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: net: vrf: Handle ipv6 multicast and link-local addresses
Date: Mon, 3 Oct 2016 16:59:53 -0300
Message-ID: <20161003195953.GD12073@kernel.org>
References: <20160727215224.EB4E26611D4@gitolite.kernel.org>
 <CAMuHMdU6zpowkWgUW0+8Fhx7BmwTn=FvVBoTKXUgNzLeBpFrHg@mail.gmail.com>
 <1d0eb1d8-708f-2238-37c9-b75004804065@cumulusnetworks.com>
 <CAMuHMdWGX3owP=xr-hhr6gE9PFRFc55Rzsc1M1JVoFLHdmuUYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Ahern <dsa@cumulusnetworks.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:59458 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751388AbcJCUAH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Oct 2016 16:00:07 -0400
Content-Disposition: inline
In-Reply-To: <CAMuHMdWGX3owP=xr-hhr6gE9PFRFc55Rzsc1M1JVoFLHdmuUYQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Aug 03, 2016 at 10:27:44PM +0200, Geert Uytterhoeven escreveu:
> On Wed, Aug 3, 2016 at 10:11 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> > On 8/3/16 1:57 PM, Geert Uytterhoeven wrote:
> >>> +static void vrf_ip6_input_dst(struct sk_buff *skb, struct net_device *vrf_dev,
> >>> > +                             int ifindex)
> >>> > +{
> >>> > +       const struct ipv6hdr *iph = ipv6_hdr(skb);
> >>> > +       struct flowi6 fl6 = {
> >>> > +               .daddr          = iph->daddr,
> >>> > +               .saddr          = iph->saddr,
> >>> > +               .flowlabel      = ip6_flowinfo(iph),
> >> The above assignment causes the following compiler warning with
> >> m68k-linux-gnu-gcc-4.1:
> >>
> >>     drivers/net/vrf.c: In function ‘vrf_ip6_input_dst’:
> >>     drivers/net/vrf.c:870: warning: initialized field with
> >> side-effects overwritten
> >>     drivers/net/vrf.c:870: warning: (near initialization for ‘fl6’)
> >>
> >> Unfortunately I have no idea what it means, nor do I see what's wrong
> >> with the code.
> >
> > no idea. Fields are initialized once and left and right data types are the same.
> >
> > Can you remove one line at a time? Line 870 is ".flowi6_proto   = iph->nexthdr," but all of the flowi6 macros are unique references to unique fields in flowi_common. The flowlabel line you point out is a unique field as well.
> 
> The only thing that seems to matter is assigning the result of the call to
> ip6_flowinfo() to .flowlabel. Assigning a constant makes the warning go away.
> 
> Yeah, the 870 line number is funny, as it doesn't point to the offending line.
> 
> > Can you run pahole on file that did compile? e.g.,
> >
> > pahole -C 'flowi6' net/ipv6/route.o
> >
> > and get the common struct too:
> >
> > pahole -C 'flowi_common' net/ipv6/route.o
> 
> No output. Perhaps pahole doesn't play well with cross-compiling?

Can you send me this net/ipv6/route.o file? It should work as long as
CONFIG_DEBUG_INFO was used to build this cross kernel.

For instance, here cross compiling perf tools for s390 from a ubuntu
16.04 container running on a fedora 24 host, I get:

[root@jouet 14.04.4]# file /var/lib/docker/devicemapper/mnt/b7ba22999d88feebc42de2ea17fe27e94febf228439fccf2b84c0c9e1ccd8af7/rootfs/tmp/build/perf/perf
/var/lib/docker/devicemapper/mnt/b7ba22999d88feebc42de2ea17fe27e94febf228439fccf2b84c0c9e1ccd8af7/rootfs/tmp/build/perf/perf: ELF 64-bit MSB shared object, IBM S/390, version 1 (SYSV), dynamically linked, interpreter /lib/ld64.so.1, for GNU/Linux 3.2.0, BuildID[sha1]=22b27009c61130ed5727bcaf9ad0813d414b8c5a, not stripped
[root@jouet 14.04.4]#

Thus a s/390 object, that I then process from a x86_64 pahole:

[root@jouet 14.04.4]# file /home/acme/git/pahole/build/pahole
/home/acme/git/pahole/build/pahole: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 2.6.32, BuildID[sha1]=c90855d4ffa815bf0dddb3463bc45aea4855d0e2, not stripped
[root@jouet 14.04.4]# 

Giving these results:

[root@jouet 14.04.4]# pahole -C sockaddr_in6 /var/lib/docker/devicemapper/mnt/b7ba22999d88feebc42de2ea17fe27e94febf228439fccf2b84c0c9e1ccd8af7/rootfs/tmp/build/perf/perf
struct sockaddr_in6 {
	sa_family_t                sin6_family;          /*     0     2 */
	in_port_t                  sin6_port;            /*     2     2 */
	uint32_t                   sin6_flowinfo;        /*     4     4 */
	struct in6_addr            sin6_addr;            /*     8    16 */
	uint32_t                   sin6_scope_id;        /*    24     4 */

	/* size: 28, cachelines: 1, members: 5 */
	/* last cacheline: 28 bytes */
};
[root@jouet 14.04.4]#

Expanding types:

[root@jouet 14.04.4]# pahole --expand_types -C sockaddr_in6 /var/lib/docker/devicemapper/mnt/b7ba22999d88feebc42de2ea17fe27e94febf228439fccf2b84c0c9e1ccd8af7/rootfs/tmp/build/perf/perf
struct sockaddr_in6 {
	/* typedef sa_family_t */ short unsigned int         sin6_family;                /*     0     2 */
	/* typedef in_port_t -> uint16_t */ short unsigned int         sin6_port;        /*     2     2 */
	/* typedef uint32_t */ unsigned int               sin6_flowinfo;                 /*     4     4 */
	struct in6_addr {
		union {
			/* typedef uint8_t */ unsigned char __u6_addr8[16];              /*          16 */
			/* typedef uint16_t */ short unsigned int __u6_addr16[8];        /*          16 */
			/* typedef uint32_t */ unsigned int __u6_addr32[4];              /*          16 */
		} __in6_u;                                                               /*     8    16 */
	} sin6_addr; /*     8    16 */
	/* typedef uint32_t */ unsigned int               sin6_scope_id;                 /*    24     4 */

	/* size: 28, cachelines: 1, members: 5 */
	/* last cacheline: 28 bytes */
};
[root@jouet 14.04.4]#

etc.

Guess I need to put together a m68k target for building the perf tools (and
test pahole & friends on such objects)... :-)

- Arnaldo
