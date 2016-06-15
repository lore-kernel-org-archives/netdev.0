From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter/nflog: nflog-range does not truncate packets
Date: Wed, 15 Jun 2016 14:39:45 +0200
Message-ID: <20160615123945.GA3594@salvia>
References: <20160602002354.GG1644@akamai.com>
 <20160606223106.GA1621@salvia>
 <57575367.4010604@akamai.com>
 <20160608121625.GA4097@salvia>
 <5759AE1B.2080500@akamai.com>
 <575E2B49.7090809@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	johunt@akamai.com, netdev@vger.kernel.org, pai.vishwain@gmail.com,
	"Lubashev, Igor" <ilubashe@akamai.com>
To: Vishwanath Pai <vpai@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55293 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932760AbcFOMjy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 08:39:54 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id CD6BAE8EA6
	for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 14:39:52 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id BC3F364481
	for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 14:39:52 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 60FD564482
	for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 14:39:46 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <575E2B49.7090809@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 12, 2016 at 11:40:57PM -0400, Vishwanath Pai wrote:
> On 06/09/2016 01:57 PM, Vishwanath Pai wrote:
> > On 06/08/2016 08:16 AM, Pablo Neira Ayuso wrote:
> >> Looking again at your code:
> >>
> >>         case NFULNL_COPY_PACKET:
> >> -               if (inst->copy_range > skb->len)
> >> +               data_len = inst->copy_range;
> >> +               if (li->u.ulog.copy_len < data_len)
> >> +                       data_len = li->u.ulog.copy_len;
> >>
> >> data_len is set to instance's copy_range.
> >>
> >> But then, if the NFLOG rule indicates smaller copy_len, you use this
> >> value. So to my understanding, NFLOG rule prevails over instance's
> >> copy_range in what matters, which is to shrink the copy range.
> >>
> >>>> --nflog-range will not override the per-instance default,
> >>>> the only time it would get preference is when its value is lesser than
> >>>> the per-instance value. If copy_range is lesser than --nflog-range then
> >>>> we retain copy_range.
> >>>>
> >>>> So basically what we are doing is min(copy_range, nflog-range).
> >>>> Just wanted to clarify this, if this is not how it's meant to be
> >>>> please let me know.
> >>>>
> >>>> Also, there is a bug in my patch, li->u.ulog.copy_len can be set to "0"
> >>>> from userspace (if --nflog-range is not specified), so we have to check
> >>>> for this condition before using the value. I will send a V2 of the patch
> >>>> based on your reply.
> >> Currently, li->u.ulog.copy_len is set to "0" by default when not
> >> specified.
> >>
> >> But copy_len = 0 is a valid possibility, so this looks a bit more
> >> tricky to me to fix since we may need to get flags here to know when
> >> this is set.
> >>
> >> Probably something like:
> >>
> >>         if (li->flags & NF_LOG_F_COPY_RANGE)
> >>                 data_len = li->u.ulog.copy_len;
> >>         /* Per-instance copy range prevails over global per-rule option. */
> >>         if (data_len < inst->copy_range)
> >>                 data_len = inst->copy_range;
> >>         if (data_len > skb->len)
> >>                 data_len = skb->len;
> >>
> >> Although this would require a bit more code to introduce these flags.
> >>
> >> You will also need a new flag for xt_NFLOG:
> >>
> >> #define XT_NFLOG_COPY_LEN       0x2
> >>
> >> it seems other XT_NFLOG_* flags were already in place.
> >>
> >> Interesting that nobody noticed this for so long BTW.
> > 
> > I tried this out, I added two flags: one for XT_NFLOG to notify the
> > kernel when --nflog-range is set by the user, and another flag for
> > nfnetlink_log to pass this on to nfulnl_log_packet. This design works
> > fine but while testing this I found a problem.
> > 
> > Lets say --nflog-range is set to 200, and the instance copy_range is set
> > to 100. According to the code above the final value of data_len will be
> > 200 so we try to pack 200 bytes into the skb. But somewhere between
> > nfnetlink_log to dumpcap the packet is getting truncated and dumpcap
> > doesn't like this:
> > 
> > $> dumpcap -y NFLOG -i nflog:5 -s 100
> > Capturing on 'nflog:5'
> > File: /tmp/wireshark_pcapng_nflog-5_20160609133531_pi6MrS
> > dumpcap: Error while capturing packets: Message truncated: (got: 228)
> > (nlmsg_len: 320)
> > Please report this to the Wireshark developers.
> > https://bugs.wireshark.org/
> > (This is not a crash; please do not report it as such.)
> > Packets captured: 0
> > Packets received/dropped on interface 'nflog:5': 0/0
> > (pcap:0/dumpcap:0/flushed:0/ps_ifdrop:0) (0.0%)
> > 
> > I'm trying to figure out where the packet is getting truncated.
> > 
> 
> I found where the problem is. This is the userspace code for libpcap:
> 
>         do {
>                 len = recv(handle->fd, handle->buffer, handle->bufsize, 0);
>                 if (handle->break_loop) {
>                         handle->break_loop = 0;
>                         return -2;
>                 }
>         } while ((len == -1) && (errno == EINTR));
> 
>        ...
> 
>         buf = handle->buffer;
>         while (len >= NLMSG_SPACE(0)) {
>                 const struct nlmsghdr *nlh = (const struct nlmsghdr *) buf;
>                 u_int32_t msg_len;
>                 nftype_t type = OTHER;
> 
>                 if (nlh->nlmsg_len < sizeof(struct nlmsghdr) || len <
> nlh->nlmsg_len) {
>                         snprintf(handle->errbuf, PCAP_ERRBUF_SIZE,
> "Message truncated: (got: %d) (nlmsg_len: %u)", len, nlh->nlmsg_len);
>                         return -1;
>                 }
>
> handle->bufsize is only big enough to accommodate the snaplen specified
> by the user in dumpcap. So if we send more data than that then we will
> break userspace. One way around this is to send min(li->u.ulog.copy_len,
> inst->copy_range). If this is OK then I can send a patch for this,
> please suggest.

But nlmsg_len should match len in this.

If we're just sending a part of the packet to userspace, then we
should adjust nlmsg_len to indicate exactly the netlink message length
that we're sending to userspace.

Is your patch triggering this nlmsg_len != len?
