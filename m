From: Alex Elder <elder@inktank.com>
Subject: Re: [PATCH] net/ceph/osdmap.c: fix undefined behavior when using
 snprintf()
Date: Wed, 23 Jan 2013 11:47:54 -0600
Message-ID: <5100224A.8010102@inktank.com>
References: <1358882429-19066-1-git-send-email-dinggnu@gmail.com> <51001447.3030600@inktank.com> <20130123174150.GA26336@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sage Weil <sage@inktank.com>,
	"David S. Miller" <davem@davemloft.net>,
	ceph-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Cong Ding <dinggnu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130123174150.GA26336@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/23/2013 11:41 AM, Cong Ding wrote:
> On Wed, Jan 23, 2013 at 10:48:07AM -0600, Alex Elder wrote:
>> On 01/22/2013 01:20 PM, Cong Ding wrote:
>>> The variable "str" is used as both the source and destination in function
>>> snprintf(), which is undefined behavior based on C11. The original description
>>> in C11 is:
>>> 	"If copying takes place between objects that
>>> 	overlap, the behavior is undefined."
>>
>> Yes, this was an ill-advised thing to do in this function.
>>
>> In fact, the only place this function is used (in osdmap_show()),
>> the non-static buffer was not initialized before the call.  (It
>> might happen to work because the same stack space was getting
>> reused each time through the loop.  Eeeeew!)
>>
>> This is just an awful couple of functions.
>>
>>> And, the function of ceph_osdmap_state_str() is to return the osdmap state, so
>>> it should return "doesn't exist" when all the conditions are not satisfied. I
>>> fix it in this patch.
>>>
>>> Based on C11, snprintf() does nothing if n==0:
>>> 	"If n is zero, nothing is written, and s may be a
>>> 	null pointer. Otherwise, output characters beyond
>>> 	the n-1st are discarded rather than being written to
>>> 	the array, and a null character is written at the
>>> 	end of the characters actually written into the
>>> 	array."
>>> so I remove the unnecessary check of len (because it is not a busy path and
>>> saves a few lines of code).
>>
>> True.  But since you know it's not going to do anything why
>> not only make the call if len is non-zero?  I.e.:
>>
>> 	else if (len)
>> 		snprintf(str, len, "doesn't exist");
>>
>> With your permission I'll make this change and will commit
>> this for you.  OK?
> It's fine, thanks. But I think it's better to check len in the beginning
> because other conditions also call snprintf with parameter len. Like this:

OK.  I'll do this.  Thank you.		-Alex


> 	if (!len)
> 		return str;
> 
> 	if ((state & CEPH_OSD_EXISTS) && (state & CEPH_OSD_UP))
> 		snprintf(str, len, "exists, up");
> 	else if (state & CEPH_OSD_EXISTS)
> 		snprintf(str, len, "exists");
> 	else if (state & CEPH_OSD_UP)
> 		snprintf(str, len, "up");
> 	else
> 		snprintf(str, len, "doesn't exist");
> 
> 	return str;
> 
> or like this:
> 
> 	if (len) {
> 		if ((state & CEPH_OSD_EXISTS) && (state & CEPH_OSD_UP))
> 			snprintf(str, len, "exists, up");
> 		else if (state & CEPH_OSD_EXISTS)
> 			snprintf(str, len, "exists");
> 		else if (state & CEPH_OSD_UP)
> 			snprintf(str, len, "up");
> 		else
> 			snprintf(str, len, "doesn't exist");
> 	}
> 	return str;
> 
> Thanks,
> - cong
> 
