From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v12 4/4] net sched actions: add time filter for
 action dumping
Date: Sun, 30 Jul 2017 21:06:53 +0200
Message-ID: <20170730190653.GD1872@nanopsycho>
References: <1501435492-28301-1-git-send-email-jhs@emojatatu.com>
 <1501435492-28301-5-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        horms@verge.net.au, dsahern@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:38573 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754291AbdG3TGz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 15:06:55 -0400
Received: by mail-wr0-f193.google.com with SMTP id g32so12821646wrd.5
        for <netdev@vger.kernel.org>; Sun, 30 Jul 2017 12:06:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1501435492-28301-5-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Jul 30, 2017 at 07:24:52PM CEST, jhs@mojatatu.com wrote:
>From: Jamal Hadi Salim <jhs@mojatatu.com>
>
>This patch adds support for filtering based on time since last used.
>When we are dumping a large number of actions it is useful to
>have the option of filtering based on when the action was last
>used to reduce the amount of data crossing to user space.
>
>With this patch the user space app sets the TCA_ROOT_TIME_DELTA
>attribute with the value in milliseconds with "time of interest
>since now".  The kernel converts this to jiffies and does the
>filtering comparison matching entries that have seen activity
>since then and returns them to user space.
>Old kernels and old tc continue to work in legacy mode since
>they dont specify this attribute.
>
>Some example (we have 400 actions bound to 400 filters); at
>installation time. Using updated when tc setting the time of
>interest to 120 seconds earlier (we see 400 actions):
>prompt$ hackedtc actions ls action gact since 120000| grep index | wc -l
>400
>
>go get some coffee and wait for > 120 seconds and try again:
>
>prompt$ hackedtc actions ls action gact since 120000 | grep index | wc -l
>0
>
>Lets see a filter bound to one of these actions:
>....
>filter pref 10 u32
>filter pref 10 u32 fh 800: ht divisor 1
>filter pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:10  (rule hit 2 success 1)
>  match 7f000002/ffffffff at 12 (success 1 )
>    action order 1: gact action pass
>     random type none pass val 0
>     index 23 ref 2 bind 1 installed 1145 sec used 802 sec
>    Action statistics:
>    Sent 84 bytes 1 pkt (dropped 0, overlimits 0 requeues 0)
>    backlog 0b 0p requeues 0
>....
>
>that coffee took long, no? It was good.
>
>Now lets ping -c 1 127.0.0.2, then run the actions again:
>prompt$ hackedtc actions ls action gact since 120 | grep index | wc -l
>1
>
>More details please:
>prompt$ hackedtc -s actions ls action gact since 120000
>
>    action order 0: gact action pass
>     random type none pass val 0
>     index 23 ref 2 bind 1 installed 1270 sec used 30 sec
>    Action statistics:
>    Sent 168 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
>    backlog 0b 0p requeues 0
>
>And the filter?
>
>filter pref 10 u32
>filter pref 10 u32 fh 800: ht divisor 1
>filter pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:10  (rule hit 4 success 2)
>  match 7f000002/ffffffff at 12 (success 2 )
>    action order 1: gact action pass
>     random type none pass val 0
>     index 23 ref 2 bind 1 installed 1324 sec used 84 sec
>    Action statistics:
>    Sent 168 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
>    backlog 0b 0p requeues 0
>
>Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Reviewed-by: Jiri Pirko <jiri@mellanox.com>
