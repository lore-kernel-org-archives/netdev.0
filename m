From: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 2/2] mac80211: Resolve sk_refcnt/sk_wmem_alloc
 issue in wifi ack path
Date: Thu, 11 Sep 2014 07:40:18 -0700
Message-ID: <5411B452.7080204@intel.com>
References: <20140910215837.23225.39149.stgit@ahduyck-bv4.jf.intel.com>	 <20140910220536.23225.92956.stgit@ahduyck-bv4.jf.intel.com> <1410419198.1825.5.camel@jlt4.sipsolutions.net> <54116D8E.20308@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54116D8E.20308-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/11/2014 02:38 AM, Arend van Spriel wrote:
> On 09/11/14 09:06, Johannes Berg wrote:
>> On Wed, 2014-09-10 at 18:05 -0400, Alexander Duyck wrote:
>>> There is a possible issue with the use, or lack thereof of sk_refcnt and
>>> sk_wmem_alloc in the wifi ack status functionality.
>>>
>>> Specifically if a socket were to request acknowledgements, and the
>>> socket
>>> were to have sk_refcnt drop to 0 resulting in it waiting on
>>> sk_wmem_alloc
>>> to reach 0 it would be possible to have sock_queue_err_skb orphan the
>>> last
>>> buffer, resulting in __sk_free being called on the socket.  After
>>> this the
>>> buffer is enqueued on sk_error_queue, however the queue has already been
>>> flushed resulting in at least a memory leak, if not a data corruption.
>>
>> Oh. Thanks :-)
> 
> Hi Alexander,
> 
> So why is this only an issue in wifi ack path. The sock_queue_err_skb()
> does not mention the caller should hold a sock reference. This seems
> entirely an issue of the sock_queue_err_skb() function itself so why not
> do sk_hold/sk_put within that function. Does it impose too much overhead?
> 
> Regards,
> Arend

I considered it but there are a number of cases where this is not an issue.

For example in the tx timestamping path there is the software timestamp
case where the buffer is cloned and the clone is queued immediately onto
the sk_error_queue.  In that case we still have a reference in the other
skb that is maintaining the socket.

So I thought it best to just address the cases where I know this could
be a problem.  I had already addressed it in the timestamping for
hardware timestamps where we are doing something similar.  So I thought
it would make sense to cover the other case that should have the same
problems.

Thanks,

Alex
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
