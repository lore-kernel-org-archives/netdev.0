From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 06/12] net: sched: support qdisc_reset on NOLOCK qdisc
Date: Wed, 13 Jan 2016 10:03:54 -0800
Message-ID: <5696918A.5000005@gmail.com>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>	<20151230175313.26257.46445.stgit@john-Precision-Tower-5810> <20160113.112016.995229320622519258.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, eric.dumazet@gmail.com, jhs@mojatatu.com,
	aduyck@mirantis.com, brouer@redhat.com, john.r.fastabend@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33315 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754507AbcAMSEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 13:04:13 -0500
Received: by mail-pa0-f66.google.com with SMTP id pv5so28314927pac.0
        for <netdev@vger.kernel.org>; Wed, 13 Jan 2016 10:04:13 -0800 (PST)
In-Reply-To: <20160113.112016.995229320622519258.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-01-13 08:20 AM, David Miller wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Wed, 30 Dec 2015 09:53:13 -0800
> 
>>  case 2: dev_deactivate sequence. This can come from a user bringing
>> 	 the interface down which causes the gso_skb list to be flushed
>> 	 and the qlen zero'd. At the moment this is protected by the
>> 	 qdisc lock so while we clear the qlen/gso_skb fields we are
>> 	 guaranteed no new skbs are added. For the lockless case
>> 	 though this is not true. To resolve this move the qdisc_reset
>> 	 call after the new qdisc is assigned and a grace period is
>> 	 exercised to ensure no new skbs can be enqueued. Further
>> 	 the RTNL lock is held so we can not get another call to
>> 	 activate the qdisc while the skb lists are being free'd.
>>
>> 	 Finally, fix qdisc_reset to handle the per cpu stats and
>> 	 skb lists.
> 
> Just wanted to note that some setups are sensitive to device
> register/deregister costs.  This is why we batch register and
> unregister operations in the core, so that the RCU grace period
> is consolidated into one when we register/unregister a lot of
> net devices.
> 
> If we now will incur a new per-device unregister RCU grace period
> when the qdisc is destroyed, it could cause a regression.
> 

It adds a synchronize_net in the error case for many users of
unregister_netdevice(). I think this should be rare and I believe
its OK to add the extra sync net in these cases. For example this
may happen when we try to add a tunnel and __dev_get_by_name() fails.
But if your worried about bring up, tear down performance I think you
should be using ifindex numbers and also not fat fingering dev
names on the cli.

Also there are a few drivers still doing their own walking of lists
and calling unregister_netdevice() directly instead of the better
APIs like unregister_netdevice_queue() and friends. I can patch these
drivers if that helps its a mechanical change but I'm not super
excited about testing things like the caif driver ;)

Further just looking at it now there are three calls to sync net in
the dev down paths. It seems we should be able to remove at least one
of those if we re-organize the tear down a bit better. But that is
another patch series.

.John
