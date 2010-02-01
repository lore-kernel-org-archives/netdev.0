From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] sky2:  receive dma mapping error handling
Date: Sun, 31 Jan 2010 23:26:03 -0500
Message-ID: <4B6657DB.3010008@majjas.com>
References: <20100128223447.GC3109@del.dom.local> <4B621316.8070308@majjas.com>
 <20100128225621.GD3109@del.dom.local> <4B6216B9.1010802@majjas.com>
 <20100128153643.0fca3c51@nehalam> <4B645EF4.4050701@majjas.com>
 <20100131003449.GA11935@del.dom.local> <4B650D53.2010607@majjas.com>
 <4B65D0F9.2020602@majjas.com> <4B65FD12.7090101@majjas.com>
 <20100131221835.GA3317@del.dom.local> <4B661E22.8090907@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <4B661E22.8090907@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/31/2010 7:19 PM, Michael Breuer wrote:
> On 1/31/2010 5:18 PM, Jarek Poplawski wrote:
> solves the dma-debug issue - i.e., elements are now being unmapped.
>
> Will leave up and hit with traffic unless a crash occurs. If I hit 
> something unrelated I'll backport to 2.6.32.7 and try that for a 
> while. I do think it's plausible that the dma errors after (during) 
> load were due to hardware limitations on the number of mapped entries 
> (haven't researched what that limit was). I would also assume that the 
> sw map would also have failed eventually.
>
> I'd suggest that regardless of whether this patch solves my crash that 
> it ought to be backported as it seems unlikely that any machine would 
> be able to survive for long without the tx entries being unmapped.
>
FYI - tried generating lots of extra tx traffic... found a way to 
generate the rx status messages on demand:
     ping -i .0000001 -s 8000 -t 2 <host> >/dev/null

Yields:
Jan 31 23:08:07 mail kernel: sky2 eth0: rx error, status 0x1f6a0010 
length 1518
Jan 31 23:08:07 mail kernel: sky2 eth0: rx error, status 0x1f6a0010 
length 1518
Jan 31 23:08:07 mail kernel: sky2 eth0: rx error, status 0x1f6a0010 
length 1518
Jan 31 23:08:07 mail kernel: sky2 eth0: rx error, status 0x1f6a0010 
length 1518
Jan 31 23:08:07 mail kernel: sky2 eth0: rx error, status 0x1f6a0010 
length 1518
Jan 31 23:08:07 mail kernel: sky2 eth0: rx error, status 0x1f6a0010 
length 1518
Jan 31 23:08:07 mail kernel: sky2 eth0: rx error, status 0x1f6a0010 
length 1518
Jan 31 23:08:07 mail kernel: sky2 eth0: rx error, status 0x1f6a0010 
length 1518
Jan 31 23:08:07 mail kernel: sky2 eth0: rx error, status 0x1f6a0010 
length 1518
Jan 31 23:08:07 mail kernel: sky2 eth0: rx error, status 0x1f6a0010 
length 1518
Jan 31 23:08:12 mail kernel: net_ratelimit: 316 callbacks suppressed
etc.
Looking at the packet trace, it seems that my Windows7 box is under 
*some* circumstances not observing the MTU. In this case, the ICMP reply 
is going back with the 8000 byte jumbo frame unfragmented. It seems that 
the reverse is also true. I don't know why sometimes win7 does this, and 
at other times properly fragments.

Oddly, prior to this attempt if I set no fragment on a ping from the 
windows box back to the linux box and a size of > mtu (like 8000), the 
ping failed. Absent the no-fragment flag, the ping properly fragmented. 
I am not sure why Windows now thinks the MTU is > 1500. I'll look into 
that when I have some time. It's possible that with 2.6.33-rc5 & the 
patches I've got that somehow path mtu discovery is broken as nothing 
changed on the windows side.

Understanding that the other side is out of spec, I'd still wonder why 
the sky2 driver generates rx errors. Perhaps overruns should be tossed 
silently... by the hardware if possible.
