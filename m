From: Jon Maloy <jon.maloy@ericsson.com>
Subject: Re: skb_try_coalesce bug?
Date: Tue, 22 Apr 2014 16:35:59 -0400
Message-ID: <5356D2AF.7030401@ericsson.com>
References: <20140422120125.GC7019@eerihug-hybrid.rnd.ki.sw.ericsson.se>	 <1398172293.29946.37.camel@edumazet-glaptop2.roam.corp.google.com>	 <5356C518.7050602@ericsson.com> <1398197116.29946.60.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Erik Hugne <erik.hugne@ericsson.com>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usevmg20.ericsson.net ([198.24.6.45]:63519 "EHLO
	usevmg20.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757594AbaDVUgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 16:36:11 -0400
In-Reply-To: <1398197116.29946.60.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/2014 04:05 PM, Eric Dumazet wrote:
> On Tue, 2014-04-22 at 15:38 -0400, Jon Maloy wrote:
> 
>>
>> In the case I encountered, our head buffer is linear (skb->data_len == 0),
>> so it is the real tailroom value that is returned. An alas, that one is big
>> enough to contain the last (small) fragment of the message.
> 
> 
> Whole point of skb_try_coalesce() is to coalesce as much as possible,
> without guarantee of keeping some sort of 'segments'
> 
> skb_try_coalesce - try to merge skb to prior one
> 
> If you do not want this to happen, (you seem to want nothing else in
> your head buffer skb->head), you need to add some logic.

Ok. I should have given a little background.

1: We send a message of 3041 bytes, inclusive TIPC header, via loopback interface.

2: This one gets chopped up in three fragments: 1420, 1420,and 201 bytes.
   (The mtu was of course wrong, but this is how I discovered the problem).

3: First fragment is received, uncloned, and serves as head.

4;  Second fragment (a clone) is received. skb_try_coalesce() fails at
    the skb_head_is_locked() test, because the buffer is a clone.
    Because of this, we add the buffer to skb_shinfo(head)->frag_list
    instead.

5: Third fragment (also a clone) is received. Now, since we check for
   space in tailroom of header before we do anything else, it slips
   in there, and bypasses the already chained-up second segment.

Regards
///jon


> 
> A helper temporarily setting head->tail = head->end would do it I guess.
> 
> 
