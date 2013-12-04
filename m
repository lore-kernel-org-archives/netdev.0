From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Change in IPv4 TCP reset behavior after kernel upgrade
Date: Wed, 4 Dec 2013 23:02:38 +0100
Message-ID: <20131204220238.GA9110@order.stressinduktion.org>
References: <2ECE9D9EEF1F524185270138AE2326593BF9B5EE@S0MSMAIL112.arc.local> <CADVnQynL6=91zAZXMAoKEeCY7=Eajfq1DyP+Dzd8xhzBhujtyQ@mail.gmail.com> <2ECE9D9EEF1F524185270138AE2326593BF9B935@S0MSMAIL112.arc.local> <20131204175610.GB27943@order.stressinduktion.org> <1386181774.30495.113.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Fiedler Roman <Roman.Fiedler@ait.ac.at>,
	Neal Cardwell <ncardwell@google.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:59927 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754906Ab3LDWCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 17:02:39 -0500
Content-Disposition: inline
In-Reply-To: <1386181774.30495.113.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 04, 2013 at 10:29:34AM -0800, Eric Dumazet wrote:
> On Wed, 2013-12-04 at 18:56 +0100, Hannes Frederic Sowa wrote:
> > On Wed, Dec 04, 2013 at 04:13:10PM +0000, Fiedler Roman wrote:
> > > -static inline void ip_select_ident_more(struct iphdr *iph, struct dst_entry *dst, struct sock *sk, int more)
> > > +static inline void ip_select_ident_more(struct sk_buff *skb, struct dst_entry *dst, struct sock *sk, int more)
> > > {
> > > - if (iph->frag_off & htons(IP_DF)) {
> > > + struct iphdr *iph = ip_hdr(skb);
> > > +
> > > + if ((iph->frag_off & htons(IP_DF)) && !skb->local_df) {
> > > if (sk && inet_sk(sk)->inet_daddr) {
> > > iph->id = htons(inet_sk(sk)->inet_id);
> > > inet_sk(sk)->inet_id += 1 + more;
> > > 
> > > ... from 3.10.16 would disable ID setting on some packets, where it was done previously. Perhaps this caused problems in and hence behaviour was changed by another patch to one of the following kernel versions. Or perhaps the additional vserver-patch in my kernel interacted with that change and made it first visible after 3.10.17.
> > > 
> > > At least there has been activity around that part of the TCP-stack near the relevant time window, so it is not completely unexpected.
> > > 
> > > Since it seems, that the patch only affects sending of RSTs, there should be no real security impact also: Only difference seems to be, that by sending SYNs to closed ports, you now can get some incrementing next ID value (do not know, where this number really comes from). With a quick look, I could not find out how this ID relates to other ID values of .e.g UDP/TCP activity, e.g. for packet spoofing. Only thing that is possible so far (and not very valuable from my point of view) is port/firewall-rule probing using SYN on closed port, mechanism:
> > 
> > E.g. icmp uses per-namespace per-cpu sockets where it counts the non-DF and
> > non-local_df fragments and increases that per-socket. TCP-RST use a global
> > per-cpu socket to send RST packets. ip_select_ident does increase inet_id for
> > each sent fragment.
> 
> Well, it should not, because for this particular socket (assuming you
> speak of ip_send_unicast_reply()), inet_sk(sk)->inet_daddr is not set.

Oh yes, actually looking at the code we definitely run into __ip_select_ident
and generate an inetpeer and use the derived ipid from that.

Roman, I would be very interested why you only experienced that with
3.10.21, could you share the specific vserver patch?
