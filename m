From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2 v2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 19 Apr 2017 06:47:48 -0700
Message-ID: <1492609668.10587.164.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1492564489-28854-1-git-send-email-jhs@emojatatu.com>
         <1492566545.10587.159.camel@edumazet-glaptop3.roam.corp.google.com>
         <b00c5e30-47e9-0e71-7980-b57740ac09be@mojatatu.com>
         <1492571845.10587.161.camel@edumazet-glaptop3.roam.corp.google.com>
         <b318fd94-d4f5-d1b8-c113-a5cf374a6fee@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@resnulli.us,
        xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36171 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763861AbdDSNrv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 09:47:51 -0400
Received: by mail-it0-f68.google.com with SMTP id a140so2976885ita.3
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 06:47:50 -0700 (PDT)
In-Reply-To: <b318fd94-d4f5-d1b8-c113-a5cf374a6fee@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-04-19 at 07:24 -0400, Jamal Hadi Salim wrote:
> On 17-04-18 11:17 PM, Eric Dumazet wrote:
> > On Tue, 2017-04-18 at 22:32 -0400, Jamal Hadi Salim wrote:
> >> On 17-04-18 09:49 PM, Eric Dumazet wrote:
> >>> On Tue, 2017-04-18 at 21:14 -0400, Jamal Hadi Salim wrote:
> 
> >>
> >> Make sense?
> >
> > What if we have 1024 actions, and user provides a 4KB buffer ?
> >
> 
> No problem - we will fit as many per batch to consume 4KB
> and will send them as long as user calls recvmsg.
> 
> > Normally multiple recvmsg() calls would be needed, but I do not see how
> > the nla_put_u32(skb, TCAA_ACT_COUNT, cb->args[1]) can always succeed.
> 
> Oh, I see the cross-talk Eric;->
> We dont pack the actions in TCAA_ACT_COUNT - we put them in
> TCAA_ACT_TAB.
> 
> Here's some strace capture that best describes what happened before
> and after which i hope will make sense. Granted tc uses 32KB from
> user space and not 4KB you mention.
> 
> We have 400 actions in the kernel at this point:
> 
> tc with no changes (doesnt for this large dump):
> ---
> recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, 
> msg_iov(1)=[{"\240\16\0\0002\0\2\0^6\367XE\3\0\0\0\0\0\0\204\16\1\0\200\0\0\0\t\0\1\0"..., 
> 32768,g}], msg_controllen=0, msg_flags=0}, 0) = 3744
> 
> ===> total actions dumped 29
> 
> recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, 
> msg_iov(1)=[{" 
> \20\0\0002\0\2\0s6\367XI\3\0\0\0\0\0\0\4\20\1\0\200\0\0\0\t\0\1\0"..., 
> 32768}], msg_controllen=0, msg_flags=0}, 0) = 4128
> 
> ==> total actions dumped 32
> 
> recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, 
> msg_iov(1)=[{" 
> \20\0\0002\0\2\0s6\367XI\3\0\0\0\0\0\0\4\20\1\0\200\0\0\0\t\0\1\0"..., 
> 32768}], msg_controllen=0, msg_flags=0}, 0) = 4128
> 
> ==> total actions dumped 32
> ....
> .....
> .........
> recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, 
> msg_iov(1)=[{"\24\0\0\0\3\0\2\0s6\367XI\3\0\0\0\0\0\0", 32768}], 
> msg_controllen=0, msg_flags=0}, 0) = 20
> -----
> 
> Goes on a few times until we get all 400 entries - last recvmsg (with
> 20B) has no actions and indicates dump is complete.
> Issue: The kernel is refusing to add more than 32 entries in the skb
> even though we get allocated 32KB for the skb.
> 
> So now lets see what happens with this change:
> ------
> recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, 
> msg_iov(1)=[{"\240\16\0\0002\0\2\0^6\367XE\3\0\0\0\0\0\0\204\16\1\0\200\0\0\0\t\0\1\0"..., 
> 32768,g}], msg_controllen=0, msg_flags=0}, 0) = 3744
> 
> ==> total actions dumped 29
> 
> recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, 
> msg_iov(1)=[{"\240~\0\0002\0\2\0^6\367XE\3\0\0\0\0\0\0\204~\1\0\200\0\0\0\t\0\1\0"..., 
> 32768,g}], msg_controllen=0, msg_flags=0}, 0) = 32416
> 
> ==> total actions dumped 253
> 
> recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, 
> msg_iov(1)=[{" 
> ;\0\0002\0\2\0^6\367XE\3\0\0\0\0\0\0\4;\1\0\200\0\0\0\t\0\1\0"..., 
> 32768,g}], msg_controllen=0, msg_flags=0}, 0) = 15136
> 
> ==> total actions dumped 118
> 
> recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, 
> msg_iov(1)=[{"\24\0\0\0\3\0\2\0s6\367XI\3\0\0\0\0\0\0", 32768}], 
> msg_controllen=0, msg_flags=0}, 0) = 20
> 
> --------
> 
> We got all 400 in 3 requests. Imagine what we have to deal with
> when we have 2M actions (the improvement is about 10x).

Just because your strace works with the size of 32768 does not mean it
will work in the future.

Please read again my question.

Try to _not_ use 32768 bytes for the recvmsg() sizes, but 4KB

You pack XXX actions until 4KB skb is full.

Then code does :

nla_put_u32(skb, TCAA_ACT_COUNT, cb->args[1])

This might fail, then you 

goto out_module_put;


Then we are stuck ?

What am I missing ?
