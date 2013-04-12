From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 02/11] ixgbe: Mask off check of frag_off as we only
 want fragment offset
Date: Fri, 12 Apr 2013 11:22:28 -0700
Message-ID: <516850E4.8020504@intel.com>
References: <1365765866-15741-1-git-send-email-jeffrey.t.kirsher@intel.com>   <1365765866-15741-3-git-send-email-jeffrey.t.kirsher@intel.com>   <1365773328.4459.19.camel@edumazet-glaptop>  <1365774332.4459.24.camel@edumazet-glaptop> <51683884.2010509@intel.com> <1365785511.4459.46.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35604 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753061Ab3DLSWc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Apr 2013 14:22:32 -0400
In-Reply-To: <1365785511.4459.46.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/12/2013 09:51 AM, Eric Dumazet wrote:
> On Fri, 2013-04-12 at 09:38 -0700, Alexander Duyck wrote:
>> On 04/12/2013 06:45 AM, Eric Dumazet wrote:
>>> On Fri, 2013-04-12 at 06:28 -0700, Eric Dumazet wrote:
>>>
>>>> I wonder if you could use core functions instead of all this...
>>>>
>>>> A simple wrapper would be :
>>> Or more something like :
>>>
>>> static noinline unsigned int ixgbe_get_headlen(unsigned char *data,
>>>                                                 u32 maxlen)
>>> {
>>>     struct skb fake;
>>>     unsigned int res;
>>>
>>>     if (maxlen < ETH_HLEN)
>>> 	return maxlen;
>>>
>>>     fake->data = data + ETH_HLEN;
>>>     fake->head = data;
>>>     fake->data_len = 0;
>>>     fake->len = maxlen - ETH_HLEN;
>>>     skb_reset_network_header(&fake);
>>>     res = __skb_get_poff(&fake);
>>>     return res ? res + ETH_HLEN : maxlen;
>>> }
>> The problem is this is way more then I need, and I would prefer not to
>> allocate a 192+ byte structure on the stack in order to just parse a
>> header that is likely less than 128 bytes.
>>
> Thats why I used 'noinline' keyword.
>
> Your code adds significative icache pressure and latencies.

The footprint for the code itself is not that large, and the fact is the
behavior is different enough from skb_flow_dissect which is what
__skb_get_poff relies on that I don't think I could get the same
behavior without adding at least one more protocol (FCOE), and probably
some sort of flag because in our case we want the header length
including L4 header for the first frame of a fragmented flow since the
goal is to leave only payload data in the pages.

>> I could probably do something like create a copy of the
>> ixgbe_get_headlen function, maybe named something like
>> etherdev_get_headlen and stored in eth.c that could be used by both igb
>> and ixgbe.  That way it would be available for anyone else who might
>> want to do something similar.  If that would work for you I could
>> probably submit that patch sometime in the next few hours.
> No please don't do that.
>
> I suggested reusing stuff, not duplicating it.
>
> The main problem is not the cpu cycles spent to parse the header, but
> bringing two cache lines for the memcpy() to pull headers.  (TCP uses 66
> bytes of headers)
>
> If you use a prefetch(data + 64), chances are good the current generic
> code will run before hitting the memory stall

The main problem I have with this is the fact that before we are done we
would have had to populate a number of fields within the fake skb before
the parsing could be completed.  This also assumes that at no point in
the future will somebody add anything that requires any other fields to
be set or unset within the skb since all of the values in fake are not
memset to 0 like a standard skb.  It would be a pain to debug this type
of issue.

For example the code snippet you sent likely wouldn't have worked
because it appears to have missed that it would also need to set
skb->protocol before being called.

I appreciate the desire to reuse, and what I meant was that since igb
and ixgbe both use essentially the same function I could move it to one
central location and both of them could use it as well as any other low
level drivers that need to just quickly parse the header out of a linear
block of data.  I just don't feel __skb_get_poff really does what I am
looking for since it assumes it is working with a skb, not just a linear
block of data.  If it could get broken up somehow so that it, or at
least pieces of it could just be used on linear blocks of data then I
might be more interested in reusing it.

Thanks,

Alex
