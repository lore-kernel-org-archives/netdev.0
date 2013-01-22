From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next V6 02/14] bridge: Add vlan filtering infrastructure
Date: Tue, 22 Jan 2013 09:31:43 -0500
Message-ID: <50FEA2CF.4060406@redhat.com>
References: <1358360289-23249-1-git-send-email-vyasevic@redhat.com> <1358360289-23249-3-git-send-email-vyasevic@redhat.com> <CAHXqBFKg6Vp5=dprDYKON2LmshhX+nSPF7KRHiQmOS68PrQq-A@mail.gmail.com> <50FC307A.5090003@redhat.com> <20130120113825.759b4a58@nehalam.linuxnetplumber.net> <50FC9F03.5000102@redhat.com> <20130121134534.78032a54.shmulik.ladkani@gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net, shemminger@vyatta.com,
	mst@redhat.com
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34502 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753042Ab3AVObw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 09:31:52 -0500
In-Reply-To: <20130121134534.78032a54.shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/21/2013 06:45 AM, Shmulik Ladkani wrote:
> Hi Vlad,
>
> On Sun, 20 Jan 2013 20:50:59 -0500 Vlad Yasevich <vyasevic@redhat.com> wrote:
>> On 01/20/2013 02:38 PM, Stephen Hemminger wrote:
>>> Let's assume the people that really want this feature are using a lot
>>> of vlan's. i.e n = 1000 or so. A bitmap is O(1). Any hash list would
>>> incur a just a big memory penalty for the list head. In other words
>>> a full bitmap is 4096 bits = 512 bytes.  If you use hash list,
>>> then the equivalent memory size would be only 64 list heads, therefore
>>> a bitmap is a better choice than a hlist.
>>>
>>
>> This was the approach taken in the RFC v1 of this series.  What I found
>> was that while it worked very well as far as speed goes, it was a bit
>> cumbersome to extend it to support pvids and it would completely fall
>> on its face for egress policy that Shmulik is suggesting.  So any kinds
>> of extensions to it were tough to do.
>
> I don't see why this is the case.
>
> How about (sketch only, names questionable...):
>
> struct net_bridge {
> +	unsigned long vlan_port_membership_bitmap[VLAN_N_VID][PORT_BITMAP_LEN];
> +	unsigned long vlan_port_egress_policy_bitmap[VLAN_N_VID][PORT_BITMAP_LEN];
> }
>
> (can be alloc'ed instead of the arrays being part of the struct)
>
> struct net_bridge_port {
> +	u16 pvid;
> };
>
> Allows O(1) to the query "is port P member of vlan V".
> Allows O(1) to the query "should vlan V egress tagged/untagged on port P".
>
> I guess this might simplify the data structures involved, avoiding the
> refcounts, etc...
>
> The penaties are:
>   - memory
>   - aesthetics (?)
>   - inefficient if query is "give me the entire list of VLANs port P is
>     member of". But do we have such a query in bridge's code?

Yes.  When a mac address is added to a port without an explicit vlan tag 
we try to add it for every vlan available on the port.

Also, in the API, the user may request vlans configured on a port.

>
> You say it went cumbersome. Am I missing something?
>
> BTW, altenatively, you may:
>
> struct net_bridge_port {
> +	unsigned long vlan_membership_bitmap[BITS_TO_LONGS(VLAN_N_VID)];
> +	unsigned long vlan_egress_policy_bitmap[BITS_TO_LONGS(VLAN_N_VID)];
> +	u16 pvid;
> };
>
> Which also allows O(1) to "is port 'nbp' member of vlan V".
>

This is what the earlier RFC patches did.  You are paying a large memory 
penalty and carrying a mostly empty bitmap when only a small number of 
vlans is used.

If someone decides that they'd like priority support, you'd need another 
array or list to hold priority values.

-vlad

> Difference:
> - For the membership structure:
>    former (within net_bridge) uses 4096 * BR_MAX_PORTS bits,
>    latter (within net_bridge_port) uses NumOfNBPs * 4096 bits
> - better aesthetics (?)
>
> Regards,
> Shmulik
>
