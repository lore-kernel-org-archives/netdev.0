From: Fiedler Roman <Roman.Fiedler@ait.ac.at>
Subject: AW: Change in IPv4 TCP reset behavior after kernel upgrade
Date: Wed, 4 Dec 2013 16:13:10 +0000
Message-ID: <2ECE9D9EEF1F524185270138AE2326593BF9B935@S0MSMAIL112.arc.local>
References: <2ECE9D9EEF1F524185270138AE2326593BF9B5EE@S0MSMAIL112.arc.local>
 <CADVnQynL6=91zAZXMAoKEeCY7=Eajfq1DyP+Dzd8xhzBhujtyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ait.ac.at ([62.218.164.131]:44333 "EHLO mx1.ait.ac.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932824Ab3LDQNV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 11:13:21 -0500
In-Reply-To: <CADVnQynL6=91zAZXMAoKEeCY7=Eajfq1DyP+Dzd8xhzBhujtyQ@mail.gmail.com>
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> Von: Neal Cardwell [mailto:ncardwell@google.com]
> 
> On Wed, Dec 4, 2013 at 5:09 AM, Fiedler Roman <Roman.Fiedler@ait.ac.at>
> wrote:
> > Hello,
> >
> > After upgrading from linux-image-3.10.17 to linux-image-3.10.21 I noticed,
> that afterwards reset packets started to be transmitted with ID != 0. For
> testing:
> >
> > tcpdump -i eth0 -nn -s0 -X -vvv 'tcp[tcpflags] & tcp-rst != 0'
> >
> > I did a short search to find out when and why this was changed (PATCH),
> but did not get any wiser.
> >
> > Was this an intended change, e.g. to increase resilience against RST-packet
> injection/DOS scenarios? Is it just accidentally?
> >
> > The ID seems to be in sequence, so it is not uninitialized memory content.
> >
> > Roman
> >
> > PS: The kernel was patched with the vserver-patch, this might have an
> influence. I did not have time yet to build a kernel without that modification.
> 
> One possibly related commit would be:
> 
> ip: generate unique IP identificator if local fragmentation is allowed
> 703133de331a7a7df47f31fb9de51dc6f68a9de8
> 
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=703
> 133de331a7a7df47f31fb9de51dc6f68a9de8
> 
> But that went into 3.10.16, which is one release outside the window
> you mention....

Thanks, but that is really close. If I'm not wrong the code ....

-static inline void ip_select_ident_more(struct iphdr *iph, struct dst_entry *dst, struct sock *sk, int more)
+static inline void ip_select_ident_more(struct sk_buff *skb, struct dst_entry *dst, struct sock *sk, int more)
{
- if (iph->frag_off & htons(IP_DF)) {
+ struct iphdr *iph = ip_hdr(skb);
+
+ if ((iph->frag_off & htons(IP_DF)) && !skb->local_df) {
if (sk && inet_sk(sk)->inet_daddr) {
iph->id = htons(inet_sk(sk)->inet_id);
inet_sk(sk)->inet_id += 1 + more;

... from 3.10.16 would disable ID setting on some packets, where it was done previously. Perhaps this caused problems in and hence behaviour was changed by another patch to one of the following kernel versions. Or perhaps the additional vserver-patch in my kernel interacted with that change and made it first visible after 3.10.17.

At least there has been activity around that part of the TCP-stack near the relevant time window, so it is not completely unexpected.

Since it seems, that the patch only affects sending of RSTs, there should be no real security impact also: Only difference seems to be, that by sending SYNs to closed ports, you now can get some incrementing next ID value (do not know, where this number really comes from). With a quick look, I could not find out how this ID relates to other ID values of .e.g UDP/TCP activity, e.g. for packet spoofing. Only thing that is possible so far (and not very valuable from my point of view) is port/firewall-rule probing using SYN on closed port, mechanism:

* Find one non-firewalled but closed port where you can send and receive responses, e.g. 443 on webserver without SSL (do not know, if that would work also when exhausting all connections to provoke RST?)
* Send a SYN, record the ID
* Spoof packets to other ports, perhaps using other source-IPs, that might suite firewall rules better to go through
* See if the IDs in your test-SYN-responses start to increase faster, meaning that the port is not firewalled from the given source but currently no application listening on it

Roman
