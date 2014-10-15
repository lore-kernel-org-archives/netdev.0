From: Vasily Averin <vvs@parallels.com>
Subject: Re: [PATCH v2] ipv4: dst_entry leak in ip_append_data()
Date: Wed, 15 Oct 2014 11:48:02 +0400
Message-ID: <543E26B2.3010206@parallels.com>
References: <543CAD2A.3070701@parallels.com> <20141014.161225.1399177558139744041.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:46253 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751261AbaJOHtj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Oct 2014 03:49:39 -0400
In-Reply-To: <20141014.161225.1399177558139744041.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 15.10.2014 00:12, David Miller wrote:
> From: Vasily Averin <vvs@parallels.com>
> Date: Tue, 14 Oct 2014 08:57:14 +0400
> 
>> v2: adjust the indentation of the arguments __ip_append_data() call
>>
>> Fixes: 2e77d89b2fa8 ("net: avoid a pair of dst_hold()/dst_release() in ip_append_data()")
>>
>> If sk_write_queue is empty ip_append_data() executes ip_setup_cork()
>> that "steals" dst entry from rt to cork. Later it calls __ip_append_data()
>> that creates skb and adds it to sk_write_queue.
>>
>> If skb was added successfully following ip_push_pending_frames() call
>> reassign dst entries from cork to skb, and kfree_skb frees dst_entry.
>>
>> However nobody frees stolen dst_entry if skb was not added into sk_write_queue.
>>
>> Signed-off-by: Vasily Averin <vvs@parallels.com>
> 
> Why doesn't ip_make_skb() need the same fix?  It seems to do the same
> thing.

It seems for me ip_make_skb() works (almost) correctly,
but seems refcounting can be is incorrect if queue can be not empty 
(Please see details below).

If __ip_append_data() returns errors ip_make_skb() calls 
__ip_flush_pending_frames() that calls ip_cork_release() inside
and frees stolen dst_entry.

If __ip_append_data() returns success -- dst refcounter changes are not required.
In this case skb will be created and added to queue (and it will not be empty)
Later in __ip_make_skb() these skb will get dst reference,
and refcounter will be decremented during kfree_skb(). 

I do not like that there is such unclear dependency between functions,
but seems currently it works correctly.

However I afraid dst refcountng can work incorrectly if sk_write_queue
can be not empty at the moment of ip_append_data() call.
It was not happen in case ip_send_unicast_reply() but probably
can happen in other places.

Let's calculate dst refcounters changes in this case.

First packet:

dst_refcount increment was happen in ip_append_data() caller, taken during rt lookup
- ip_append_data():
--  sk_write_queue is empty, ip_setup_cork() steals dst entry
-- __ip_append_data() adds skb to queue, queue is not flushed, waiting for next packets.
ip_rt_put in ip_append_data() caller does not work, because dst reference was stolen.

dst refcount here +1

then we want to sent 2nd packet:
dst refcount increment was happen in ip_append_data() caller
- ip_append_data():
-- sk_write_queue is NOT empty, dst was not stolen
-- __ip_append_data() adds skb to queue
ip_rt_put in ip_append_data() caller decrements dst refcount, because it as not stolen

dst refcount here +1 

Then we handle new packets, all of them are added to queue

dst refcount is still +1

Then queue is flushed.
Each packet in queue get dst reference from cork,
Each kfree_skb decrements dst refcounter, and it may become negative.

Am I wrong probably?
