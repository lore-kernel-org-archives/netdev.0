From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 12/14] i40e: allow i40e_update_filter_state to skip
 broadcast filters
Date: Sun, 12 Feb 2017 13:17:34 +0300
Message-ID: <639a9d62-a283-9fcb-4fad-dc7aeda74c7f@cogentembedded.com>
References: <20170212053028.98581-1-jeffrey.t.kirsher@intel.com>
 <20170212053028.98581-13-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:33294 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751111AbdBLKRf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 05:17:35 -0500
Received: by mail-lf0-f43.google.com with SMTP id x1so39847565lff.0
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 02:17:35 -0800 (PST)
In-Reply-To: <20170212053028.98581-13-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 2/12/2017 8:30 AM, Jeff Kirsher wrote:

> From: Jacob Keller <jacob.e.keller@intel.com>
>
> Fix a bug where we modified the mac_filter_hash while outside a lock,
> when handling addition of broadcast filters.
>
> Normally, we add filters to firmware by batching the additions into
> lists and issuing 1 update for every few filters. Broadcast filters are
> handled differently, by instead setting the broadcast promiscuous mode
> flags. In order to make sure the 1<->1 mapping of filters in our
> addition array lined up with filters in the hlist tmp_add_list, we had
> to remove the filter and move it back to the main hash. However, we
> didn't do this under lock, which could cause consistency problems for
> the list.
>
> Fix this by updating i40e_update_filter_state logic so that it knows to
> avoid broadcast filters. This ensures that we don't have to remove the
> filter separately, and can put it back using the normal flow.
>
> Change-ID: Id288fade80b3e3a9a54b68cc249188cb95147518
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_main.c | 37 ++++++++++++++++++++++-------
>  1 file changed, 29 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index fa4a04d..06c80d4 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -1843,6 +1843,31 @@ static void i40e_undo_filter_entries(struct i40e_vsi *vsi,
>  }
>
>  /**
> + * i40e_next_entry - Get the next non-broadcast filter from a list
> + * @f: pointer to filter in list
> + *
> + * Returns the next non-broadcast filter in the list. Required so that we
> + * ignore broadcast filters within the list, since these are not handled via
> + * the normal firmware update path.
> + */
> +static struct i40e_mac_filter *i40e_next_filter(struct i40e_mac_filter *f)
> +{
> +	while (f) {
> +		f = hlist_entry(f->hlist.next,
> +				typeof(struct i40e_mac_filter),
> +				hlist);
> +
> +		/* keep going if we found a broadcast filter */
> +		if (f && is_broadcast_ether_addr(f->macaddr))
> +			continue;
> +
> +		break;

    Isn't it simpler to *break* on an inverted condition above?
This way, *continue* isn;'t needed...

[...]

MBR, Sergei
