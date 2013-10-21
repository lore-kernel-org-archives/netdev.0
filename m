From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net] bridge: clean the nf_bridge status when forwarding
 the skb
Date: Mon, 21 Oct 2013 11:00:48 -0400
Message-ID: <526541A0.4000504@gmail.com>
References: <1381791096-3561-1-git-send-email-antonio@meshcoding.com> <20131017112857.GA11318@localhost> <20131017113735.GB2699@open-mesh.com> <20131018111041.GA10964@localhost> <20131018113555.GK2596@neomailbox.net> <52614669.5040301@redhat.com> <20131018144618.GL2596@neomailbox.net> <526154B2.2060900@redhat.com> <20131018154123.GM2596@neomailbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Antonio Quartulli <antonio@open-mesh.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Antonio Quartulli <antonio@meshcoding.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:37495 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752893Ab3JUPAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 11:00:53 -0400
Received: by mail-lb0-f182.google.com with SMTP id p9so5576919lbv.41
        for <netdev@vger.kernel.org>; Mon, 21 Oct 2013 08:00:52 -0700 (PDT)
In-Reply-To: <20131018154123.GM2596@neomailbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/2013 11:41 AM, Antonio Quartulli wrote:
> On Fri, Oct 18, 2013 at 11:33:06AM -0400, Vlad Yasevich wrote:
>> On 10/18/2013 10:46 AM, Antonio Quartulli wrote:
>>> On Fri, Oct 18, 2013 at 10:32:09AM -0400, Vlad Yasevich wrote:
>>>> On 10/18/2013 07:35 AM, Antonio Quartulli wrote:
>>>>> On Fri, Oct 18, 2013 at 01:10:41PM +0200, Pablo Neira Ayuso wrote:
>>>>>> On Thu, Oct 17, 2013 at 01:37:35PM +0200, Antonio Quartulli wrote:
>>>>>>> On Thu, Oct 17, 2013 at 04:28:57AM -0700, Pablo Neira Ayuso wrote:
>>>
>>> [...]
>>>
>>>>>
>>>>> The problem I was having was due to an skb entering br0 first and br1 later.
>>>>> When reaching br1 skb->nf_bridge was != NULL because of the previous processing
>>>>> in br0.
>>>>>
>>>>
>>>> Doesn't br_nf_pre_routing already take care of this for you?  It will
>>>> drop the ref on the current nf_bridge and allocate a new one.  Is that
>>>> not sufficient?
>>>
>>> In my case that line is not reached because
>>>
>>>    700         if (!IS_IP(skb) && !IS_VLAN_IP(skb) && !IS_PPPOE_IP(skb))
>>>
>>> is always true: the packet getting analysed is a batman-adv encapsulated packet,
>>> which does not match any of the three above.
>>>
>>> Cheers,
>>>
>>
>> Looking at other encapsulators (PPP, iptunnel, VXLAN), they do
>> nf_reset() on input.  Would that be appropriate for batman as well?
>
> I thought that too.
>
> But at this point, wouldn't it be better to do a reset here and remove the other
> resets from any other encapsulation module?
>
> Maybe this operation is supposed to not happen if no encapsulation is involved?

This is exactly right.  The reset happens much later if there is no 
encapsulation.  However, if there is an encapsuation that changes the 
hader values that are used to filter, then nf_reset has to happen.
That is why nf_reset happens input to the encapsulation layer instead
of always on output from bridge.

-vlad

> I thought that polishing the nf state when exiting the nf related path was a
> clean and easy solution.
>
> Moreover we avoid that any newly implemented tunneling module hit this problem again.
>
>
> Cheers,
>
