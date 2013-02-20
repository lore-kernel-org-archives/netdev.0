From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [RFC PATCH] ipv6: Split from and expires field in dst_entry out
 of union [net-next]
Date: Wed, 20 Feb 2013 14:33:39 +0800
Message-ID: <51246E43.5010202@cn.fujitsu.com>
References: <1361231718.19353.117.camel@edumazet-glaptop>  <1361305694-8303-1-git-send-email-nhorman@tuxdriver.com>  <1361308665.19353.161.camel@edumazet-glaptop>  <20130219214934.GD31871@hmsreliant.think-freely.org> <1361310958.19353.164.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, Jiri Bohac <jbohac@suse.cz>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:46240 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932597Ab3BTGc5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2013 01:32:57 -0500
In-Reply-To: <1361310958.19353.164.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric & Neil,
On 2013/02/20 05:55, Eric Dumazet wrote:
> On Tue, 2013-02-19 at 16:49 -0500, Neil Horman wrote:
>> On Tue, Feb 19, 2013 at 01:17:45PM -0800, Eric Dumazet wrote:
>>> On Tue, 2013-02-19 at 15:28 -0500, Neil Horman wrote:
>>>
>>>>  static inline void rt6_update_expires(struct rt6_info *rt, int timeout)
>>>>  {
>>>>  	if (!(rt->rt6i_flags & RTF_EXPIRES)) {
>>>> -		if (rt->dst.from)
>>>> -			dst_release(rt->dst.from);
>>>> +		dst_release(rt->dst.from);
>>>>  		/* dst_set_expires relies on expires == 0 
>>>>  		 * if it has not been set previously.
>>>>  		 */
>>>>  		rt->dst.expires = 0;
>>>> +		rt6->dst.from = NULL;
>>>>  	}
>>>>  
>>>
>>> Sorry you didnt really address the problem, only reduce the race window.
>>>
>> I kinda had a feeling you would say that, but the only other solution I see here
>> is to either introduce some locking to protect the from pointer, or two revert
>> the patch that introduced the from pointer alltogether, neither of which sounds
>> appealing to me.  I suppose we could use an xchng to atomically update the from
>> pointer, so there was only ever one context that was able to free it in
>> rt6_update_path.  Does that seem reasonable to you?
> 

Thanks for your research on this problem.

> I believe the setting of rt6->dst.from is safe :
> It should be done at :
> - dst creation time, when we are the only user.
> - dst destry time, when we are the only user.
> 
> We only have to do the dst_release() at the right place, when we are the
> last user of the dst.
> 
> So rt6_update_expires() should not mess with rt6->dst.from at all.
> 

How can we?
one usage of rt6_update_expires and rt6_set_expires
is changing rt6->dst.from to rt6->dst.expires, we should release the
already holded reference of rt6->dst.from.

I think maybe we should rework the commit 1716a96101c49186b
(ipv6: fix problem with expired dst cache). just force setting flag
RTF_EXPIRES and expires for the rt6 which copied from the rt6(which
is generated from RA). The only problem of this situation is this
copied rt6's expire time may be imprecise, we may receive a new
RA with a new expire time.
