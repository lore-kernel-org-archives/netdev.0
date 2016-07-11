From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next 2/4] udp offload: allow GRO on 0 checksum
 packets
Date: Mon, 11 Jul 2016 15:21:40 +0200
Message-ID: <1468243300.4608.38.camel@redhat.com>
References: <cover.1467907022.git.pabeni@redhat.com>
	 <60369c715ef9948b088416639f0bec800f632f9a.1467907022.git.pabeni@redhat.com>
	 <CALx6S377LtT4tFwRaR1K6=+K9npdqxHW8wLgL4AubN65RwKNjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jiri Benc <jbenc@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45924 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751093AbcGKNVn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2016 09:21:43 -0400
In-Reply-To: <CALx6S377LtT4tFwRaR1K6=+K9npdqxHW8wLgL4AubN65RwKNjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-07-08 at 16:03 -0500, Tom Herbert wrote:
> On Thu, Jul 7, 2016 at 10:58 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> > currently, UDP packets with zero checksum are not allowed to
> > use udp offload's GRO. This patch admits such packets to
> > GRO, if the related socket settings allow it: ipv6 packets
> > are not admitted if the sockets don't have the no_check6_rx
> > flag set.
> >
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> > ---
> >  net/ipv4/udp_offload.c | 6 +++++-
> >  1 file changed, 5 insertions(+), 1 deletion(-)
> >
> > diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> > index 9c37338..ac783f4 100644
> > --- a/net/ipv4/udp_offload.c
> > +++ b/net/ipv4/udp_offload.c
> > @@ -257,7 +257,7 @@ struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
> >         struct sock *sk;
> >
> >         if (NAPI_GRO_CB(skb)->encap_mark ||
> > -           (skb->ip_summed != CHECKSUM_PARTIAL &&
> > +           (uh->check && skb->ip_summed != CHECKSUM_PARTIAL &&
> >              NAPI_GRO_CB(skb)->csum_cnt == 0 &&
> >              !NAPI_GRO_CB(skb)->csum_valid))
> 
> Paolo,
> 
> I think you might be misunderstanding the intent of this conditional.
> It is trying to deduce that that the inner TCP checksum has likely
> been validated or can be validated without doing  packet checksum
> calculation. This is trying to avoid doing host side checksum
> calculation in the GRO path and really has little to do with rather
> uh->check is zero or not. The assumption was that we shouldn't compute
> whole packet checksums in the GRO path because of performance. If this
> assumption is no longer valid (i.e. there's good data saying doing
> checksums in GRO path is a benefit) then all the checksum parts of
> this conditional should be removed.

Oh, my bad! I was hit by an ixgbe errata (82599 sometimes marks zero
checksum udp packets with CHECKSUM_NONE), so in my tests the above
condition was matched by 0 csum UDP packets. Than I misread csum_cnt
documentation, assuming it was not incremented for zero checksum UDP
packets: I thought that the matches I saw were due to !uh->check
instead of missing offload.

Thank you for the clarification,

Paolo
