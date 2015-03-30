From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH net-next v9 6/7] ixgbevf: Add RSS Key query code
Date: Mon, 30 Mar 2015 08:07:48 -0700
Message-ID: <551966C4.2090301@redhat.com>
References: <1427645497-8339-1-git-send-email-vladz@cloudius-systems.com> <1427645497-8339-7-git-send-email-vladz@cloudius-systems.com> <551876DA.1000607@gmail.com> <551943CE.4050108@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, avi@cloudius-systems.com,
	gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33432 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752478AbbC3PHu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 11:07:50 -0400
In-Reply-To: <551943CE.4050108@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 03/30/2015 05:38 AM, Vlad Zolotarov wrote:
>
>
> On 03/30/15 01:04, Alexander Duyck wrote:
>> On 03/29/2015 09:11 AM, Vlad Zolotarov wrote:
>>> Add the ixgbevf_get_rss_key() function that queries the PF for an 
>>> RSS Random Key
>>> using a new VF-PF channel IXGBE_VF_GET_RSS_KEY command.
>>>
>>> This patch adds the support for 82599 and x540 devices only. Support 
>>> for other
>>> devices will be added later.
>>>
>>> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
>>> ---
>>> New in v9:
>>>     - Reduce the support to 82599 and x540 devices only.
>>>     - Added IXGBEVF_RSS_HASH_KEY_SIZE macro.
>>>
>>> New in v8:
>>>     - Protect a mailbox access.
>>>
>>> New in v6:
>>>     - Return a proper return code when an operation is blocked by PF.
>>>
>>> New in v2:
>>>     - Added a more detailed patch description.
>>>
>>> New in v1 (compared to RFC):
>>>     - Use "if-else" statement instead of a "switch-case" for a 
>>> single option case
>>>       (in ixgbevf_get_rss_key()).
>>> ---
>>>   drivers/net/ethernet/intel/ixgbevf/ixgbevf.h |  1 +
>>>   drivers/net/ethernet/intel/ixgbevf/mbx.h     |  1 +
>>>   drivers/net/ethernet/intel/ixgbevf/vf.c      | 66 
>>> ++++++++++++++++++++++++++++
>>>   drivers/net/ethernet/intel/ixgbevf/vf.h      |  1 +
>>>   4 files changed, 69 insertions(+)
>>>
>>> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h 
>>> b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
>>> index bc939a1..6771ae3 100644
>>> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
>>> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
>>> @@ -145,6 +145,7 @@ struct ixgbevf_ring {
>>>   #define MAX_RX_QUEUES IXGBE_VF_MAX_RX_QUEUES
>>>   #define MAX_TX_QUEUES IXGBE_VF_MAX_TX_QUEUES
>>>   #define IXGBEVF_MAX_RSS_QUEUES    2
>>> +#define IXGBEVF_RSS_HASH_KEY_SIZE    40
>>>     #define IXGBEVF_DEFAULT_TXD    1024
>>>   #define IXGBEVF_DEFAULT_RXD    512
>>> diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.h 
>>> b/drivers/net/ethernet/intel/ixgbevf/mbx.h
>>> index 66e138b..82f44e0 100644
>>> --- a/drivers/net/ethernet/intel/ixgbevf/mbx.h
>>> +++ b/drivers/net/ethernet/intel/ixgbevf/mbx.h
>>> @@ -110,6 +110,7 @@ enum ixgbe_pfvf_api_rev {
>>>     /* mailbox API, version 1.2 VF requests */
>>>   #define IXGBE_VF_GET_RETA    0x0a    /* VF request for RETA */
>>> +#define IXGBE_VF_GET_RSS_KEY    0x0b    /* get RSS hash key */
>>>     /* length of permanent address message returned from PF */
>>>   #define IXGBE_VF_PERMADDR_MSG_LEN    4
>>> diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c 
>>> b/drivers/net/ethernet/intel/ixgbevf/vf.c
>>> index 2676c0b..ec68145 100644
>>> --- a/drivers/net/ethernet/intel/ixgbevf/vf.c
>>> +++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
>>> @@ -301,6 +301,72 @@ static inline int 
>>> ixgbevf_get_reta_locked(struct ixgbe_hw *hw, u32 *msgbuf,
>>>       return 0;
>>>   }
>>>   +static inline int ixgbevf_get_rss_key_locked(struct ixgbe_hw *hw, 
>>> u8 *rss_key)
>>> +{
>>> +    int err;
>>> +    u32 msgbuf[IXGBE_VFMAILBOX_SIZE];
>>> +
>>> +    /* We currently support the RSS Random Key retrieval for 82599 
>>> and x540
>>> +     * devices only.
>>> +     *
>>> +     * Thus return an error if API doesn't support RSS Random Key 
>>> retrieval
>>> +     * or if the operation is not supported for this device type.
>>> +     */
>>> +    if (hw->api_version != ixgbe_mbox_api_12 ||
>>> +        hw->mac.type >= ixgbe_mac_X550_vf)
>>> +        return -EPERM;
>>> +
>> The return type here should be not supported, or IXGBE_NOT_IMPLEMENTED,
>> not no permissions.
>
> I think a standard EOPNOTSUPP would be a much better choice.
> Why do u have this ixgbe-specific return values in addition to 
> standard POSIX ones anyway?

It has to do with being OS agnostic.  If you want to port this to BSD, 
Linux, DPDK, etc, then you can't always rely on all the error return 
values being there so there is a tendency to implement your own.  As 
with the other function you might be best off just returning 
IXGBE_ERR_MBX since the x550 and API_12 don't support the RSS messages.

- Alex
