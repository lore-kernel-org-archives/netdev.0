From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH net-next v9 6/7] ixgbevf: Add RSS Key query code
Date: Mon, 30 Mar 2015 09:54:39 -0700
Message-ID: <55197FCF.5060402@redhat.com>
References: <1427645497-8339-1-git-send-email-vladz@cloudius-systems.com> <1427645497-8339-7-git-send-email-vladz@cloudius-systems.com> <551876DA.1000607@gmail.com> <5519554A.1010101@cloudius-systems.com> <55196757.9010008@redhat.com> <55196914.7020307@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, avi@cloudius-systems.com,
	gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44097 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752633AbbC3Qyp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 12:54:45 -0400
In-Reply-To: <55196914.7020307@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 03/30/2015 08:17 AM, Vlad Zolotarov wrote:
>
>
> On 03/30/15 18:10, Alexander Duyck wrote:
>>
>> On 03/30/2015 06:53 AM, Vlad Zolotarov wrote:
>>>
>>>
>>> On 03/30/15 01:04, Alexander Duyck wrote:
>>>> On 03/29/2015 09:11 AM, Vlad Zolotarov wrote:
>>>>> Add the ixgbevf_get_rss_key() function that queries the PF for an 
>>>>> RSS Random Key
>>>>> using a new VF-PF channel IXGBE_VF_GET_RSS_KEY command.
>>>>>
>>>>> This patch adds the support for 82599 and x540 devices only. 
>>>>> Support for other
>>>>> devices will be added later.
>>>>>
>>>>> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
>>>>> ---
>>>>> New in v9:
>>>>>     - Reduce the support to 82599 and x540 devices only.
>>>>>     - Added IXGBEVF_RSS_HASH_KEY_SIZE macro.
>>>>>
>>>>> New in v8:
>>>>>     - Protect a mailbox access.
>>>>>
>>>>> New in v6:
>>>>>     - Return a proper return code when an operation is blocked by PF.
>>>>>
>>>>> New in v2:
>>>>>     - Added a more detailed patch description.
>>>>>
>>>>> New in v1 (compared to RFC):
>>>>>     - Use "if-else" statement instead of a "switch-case" for a 
>>>>> single option case
>>>>>       (in ixgbevf_get_rss_key()).
>>>>> ---
>>>>>   drivers/net/ethernet/intel/ixgbevf/ixgbevf.h |  1 +
>>>>>   drivers/net/ethernet/intel/ixgbevf/mbx.h     |  1 +
>>>>>   drivers/net/ethernet/intel/ixgbevf/vf.c      | 66 
>>>>> ++++++++++++++++++++++++++++
>>>>>   drivers/net/ethernet/intel/ixgbevf/vf.h      |  1 +
>>>>>   4 files changed, 69 insertions(+)
>>>>>
>>>>> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h 
>>>>> b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
>>>>> index bc939a1..6771ae3 100644
>>>>> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
>>>>> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
>>>>> @@ -145,6 +145,7 @@ struct ixgbevf_ring {
>>>>>   #define MAX_RX_QUEUES IXGBE_VF_MAX_RX_QUEUES
>>>>>   #define MAX_TX_QUEUES IXGBE_VF_MAX_TX_QUEUES
>>>>>   #define IXGBEVF_MAX_RSS_QUEUES    2
>>>>> +#define IXGBEVF_RSS_HASH_KEY_SIZE    40
>>>>>     #define IXGBEVF_DEFAULT_TXD    1024
>>>>>   #define IXGBEVF_DEFAULT_RXD    512
>>>>> diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.h 
>>>>> b/drivers/net/ethernet/intel/ixgbevf/mbx.h
>>>>> index 66e138b..82f44e0 100644
>>>>> --- a/drivers/net/ethernet/intel/ixgbevf/mbx.h
>>>>> +++ b/drivers/net/ethernet/intel/ixgbevf/mbx.h
>>>>> @@ -110,6 +110,7 @@ enum ixgbe_pfvf_api_rev {
>>>>>     /* mailbox API, version 1.2 VF requests */
>>>>>   #define IXGBE_VF_GET_RETA    0x0a    /* VF request for RETA */
>>>>> +#define IXGBE_VF_GET_RSS_KEY    0x0b    /* get RSS hash key */
>>>>>     /* length of permanent address message returned from PF */
>>>>>   #define IXGBE_VF_PERMADDR_MSG_LEN    4
>>>>> diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c 
>>>>> b/drivers/net/ethernet/intel/ixgbevf/vf.c
>>>>> index 2676c0b..ec68145 100644
>>>>> --- a/drivers/net/ethernet/intel/ixgbevf/vf.c
>>>>> +++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
>>>>> @@ -301,6 +301,72 @@ static inline int 
>>>>> ixgbevf_get_reta_locked(struct ixgbe_hw *hw, u32 *msgbuf,
>>>>>       return 0;
>>>>>   }
>>>>>   +static inline int ixgbevf_get_rss_key_locked(struct ixgbe_hw 
>>>>> *hw, u8 *rss_key)
>>>>> +{
>>>>> +    int err;
>>>>> +    u32 msgbuf[IXGBE_VFMAILBOX_SIZE];
>>>>> +
>>>>> +    /* We currently support the RSS Random Key retrieval for 
>>>>> 82599 and x540
>>>>> +     * devices only.
>>>>> +     *
>>>>> +     * Thus return an error if API doesn't support RSS Random Key 
>>>>> retrieval
>>>>> +     * or if the operation is not supported for this device type.
>>>>> +     */
>>>>> +    if (hw->api_version != ixgbe_mbox_api_12 ||
>>>>> +        hw->mac.type >= ixgbe_mac_X550_vf)
>>>>> +        return -EPERM;
>>>>> +
>>>> The return type here should be not supported, or 
>>>> IXGBE_NOT_IMPLEMENTED,
>>>> not no permissions.
>>>>
>>>>> +    msgbuf[0] = IXGBE_VF_GET_RSS_KEY;
>>>>> +    err = hw->mbx.ops.write_posted(hw, msgbuf, 1);
>>>>> +
>>>>> +    if (err)
>>>>> +        return err;
>>>>> +
>>>>> +    err = hw->mbx.ops.read_posted(hw, msgbuf, 11);
>>>>> +
>>>>> +    if (err)
>>>>> +        return err;
>>>>> +
>>>>> +    msgbuf[0] &= ~IXGBE_VT_MSGTYPE_CTS;
>>>>> +
>>>>> +    /* If the operation has been refused by a PF return -EPERM */
>>>>> +    if (msgbuf[0] == (IXGBE_VF_GET_RETA | IXGBE_VT_MSGTYPE_NACK))
>>>>> +        return -EPERM;
>>>>> +
>>>>> +    /* If we didn't get an ACK there must have been
>>>>> +     * some sort of mailbox error so we should treat it
>>>>> +     * as such.
>>>>> +     */
>>>>> +    if (msgbuf[0] != (IXGBE_VF_GET_RSS_KEY | IXGBE_VT_MSGTYPE_ACK))
>>>>> +        return IXGBE_ERR_MBX;
>>>>> +
>>>>> +    memcpy(rss_key, msgbuf + 1, IXGBEVF_RSS_HASH_KEY_SIZE);
>>>>> +
>>>>> +    return 0;
>>>>> +}
>>>>> +
>>>>> +/**
>>>>> + * ixgbevf_get_rss_key - get the RSS Random Key
>>>>> + * @hw: pointer to the HW structure
>>>>> + * @reta: buffer to fill with RETA contents.
>>>>> + *
>>>>> + * The "rss_key" buffer should be big enough to contain 10 
>>>>> registers.
>>>>> + * Ensures the atomicy of a mailbox access using the 
>>>>> adapter.mbx_lock spinlock.
>>>>> + *
>>>>> + * Returns: 0 on success.
>>>>> + *          if API doesn't support this operation - (-EPERM).
>>>>> + */
>>>>> +int ixgbevf_get_rss_key(struct ixgbevf_adapter *a, u8 *rss_key)
>>>>> +{
>>>>> +    int rc;
>>>>> +
>>>>> +    spin_lock_bh(&a->mbx_lock);
>>>>> +    rc = ixgbevf_get_rss_key_locked(&a->hw, rss_key);
>>>>> +    spin_unlock_bh(&a->mbx_lock);
>>>>> +
>>>>> +    return rc;
>>>>> +}
>>>>> +
>>>> Since there is currently no cases where you would be getting the 
>>>> rss_key
>>>> without the RETA you might just want to combine this function with
>>>> ixgbevf_get_reta so you only take the lock once and process both
>>>> messages in one pass instead of having to bounce the spinlock.
>>>
>>> I'd rather not do this.
>>> Let's start from the beginning: the locks here should be removed and
>>> added at the caller level to match what u wrote about patch04.
>>> Then about the uniting the two functions mentioned above - there isn't
>>> any added value of doing this. Taking a lock only once may be done
>>> without uniting (see PATCH07 in v10 series).
>>> On the other hand, this uniting is going to make the code awkward and
>>> unclear ("why are these together anyway?").
>>> So, I'd rather keep these functions as they are apart from fixing 
>>> the locking issue. I'll essentially export the _locked functions.
>>>
>>> thanks,
>>> vlad
>>
>> Agreed, just export the _locked functions and drop the _locked 
>> extension.
>
> Hmmm... I think keeping the _locked extension would make sense since 
> it would explicitly hint that these functions have to be called under 
> the lock. There are other similar examples in the ixgbe/ixgbevf code 
> already.

The thing is the mailbox lock is only really needed to avoid contention 
with the few rare cases where the mailbox is accessed outside of the 
RTNL lock, also there is going to end up needing to be a different 
version of the function for x550 since it has direct register access to 
the redirection table via registers (mailbox lock is not needed since it 
is direct register access), so it might be worth it to take that into 
account in the naming.

One option you might consider would be to look at adding get_reta and 
get_rssrk function pointers to the ixgbe_mac_operations structure and 
then splitting up ixgbevf_mac_ops so that you have the original, and an 
x550 version that doesn't populate those two function pointers.  That 
might make it easier to then implement the x550 version later.  You 
could probably even do something similar for the PF functionality as 
that way you could easily identify the functions that support getting 
the RETA and RSSRK by simply checking to see if those function pointers 
are present.

As far as the other patches I am okay with the return being -ENOTSUPP 
for the x550 for now.

- Alex
