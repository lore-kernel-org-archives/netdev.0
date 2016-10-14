From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH net 3/5] net/ncsi: Fix stale link state of inactive
 channels on failover
Date: Fri, 14 Oct 2016 21:37:23 +1100
Message-ID: <20161014103722.GB6278@gwshan>
References: <1476413614-24586-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1476413614-24586-4-git-send-email-gwshan@linux.vnet.ibm.com>
 <CACPK8Xf1A2pvE0WCe2araRxZyMu9wkw=L=2-WuXrkBthehdfgw@mail.gmail.com>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org,
        davem@davemloft.net
To: Joel Stanley <joel@jms.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:47091 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752356AbcJNKhG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 06:37:06 -0400
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9EAXbmE141565
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 06:37:05 -0400
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com [125.16.236.9])
        by mx0b-001b2d01.pphosted.com with ESMTP id 262uvcx3h2-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 06:37:05 -0400
Received: from localhost
        by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Fri, 14 Oct 2016 16:07:01 +0530
Received: from d28relay06.in.ibm.com (d28relay06.in.ibm.com [9.184.220.150])
        by d28dlp03.in.ibm.com (Postfix) with ESMTP id 13C80125804F
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 16:07:32 +0530 (IST)
Received: from d28av07.in.ibm.com (d28av07.in.ibm.com [9.184.220.146])
        by d28relay06.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9EAaxrC23330950
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 16:06:59 +0530
Received: from d28av07.in.ibm.com (localhost [127.0.0.1])
        by d28av07.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9EAaup6018069
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 16:06:58 +0530
Content-Disposition: inline
In-Reply-To: <CACPK8Xf1A2pvE0WCe2araRxZyMu9wkw=L=2-WuXrkBthehdfgw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 14, 2016 at 04:32:28PM +1030, Joel Stanley wrote:
>On Fri, Oct 14, 2016 at 1:23 PM, Gavin Shan <gwshan@linux.vnet.ibm.com> wrote:
>> The issue was found on BCM5718 which has two NCSI channels in one
>> package: C0 and C1. Both of them are connected to different LANs,
>> means they are in link-up state and C0 is chosen  as the active
>> one until resetting BCM5718 happens as below.
>>
>> Resetting BCM5718 results in LSC (Link State Change) AEN packet
>> received on C0, meaning LSC AEN is missed on C1. When LSC AEN packet
>> received on C0 to report link-down, it fails over to C1 because C1
>> is in link-up state as software can see. However, C1 is in link-down
>> state in hardware. It means the link state is out of synchronization
>> between hardware and software, resulting in inappropriate channel (C1)
>> selected as active one.
>>
>> This resolves the issue by sending separate GLS (Get Link Status)
>> commands to all channels in the package before trying to do failover.
>> The last link state on all channels in the package is retrieved. With
>> it, C0 is selected as active one as expected.
>
>I follow this, and can see that happening in the
>ncsi_dev_state_suspend_gls state. However, what is
>
>> -               nd->state = ncsi_dev_state_suspend_dcnt;
>> +               if (ndp->flags & NCSI_DEV_RESHUFFLE)
>> +                       nd->state = ncsi_dev_state_suspend_gls;
>> +               else
>> +                       nd->state = ncsi_dev_state_suspend_dcnt;
>
>However, what is this doing? I'm not quite sure what
>NCSI_DEV_RESHUFFLE is and why we enable it?
>

NCSI_DEV_RESHUFFLE is set when we need failover, which happens on
resetting NIC or unplugging the cable connected to the active channel
(port) or other events. The first step for failover is to suspend
currently active channel and then choose the best one (channel's link
state is important factor) to be active. ncsi_dev_state_suspend_gls
ensures we will get updated link state of available channels before
choosing and enabling next active channel. If there are no failover
happening, we needn't get the update link state on the available
channels and the state ncsi_dev_state_suspend_gls will be skipped.

I think I need put comments here to explain the change in next revision.

Thanks,
Gavin

>>
>>                 ret = ncsi_xmit_cmd(&nca);
>>                 if (ret)
>>                         goto error;
>>
>>                 break;
>> +       case ncsi_dev_state_suspend_gls:
>> +               ndp->pending_req_num = np->channel_num;
>> +
>> +               nca.type = NCSI_PKT_CMD_GLS;
>> +               nca.package = np->id;
>> +               nd->state = ncsi_dev_state_suspend_dcnt;
>> +
>> +               NCSI_FOR_EACH_CHANNEL(np, nc) {
>> +                       nca.channel = nc->id;
>> +                       ret = ncsi_xmit_cmd(&nca);
>> +                       if (ret)
>> +                               goto error;
>> +               }
>> +
>> +               break;
>>         case ncsi_dev_state_suspend_dcnt:
>>         case ncsi_dev_state_suspend_dc:
>>         case ncsi_dev_state_suspend_deselect:
>> --
>> 2.1.0
>>
>
