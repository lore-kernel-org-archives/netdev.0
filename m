From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next 1/8] net/ncsi: Avoid unused-value build warning
 from ia64-linux-gcc
Date: Thu, 29 Sep 2016 21:40:39 +1000
Message-ID: <20160929114039.GA13381@gwshan>
References: <1475125395-8459-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1475125395-8459-2-git-send-email-gwshan@linux.vnet.ibm.com>
 <20160929.015404.76401694814645494.davem@davemloft.net>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gwshan@linux.vnet.ibm.com, netdev@vger.kernel.org, joel@jms.id.au,
        yuvali@mellanox.com, benh@kernel.crashing.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:52233 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755041AbcI2Lkl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 07:40:41 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8TBbo7x092840
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 07:40:40 -0400
Received: from e28smtp08.in.ibm.com (e28smtp08.in.ibm.com [125.16.236.8])
        by mx0a-001b2d01.pphosted.com with ESMTP id 25rwkh3b2p-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 07:40:40 -0400
Received: from localhost
        by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 29 Sep 2016 17:10:36 +0530
Received: from d28relay06.in.ibm.com (d28relay06.in.ibm.com [9.184.220.150])
        by d28dlp01.in.ibm.com (Postfix) with ESMTP id 3E8E9E0040
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 17:10:03 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
        by d28relay06.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8TBeYqd38928438
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 17:10:34 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
        by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8TBeUSk005715
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 17:10:33 +0530
Content-Disposition: inline
In-Reply-To: <20160929.015404.76401694814645494.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 29, 2016 at 01:54:04AM -0400, David Miller wrote:
>From: Gavin Shan <gwshan@linux.vnet.ibm.com>
>Date: Thu, 29 Sep 2016 15:03:08 +1000
>
>> This replaces the atomic access to NCSI channel's state with READ_ONCE()
>> and WRITE_ONCE() to avoid the above build warning. We needn't hold the
>> channel's lock when updating its state as well. No logical changes
>> introduced.
>
>I don't understand this.
>
>If it's important to take the lock for the list add/del, then it must
>be important to make the state change appear atomic wrt. that lock as
>well.
>
>Can parallel threads of control enter these functions which change the
>state?  If so, then you need to make the state changes under the lock.
>In fact, you probably have to make the state tests under the locks as
>well.
>
>If not, please explain what prevents it from happening.
>

Dave, thanks for your comments. I think it's occasionally working on
AST2400 and AST2500 platforms. It's reasonable to grab the lock before
fetching or updating the NCSI channel's state. Adding and removing the
channel from the list also need taking the lock as well. I will modify
the code accordingly in next revision.

AST2400/AST2500 has single CPU. The channel's state (and the linked
list) are changed in softirq context (packet Rx handler or timer),
meaning they are not accessed in parallel mode. However, NCSI stack
cannot make assumption to be run on single CPU platforms only. So
yes, we need the lock to protect them.

Thanks,
Gavin
