From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH tip/core/rcu 11/14] bonding/bond_main: Apply ACCESS_ONCE()
 to avoid sparse false positive
Date: Sat, 16 Nov 2013 12:32:16 +0800
Message-ID: <5286F550.10900@gmail.com>
References: <20131116003946.GA316@linux.vnet.ibm.com> <1384562417-817-1-git-send-email-paulmck@linux.vnet.ibm.com> <1384562417-817-11-git-send-email-paulmck@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, mingo@kernel.org,
	laijs@cn.fujitsu.com, dipankar@in.ibm.com,
	akpm@linux-foundation.org, mathieu.desnoyers@efficios.com,
	josh@joshtriplett.org, niv@us.ibm.com, tglx@linutronix.de,
	peterz@infradead.org, rostedt@goodmis.org, dhowells@redhat.com,
	edumazet@google.com, darren@dvhart.com, fweisbec@gmail.com,
	sbw@mit.edu, Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384562417-817-11-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=D3=DA 2013/11/16 8:40, Paul E. McKenney =D0=B4=B5=C0:
> From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
>
> The sparse checking for rcu_assign_pointer() was recently upgraded
> to reject non-__kernel address spaces.  This also rejects __rcu,
> which is almost always the right thing to do.  However, the uses in
> bond_change_active_slave() and __bond_release_one() are legitimate:
> They are assigning a pointer to an element from an RCU-protected list
> (or a NULL pointer), and all elements of this list are already visibl=
e
> to caller.
>
> This commit therefore silences these false positives either by launde=
ring
> the pointers using ACCESS_ONCE() as suggested by Eric Dumazet and Jos=
h
> Triplett, or by using RCU_INIT_POINTER() for NULL pointer assignments=
=2E
I think it is fit for net-next.


> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: bridge@lists.linux-foundation.org
> Cc: netdev@vger.kernel.org
> ---
>  drivers/net/bonding/bond_main.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 72df399c4ab3..bbd7fd3e46fe 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -890,7 +890,8 @@ void bond_change_active_slave(struct bonding *bon=
d, struct slave *new_active)
>  		if (new_active)
>  			bond_set_slave_active_flags(new_active);
>  	} else {
> -		rcu_assign_pointer(bond->curr_active_slave, new_active);
> +		/* Both --rcu and visible, so ACCESS_ONCE() is OK. */
> +		ACCESS_ONCE(bond->curr_active_slave) =3D new_active;
>  	}
> =20
>  	if (bond->params.mode =3D=3D BOND_MODE_ACTIVEBACKUP) {
> @@ -1801,7 +1802,7 @@ static int __bond_release_one(struct net_device=
 *bond_dev,
>  	}
> =20
>  	if (all) {
> -		rcu_assign_pointer(bond->curr_active_slave, NULL);
> +		RCU_INIT_POINTER(bond->curr_active_slave, NULL);
>  	} else if (oldcurrent =3D=3D slave) {
>  		/*
>  		 * Note that we hold RTNL over this sequence, so there
