From: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
Subject: Re: Regression in throughput between kvm guests over virtual bridge
Date: Mon, 25 Sep 2017 16:18:13 -0400
Message-ID: <78678f33-c9ba-bf85-7778-b2d0676b78dd@linux.vnet.ibm.com>
References: <4c7e2924-b10f-0e97-c388-c8809ecfdeeb@linux.vnet.ibm.com>
 <bdd417dc-9e2f-4a2e-534b-c6aa38f002f2@redhat.com>
 <e022cfa7-ef65-550f-06e8-f6e29f1d68a0@redhat.com>
 <627d0c7a-dce5-3094-d5d4-c1507fcb8080@linux.vnet.ibm.com>
 <50891c14-3fc6-f519-8c03-07bdef3090f4@redhat.com>
 <e42083d9-ae7b-7207-e5e6-06483bf6293e@linux.vnet.ibm.com>
 <15abafa1-6d58-cd85-668a-bf361a296f52@redhat.com>
 <7345a69d-5e47-7058-c72b-bdd0f3c69210@linux.vnet.ibm.com>
 <55f9173b-a419-98f0-2516-cbd57299ba5d@redhat.com>
 <c9d43af9-f095-043a-7d46-acd84a18f75a@redhat.com>
 <7d444584-3854-ace2-008d-0fdef1c9cef4@linux.vnet.ibm.com>
 <1173ab1f-e2b6-26b3-8c3c-bd5ceaa1bd8e@redhat.com>
 <129a01d9-de9b-f3f1-935c-128e73153df6@linux.vnet.ibm.com>
 <3f824b0e-65f9-c69c-5421-2c5f6b349b09@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, mst@redhat.com
To: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:44024 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S934287AbdIYUST (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 16:18:19 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8PKFhp2136551
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 16:18:18 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2d76dp704s-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 16:18:18 -0400
Received: from localhost
        by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <mjrosato@linux.vnet.ibm.com>;
        Mon, 25 Sep 2017 16:18:17 -0400
In-Reply-To: <3f824b0e-65f9-c69c-5421-2c5f6b349b09@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/2017 12:03 AM, Jason Wang wrote:
> 
> 
> On 2017年09月21日 03:38, Matthew Rosato wrote:
>>> Seems to make some progress on wakeup mitigation. Previous patch tries
>>> to reduce the unnecessary traversal of waitqueue during rx. Attached
>>> patch goes even further which disables rx polling during processing tx.
>>> Please try it to see if it has any difference.
>> Unfortunately, this patch doesn't seem to have made a difference.  I
>> tried runs with both this patch and the previous patch applied, as well
>> as only this patch applied for comparison (numbers from vhost thread of
>> sending VM):
>>
>> 4.12    4.13     patch1   patch2   patch1+2
>> 2.00%   +3.69%   +2.55%   +2.81%   +2.69%   [...] __wake_up_sync_key
>>
>> In each case, the regression in throughput was still present.
> 
> This probably means some other cases of the wakeups were missed. Could
> you please record the callers of __wake_up_sync_key()?
> 

Hi Jason,

With your 2 previous patches applied, every call to __wake_up_sync_key
(for both sender and server vhost threads) shows the following stack trace:

     vhost-11478-11520 [002] ....   312.927229: __wake_up_sync_key
<-sock_def_readable
     vhost-11478-11520 [002] ....   312.927230: <stack trace>
 => dev_hard_start_xmit
 => sch_direct_xmit
 => __dev_queue_xmit
 => br_dev_queue_push_xmit
 => br_forward_finish
 => __br_forward
 => br_handle_frame_finish
 => br_handle_frame
 => __netif_receive_skb_core
 => netif_receive_skb_internal
 => tun_get_user
 => tun_sendmsg
 => handle_tx
 => vhost_worker
 => kthread
 => kernel_thread_starter
 => kernel_thread_starter

>>
>>> And two questions:
>>> - Is the issue existed if you do uperf between 2VMs (instead of 4VMs)
>> Verified that the second set of guests are not actually required, I can
>> see the regression with only 2 VMs.
>>
>>> - Can enable batching in the tap of sending VM improve the performance
>>> (ethtool -C $tap rx-frames 64)
>> I tried this, but it did not help (actually seemed to make things a
>> little worse)
>>
> 
>  I still can't see a reason that can lead more wakeups, will take more
> time to look at this issue and keep you posted.
> 
> Thanks
> 
