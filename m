From: Brian Haley <brian.haley@hp.com>
Subject: Re: SO_BINDTODEVICE inconsistency between IPv4 and IPv6
Date: Fri, 18 Mar 2011 10:31:46 -0400
Message-ID: <4D836CD2.5070807@hp.com>
References: <1300357750.2589.46.camel@macbook.infradead.org>	 <4D82B4DB.2060006@hp.com> <1300438473.16342.18.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Yuniverg, Michael" <michael.yuniverg@intel.com>,
	"Yedvab, Nadav" <nadav.yedvab@intel.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:8372 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953Ab1CRObu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 10:31:50 -0400
In-Reply-To: <1300438473.16342.18.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/18/2011 04:54 AM, David Woodhouse wrote:
> On Thu, 2011-03-17 at 21:26 -0400, Brian Haley wrote:
>> Hmm, "connection refused", do you have any iptables rules installed?  Connecting
>> to a local global address worked fine for me on 2.6.32-30 using a home-grown
>> test app.
> 
> Thanks for looking at this.
> 
> Just to confirm... after your server does SO_BINDTODEVICE to 'lo', your
> clients on the same host can make a successful connection to global IPv6
> addresses which are assigned to the *other* interfaces? 
> 
> Can you show your version of the test app, and your results? What kernel
> is this on?

Sorry, I just re-ran my test again and noticed the SO_BINDTODEVICE failed,
since I was running it as myself, not root, so I see the same behavior as
you.  I'm not sure if this is a bug per-se, and there is this comment
in ip6_rcv() pointing towards this:

        /*
         * Store incoming device index. When the packet will
         * be queued, we cannot refer to skb->dev anymore.
         *
         * BTW, when we send a packet for our own local address on a
         * non-loopback interface (e.g. ethX), it is being delivered
         * via the loopback interface (lo) here; skb->dev = loopback_dev.
         * It, however, should be considered as if it is being
         * arrived via the sending interface (ethX), because of the
         * nature of scoping architecture. --yoshfuji
         */
        IP6CB(skb)->iif = skb_dst(skb) ? ip6_dst_idev(skb_dst(skb))->dev->ifindex : dev->ifindex;

That's probably why it's not matching.

I think Yoshifuji would be the best one to ask, cc'd.

-Brian
