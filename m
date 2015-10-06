From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH v4] net/bonding: send arp in interval if no active slave
Date: Tue, 06 Oct 2015 15:58:54 -0400
Message-ID: <561427FE.7010904@redhat.com>
References: <56094137.9030206@redhat.com> <1444161197-38442-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Uwe Koziolek <uwe.koziolek@redknee.com>,
	Jay Vosburgh <jay.vosburgh@canonical.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Veaceslav Falico <vfalico@gmail.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444161197-38442-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarod Wilson wrote:
> From: Uwe Koziolek<uwe.koziolek@redknee.com>
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
> CC: Jay Vosburgh<jay.vosburgh@canonical.com>
> CC: Andy Gospodarek<gospo@cumulusnetworks.com>
> CC: Veaceslav Falico<vfalico@gmail.com>
> CC: netdev@vger.kernel.org
> Signed-off-by: Uwe Koziolek<uwe.koziolek@redknee.com>
> Signed-off-by: Jarod Wilson<jarod@redhat.com>
> ---
> v2: add code comment as to why change is needed
> v3: fix wrapping of comments
> v4: [jarod] add module parameter gating of code addition
>
>   drivers/net/bonding/bond_main.c | 24 ++++++++++++++++++++++++
>   include/net/bonding.h           |  1 +
>   2 files changed, 25 insertions(+)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 90f2615..72ab512 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -95,6 +95,7 @@ static int miimon;
>   static int updelay;
>   static int downdelay;
>   static int use_carrier	= 1;
> +static int arp_slow_switch;
>   static char *mode;
>   static char *primary;
>   static char *primary_reselect;
> @@ -133,6 +134,10 @@ MODULE_PARM_DESC(downdelay, "Delay before considering link down, "
>   module_param(use_carrier, int, 0);
>   MODULE_PARM_DESC(use_carrier, "Use netif_carrier_ok (vs MII ioctls) in miimon; "
>   			      "0 for off, 1 for on (default)");
> +module_param(arp_slow_switch, int, 0);
> +MODULE_PARM_DESC(arp_slow_switch, "Do extra arp checks for switches with arp "
> +				  "caches that are slow to update; "
> +				  "0 for off (default), 1 for on");
>   module_param(mode, charp, 0);
>   MODULE_PARM_DESC(mode, "Mode of operation; 0 for balance-rr, "
>   		       "1 for active-backup, 2 for balance-xor, "
> @@ -2793,6 +2798,18 @@ static bool bond_ab_arp_probe(struct bonding *bond)
>   			return should_notify_rtnl;
>   	}
>
> +	/* Sometimes the forwarding tables of the switches are not update
> +	 * fast enough, so the first arp response after a slave change is
> +	 * received on the wrong slave.
> +	 *
> +	 * The arp requests will be retried 2 times on the same slave.
> +	 */
> +	if (arp_slow_switch &&

This here should actually be bond->params.arp_slow_switch, but I'd like 
to hear first if a module parameter gating this change is even a 
remotely acceptable idea. It'd keep the logic identical in the default 
case though, and still allow for people like Uwe that need it to deploy 
the work-around.

Though I'm slightly curious if this problem does NOT manifest by simply 
setting a larger arp_interval. Early on, I thought I'd heard that other 
intervals had been tried with the same results, but a comment in this 
thread suggested maybe only 500 had been tried.

-- 
Jarod Wilson
jarod@redhat.com
