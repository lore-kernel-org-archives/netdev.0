From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 2/2] net_sched: optimize tcf_match_indev()
Date: Sun, 22 Dec 2013 12:12:16 -0500
Message-ID: <52B71D70.5010401@mojatatu.com>
References: <1387503292-20078-1-git-send-email-xiyou.wangcong@gmail.com>	<1387503292-20078-2-git-send-email-xiyou.wangcong@gmail.com> <CAM_iQpXgRzPLp=qyD2pYC=J-=xRqDqVRAxm=grZJDF2ZuCsSfw@mail.gmail.com> <52B60384.6000002@mojatatu.com> <52B712D3.9050605@mojatatu.com> <52B71B89.2050603@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080100000809070306000602"
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:47787 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753578Ab3LVRMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 12:12:20 -0500
Received: by mail-ie0-f173.google.com with SMTP id to1so5131134ieb.4
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 09:12:20 -0800 (PST)
In-Reply-To: <52B71B89.2050603@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080100000809070306000602
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 12/22/13 12:04, Jamal Hadi Salim wrote:
> On 12/22/13 11:26, Jamal Hadi Salim wrote:
>
>> BTW: This indev feature was supposed to be "temporary";->
>> but has stuck around all these years. Not sure how widely it is
>> used. I will send you a testcase shortly. If it passes for you
>> please add my ACKed-by
>
>
> Attached.
> Please run before and after your changes and compare results.
>

And here's another one for u32

cheers,
jamal


--------------080100000809070306000602
Content-Type: text/plain; charset=us-ascii;
 name="indev-tests2"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="indev-tests2"

#
#
sudo ifconfig dummy0 up
#
sudo tc qdisc del dev dummy0 root handle 1: prio
sudo tc qdisc add dev dummy0 root handle 1: prio
# All traffic originating from eth0 will be accounted
# by the action
sudo tc filter add dev dummy0 protocol ip pref 1 parent 1: \
u32 match u32 0 0 \
classid 1:1 indev eth0 \
action ok
#
# All traffic originating from lo will be accounted
# by the action
sudo tc filter add dev dummy0 protocol ip pref 2 parent 1:  \
u32 match u32 0 0 \
classid 1:2 indev lo \
action ok
#-- catch all if we screwed up ---
sudo tc filter add dev dummy0 protocol ip pref 3 parent 1: \
u32 match u32 0 0 \
classid 1:3 \
action ok
#
#
sudo tc qdisc del dev eth0 ingress
sudo tc qdisc add dev eth0 ingress
sudo tc qdisc del dev lo ingress
sudo tc qdisc add dev lo ingress
#
sudo tc filter add dev lo parent ffff: protocol ip \
u32 match ip protocol 1 0xff \
flowid 1:1 \
action skbedit mark 1 \
action mirred egress mirror dev dummy0 
#
#
sudo tc filter add dev eth0 parent ffff: protocol ip \
u32 match ip src 8.8.8.8/32 \
flowid 1:11 \
action skbedit mark 1 \
action mirred egress mirror dev dummy0 
# ping -c 1 127.0.0.1
# ping -c 1 8.8.8.8
# Then lets make sure all stats are correct
sudo tc -s actions ls action skbedit
sudo tc -s actions ls action mirred
sudo tc -s actions ls action gact
sudo tc -s filter ls dev dummy0 parent 1: protocol ip  
sudo tc -s filter ls dev eth0 parent ffff: protocol ip  
sudo tc -s filter ls dev lo parent ffff: protocol ip  
#
#

--------------080100000809070306000602--
