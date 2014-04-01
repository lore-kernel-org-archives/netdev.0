From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH v2] bonding: Inactive slaves should keep inactive flag's
 value
Date: Tue, 01 Apr 2014 13:30:35 +0200
Message-ID: <533AA35B.8050004@redhat.com>
References: <1396339327-24899-1-git-send-email-zheng.x.li@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	joe.jin@oracle.com
To: Zheng Li <zheng.x.li@oracle.com>, netdev@vger.kernel.org,
	fubar@us.ibm.com, andy@greyhouse.net, j.vosburgh@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1396339327-24899-1-git-send-email-zheng.x.li@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/01/2014 10:02 AM, Zheng Li wrote:
> bond_open is not setting the inactive flag correctly for some modes (alb and
> tlb), resulting in error behavior if the bond has been administratively set
> down and then back up. This effect should not occur when slaves are added while
> the bond is up; it's something that only happens after a down/up bounce of the
> bond.
> 
> For example, in bond tlb or alb mode, domu send some ARP request which go out
> from dom0 bond's active slave, then the ARP broadcast request packets go back to
> inactive slave from switch, because the inactive slave's inactive flag is zero,
> kernel will receive the packets and pass them to bridge that cause dom0's bridge
> map domu's MAC address to port of bond, bridge should map domu's MAC to port of
> vif.
> 
> Signed-off-by: Zheng Li <zheng.x.li@oracle.com>
> Signed-off-by: Jay Vosburgh <j.vosburgh@gmail.com>
> ---
>  drivers/net/bonding/bond_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index e5628fc..f97d72e 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3058,7 +3058,7 @@ static int bond_open(struct net_device *bond_dev)
>  	if (bond_has_slaves(bond)) {
>  		read_lock(&bond->curr_slave_lock);
>  		bond_for_each_slave(bond, slave, iter) {
> -			if ((bond->params.mode == BOND_MODE_ACTIVEBACKUP)
> +			if ((bond->params.mode == BOND_MODE_ACTIVEBACKUP || bond_is_lb(bond))
IIRC, this check is identical to USES_PRIMARY().

>  				&& (slave != bond->curr_active_slave)) {
>  				bond_set_slave_inactive_flags(slave,
>  							      BOND_SLAVE_NOTIFY_NOW);
> 
