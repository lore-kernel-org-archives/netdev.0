From: Shrikrishna Khare <skhare@vmware.com>
Subject: Re: [PATCH net-next] Driver: Vmxnet3: Copy TCP header to mapped
 frame for IPv6 packets
Date: Sat, 28 Feb 2015 19:16:00 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1502281846330.20149@shri-linux.eng.vmware.com>
References: <1425153509-31582-1-git-send-email-skhare@vmware.com> <54F24ACC.7020108@cogentembedded.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: sbhatewara@vmware.com, pv-drivers@vmware.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Amitabha Banerjee <banerjeea@vmware.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([208.91.2.13]:60282 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752280AbbCADQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 22:16:01 -0500
In-Reply-To: <54F24ACC.7020108@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, 28 Feb 2015, Sergei Shtylyov wrote:

> Hello.
> 
> On 02/28/2015 10:58 PM, Shrikrishna Khare wrote:
> 
> > Allows for packet parsing to be done by the fast path. This performance
> > optimization already exists for IPv4. Add similar logic for IPv6.
> 
> > Signed-off-by: Amitabha Banerjee <banerjeea@vmware.com>
> > Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
> > ---
> >   drivers/net/vmxnet3/vmxnet3_drv.c | 26 ++++++++++++++++----------
> >   drivers/net/vmxnet3/vmxnet3_int.h |  5 +++--
> >   2 files changed, 19 insertions(+), 12 deletions(-)
> 
> > diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c
> > b/drivers/net/vmxnet3/vmxnet3_drv.c
> > index 294214c..9216e6a 100644
> > --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> > +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> [...]
> > @@ -831,16 +832,20 @@ vmxnet3_parse_and_copy_hdr(struct sk_buff *skb, struct
> > vmxnet3_tx_queue *tq,
> >   			if (ctx->ipv4) {
> >   				const struct iphdr *iph = ip_hdr(skb);
> > 
> > -				if (iph->protocol == IPPROTO_TCP)
> > -					ctx->l4_hdr_size = tcp_hdrlen(skb);
> > -				else if (iph->protocol == IPPROTO_UDP)
> > -					ctx->l4_hdr_size = sizeof(struct
> > udphdr);
> > -				else
> > -					ctx->l4_hdr_size = 0;
> > -			} else {
> > -				/* for simplicity, don't copy L4 headers */
> > -				ctx->l4_hdr_size = 0;
> > +				protocol = iph->protocol;
> > +			} else if (ctx->ipv6) {
> > +				const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
> > +
> > +				protocol = ipv6h->nexthdr;
> >   			}
> > +
> > +			if (protocol == IPPROTO_TCP)
> > +				ctx->l4_hdr_size = tcp_hdrlen(skb);
> > +			else if (protocol == IPPROTO_UDP)
> > +				ctx->l4_hdr_size = sizeof(struct udphdr);
> > +			else
> > +				ctx->l4_hdr_size = 0;
> > +
> 
>    I think the above is asking to be a 'switch (protocol)' instead.
> 
> WBR, Sergei
> 
> 

Thanks for the review, Sergei. Would fix it, and resubmit the patch.

Thanks,
Shri
