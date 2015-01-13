From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [RFC PATCH v2 2/2] net: ixgbe: implement af_packet direct queue
 mappings
Date: Tue, 13 Jan 2015 15:26:45 +0100
Message-ID: <54B52B25.1070809@redhat.com>
References: <20150113043509.29985.33515.stgit@nitbit.x32> <20150113043542.29985.15658.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, danny.zhou@intel.com,
	nhorman@tuxdriver.com, john.ronciak@intel.com,
	hannes@stressinduktion.org, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40954 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752143AbbAMO1B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 09:27:01 -0500
In-Reply-To: <20150113043542.29985.15658.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2015 05:35 AM, John Fastabend wrote:
...
> +static int ixgbe_ndo_split_queue_pairs(struct net_device *dev,
> +				       unsigned int start_from,
> +				       unsigned int qpairs_num,
> +				       struct sock *sk)
> +{
> +	struct ixgbe_adapter *adapter = netdev_priv(dev);
> +	unsigned int qpair_index;

We should probably return -EINVAL, still from within the setsockopt
call when qpairs_num is 0?

> +	/* allocate whatever available qpairs */
> +	if (start_from == -1) {

I guess we should define the notion of auto-select into a uapi
define instead of -1, which might not be overly obvious.

Anyway, extending Documentation/networking/packet_mmap.txt with
API details/examples at least for a non-RFC version is encouraged. ;)

> +		unsigned int count = 0;
> +
> +		for (qpair_index = adapter->num_rx_queues;
> +		     qpair_index < MAX_RX_QUEUES;
> +		     qpair_index++) {
> +			if (!adapter->user_queue_info[qpair_index].sk_handle) {
> +				count++;
> +				if (count == qpairs_num) {
> +					start_from = qpair_index - count + 1;
> +					break;
> +				}
> +			} else {
> +				count = 0;
> +			}
> +		}
> +	}
> +
> +	/* otherwise the caller specified exact queues */
> +	if ((start_from > MAX_TX_QUEUES) ||
> +	    (start_from > MAX_RX_QUEUES) ||
> +	    (start_from + qpairs_num > MAX_TX_QUEUES) ||
> +	    (start_from + qpairs_num > MAX_RX_QUEUES))
> +		return -EINVAL;

Shouldn't this be '>=' if I see this correctly?

> +	/* If the qpairs are being used by the driver do not let user space
> +	 * consume the queues. Also if the queue has already been allocated
> +	 * to a socket do fail the request.
> +	 */
> +	for (qpair_index = start_from;
> +	     qpair_index < start_from + qpairs_num;
> +	     qpair_index++) {
> +		if ((qpair_index < adapter->num_tx_queues) ||
> +		    (qpair_index < adapter->num_rx_queues))
> +			return -EINVAL;
> +
> +		if (adapter->user_queue_info[qpair_index].sk_handle)
> +			return -EBUSY;
> +	}
> +
> +	/* remember the sk handle for each queue pair */
> +	for (qpair_index = start_from;
> +	     qpair_index < start_from + qpairs_num;
> +	     qpair_index++) {
> +		adapter->user_queue_info[qpair_index].sk_handle = sk;
> +		adapter->user_queue_info[qpair_index].num_of_regions = 0;
> +	}
> +
> +	return 0;
> +}

I guess many drivers would need to implement similar code, do you see
a chance to move generic parts to the core, at least for some helper
functions?

Thanks,
Daniel
