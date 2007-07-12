From: "Andrew Gallatin" <gallatin@gmail.com>
Subject: Re: [RFC 0/3] lro: Generic Large Receive Offload for TCP traffic
Date: Thu, 12 Jul 2007 12:01:53 -0400
Message-ID: <3cea2ee30707120901m6c5116c9q4ed0ee0c55222b19@mail.gmail.com>
References: <200707111621.24852.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Christoph Raisch" <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	"Marcus Eder" <meder@de.ibm.com>,
	"Thomas Klein" <tklein@de.ibm.com>, stefan.roscher@de.ibm.com,
	brice@myri.com, loic@myri.com
To: "Jan-Bernd Themann" <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.176]:37362 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763826AbXGLQBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 12:01:55 -0400
Received: by ik-out-1112.google.com with SMTP id b32so149425ika
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2007 09:01:54 -0700 (PDT)
In-Reply-To: <200707111621.24852.ossthema@de.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/11/07, Jan-Bernd Themann <ossthema@de.ibm.com> wrote:
> Generic Large Receive Offload proposal

I'm very glad that somebody is stepping up to take responsibility
for this!

I'm the primary author of the Myricom Myri10GE driver, and its LRO mechanism
(which has been rejected several times when posted here).  I don't subscribe
to the LKML or netdev lists (the b/w is way too much for me).
Thankfully, my colleague Brice (who maintains our driver in the kernel)
forwarded me this message.

I looked at your patch, and I believe that we can improve the
performance further by using a slightly different approach, or at
least making that approach optional.

When I first did our LRO implementation, it aggregated packets
essentially the same way you are doing it -- by appending packets to
the frag_list.  I did quite extensive profiling, and the most expensive
operations seemed to be the allocation and freeing of memory.  A
colleague of mine (Loic, CC'ed) came up with the brilliant idea of
receiving into pages.  When I implemented his suggestion, it turned
out to be much, much more efficient to receive into pages, and to
accumulate the pages to the frags array.

The benchmarks I did on very low end machines in my lab (2GHz
amd64 x2 3800+) showed that the receiver was saturated at roughly
4.2Gb/s without LRO, 5.7Gb/s with frag_list based LRO, 8.6Gb/s with
frags array based LRO, and somewhat idle at line rate with frags array
based LRO and 32KB order=3 pages. (This is 1500b frames, BTW).

The savings comes from being able to do fewer allocations.  For
example, 2 1500b packets fit in a single page.  So, for a "full" frag
array, we have 16 1/2 4KB pages and a single skb holding them.
This works out to be 9 allocations for roughly 23KB of payload,
rather than 16. Using order 3 (32KB) pages, it gets even better,
and we have just 2 allocations per full skb frag list.

So... It would be wonderful if your patch could also deal with
data residing in pages, rather than in skbs.  I can understand
how you might not want to modify your driver to do this, which
is why I'm asking about making it optional.  However,
your driver would probably benefit from receiving into
pages, and I encourage you to investigate that.

I'm picturing an additional path into lro, such as:

int lro_maybe_receive_frags(struct net_lro_mgr *lro_mgr,
                struct skb_frag_struct *frags,
                int len,  void *priv);


This would return 0 if the packet was "accepted", and an
error if it was not.  It would then call a modified
__lro_proc_skb() (perhaps better named __lro_proc_segment())
which would have the length as an argument (so as to avoid
the need to pass the skb to lro_tcp_ip_check()) in addition
to the *frags.

The only real additional work would be in having an alternate path
inside lro_init_desc() which allocated an skb to hang the pages from
if the passed skb was null, and in having an alternate
lro_add_packet() path which added the frag(s), rather than chaining an
skb.

Also, your patch does not seem to maintain TCP checksums.
To be fair, we did not maintain checksums in our earlier LRO
work either, and it was much simpler that way! :) However,
not maintaining the TCP checksum can lead to user complaints
(invalid csum reported by traffic sniffers), as well as problems
when various filtering software is used which attempts to
re-write the TCP header.

I would very much appreciate it if you could look at my LRO
implementation in our Myri10GE driver which has been
posted (and rejected) several times in the past by Brice.
The source code is also available at:
http://www.myri.com/ftp/pub/Myri10GE/myri10ge-linux.1.3.0.tgz.
It uses a page based approach, and it maintains correct TCP
checksums.

This driver is Dual BSD/GPL licensed, and you are free to take
whatever you like.

Thank you again for stepping up with a generic implementation!

Drew
