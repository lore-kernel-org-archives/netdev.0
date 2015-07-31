From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [Patch net] act_pedit: check binding before calling tcf_hash_release()
Date: Fri, 31 Jul 2015 13:10:35 +0200
Message-ID: <55BB57AB.5030003@iogearbox.net>
References: <1438301541-26192-1-git-send-email-xiyou.wangcong@gmail.com> <1438301541-26192-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51587 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbbGaLKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 07:10:38 -0400
In-Reply-To: <1438301541-26192-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/31/2015 02:12 AM, Cong Wang wrote:
> When we share an action within a filter, the bind refcnt
> should increase, therefore we should not call tcf_hash_release().
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>

Seems like this slipped in via commit 1a29321ed045. The ugly thing is that
this leads to a use-after-free.

# tc actions add action pedit munge offset 2 u16 at 0 0f0000000 22 set 11500
# tc actions show action pedit
   action order 0:  pedit action pass keys 1
   index 1 ref 1 bind 0
   key #0  at 0: val 00002cec mask ffff0000
# tc filter add dev foo parent 1: bpf bytecode "$FOO" flowid 1:1 action pedit index 1
# tc filter show dev foo
   filter parent 1: protocol all pref 49152 bpf
   filter parent 1: protocol all pref 49152 bpf handle 0x1 flowid 1:1 bytecode '1,6 0 0 4294967295'
   action order 1: pedit action pass keys 1
   index 1 ref 1 bind 0
   key #0  at 0: val 00002cec mask ffff0000
# tc actions del action pedit index 1

.... and now you can wait for the next egress packet. ;)

Thanks for the fix Cong!

Fixes: 1a29321ed045 ("net_sched: act: Dont increment refcnt on replace")
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
