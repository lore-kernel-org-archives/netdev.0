From: David Newall <davidn@davidnewall.com>
Subject: Re: Revert 462fb2af9788a82a534f8184abfde31574e1cfa0 (bridge : Sanitize
 skb before it enters the IP stack)
Date: Wed, 21 May 2014 17:19:00 +0930
Message-ID: <537C5A6C.3030809@davidnewall.com>
References: <537621AC.1060409@davidnewall.com> <5379FFFD.1050705@davidnewall.com> <20140519140119.GA24523@breakpoint.cc> <537A12EA.4060604@davidnewall.com> <20140519170915.GB24523@breakpoint.cc> <537A6E5C.6090602@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: Bart De Schuymer <bdschuym@pandora.be>,
	Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <537A6E5C.6090602@pandora.be>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Bart,

Thanks for thinking about this.

On 20/05/14 06:19, Bart De Schuymer wrote:
> Perhaps it's possible to call ip_options_compile with a skb == NULL, 
> like ip_options.c::ip_options_get_finish does. That way we don't need 
> to duplicate code.

I think not.  My reading of the discussion behind the commit is that skb 
cb area could contain something that was confused for IP options.  To 
solve that, and to allow for proper response when the packet's DF flag 
was set, the cb area was cleared and ip_options_compile() was called.  
Calling that function does only part of the job, leaving slots for 
addresses (and possibly timestamps) to be filled in by a later function; 
possibly ip_forward_options().  I did try calling that; it failed; 
skb_rtable() returned NULL.

I have also read enough comments deriding the "incestuous" relationship 
between bridge and IP to convince me that the relationship should be 
severed.  A bridge is such a simple concept which, when it starts 
looking into the payload, ceases to be a bridge.

I have experience in this code measured in hours; not a lot.  I welcome 
correction if I misunderstand things.

> An alternative would be to make sure that the data pointed to by IPCB 
> and BR_INPUT_SKB_CB don't overlap. If this were the case, we could 
> indeed just revert the commit that was referred to.

They are identical spaces, but you imply a good point: the cb area is 
possibly being used, simultaneously, for two, incompatible purposes.  
Yet another argument for divorcing bridge of ip logic.

Regards,

David
