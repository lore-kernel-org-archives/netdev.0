From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] sctp: Correct type and usage of sctp_end_cksum()
Date: Thu, 25 Apr 2013 22:12:14 +0900
Message-ID: <20130425131214.GA5727@verge.net.au>
References: <1366336498-25917-1-git-send-email-horms@verge.net.au>
 <20130419131043.GC19017@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: Neil Horman <nhorman@tuxdriver.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:39338 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757936Ab3DYNMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 09:12:17 -0400
Content-Disposition: inline
In-Reply-To: <20130419131043.GC19017@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 19, 2013 at 09:10:43AM -0400, Neil Horman wrote:
> On Fri, Apr 19, 2013 at 10:54:58AM +0900, Simon Horman wrote:
> > Change the type of the crc32 parameter of sctp_end_cksum()
> > from __be32 to __u32 to reflect that fact that it is passed
> > to cpu_to_le32().
> > 
> > There are five in-tree users of sctp_end_cksum().
> > The following four had warnings flagged by sparse which are
> > no longer present with this change.
> > 
> > net/netfilter/ipvs/ip_vs_proto_sctp.c:sctp_nat_csum()
> > net/netfilter/ipvs/ip_vs_proto_sctp.c:sctp_csum_check()
> > net/sctp/input.c:sctp_rcv_checksum()
> > net/sctp/output.c:sctp_packet_transmit()
> > 
> > The fifth user is net/netfilter/nf_nat_proto_sctp.c:sctp_manip_pkt().
> > It has been updated to pass a __u32 instead of a __be32,
> > the value in question was already calculated in cpu byte-order.
> > 
> > net/netfilter/nf_nat_proto_sctp.c:sctp_manip_pkt() has also
> > been updated to assign the return value of sctp_end_cksum()
> > directly to a variable of type __le32, matching the
> > type of the return value. Previously the return value
> > was assigned to a variable of type __be32 and then that variable
> > was finally assigned to another variable of type __le32.
> > 
> > Problems flagged by sparse.
> > Compile and sparse tested only.
> > 
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> > ---
> >  include/net/sctp/checksum.h       |    2 +-
> >  net/netfilter/nf_nat_proto_sctp.c |    5 ++---
> >  2 files changed, 3 insertions(+), 4 deletions(-)
> > 
> > diff --git a/include/net/sctp/checksum.h b/include/net/sctp/checksum.h
> > index befc8d2..5a2110d 100644
> > --- a/include/net/sctp/checksum.h
> > +++ b/include/net/sctp/checksum.h
> > @@ -77,7 +77,7 @@ static inline __u32 sctp_update_cksum(__u8 *buffer, __u16 length, __u32 crc32)
> >  	return sctp_crc32c(crc32, buffer, length);
> >  }
> >  
> > -static inline __le32 sctp_end_cksum(__be32 crc32)
> > +static inline __le32 sctp_end_cksum(__u32 crc32)
> >  {
> >  	return cpu_to_le32(~crc32);
> >  }
> > diff --git a/net/netfilter/nf_nat_proto_sctp.c b/net/netfilter/nf_nat_proto_sctp.c
> > index e64faa5..396e55d 100644
> > --- a/net/netfilter/nf_nat_proto_sctp.c
> > +++ b/net/netfilter/nf_nat_proto_sctp.c
> > @@ -36,7 +36,7 @@ sctp_manip_pkt(struct sk_buff *skb,
> >  {
> >  	struct sk_buff *frag;
> >  	sctp_sctphdr_t *hdr;
> > -	__be32 crc32;
> > +	__u32 crc32;
> >  
> >  	if (!skb_make_writable(skb, hdroff + sizeof(*hdr)))
> >  		return false;
> > @@ -55,8 +55,7 @@ sctp_manip_pkt(struct sk_buff *skb,
> >  	skb_walk_frags(skb, frag)
> >  		crc32 = sctp_update_cksum((u8 *)frag->data, skb_headlen(frag),
> >  					  crc32);
> > -	crc32 = sctp_end_cksum(crc32);
> > -	hdr->checksum = crc32;
> > +	hdr->checksum = sctp_end_cksum(crc32);
> >  
> >  	return true;
> >  }
> > -- 
> > 1.7.10.4
> > 
> > 
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Pablo, are you interested in taking this through nf-next?
Or is it more appropriate for net-next. Or should I split
it into two patches on a per-file basis, yielding one patch for each tree?
