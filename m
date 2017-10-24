From: Alex Vesker <valex@mellanox.com>
Subject: Re: [for-next 08/12] net/mlx5e: IPoIB, Use hash-table to map between
 QPN to child netdev
Date: Tue, 24 Oct 2017 09:28:56 +0300
Message-ID: <98e54fb7-febd-7d7a-0e6c-308b4203d221@mellanox.com>
References: <20171014184827.18491-1-saeedm@mellanox.com>
 <20171014184827.18491-9-saeedm@mellanox.com>
 <20171023154736.GF11952@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>, <netdev@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>, Leon Romanovsky <leonro@mellanox.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr40084.outbound.protection.outlook.com ([40.107.4.84]:25952
        "EHLO EUR03-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751319AbdJXG3C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Oct 2017 02:29:02 -0400
In-Reply-To: <20171023154736.GF11952@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/23/2017 6:47 PM, Jason Gunthorpe wrote:
> On Sat, Oct 14, 2017 at 11:48:23AM -0700, Saeed Mahameed wrote:
>> From: Alex Vesker <valex@mellanox.com>
>>
>> This change is needed for PKEY support, since the RQs are shared
>> between the child interface and the parent. The parent is responsible
>> for NAPI and the precessing of RX completions. Using the dqpn in the
>> completion descriptor we set the corresponding child IPoIB netdevice
>> on the SKB.
>> The mapping between the dqpn and the netdevice is done using a HT,
>> each mlx5 IPoIB interface registers its mapping on creation.
> It seems really really weird to share the receive Q across all of the
> children and do the sorting in software.. why is this done like this?
>
> Wouldn't it be better to allow the children to progress concurrently,
> potentially on multiple cores? They all have their own QPs after all..
>
> Jason
The child interface RQs are in minimum size since they are not used.
The reason for this is saving resources, since we want to be able to 
support many PKEYs
and allocating less memory while reusing HW resources such as flow 
steering table.
This solution allowed us save memory on allocating the RQs of the child 
and use the same
HW flow steering table, TIR, RQT. Using the hash table doesn't impact on 
performance.
The parent have multiple RQs on different cores running in parallel.
