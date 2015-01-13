From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH v2 2/2] net: ixgbe: implement af_packet direct queue
 mappings
Date: Tue, 13 Jan 2015 07:46:53 -0800
Message-ID: <54B53DED.4040502@gmail.com>
References: <20150113043509.29985.33515.stgit@nitbit.x32> <20150113043542.29985.15658.stgit@nitbit.x32> <54B52B25.1070809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, danny.zhou@intel.com,
	nhorman@tuxdriver.com, john.ronciak@intel.com,
	hannes@stressinduktion.org, brouer@redhat.com
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:39583 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752992AbbAMPrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 10:47:11 -0500
Received: by mail-ob0-f178.google.com with SMTP id gq1so3111942obb.9
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 07:47:10 -0800 (PST)
In-Reply-To: <54B52B25.1070809@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2015 06:26 AM, Daniel Borkmann wrote:
> On 01/13/2015 05:35 AM, John Fastabend wrote:
> ...
>> +static int ixgbe_ndo_split_queue_pairs(struct net_device *dev,
>> +                       unsigned int start_from,
>> +                       unsigned int qpairs_num,
>> +                       struct sock *sk)
>> +{
>> +    struct ixgbe_adapter *adapter = netdev_priv(dev);
>> +    unsigned int qpair_index;
>
> We should probably return -EINVAL, still from within the setsockopt
> call when qpairs_num is 0?

yep,

>
>> +    /* allocate whatever available qpairs */
>> +    if (start_from == -1) {
>
> I guess we should define the notion of auto-select into a uapi
> define instead of -1, which might not be overly obvious.

Certainly not obvious should be defined in the UAPI.

>
> Anyway, extending Documentation/networking/packet_mmap.txt with
> API details/examples at least for a non-RFC version is encouraged. ;)

Yep for the non-RFC version I'll add an example to packet_mmap.txt

>
>> +        unsigned int count = 0;
>> +
>> +        for (qpair_index = adapter->num_rx_queues;
>> +             qpair_index < MAX_RX_QUEUES;
>> +             qpair_index++) {
>> +            if (!adapter->user_queue_info[qpair_index].sk_handle) {
>> +                count++;
>> +                if (count == qpairs_num) {
>> +                    start_from = qpair_index - count + 1;
>> +                    break;
>> +                }
>> +            } else {
>> +                count = 0;
>> +            }
>> +        }
>> +    }
>> +
>> +    /* otherwise the caller specified exact queues */
>> +    if ((start_from > MAX_TX_QUEUES) ||
>> +        (start_from > MAX_RX_QUEUES) ||
>> +        (start_from + qpairs_num > MAX_TX_QUEUES) ||
>> +        (start_from + qpairs_num > MAX_RX_QUEUES))
>> +        return -EINVAL;
>
> Shouldn't this be '>=' if I see this correctly?

hmm I think this is correct the device allocates MAX_TX_QUEUES so the
queue space index is (0, MAX_TX_QUEUES - 1). So MAX_TX_QUEUES and
MAX_RX_QUEUES would be an invalid access below,

>
>> +    /* If the qpairs are being used by the driver do not let user space
>> +     * consume the queues. Also if the queue has already been allocated
>> +     * to a socket do fail the request.
>> +     */
>> +    for (qpair_index = start_from;
>> +         qpair_index < start_from + qpairs_num;
>> +         qpair_index++) {
>> +        if ((qpair_index < adapter->num_tx_queues) ||
>> +            (qpair_index < adapter->num_rx_queues))
>> +            return -EINVAL;
>> +
>> +        if (adapter->user_queue_info[qpair_index].sk_handle)
>> +            return -EBUSY;
>> +    }
>> +
>> +    /* remember the sk handle for each queue pair */
>> +    for (qpair_index = start_from;
>> +         qpair_index < start_from + qpairs_num;
>> +         qpair_index++) {
>> +        adapter->user_queue_info[qpair_index].sk_handle = sk;
>> +        adapter->user_queue_info[qpair_index].num_of_regions = 0;
                                     ^^^^^^^^^^^^^^
                                     (0, MAX_TX_QUEUES - 1)

@@ -673,6 +687,9 @@ Hunk #2, a/drivers/net/ethernet/intel/ixgbe/ixgbe.h 
struct ixgbe_adapter {

         struct ixgbe_q_vector *q_vector[MAX_Q_VECTORS];

+       /* Direct User Space Queues */
+       struct ixgbe_user_queue_info user_queue_info[MAX_RX_QUEUES];
+



>> +    }
>> +
>> +    return 0;
>> +}
>
> I guess many drivers would need to implement similar code, do you see
> a chance to move generic parts to the core, at least for some helper
> functions?

I'm not entirely sure about this. It depends on how the driver manages
its queue space. Many of the 10Gpbs devices it seems could use similar
logic so it might make sense. Other drivers might conjure the queues
out of some other bank of queues. If I'm looking @ the devices I have
here, i40e at least would manage the queues slightly different then this
I think.

>
> Thanks,
> Daniel


-- 
John Fastabend         Intel Corporation
