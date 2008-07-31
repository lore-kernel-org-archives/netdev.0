From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: Fix ip6_xmit to send fragments if ipfragok is true
Date: Thu, 31 Jul 2008 17:11:56 +0800
Message-ID: <489181DC.40507@cn.fujitsu.com>
References: <489153ED.9030701@cn.fujitsu.com> <20080731082053.GA6463@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58721 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752437AbYGaJNn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2008 05:13:43 -0400
In-Reply-To: <20080731082053.GA6463@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Jul 31, 2008 at 01:55:57PM +0800, Wei Yongjun wrote:
>   
>> SCTP used ip6_xmit() to send fragments after received ICMP packet too
>> big message. But while send packet used ip6_xmit, the skb->local_df is
>> not initialized. So when skb if enter ip6_fragment
>> <../cgi-bin/global.cgi?pattern=ip6_fragment&type=reference>(), the following
>> code will discard the skb.
>>     
>
> That sounds broken.  ip6_xmit is for TCP-like protocols that
> perform PMTU-discovery.  Therefore it should never fragment
> locally.
>
> So either SCTP needs to do the same, or it should switch to
> something other than ip6_xmit.
>   

So what does the ipfragok paramater means?
TCP used  ip6_xmit always set ipfragok = 0. But if ipfragok=1, what will 
happend?

If ipfragok = 0, and skb->len > mtu, ip6_xmit will discard the skb.

If ipfragok=1, ip6_xmit will pass skb to ip6_output() and send skb used 
ip6_fragment(), but skb will be discard since local_df is 0, it seems 
that ipfragok has no effect.

skb->local_df is set to 1 if np->pmtudisc < IPV6_PMTUDISC_DO in other 
place, so I think it may also set to 1 if np->pmtudisc < 
IPV6_PMTUDISC_DO, and send the skb used ip6_fragment(). Is this correct?

As I know, if I send skb in IPv4 used ip_queue_xmit(ipfragok=1), skb 
will be send in fragments if len > mtu.

int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
              struct ipv6_txoptions *opt, int ipfragok)
{
        ...
        mtu = dst_mtu(dst);
        if ((skb->len <= mtu) || ipfragok || skb_is_gso(skb)) {
                IP6_INC_STATS(ip6_dst_idev(skb->dst),
                              IPSTATS_MIB_OUTREQUESTS);
                return NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, dst->dev,
                                dst_output);
        }

        if (net_ratelimit())
                printk(KERN_DEBUG "IPv6: sending pkt_too_big to self\n");
        ...
}

int ip6_output(struct sk_buff *skb)
{
        if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
                                dst_allfrag(skb->dst))
                return ip6_fragment(skb, ip6_output2);
        else
                return ip6_output2(skb);
}


