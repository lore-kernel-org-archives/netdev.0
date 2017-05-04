From: David Arcari <darcari@redhat.com>
Subject: Re: [PATCH] aquantia: Fix "ethtool -S" crash when adapter down.
Date: Thu, 4 May 2017 16:39:25 -0400
Message-ID: <fc1105a3-5d97-9d2f-f3c4-db8e65b69db2@redhat.com>
References: <9ea5a2ba21b4f8b22a63acf39135a41e2f1da23c.1493928470.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>
To: Pavel Belous <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44190 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751228AbdEDUj0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 16:39:26 -0400
In-Reply-To: <9ea5a2ba21b4f8b22a63acf39135a41e2f1da23c.1493928470.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2017 04:10 PM, Pavel Belous wrote:
> From: Pavel Belous <pavel.belous@aquantia.com>
> 
> This patch fixes the crash that happens when driver tries to collect statistics
> from already released "aq_vec" object.
> If adapter is in "down" state we still allow user to see statistics from HW.
> 
> V2: fixed braces around "aq_vec_free".
> 
> Fixes: 97bde5c4f909 ("net: ethernet: aquantia: Support for NIC-specific code")
> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
> ---
>  drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> index cdb0299..9ee1c50 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> @@ -755,7 +755,7 @@ void aq_nic_get_stats(struct aq_nic_s *self, u64 *data)
>  	count = 0U;
>  
>  	for (i = 0U, aq_vec = self->aq_vec[0];
> -		self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i]) {
> +		aq_vec && self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i]) {
>  		data += count;
>  		aq_vec_get_sw_stats(aq_vec, data, &count);
>  	}
> @@ -959,8 +959,10 @@ void aq_nic_free_hot_resources(struct aq_nic_s *self)
>  		goto err_exit;
>  
>  	for (i = AQ_DIMOF(self->aq_vec); i--;) {
> -		if (self->aq_vec[i])
> +		if (self->aq_vec[i]) {
>  			aq_vec_free(self->aq_vec[i]);
> +			self->aq_vec[i] = NULL;
> +		}
>  	}
>  
>  err_exit:;
> 

Resolves the ethtool crash.

Tested-by: David Arcari <darcari@redhat.com>
