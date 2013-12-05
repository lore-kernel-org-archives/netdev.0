From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net] bonding: add ACCESS_ONCE() and change local var names
Date: Thu, 05 Dec 2013 15:27:10 +0100
Message-ID: <52A08D3E.4070900@redhat.com>
References: <1386252644-3536-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63814 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756546Ab3LEObf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Dec 2013 09:31:35 -0500
In-Reply-To: <1386252644-3536-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/2013 03:10 PM, Nikolay Aleksandrov wrote:
> We use bond->params.packets_per_slave without any locking in 2 places:
> bond_rr_gen_id() and bonding_show_packets_per_slave(), so as a
> precaution and to show what's intended, add ACCESS_ONCE() when fetching
> it in the local variable.
> Also rename the local variables to pps_tmp so they're not with the name
> of the module parameter to avoid confusion.
> 
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Veaceslav Falico <vfalico@redhat.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---
> Please note that this patch is on top of the one I posted earlier today
> ("bonding: fix packets_per_slave showing").
> Also I'm not adding ACCESS_ONCE() to bond_check_params() now as we don't
> export almost anything through /sys/module/bonding/parameters and moreover
> it's a new feature and thus net-next material if such an export is to be
> made.
> 
>  drivers/net/bonding/bond_main.c  | 7 +++----
>  drivers/net/bonding/bond_sysfs.c | 8 ++++----
>  2 files changed, 7 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 36eab0c..3ec3036 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3590,10 +3590,10 @@ void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int slave_id)
>   */
>  static u32 bond_rr_gen_slave_id(struct bonding *bond)
>  {
> -	int packets_per_slave = bond->params.packets_per_slave;
> +	int pps_tmp = ACCESS_ONCE(bond->params.packets_per_slave);
>  	u32 slave_id;
>  
> -	switch (packets_per_slave) {
> +	switch (pps_tmp) {
>  	case 0:
>  		slave_id = prandom_u32();
>  		break;
> @@ -3601,8 +3601,7 @@ static u32 bond_rr_gen_slave_id(struct bonding *bond)
>  		slave_id = bond->rr_tx_counter;
>  		break;
>  	default:
> -		slave_id = reciprocal_divide(bond->rr_tx_counter,
> -					     packets_per_slave);
> +		slave_id = reciprocal_divide(bond->rr_tx_counter, pps_tmp);
>  		break;
>  	}
>  	bond->rr_tx_counter++;
> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
> index 0ae580b..1a0ae85 100644
> --- a/drivers/net/bonding/bond_sysfs.c
> +++ b/drivers/net/bonding/bond_sysfs.c
> @@ -1635,12 +1635,12 @@ static ssize_t bonding_show_packets_per_slave(struct device *d,
>  					      char *buf)
>  {
>  	struct bonding *bond = to_bond(d);
> -	unsigned int packets_per_slave = bond->params.packets_per_slave;
> +	unsigned int pps_tmp = ACCESS_ONCE(bond->params.packets_per_slave);
>  
> -	if (packets_per_slave > 1)
> -		packets_per_slave = reciprocal_value(packets_per_slave);
> +	if (pps_tmp > 1)
> +		pps_tmp = reciprocal_value(pps_tmp);
>  
> -	return sprintf(buf, "%u\n", packets_per_slave);
> +	return sprintf(buf, "%u\n", pps_tmp);
>  }
>  
>  static ssize_t bonding_store_packets_per_slave(struct device *d,
> 
Self-nak
please disregard this patch and sorry for the noise. I'm so blind...

Nik
