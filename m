From: Ben Greear <greearb@candelatech.com>
Subject: Re: gettime: Was (Re: Route cache performance under stress
Date: Wed, 11 Jun 2003 23:32:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EE81E89.1040004@candelatech.com>
References: <20030610.203325.41658167.davem@redhat.com>	<20030611065255.L39678@shell.cyberus.ca>	<20030611120803.GB22720@wotan.suse.de> <20030611.203015.104061804.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, hadi@shell.cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030611.203015.104061804.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
>    From: Andi Kleen <ak@suse.de>
>    Date: Wed, 11 Jun 2003 14:08:03 +0200
> 
>    Another way is to just store jiffies (= 10 or 1ms accuracy) 
>    
>    This should be nearly zero cost and accurate enough at least for TCP.
>    
> TCP doesn't use it Andi.  SO_RECVSTAMP etc. uses it and that
> MUST be accurate.
> 
> People, start approaching this from an actually implementable
> angle, not one's that have no basis in reality :)

I think we need a generic method to get something like the
TSC..ie very fast, very precise.

Then, we need a way to turn this into the time-of-day.

After that, we can calculate time-of-day in a lazy manner.

Something like:

/* In driver or as early as possible */
skb->rx_stamp = getCurTSC();
skb->flags |= (RX_STAMP_IS_NOT_YET_CONVERTED);
....

/* somebody wants to know what time of day rx-stamp was */
if (skb->flags & (RX_STAMP_IS_NOT_YET_CONVERTED)) {
   skb->rx_stamp = do_gettimeofday() - ((getCurTSC() - skb->rx_stamp) *
                                        (magic-conversion-to-timeval-units));
   skb->flags &= ~(RX_STAMP_IS_NOT_YET_CONVERTED);
}
/* rx_stamp is now relative to time-of-day */


But, Dave mentioned TSC is not always good to use, and it won't work at all
on older cpus, so the getCurTSC() thing probably needs to be a macro...
Seems like this macro would be useful in lots of places...pktgen for
instance :)

Ben

> 
>    
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
