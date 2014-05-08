From: V JobNickname <workofv@gmail.com>
Subject: Re: Is 3.18 patch "The tcp: TSO packets automatic sizing" will cause
 to Troughput drop when enable NO_HZ_IDEL or HIGH_RES_TIMERS ?
Date: Thu, 8 May 2014 13:48:39 +0800
Message-ID: <CANHbGWtGx+no=pDgD=Ay3HyqkyFcD_QPmJuzudky9dg52MD+6g@mail.gmail.com>
References: <CANHbGWs=oQBDVVZc8h5wX0WY+PRbQfCqiv5FrF1tH29QGiRndA@mail.gmail.com>
	<CADVnQy=1WdUT1xHX04uBQtROwOYDZF6idw1Qx2o2DM13kWWjFQ@mail.gmail.com>
	<CANHbGWsqBZEw0-6A0zE6PrSUF1osbN86mcYxjo9Z4V6WWyXTww@mail.gmail.com>
	<1399479939.15399.160.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Neal Cardwell <ncardwell@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:52211 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbaEHFsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 01:48:39 -0400
Received: by mail-ig0-f182.google.com with SMTP id uy17so2092655igb.3
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 22:48:39 -0700 (PDT)
In-Reply-To: <1399479939.15399.160.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-05-08 0:25 GMT+08:00 Eric Dumazet <eric.dumazet@gmail.com>:
> On Wed, 2014-05-07 at 23:51 +0800, V JobNickname wrote:
>
>>
>> Porting to the v3.15-rc4 from main stream, the performance is well when
>>  enabled NO_HZ_IDEL or HIGH_RES_TIMERS.
>>
>> I also try the version before commit 740b0f1841f6  tcp: switch rtt
>> estimations to usec resolution, i.e
>> 363ec392352 net: add skb_mstamp infrastructure,
>> also not cause to performance drop. So I think my case is regardless
>> to use jiffie or nesc in tcp_update_pacing_rate().
>>
>> Then I try more eraly version and found that in 3.14-rc2 thes case was
>> hit but solved at 3.14-rc3.
>> (I use "git checkout -b 3.14-rc2 v3.14-rc2" and "git checkout -b
>> 3.14-rc3 v3.14-rc3"  to get taged version,
>> and use "git checkout 3.14-rc2/3.14-rc3 to switch between". Hope my
>> usage are correct, since I'm not familer with git.)
>>
>> I think some commit between 3.14-rc2 and 3.14-rc3 can help find the
>> root cause of my case.
>>
>> ps.
>> But I don't know how to use git to update from rc2 to rc3 by each
>> commit(or maybe binary search commit log), and find that one commit.
>>
>> For example, I would like to following logs start from 3.14-rc2 tag in
>> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/log/?h=linux-3.14.y&ofs=1650
>>
>> Can I,
>>
>> git checkout 3.14-rc2 -- switch to 3.14-rc2
>> git checout 07b0e5b10258b48e5edfb6c8ac156f05510eb775 (ASoC: da9055:
>> Fix device registration of PMIC and CODEC devices)
>> will the commit between this commit and 3.14-rc2 also updated?
>> if this commit solve my case, I can try some one commit between it and 3.14-rc2.
>> such as
>> git checkout a49f56eec54d864ba0fda838e4c8bf5c72f3eb08 (microblaze: Fix
>> a typo when disabling stack protection)
>> should I revert to 3.14-rc2 first, or the git will done it?
>>
>> Thanks
>
> I am wondering if you are asking for git bisect maybe ?
>
> https://www.kernel.org/pub/software/scm/git/docs/git-bisect.html
>
> But in this case I am not sure it will help.
>
> An old bug can sit for years, and finally be discovered when some other
> change is done.
>
>
I still try the git bisect.
Note that, in my case the "good" means "8xMbps" and bad is "17x Mbps",
I start at 3.17-rc2 as good to find first bad commit.
The results are

git bisect start
# good: [b28a960c42fcd9cfc987441fa6d1c1a471f0f9ed] Linux 3.14-rc2
git bisect good b28a960c42fcd9cfc987441fa6d1c1a471f0f9ed
# bad: [6d0abeca3242a88cab8232e4acd7e2bf088f3bc2] Linux 3.14-rc3
git bisect bad 6d0abeca3242a88cab8232e4acd7e2bf088f3bc2
# bad: [cb6ef42e516cb8948f15e4b70dc03af8020050a2] EDAC: Correct
workqueue setup path
git bisect bad cb6ef42e516cb8948f15e4b70dc03af8020050a2
# bad: [960b589f86c74ce582922fcb996103271081f4de] bridge: Properly
check if local fdb entry can be deleted in br_fdb_change_mac_address
git bisect bad 960b589f86c74ce582922fcb996103271081f4de
# bad: [f41f03196041f91acad2b6d2b3e1f800aed60100] Merge branch
'master' of git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf
git bisect bad f41f03196041f91acad2b6d2b3e1f800aed60100
# good: [028b86b7671d17eb9a614924eb46d5efb9db931a] Merge branch
'fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch
git bisect good 028b86b7671d17eb9a614924eb46d5efb9db931a
# good: [4a5ab4e224288403b0b4b6b8c4d339323150c312] tcp: remove 1ms
offset in srtt computation
git bisect good 4a5ab4e224288403b0b4b6b8c4d339323150c312
# good: [51292c0735eb2d9e29115cbf6264845e19a6c77d] netfilter: nft_ct:
fix missing NFT_CT_L3PROTOCOL key in validity checks
git bisect good 51292c0735eb2d9e29115cbf6264845e19a6c77d
# good: [0165d9325d6a3cf856e2cbbe64a0f4635ac75893] netfilter:
nf_tables: fix racy rule deletion
git bisect good 0165d9325d6a3cf856e2cbbe64a0f4635ac75893
# good: [2fb91ddbf8e1dcb207e1e2085473aeaeff975102] netfilter:
nft_rbtree: fix data handling of end interval elements
git bisect good 2fb91ddbf8e1dcb207e1e2085473aeaeff975102
# good: [6d8c00d58e9e484fdc41aaaf62e5d8364efe375a] netfilter:
nf_tables: unininline nft_trace_packet()
git bisect good 6d8c00d58e9e484fdc41aaaf62e5d8364efe375a

f41f03196041f91acad2b6d2b3e1f800aed60100 is the first bad commit
(Merge branch 'master' of
git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf)

But this merge commit only touch netfilter related code, which I
doesn't enabled in .config.
Another problem is the 3.14-rc2 tag is at 2014-02-10, but some of
above search is early than the day, and not between 3.14-rc2 to
3.14-rc3 when I check with "git log"
So, this is not help for my case...
Thanks
