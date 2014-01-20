From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next 3/6] net_sched: act: hide struct tcf_common from
 API
Date: Mon, 20 Jan 2014 08:01:09 -0500
Message-ID: <52DD1E15.2040400@mojatatu.com>
References: <1389987427-14085-1-git-send-email-xiyou.wangcong@gmail.com> <1389987427-14085-4-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:61978 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751832AbaATNBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 08:01:13 -0500
Received: by mail-ie0-f173.google.com with SMTP id e14so8192631iej.32
        for <netdev@vger.kernel.org>; Mon, 20 Jan 2014 05:01:12 -0800 (PST)
In-Reply-To: <1389987427-14085-4-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/17/14 14:37, Cong Wang wrote:
> Now we can totally hide it from modules. tcf_hash_*() API's
> will operate on struct tc_action, modules don't need to care about
> the details.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Had to stare at this a bit longer - I am afraid
this and rest look a little suspect.
Can you run some tests for me after your patches?
I could do it in about 1 day if you dont have time.

---
#add a couple of tests
sudo tc actions add action drop index 10
sudo tc actions add action drop index 12
# now list them - should see both.
sudo tc actions ls action gact
#now flush them
sudo tc actions flush action gact
# now list them - should see them gone
sudo tc actions ls action gact
---

And for the last patch, in particular
---
#add two actions by index
sudo tc actions add action drop index 10
sudo tc actions add action ok index 12
# we need an ingress qdisc to attach filter to
sudo tc qdisc del dev lo parent ffff:
sudo tc qdisc add dev lo ingress
#use existing action index 10
sudo tc filter add dev lo parent ffff: protocol ip prio 8 \
u32 match ip dst 127.0.0.8/32 flowid 1:10 action gact index 10
#double bind
sudo tc filter add dev lo parent ffff: protocol ip prio 7 \
u32 match ip src 127.0.0.10/32 flowid 1:11 action gact index 10
# now lets see the filters..
sudo tc filter ls dev lo parent ffff: protocol ip
#display the actions and pay attention to the bind count
sudo tc actions ls action gact
#try to readd an existing action
sudo tc actions add action ok index 12
#it should be rejected - now list it and make sure refcnt doesnt go up
sudo tc actions ls action gact
#delete action index 12 (which is not bound)
sudo tc actions del action gact index 12
#list and make sure index 12 is gone
sudo tc actions ls action gact
#delete action index 10 (which is bound)
sudo tc actions del action gact index 10
#display to see it is still there ..
sudo tc actions ls action gact
#Repeat above two steps several times and make sure action 10 stays
# action should not be deleted...
#
# delete qdisc - which should delete all filters but not
# action that were not created by filters
sudo tc qdisc del dev lo parent ffff:
#ok now that filter is gone, lets see the actions ..
#pay attention to binds and references
sudo tc actions ls action gact
#
#delete action index 10 (which is no longer bound)
sudo tc actions del action gact index 10
#display to see it is gone
sudo tc actions ls action gact


cheers,
jamal
