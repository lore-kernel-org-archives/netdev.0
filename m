From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH v4] net/bonding: send arp in interval if no active slave
Date: Wed, 7 Oct 2015 14:03:39 +0200
Message-ID: <56150A1B.10405@cumulusnetworks.com>
References: <56094137.9030206@redhat.com>
 <1444161197-38442-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Uwe Koziolek <uwe.koziolek@redknee.com>,
	Jay Vosburgh <jay.vosburgh@canonical.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Veaceslav Falico <vfalico@gmail.com>, netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444161197-38442-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/06/2015 09:53 PM, Jarod Wilson wrote:
> From: Uwe Koziolek <uwe.koziolek@redknee.com>
> 
> With some very finicky switch hardware, active backup bonding can get into
> a situation where we play ping-pong between interfaces, trying to get one
> to come up as the active slave. There seems to be an issue with the
> switch's arp replies either taking too long, or simply getting lost, so we
> wind up unable to get any interface up and active. Sometimes, the issue
> sorts itself out after a while, sometimes it doesn't.
> 
> Testing with num_grat_arp has proven fruitless, but sending an additional
> arp on curr_arp_slave if we're still in the arp_interval timeslice in
> bond_ab_arp_probe(), has shown to produce 100% reliability in testing with
> this hardware combination.
> 
> [jarod: manufacturing of changelog, addition of modparam gating]
> CC: Jay Vosburgh <jay.vosburgh@canonical.com>
> CC: Andy Gospodarek <gospo@cumulusnetworks.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: netdev@vger.kernel.org
> Signed-off-by: Uwe Koziolek <uwe.koziolek@redknee.com>
> Signed-off-by: Jarod Wilson <jarod@redhat.com>
> ---
> v2: add code comment as to why change is needed
> v3: fix wrapping of comments
> v4: [jarod] add module parameter gating of code addition
> 
Hi all,
As Andy already stated I'm not a fan of such workarounds either but it's
necessary sometimes so if this is going to be actually considered then a
few things need to be fixed. Please make this a proper bonding option
which can be changed at runtime and not only via a module parameter.
Now, I saw that you've only tested with 500 ms, can't this be fixed by using
a different interval ? This seems like a very specific problem to have a
whole new option for.
I really want to say fix the switch but I know that's not an option. :-)
A few minor nits below,

>  drivers/net/bonding/bond_main.c | 24 ++++++++++++++++++++++++
>  include/net/bonding.h           |  1 +
>  2 files changed, 25 insertions(+)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 90f2615..72ab512 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -95,6 +95,7 @@ static int miimon;
>  static int updelay;
>  static int downdelay;
>  static int use_carrier	= 1;
> +static int arp_slow_switch;
>  static char *mode;
>  static char *primary;
>  static char *primary_reselect;
> @@ -133,6 +134,10 @@ MODULE_PARM_DESC(downdelay, "Delay before considering link down, "
>  module_param(use_carrier, int, 0);
>  MODULE_PARM_DESC(use_carrier, "Use netif_carrier_ok (vs MII ioctls) in miimon; "
>  			      "0 for off, 1 for on (default)");
> +module_param(arp_slow_switch, int, 0);
> +MODULE_PARM_DESC(arp_slow_switch, "Do extra arp checks for switches with arp "
> +				  "caches that are slow to update; "
> +				  "0 for off (default), 1 for on");
>  module_param(mode, charp, 0);
>  MODULE_PARM_DESC(mode, "Mode of operation; 0 for balance-rr, "
>  		       "1 for active-backup, 2 for balance-xor, "
> @@ -2793,6 +2798,18 @@ static bool bond_ab_arp_probe(struct bonding *bond)
>  			return should_notify_rtnl;
>  	}
>  
> +	/* Sometimes the forwarding tables of the switches are not update
^ s/update/updated/

> +	 * fast enough, so the first arp response after a slave change is
> +	 * received on the wrong slave.
> +	 *
> +	 * The arp requests will be retried 2 times on the same slave.
> +	 */
> +	if (arp_slow_switch &&
> +	    bond_time_in_interval(bond, curr_arp_slave->last_link_up, 2)) {
> +		bond_arp_send_all(bond, curr_arp_slave);
> +		return should_notify_rtnl;
> +	}
> +
>  	bond_set_slave_inactive_flags(curr_arp_slave, BOND_SLAVE_NOTIFY_LATER);
>  
>  	bond_for_each_slave_rcu(bond, slave, iter) {
> @@ -4280,6 +4297,12 @@ static int bond_check_params(struct bond_params *params)
>  		use_carrier = 1;
>  	}
>  
> +	if ((arp_slow_switch != 0) && (arp_slow_switch != 1)) {
^^ no need for the extra ()

> +		pr_warn("Warning: arp_slow_switch module parameter (%d), not of valid value (0/1), so it was set to 1\n",
> +			arp_slow_switch);
> +		arp_slow_switch = 1;
^^ please default to old behaviour in this case (0)

> +	}
> +
>  	if (num_peer_notif < 0 || num_peer_notif > 255) {
>  		pr_warn("Warning: num_grat_arp/num_unsol_na (%d) not in range 0-255 so it was reset to 1\n",
>  			num_peer_notif);
> @@ -4516,6 +4539,7 @@ static int bond_check_params(struct bond_params *params)
>  	params->updelay = updelay;
>  	params->downdelay = downdelay;
>  	params->use_carrier = use_carrier;
> +	params->arp_slow_switch = arp_slow_switch;
>  	params->lacp_fast = lacp_fast;
>  	params->primary[0] = 0;
>  	params->primary_reselect = primary_reselect_value;
> diff --git a/include/net/bonding.h b/include/net/bonding.h
> index c1740a2..208d31c 100644
> --- a/include/net/bonding.h
> +++ b/include/net/bonding.h
> @@ -120,6 +120,7 @@ struct bond_params {
>  	int arp_validate;
>  	int arp_all_targets;
>  	int use_carrier;
> +	int arp_slow_switch;
>  	int fail_over_mac;
>  	int updelay;
>  	int downdelay;
> 
