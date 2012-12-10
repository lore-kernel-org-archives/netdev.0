From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC PATCH] af_packet: don't to defrag shared skb
Date: Mon, 10 Dec 2012 10:29:48 +0100
Message-ID: <1355131788.9857.1.camel@jlt4.sipsolutions.net>
References: <1354906561-4695-1-git-send-email-eric@regit.org>
	 <20121207.153134.25835204617509469.davem@davemloft.net>
	 <1354915824.9124.11.camel@jlt4.sipsolutions.net>
	 (sfid-20121207_223020_561049_DB965D43) <1354916502.9124.18.camel@jlt4.sipsolutions.net>
	 (sfid-20121207_224129_500056_6617D80D) <1354918363.9124.29.camel@jlt4.sipsolutions.net>
	 (sfid-20121207_231231_221604_E7B34625) <1354919017.9124.33.camel@jlt4.sipsolutions.net>
	 (sfid-20121207_232321_820322_B0AAB1D2)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric-EVVnsjFE0OfYtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1354919017.9124.33.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org> (sfid-20121207_232321_820322_B0AAB1D2)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-12-07 at 23:23 +0100, Johannes Berg wrote:
> Oh I should say ... IP is like black magic to me ;-)
> 
> > -	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
> > +	if (!skb_copy_bits(skb, 0, &iph, sizeof(iph)))
> >  		return skb;
> >  
> > -	iph = ip_hdr(skb);
> > -	if (iph->ihl < 5 || iph->version != 4)
> > +	if (iph.ihl < 5 || iph.version != 4)
> >  		return skb;
> > -	if (!pskb_may_pull(skb, iph->ihl*4))
> > -		return skb;
> > -	iph = ip_hdr(skb);
> > -	len = ntohs(iph->tot_len);
> > -	if (skb->len < len || len < (iph->ihl * 4))
> > +
> > +	len = ntohs(iph.tot_len);
> > +	if (skb->len < len || len < (iph.ihl * 4))
> >  		return skb;
> >  
> > -	if (ip_is_fragment(ip_hdr(skb))) {
> > +	if (ip_is_fragment(&iph)) {
> >  		skb = skb_share_check(skb, GFP_ATOMIC);
> >  		if (skb) {
> > +			if (!pskb_may_pull(skb, iph.ihl*4))
> > +				return skb;
> 
> I moved this here but I have no idea what it does.

Well, ok, looking further it does seem kinda obvious -- ip_defrag()
assumes the IP header is (fully?) present in the skb header, so that's
what this does.

Eric (Leblond), could you test this patch?

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
