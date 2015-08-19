From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC v2 3/3] iwlwifi: mvm: transfer the truesize to the last TSO
 segment
Date: Wed, 19 Aug 2015 22:10:13 +0300
Message-ID: <55D4D495.9070705@cogentembedded.com>
References: <1439989181-4444-1-git-send-email-emmanuel.grumbach@intel.com>
 <1439989181-4444-4-git-send-email-emmanuel.grumbach@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ido@wizery.com, netdev@vger.kernel.org
To: Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:35906 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbbHSTKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 15:10:18 -0400
Received: by lagz9 with SMTP id z9so9093088lag.3
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 12:10:16 -0700 (PDT)
In-Reply-To: <1439989181-4444-4-git-send-email-emmanuel.grumbach@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/19/2015 03:59 PM, Emmanuel Grumbach wrote:

> This allows to release the backpressure on the socket only
> when the last segment is released.
> Now the truesize looks like this:
> if the truesize of the original skb is 65420, all the
> segments will have a truesize of 704 (skb itself) and the
> last one will have 65420.
>
> Change-Id: I3c894cf2afc0aedfe7b2a5b992ba41653ff79c0e
> Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
> ---
>   drivers/net/wireless/iwlwifi/mvm/tx.c | 17 ++++++++++++++++-
>   1 file changed, 16 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/iwlwifi/mvm/tx.c b/drivers/net/wireless/iwlwifi/mvm/tx.c
> index 5046833..046e50d 100644
> --- a/drivers/net/wireless/iwlwifi/mvm/tx.c
> +++ b/drivers/net/wireless/iwlwifi/mvm/tx.c
[...]
> @@ -1034,6 +1035,20 @@ static int iwl_mvm_tx_tso(struct iwl_mvm *mvm, struct sk_buff *skb_gso,
>   		}
>
>   		__skb_queue_tail(mpdus_skb, skb);
> +		sum_truesize += skb->truesize;
> +	}
> +
> +	/* Release the backpressure on the socket only when
> +	 * the last segment is released.
> +	 */
> +	if (skb_gso->destructor == sock_wfree) {
> +		struct sk_buff *tail = mpdus_skb->prev;
> +
> +		swap(tail->truesize, skb_gso->truesize);
> +		swap(tail->destructor, skb_gso->destructor);
> +		swap(tail->sk, skb_gso->sk);
> +                atomic_add(sum_truesize - skb_gso->truesize,

    Please indent using tabs, not spaces.

> +                           &skb_gso->sk->sk_wmem_alloc);
>   	}
>
>   	ret = 0;

MBR, Sergei
