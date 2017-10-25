From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/1] tc/actions: introduce support for jump
 action
Date: Wed, 25 Oct 2017 12:35:41 +0200
Message-ID: <20171025123541.6a7e55f9@shemminger-XPS-13-9360>
References: <1508683690-3440-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:51073 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932378AbdJYKf6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 06:35:58 -0400
Received: by mail-wm0-f68.google.com with SMTP id u138so931805wmu.5
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 03:35:57 -0700 (PDT)
In-Reply-To: <1508683690-3440-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 22 Oct 2017 10:48:10 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> Seems like my old patches didnt make it into the tree - so here goes
> 
> Sample use case:
> 
> ... add ingress qdisc
> sudo $TC qdisc add dev $ETH ingress
> 
>  ... if we exceed rate of 1kbps (burst of 90K), do an absolute jump of 2 actions
> sudo $TC actions add action police rate 1kbit burst 90k conform-exceed jump 2 / pipe
> 
> sudo $TC -s actions ls action police
> ---
>  action order 0:  police 0x4 rate 1Kbit burst 23440b mtu 2Kb action jump 2/pipe overhead 0b
>  ref 1 bind 0 installed 41 sec used 41 sec
>  Action statistics:
>   Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>   backlog 0b 0p requeues 0
> --
> 
> ... lets add a couple of marks so we can use them to mark exceed/not exceed
> sudo $TC actions add action skbedit mark 11 ok index 11
> sudo $TC actions add action skbedit mark 12 ok index 12
> 
> ... if we dont exceed our rate we get a mark of 11, else mark of 12
> sudo $TC filter add dev $ETH parent ffff: protocol ip prio 8 u32 \
> match ip dst 127.0.0.8/32 flowid 1:10 \
> action police index 4 \
> action skbedit index 11 \
> action skbedit index 12
> 
> Ok, lets keep this thing a little busy..
> sudo ping -f -c 10000 127.0.0.8
> 
> ... now lets see the filters..
> sudo $TC -s filter ls dev $ETH parent ffff: protocol ip
> 
> ----
> filter pref 8 u32 chain 0
> filter pref 8 u32 chain 0 fh 800: ht divisor 1
> filter pref 8 u32 chain 0 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:10 not_in_hw  (rule hit 20000 success 10000)
>   match 7f000008/ffffffff at 16 (success 10000 )
> 	action order 1:  police 0x4 rate 1Kbit burst 23440b mtu 2Kb action jump 2/pipe overhead 0b
> 	ref 2 bind 1 installed 198 sec used 2 sec
> 	Action statistics:
> 	Sent 840000 bytes 10000 pkt (dropped 0, overlimits 9721 requeues 0)
> 	backlog 0b 0p requeues 0
> 
> 	action order 2:  skbedit mark 11 pass
> 	 index 11 ref 2 bind 1 installed 127 sec used 2 sec
>  	Action statistics:
> 	Sent 23436 bytes 279 pkt (dropped 0, overlimits 0 requeues 0)
> 	backlog 0b 0p requeues 0
> 
> 	action order 3:  skbedit mark 12 pass
> 	 index 12 ref 2 bind 1 installed 127 sec used 2 sec
>  	Action statistics:
> 	Sent 816564 bytes 9721 pkt (dropped 0, overlimits 0 requeues 0)
> 	backlog 0b 0p requeues 0
> -----
> 
> As can be seen 97.21% of the packets were marked as exceeding the allocated
> rate; you could do something clever with the skb mark after this.
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied, but it required editing of commit message because you used --- as a separator
which for git indicates end of commit text that should be included.
