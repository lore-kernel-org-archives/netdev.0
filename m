From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCHv4 net-next] vxlan: virtual extensible lan
Date: Tue, 25 Sep 2012 14:55:13 -0700
Message-ID: <CAEP_g=_PQSx_OVcU47OJFKgO_MpWSKStmGnVB76vSm=Z7r6mvg@mail.gmail.com>
References: <20120924184304.727711327@vyatta.com> <20120924185050.162920909@vyatta.com>
 <20120924205822.GI26494@x200.localdomain> <20120924145031.3b0122e6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chris Wright <chrisw@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog119.obsmtp.com ([74.125.149.246]:40428 "HELO
	na3sys009aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750898Ab2IYVze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 17:55:34 -0400
Received: by mail-ob0-f174.google.com with SMTP id uo13so6414874obb.19
        for <netdev@vger.kernel.org>; Tue, 25 Sep 2012 14:55:33 -0700 (PDT)
In-Reply-To: <20120924145031.3b0122e6@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 24, 2012 at 2:50 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> +static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
[...]
> +       /* Do PMTU */
> +       if (skb->protocol == htons(ETH_P_IP)) {
> +               df |= old_iph->frag_off & htons(IP_DF);
> +               if (df && mtu < pkt_len) {
> +                       icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
> +                                 htonl(mtu));
> +                       ip_rt_put(rt);
> +                       goto tx_error;
> +               }
> +       }
> +#if IS_ENABLED(CONFIG_IPV6)
> +       else if (skb->protocol == htons(ETH_P_IPV6)) {
> +               if (mtu >= IPV6_MIN_MTU && mtu < pkt_len) {
> +                       icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
> +                       ip_rt_put(rt);
> +                       goto tx_error;
> +               }
> +       }
> +#endif

Won't this black hole packets if we need to generate ICMP messages?
Since we're doing switching and not routing here icmp_send() doesn't
necessarily have a route to the relevant endpoint.  It looks like
Ethernet over GRE has this issue as well.
