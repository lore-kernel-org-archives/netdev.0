From: "David S. Miller" <davem@redhat.com>
Subject: Re: pskb change in dst->output
Date: Wed, 7 Jul 2004 17:17:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040707171759.025eb13b.davem@redhat.com>
References: <20040707231221.GA30565@gondor.apana.org.au>
	<Xine.LNX.4.44.0407071931480.28863-100000@thoron.boston.redhat.com>
	<20040708000421.GA30918@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040708000421.GA30918@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 8 Jul 2004 10:04:21 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, Jul 07, 2004 at 07:33:18PM -0400, James Morris wrote:
> > 
> > > So is there a caller to dst_output that does this as well?
> > 
> > The TCP code often clones skbs to be transmitted.
> 
> Thanks for the pointer.

This isn't the case that prompted James's changes though.

It's a UDP packet, to multicast, with hw checksumming enabled,
that gets looped back via ip_mc_output() here:

	if (rt->rt_flags&RTCF_MULTICAST) {
		if ((!sk || inet_sk(sk)->mc_loop)
#ifdef CONFIG_IP_MROUTE
		/* Small optimization: do not loopback not local frames,
		   which returned after forwarding; they will be  dropped
		   by ip_mr_input in any case.
		   Note, that local frames are looped back to be delivered
		   to local recipients.

		   This check is duplicated in ip_mr_input at the moment.
		 */
		    && ((rt->rt_flags&RTCF_LOCAL) || !(IPCB(skb)->flags&IPSKB_FORWARDED))
#endif
		) {
			struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
			if (newskb)
				NF_HOOK(PF_INET, NF_IP_POST_ROUTING, newskb, NULL,
					newskb->dev, 
					ip_dev_loopback_xmit);
		}

If this goes through netfilter, before James's changes, in any way
shape or form, the checksum of the original SKB will be corrupted.
This breaks dhcp for example, and it's really common because if you
just build selinux even without using any rules, packets go through
netfilter.

That is what James's changes, to move the actual packet mucking deeper
in the netfilter call chain (to where packet modifications really happen)
so that we can fix the above described case without unneeded expense
added.
