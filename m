From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: Re: [RFC] TCP:  Support configurable delayed-ack parameters.
Date: Thu, 21 Jun 2012 09:04:31 -0700
Message-ID: <4FE3460F.7030001@candelatech.com>
References: <1340067163-29329-1-git-send-email-greearb@candelatech.com> <1340082688.7491.2299.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Daniel Baluta <dbaluta-+zzKsuq53OdBDgjK7y7TUQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1340082688.7491.2299.camel@edumazet-glaptop>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/18/2012 10:11 PM, Eric Dumazet wrote:
> On Mon, 2012-06-18 at 17:52 -0700, greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org wrote:

>> In order to keep a multiply out of the hot path, the segs * mss
>> computation is recalculated and cached whenever segs or mss changes.
>>
>
> I know David was worried about this multiply, but current cpus do a
> multiply in at most 3 cycles.
>
> Addding an u32 field in socket structure adds 1/16 of a cache line, and
> adds more penalty.
>
> Avoiding to build/send an ACK packet can save us so many cpu cycles that
> the multiply is pure noise.

I modified the patch as you suggested to remove the cached multiply
and just do the multiply in the hot path (and fixed a few other bugs in
the implementation).  And yes, I know Dave doesn't like the patch, so
it's unlikely to ever go upstream...

Test system is i5 processor laptop, 3.3.7+ kernel, Fedora 17, running wifi
traffic and wired NIC through an AP (sending-to-self, with proper
routing rules to make this function as desired).  AP is 3x3 mimo,
laptop is 2x2, max nominal rate of 300Mbps.  Channel is 149.
Both nics are Atheros (ath9k).
Laptop and AP is about 3 feet apart, and AP antenna & laptop rotation
have been tweaked for maximum throughput.

Traffic generator is our in-house tool, but it generally matches
iperf when used with the same configuration.  Send-buffer size
is configured at 1MB (with system defaults performance is much worse).

This is wifi upload, with station sending to wired Ethernet port.

I only changed the max-segs values for this test, leaving the min/max
delay-ack timers at defaults.

Rate is calculated over TCP data throughput, ie not counting headers.
The rates bounce around a bit, but I tried to report the average.

segs == 1:  196Mbps TCP throughput, 17,000 pps tx, 4,000 pps rx on wlan interface.

segs == 20: 203Mbps, 17,300 pps tx, 1400 pps rx

segs == 64: 217Mbps, 18300 pps tx, 311 pps rx

segs == 1024: 231Mbps, 19200 pps tx, 118 pps rx.

Note that with pure UDP throughput, I see right at 230-240Mbps when
everything is running smoothly, so setting delack-segs to a high value
allows TCP to approach UDP throughput.

I'll repost the patch (against 3.5-rcX) that I'm using later today
after some more testing in case someone else wants to try it out.

Thanks,
Ben



-- 
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
