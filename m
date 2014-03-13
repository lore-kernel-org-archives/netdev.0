From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RCU PATCH 00/14] Remove qdisc lock around ingress Qdisc
Date: Thu, 13 Mar 2014 04:44:25 -0400
Message-ID: <53216FE9.7090604@mojatatu.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32> <53200588.5060805@mojatatu.com> <53208F11.8010304@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040006090701090009060602"
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:57803 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbaCMIo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 04:44:29 -0400
Received: by mail-wi0-f181.google.com with SMTP id bs8so747002wib.14
        for <netdev@vger.kernel.org>; Thu, 13 Mar 2014 01:44:28 -0700 (PDT)
In-Reply-To: <53208F11.8010304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040006090701090009060602
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit

On 03/12/14 12:45, John Fastabend wrote:
> On 03/11/2014 11:58 PM, Jamal Hadi Salim wrote:
>> On 03/10/14 13:03, John Fastabend wrote:
>
> Sure I can provide this data as part of the patch description. My
> expectation is now that the qdisc lock is not needed there should
> be less impact to throughput/latency due to filter updates.

Thats what i would think as well (which would be great).

>
> Yes upto one RCU grace period. Although I don't think this is an
> issue because we get consistency eventually and even with the qdisc
> lock there is no way to know if a set of skbs hit the filter list
> before or after the update.
>

Probably not a big issue - but needs to be document clearly since the
expectations have changed.

> I'll get a v2 out tomorrow morning after making Eric's changes and
> fixing the last compiler warning.
>

There is one more thing. Actions can be shared. I am wondering how this
change is going to affect it - can you try this attached script? Sorry,
I could have sent a much simpler script - but this is one sitting on
my laptop (i have annotated it - notice the 2 policer instances
are shared).
Would be useful to do pings across two devices at the same time while 
concurently doing dumps and see if anything goes crazy (like an oops).

cheers,
jamal


>> net/core/gen_estimator.c: In function ‘gen_get_bstats’:
>> net/core/gen_estimator.c:163:43: warning: pointer type mismatch in
>> conditional expression [enabled by default]
>> net/core/gen_estimator.c: In function ‘gen_find_node’:
>> net/core/gen_estimator.c:191:28: warning: pointer type mismatch in
>> conditional expression [enabled by default]
>
> compiler doesn't like the usage of voids here.
>
> Thanks,
> John
>
>
>>
>> cheers,
>> jamal
>>
>>
>>
>
>


--------------040006090701090009060602
Content-Type: text/plain; charset=us-ascii;
 name="shared-act-tst1"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="shared-act-tst1"

TC="/sbin/tc"
#
sudo ifconfig dummy0 up
sudo ifconfig dummy1 up
DEV1="eth0"
DEV2="eth1"
#
#
#
sudo $TC qdisc del dev $DEV1 ingress
sudo $TC qdisc add dev $DEV1 ingress
sudo $TC qdisc del dev $DEV2 ingress
sudo $TC qdisc add dev $DEV2 ingress
#Note - older tc did not pipe for skbedit (add "pipe" if this is rejected)
sudo $TC filter add dev $DEV1 parent ffff: protocol ip pref 10 \
u32 match ip protocol 1 0xff flowid 1:10 \
action skbedit mark 11 \
action police rate 10kbit burst 10k pipe index 1 \
action skbedit mark 12 \
action police rate 20kbit burst 20k pipe index 2 \
action mirred egress mirror dev dummy0
#note sharing of the two policers by two flows
#across multiple devices
sudo $TC filter add dev $DEV2 parent ffff: protocol ip pref 10 \
u32 match ip protocol 1 0xff flowid 1:10 \
action skbedit mark 21 \
action police rate 10kbit burst 10k pipe index 1 \
action skbedit mark 22 \
action police rate 20kbit burst 20k pipe index 2 \
action mirred egress mirror dev dummy1
#
#
# now do a ping -f to somewhere, for more exciting results
# do a -s 2048 or so
# sudo ping -f 192.168.1.100 -c 10000
# sudo ping -f 127.0.0.1 -c 10000
#
sudo tc -s filter ls dev $DEV1 parent ffff: protocol ip 
sudo tc -s filter ls dev $DEV2 parent ffff: protocol ip 
sudo tc -s actions ls action police
sudo tc -s actions ls action skbedit

--------------040006090701090009060602--
