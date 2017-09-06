From: =?utf-8?Q?H=C3=A5kon_Bugge?= <haakon.bugge@oracle.com>
Subject: Re: [PATCH net] rds: Fix incorrect statistics counting
Date: Wed, 6 Sep 2017 18:12:58 +0200
Message-ID: <715EA84D-6ACA-45DE-9EA2-6122E11545E8@oracle.com>
References: <20170906152950.17766-1-Haakon.Bugge@oracle.com>
 <b620a15a-e60e-5c35-ffef-ee485d338774@oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        OFED mailing list <linux-rdma@vger.kernel.org>,
        rds-devel@oss.oracle.com, linux-kernel@vger.kernel.org,
        Knut Omang <knut.omang@oracle.com>
To: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b620a15a-e60e-5c35-ffef-ee485d338774@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On 6 Sep 2017, at 17:58, Santosh Shilimkar <santosh.shilimkar@oracle.com> wrote:
> 
> On 9/6/2017 8:29 AM, Håkon Bugge wrote:
>> In rds_send_xmit() there is logic to batch the sends. However, if
>> another thread has acquired the lock, it is considered a race and we
>> yield. The code incrementing the s_send_lock_queue_raced statistics
>> counter did not count this event correctly.
>> This commit removes a small race in determining the race and
>> increments the statistics counter correctly.
>> Signed-off-by: Håkon Bugge <haakon.bugge@oracle.com>
>> Reviewed-by: Knut Omang <knut.omang@oracle.com>
>> ---
>>  net/rds/send.c | 16 +++++++++++++---
>>  1 file changed, 13 insertions(+), 3 deletions(-)
> Those counters are not really to give that accurate so
> am not very keen to add additional cycles in send paths
> and add additional code. Have you seen any real issue
> or this is just a observation. s_send_lock_queue_raced
> counter is never used to check for smaller increments
> and hence the question.

Hi Santosh,


Yes, I agree with accuracy of s_send_lock_queue_raced. But the main point is that the existing code counts some partial share of when it is _not_ raced.

So, in the critical path, my patch adds one test_bit(), which hits the local CPU cache, if not raced. If raced, some other thread is in control, so I would not think the added cycles would make any big difference.

I can send a v2 where the race tightening is removed if you like.


Thxs, Håkon
