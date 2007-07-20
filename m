From: Richard MUSIL <richard.musil@st.com>
Subject: Re: [GENETLINK]: Question: global lock (genl_mutex) possible refinement?
Date: Fri, 20 Jul 2007 15:58:23 +0200
Message-ID: <46A0BF7F.80001@st.com>
References: <46A0B017.4080505@st.com> <46A0B6DE.1080904@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s200aog11.obsmtp.com ([207.126.144.125]:44576 "EHLO
	s200aog11.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757787AbXGTN6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 09:58:37 -0400
In-Reply-To: <46A0B6DE.1080904@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Richard MUSIL wrote:
>> I am currently trying to write a module which communicates with user
>> space using NETLINK_GENERIC. This module (dev_mgr) manages virtual
>> devices which are also supposed to use genetlink for communication
>> with user space.
>>
>> I want to do something like that:
>> dev_mgr <- receives message from user space to create new device
>> dev_mgr    inside 'doit' handler:
>>     1. creates device
>>     2. registers new genetlink family for the device
>>     3. returns family name and id to user
>>
>> This should work similarly for device removal.
>>
>> After few reboots I found out that 2. blocks on genl_mutex, since this
>> mutex is already acquired when genl_register_family is called (by
>> genl_rcv).
>>
>> I do not see why registering new family (when processing message for
>> another family) should be a problem. In fact from genl_lock and
>> genl_trylock occurrence it seems that genl_mutex is mostly used for
>> syncing access to family list and also for message processing.
>> Since I am not (yet) familiar enough with (ge)netlink internals I am
>> asking:
>> Would it make sense to split the mutex into two, one for family list
>> and one for messaging, so it would be possible to change families when
>> processing the message?
>>
>> Simple split could introduce possible danger of user removing family
>> inside processing of the message for this particular family, but would
>> this really be a danger?
>>   
> 
> The usual way to do this for auto-loading of modules that register
> things that take a mutex that is already held during netlink queue
> processing, like qdiscs, classifiers, .. is:
> 
> - look for <qdisc/classifier/...>, if not found:
> - drop mutex (using the __ unlock variant to avoid reentering queue
> processing)
> - perform module loading (which takes the mutex and registers itself)
> - grab mutex again
> - look for <qdisc/classifier/...> again
> - if not found return -ENOENT
> - if found drop reference, return -EAGAIN
> 
> The caller is changed to handle -EAGAIN by replaying the entire
> request. Your problem sounds very similar, look at net/sched/sch_api.c
> for an example.

The aforementioned mutex is local to genetlink module, so I cannot temporarily drop it, call the stuff and grab it again (which was mine original thought too).
In fact the only way to go around (without changing the genetlink) seems to schedule the family registration to some other context outside message processing. But this would be clearly much more complex than doing it directly in message handler and also a bit against "ease of use" which genetlink is supposed to offer.

My question was if its really necessary to sync both message processing and genetlink family management on one primitive. I believe it is not, but I would rather be happy if someone who maintains it confirm this theory. Meanwhile I am going to do quick mod to genetlink and if it goes well, post the patch, which seems to be quite simple.

--
Richard
