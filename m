From: Patrick McHardy <kaber@trash.net>
Subject: Re: [GENETLINK]: Question: global lock (genl_mutex) possible refinement?
Date: Fri, 20 Jul 2007 15:21:34 +0200
Message-ID: <46A0B6DE.1080904@trash.net>
References: <46A0B017.4080505@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Richard MUSIL <richard.musil@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61331 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756901AbXGTNZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 09:25:13 -0400
In-Reply-To: <46A0B017.4080505@st.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Richard MUSIL wrote:
> I am currently trying to write a module which communicates with user space using NETLINK_GENERIC. This module (dev_mgr) manages virtual devices which are also supposed to use genetlink for communication with user space.
>
> I want to do something like that:
> dev_mgr <- receives message from user space to create new device
> dev_mgr	inside 'doit' handler:
> 	1. creates device
> 	2. registers new genetlink family for the device
> 	3. returns family name and id to user
>
> This should work similarly for device removal.
>
> After few reboots I found out that 2. blocks on genl_mutex, since this mutex is already acquired when genl_register_family is called (by genl_rcv).
>
> I do not see why registering new family (when processing message for another family) should be a problem. In fact from genl_lock and genl_trylock occurrence it seems that genl_mutex is mostly used for syncing access to family list and also for message processing.
> Since I am not (yet) familiar enough with (ge)netlink internals I am asking:
> Would it make sense to split the mutex into two, one for family list and one for messaging, so it would be possible to change families when processing the message?
>
> Simple split could introduce possible danger of user removing family inside processing of the message for this particular family, but would this really be a danger?
>   

The usual way to do this for auto-loading of modules that register
things that take a mutex that is already held during netlink queue
processing, like qdiscs, classifiers, .. is:

- look for <qdisc/classifier/...>, if not found:
- drop mutex (using the __ unlock variant to avoid reentering queue 
processing)
- perform module loading (which takes the mutex and registers itself)
- grab mutex again
- look for <qdisc/classifier/...> again
- if not found return -ENOENT
- if found drop reference, return -EAGAIN

The caller is changed to handle -EAGAIN by replaying the entire
request. Your problem sounds very similar, look at net/sched/sch_api.c
for an example.


