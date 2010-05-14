From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCHv2] netfilter: Remove skb_is_nonlinear check from nf_conntrack_sip
Date: Fri, 14 May 2010 21:41:53 +0200
Message-ID: <4BEDA781.4040905@trash.net>
References: <20100514180138.GF15969@obsidianresearch.com> <4BED92AF.50704@trash.net> <20100514182601.GJ15969@obsidianresearch.com> <4BED99A3.2050404@trash.net> <4BEDA3CA.4030407@trash.net> <alpine.LSU.2.01.1005142133001.16437@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1005142133001.16437@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Friday 2010-05-14 21:26, Patrick McHardy wrote:
>>>> Should this be NF_DROP? As I understand it skb_linearize only failes
>>>> if it runs out of memory, which probably means dropping is OK. But
>>>> passing a packet that might need rewriting could be harmful..
>>> We so far also didn't rewrite the packet. But agreed, its
>>> a corner case and dropping it is the safer choice.
>> This is what I've added to my tree. Tested with asterisk and TSO
>> enabled NIC, which fails without this patch.
>>
> 
> [..patch..]
> 
> Shouldn't we do this for the other nf_conntrack_xyz too?
> That would mean getting rid of the size-limited locked packet
> buffer.

Those got introduced to avoid the linearization. SIP is kind of special
because its the only helper mangling packets multiple times with
variable sizes and is currently unable to use the data copying scheme.
Amanda does this as well, but uses the string search API, which works
fine.

The best fix to get rid of the copying in other helpers would be to
convert them to the string search API. I started doing that a few
years ago, but never finished it. One related improvement we could
add would be to make only those parts of the skb writable that are
actually written to when mangling packets, at least for non-linear
non-paged skbs (using frag_list).
