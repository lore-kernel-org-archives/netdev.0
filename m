From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH RFC] net: decrease the length of backlog queue immediately
 after it's detached from sk
Date: Fri, 8 Apr 2016 19:18:51 +0800
Message-ID: <5707939B.2030907@huawei.com>
References: <1459315001-3448-1-git-send-email-yangyingliang@huawei.com>
 <1459315520.6473.187.camel@edumazet-glaptop3.roam.corp.google.com>
 <1459316043.6473.188.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FB6AA7.1080004@huawei.com>
 <1459345637.6473.205.camel@edumazet-glaptop3.roam.corp.google.com>
 <5705F759.9020003@huawei.com>
 <1460024518.6473.389.camel@edumazet-glaptop3.roam.corp.google.com>
 <1460040665.6473.398.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	Ding Tianhong <dingtianhong@huawei.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([58.251.152.52]:23171 "EHLO
	szxga04-in.huawei.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752633AbcDHLTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 07:19:22 -0400
In-Reply-To: <1460040665.6473.398.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016/4/7 22:51, Eric Dumazet wrote:
> On Thu, 2016-04-07 at 03:21 -0700, Eric Dumazet wrote:
>
>> Please do not send patches before really understanding the issue you
>> have.
>>
>> Having a backlog of 12506206 bytes is ridiculous. Dropping packets is
>> absolutely fine if this ever happens.
>>
>> Something is really wrong on your host, or the sender simply does not
>> comply with TCP protocol (not caring of receiver window at all)
>>
>> Since you added a trace of truesize, please also trace skb->len
>>

[2016-04-08 18:33:39][ 9748.726948] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:12607514 rmem_alloc:0, truesize:31992, len:17540
[2016-04-08 18:33:39][ 9748.726964] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:12607514 rmem_alloc:29326, truesize:18662, 
len:10240
[2016-04-08 18:33:39][ 9748.726986] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:12607514 rmem_alloc:0, truesize:39990, len:21920
[2016-04-08 18:33:39][ 9748.727028] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:12607514 rmem_alloc:0, truesize:58652, len:32140
[2016-04-08 18:33:39][ 9748.727068] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:12607514 rmem_alloc:0, truesize:58652, len:32140
[2016-04-08 18:33:39][ 9748.727082] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:12607514 rmem_alloc:21328, truesize:5332, len:2940
[2016-04-08 18:33:39][ 9748.727310] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:12607514 rmem_alloc:0, truesize:53320, len:29220
[2016-04-08 18:33:39][ 9748.727326] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:12607514 rmem_alloc:26660, truesize:7998, len:4400
[2016-04-08 18:33:39][ 9748.727352] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:12607514 rmem_alloc:47988, truesize:58652, 
len:32140
[2016-04-08 18:33:39][ 9748.727389] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:12607514 rmem_alloc:0, truesize:39990, len:21920
[2016-04-08 18:33:39][ 9748.727409] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:12607514 rmem_alloc:58652, truesize:18662, 
len:10240

If I expand buffer 5 times((sndbuf+rcvbuf)*5). There are only 5M data in 
backlog at most.

[2016-04-08 18:33:39][ 9748.777743] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:5435954 rmem_alloc:0, truesize:55986, len:30680
[2016-04-08 18:33:39][ 9748.777762] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:5457282 rmem_alloc:58652, truesize:21328, 
len:11700
[2016-04-08 18:33:39][ 9748.777804] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:5515934 rmem_alloc:55986, truesize:58652, 
len:32140
[2016-04-08 18:33:39][ 9748.777818] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:5537262 rmem_alloc:0, truesize:21328, len:11700
[2016-04-08 18:33:39][ 9748.777839] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:5574586 rmem_alloc:0, truesize:37324, len:20460
[2016-04-08 18:33:39][ 9748.777854] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:5601246 rmem_alloc:58652, truesize:26660, 
len:14620
[2016-04-08 18:33:39][ 9748.777881] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:5659898 rmem_alloc:21328, truesize:58652, 
len:32140
[2016-04-08 18:33:39][ 9748.777894] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:5675894 rmem_alloc:37324, truesize:15996, len:8780
[2016-04-08 18:33:39][ 9748.778047] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:58652 rmem_alloc:0, truesize:58652, len:32140
[2016-04-08 18:33:39][ 9748.778075] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:117304 rmem_alloc:0, truesize:58652, len:32140
[2016-04-08 18:33:39][ 9748.778084] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:122636 rmem_alloc:0, truesize:5332, len:2940
[2016-04-08 18:33:39][ 9748.778109] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:175956 rmem_alloc:0, truesize:53320, len:29220
[2016-04-08 18:33:39][ 9748.778156] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:234608 rmem_alloc:0, truesize:58652, len:32140
[2016-04-08 18:33:39][ 9748.778178] TCP: rcvbuf:10485760 sndbuf:2097152 
limit:12582912 backloglen:282596 rmem_alloc:58652, truesize:47988, len:26300
>
> BTW, have you played with /proc/sys/net/ipv4/tcp_adv_win_scale ?
>

I expand  tcp_adv_win_scale and tcp_rmem. It has no effect.
>
>
>
>
