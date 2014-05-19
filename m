From: David Newall <davidn@davidnewall.com>
Subject: Re: Revert 462fb2af9788a82a534f8184abfde31574e1cfa0 (bridge : Sanitize
 skb before it enters the IP stack)
Date: Mon, 19 May 2014 23:49:22 +0930
Message-ID: <537A12EA.4060604@davidnewall.com>
References: <537621AC.1060409@davidnewall.com> <5379FFFD.1050705@davidnewall.com> <20140519140119.GA24523@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	bridge@lists.linux-foundation.org
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140519140119.GA24523@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for the reply.  I've been hanging out for it!

On 19/05/14 23:31, Florian Westphal wrote:
> Well, did you test what happens if we try to refrag a packet
> containing ip options after the revert?
>
> can happen e.g. when using netfilter conntrack on top of a bridge.

No.  I expect it would panic, as was reported prior to the commit.

I tried to persevere with the commit: I recalculated checksum, which 
left routes and times improperly updated in options.  Then I tried 
calling ip_forward_options, which looks like it would correctly update 
RR and TS (not to mention checksum)m but that bombed because skb_rtable 
returned NULL.  I think calling skb_set_dst would answer that, but I 
don't know how to get a valid dst.  (I asked for help but no answer.)

I see three ways to progress:

1. Possibly call ip_forward_option, but that requires somebody who 
understands this code to help;
2. Just recalculate the checksum, leaving crap in the options; or
3. Revert the commit.

Option 1 doesn't look like it's going to happen; option 2 is stupid; 
leaving option 3, and I begin to think that's the right way to go if 
bridge is supposed to be a bridge and not a router.  The idea that 
bridge is doing too much seems to have quite a lot of currency, so think 
of reversion as chopping off a canker.  Or we keep fixing bugs, adding 
to bridge, until it replicates all of IP.

How does a packet get fragmented in this case?  Does it only happen when 
bridging to a device with smaller MTU?  That scenario sounds quite 
un-bridge-like.  It also sounds like something that can be handled by 
real routing.
