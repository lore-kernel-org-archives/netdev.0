From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCH net-next v2 2/2] Re-check for a VIO_DESC_READY data descriptor
 after short udelay()
Date: Tue, 02 Sep 2014 12:27:19 -0400
Message-ID: <5405EFE7.4090302@oracle.com>
References: <20140902162029.GC31516@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30234 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754727AbaIBQ1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 12:27:23 -0400
Received: from acsinet21.oracle.com (acsinet21.oracle.com [141.146.126.237])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id s82GRMXU010488
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 2 Sep 2014 16:27:23 GMT
Received: from userz7021.oracle.com (userz7021.oracle.com [156.151.31.85])
	by acsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id s82GRLMS017727
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 2 Sep 2014 16:27:21 GMT
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
	by userz7021.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id s82GRK2N013734
	for <netdev@vger.kernel.org>; Tue, 2 Sep 2014 16:27:20 GMT
In-Reply-To: <20140902162029.GC31516@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sowmini,
	One of the things I found while looking at the code is that the
write memory barrier is in the wrong place. I have a patch to fix it, but
it means the last descriptor will NOT be marked as ready until the cache
is flushed, which may be delayed.
	That fix may make this one moot. Maybe not, but certainly there is
an unnecessary delay in notifying the peer because of that bug. The fix is
simply to move the "wmb()" after, instead of before, setting VIO_DESC_READY.
I mentioned it in our stand-up last week, which you couldn't attend, because
I pointed it out for the VDC driver, which also has the same problem.

	You may want to retry with that change to see if the delay still
helps.
							+-DLS

On 09/02/2014 12:20 PM, Sowmini Varadhan wrote:
> 
> Upon encountering the first !VIO_DESC_READY in vnet_walk_rx(),
> it is frequently worthwhile to re-check the descriptor status
> after a short microsecond delay, as a bursty sender could
> be actively populating the descriptors, and the short udelay()
> is far less expensive than rolling back to ldc_rx() and having
> to wake up and read data on another LDC message.
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Acked-by: Raghuram Kothakota <raghuram.kothakota@oracle.com>
> ---
> changes since v1: moved label `again', variable `retries' to this patchset.
> 
>  drivers/net/ethernet/sun/sunvnet.c | 23 ++++++++++++++++++++---
>  1 file changed, 20 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
> index 8f90b57..7b1f320 100644
> --- a/drivers/net/ethernet/sun/sunvnet.c
> +++ b/drivers/net/ethernet/sun/sunvnet.c
> @@ -390,11 +390,28 @@ static int vnet_walk_rx(struct vnet_port *port, struct vio_dring_state *dr,
>  	viodbg(DATA, "vnet_walk_rx start[%08x] end[%08x]\n", start, end);
>  
>  	while (start != end) {
> -		int ack = 0, err = vnet_walk_rx_one(port, dr, start, &ack);
> +		int retries;
> +		int ack = 0, err;
> +
> +		retries = 0;
> +again:
> +		err = vnet_walk_rx_one(port, dr, start, &ack);
>  		if (err == -ECONNRESET)
>  			return err;
> -		if (err != 0)
> -			break;
> +		if (err != 0)  {
> +			/* The descriptor was not READY. Retry with a
> +			 * small delay, in case we have a bursty sender
> +			 * that is actively populating the descriptors, to
> +			 * reduce the overhead of stopping and re-entering
> +			 * which would involve expensive LDC messages.
> +			 */
> +			if (retries++ < 3) {
> +				udelay(4);
> +				goto again;
> +			} else {
> +				break;
> +			}
> +		}
>  		if (ack_start == -1)
>  			ack_start = start;
>  		ack_end = start;
> 
