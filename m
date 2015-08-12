From: Sorin Dumitru <sorin@returnze.ro>
Subject: Re: [PATCH] net: Use SK_MEM_QUANTUM as minimum for tcp/udp rmem/wmem
Date: Wed, 12 Aug 2015 20:00:56 +0300
Message-ID: <CALh4rZqte0muVz0YLBVnsb9xzMh-xjKG8wmbi9Yo=9ge6z90HQ@mail.gmail.com>
References: <1438806414-751067-1-git-send-email-calvinowens@fb.com>
	<20150809.224114.818332231954008575.davem@davemloft.net>
	<20150811033406.GA1136819@mail.thefacebook.com>
	<20150810.204630.1903301700926701432.davem@davemloft.net>
	<20150812045420.GA3908557@mail.thefacebook.com>
	<1439389261.29802.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Calvin Owens <calvinowens@fb.com>,
	Sorin Dumitru <sdumitru@ixiacom.com>,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:34635 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932189AbbHLRA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 13:00:58 -0400
Received: by labd1 with SMTP id d1so12677369lab.1
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 10:00:56 -0700 (PDT)
In-Reply-To: <1439389261.29802.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 12, 2015 at 5:21 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2015-08-11 at 21:54 -0700, Calvin Owens wrote:
>> Commit 8133534c760d4083 ("net: limit tcp/udp rmem/wmem to
>> SOCK_{RCV,SND}BUF_MIN") modified four sysctls to enforce that the values
>> written to them are not less than SOCK_MIN_{RCV,SND}BUF.
>>
>> That change causes 4096 (or SK_MEM_QUANTUM) to no longer be accepted as
>> a valid value for 'min' in tcp_wmem and udp_wmem_min. 4096 has been the
>> default for both of those sysctls for a long time, and unfortunately
>> seems to be an extremely popular setting. This change breaks a large
>> number of sysctl configurations at FB.
>>
>> That commit referred to b1cb59cf2efe7971 ("net: sysctl_net_core: check
>> SNDBUF and RCVBUF for min length"), which choose to use the SOCK_MIN
>> constants as the lower limits to avoid nasty bugs. But AFAICS, a limit
>> of SOCK_MIN_SNDBUF isn't necessary to do that: the BUG_ON cited in the
>> commit message seems to have happened because unix_stream_sendmsg()
>> expects a minimum of a full page (ie SK_MEM_QUANTUM) and the math broke,
>> not because it had less than SOCK_MIN_SNDBUF allocated.
>>
>> Nothing seems to assume that it has at least SOCK_MIN_SNDBUF to play
>> with, so I think enforcing a minimum of SK_MEM_QUANTUM avoids the sort
>> of bugs 8133534c was trying to avoid, and it does so without breaking
>> anybody's sysctl configurations.
>>
>> Fixes: 8133534c760d4083 ("net: limit tcp/udp rmem/wmem to SOCK_MIN...")
>> Signed-off-by: Calvin Owens <calvinowens@fb.com>
>> ---
>
> #define SK_MEM_QUANTUM ((int)PAGE_SIZE)
>
> Some arches have PAGE_SIZE = 65536
>
> So your patch might break scripts as well for them.
>
> We should revert 8133534c760d4083.
>

Would clamping the values to a min value, like setsockopt(SO_SNDBUF)
does, be an option?
I still find it odd that SO_SNDBUF limits you, while the /proc
interface doesn't. If you think it's
too much, I'm ok with reverting it since it affects scripts.

On those arches where PAGE_SIZE == 64K(or > 16K) it looks like we have
tcp_wmem[1]
smaller than tcp_wmem[0]. Shouldn't we do something about this?
