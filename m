From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [tipc-discussion] [PATCH] tipc: fix a lockdep warning
Date: Thu, 5 Dec 2013 16:56:54 +0800
Message-ID: <52A03FD6.3060303@windriver.com>
References: <528F136E.1030506@huawei.com> <528F1F2B.3080205@windriver.com> <EB28B29A-A58C-4A5C-A4F9-DD30E82B7449@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: wangweidong <wangweidong1@huawei.com>,
	"<jon.maloy@ericsson.com>" <jon.maloy@ericsson.com>,
	"<allan.stephens@windriver.com>" <allan.stephens@windriver.com>,
	"<davem@davemloft.net>" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>,
	"dingtianhong@huawei.com" <dingtianhong@huawei.com>
To: Jason HU <huzhijiang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:42422 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053Ab3LEI5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 03:57:17 -0500
In-Reply-To: <EB28B29A-A58C-4A5C-A4F9-DD30E82B7449@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>>> diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
>>> index e0d0805..ab8f96c 100644
>>> --- a/net/tipc/name_distr.c
>>> +++ b/net/tipc/name_distr.c
>>> @@ -138,7 +138,9 @@ static void named_cluster_distribute(struct sk_buff *buf)
>>>            if (!buf_copy)
>>>                break;
>>>            msg_set_destnode(buf_msg(buf_copy), n_ptr->addr);
>>> +            write_unlock_bh(&tipc_nametbl_lock);
>>>            tipc_link_send(buf_copy, n_ptr->addr, n_ptr->addr);
>>> +            write_lock_bh(&tipc_nametbl_lock);
>>
>> We cannot temporarily release/hold tipc_nametbl_lock here, please see
>> below call path:
>>
>> tipc_nametbl_withdraw()
>>  tipc_named_withdraw()
>>    named_cluster_distribute()
>>      tipc_link_send()
>>
>> Especially in tipc_nametbl_withdraw(), we must hold tipc_nametbl_lock to
>> protect name table before tipc_named_withdraw() is called. If we
>> temporarily release tipc_nametbl_lock in named_cluster_distribute(), I
>> am afraid that name table might be changed by another thread at the
>> moment, having name table inconsistent possibly.
> 
> If the inconsistent possibility that you worried about is the matter of mutually exclusive between user threads which call bind(), then I think it will not occur, because we still got port lock hold when calling tipc_nametbl_publish(). So even we do not have to use tipc_nametbl_lock to warp up both tipc_nametbl_insert_publ() and tipc_name_publish() . Just tipc_nametbl_insert_publ() is enough. May be I missed something, please correct me.
> 

Actually now the key point for us is not to discuss whether the patch is
right or not, but consider whether the patch is necessary or not. As I
emphasized below, tipc_net_lock will be quickly removed completely. Even
if the patch is correct now, we have to revert it after the removal of
tipc_net_lock because:

1. the patch reported warning will automatically disappear if
tipc_net_lcok is removed.

2. I believe no anyone likes what the patch is doing.

Regards,
Ying

> 
> 
>>
>> Actually we are implementing another patchset purging the tipc_net_lock
>> from TIPC stack. If the patchset is involved, I guess the issue would
>> disappear.
>>
>> If you have an interesting to see how to purge to tipc_net_lock, please
>> monitor tipc-discussion mail list.
>>
>> Regards,
>> Ying
>>
