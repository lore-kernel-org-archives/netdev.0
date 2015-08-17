From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH] net/bonding: send arp in interval if no active slave
Date: Mon, 17 Aug 2015 18:55:00 +0200
Message-ID: <20150817165500.GA21512@vps.falico.eu>
References: <1439828583-27325-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-kernel@vger.kernel.org,
	Uwe Koziolek <uwe.koziolek@redknee.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1439828583-27325-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 17, 2015 at 12:23:03PM -0400, Jarod Wilson wrote:
>From: Uwe Koziolek <uwe.koziolek@redknee.com>
>
>With some very finicky switch hardware, active backup bonding can get into
>a situation where we play ping-pong between interfaces, trying to get one
>to come up as the active slave. There seems to be an issue with the
>switch's arp replies either taking too long, or simply getting lost, so we
>wind up unable to get any interface up and active. Sometimes, the issue
>sorts itself out after a while, sometimes it doesn't.
>
>Testing with num_grat_arp has proven fruitless, but sending an additional
>arp on curr_arp_slave if we're still in the arp_interval timeslice in
>bond_ab_arp_probe(), has shown to produce 100% reliability in testing with
>this hardware combination.

Sorry, I don't understand the logic of why it works, and what exactly are
we fixiing here.

It also breaks completely the logic for link state management in case of no
current active slave for 2*arp_interval.

Could you please elaborate what exactly is fixed here, and how it works? :)

p.s. num_grat_arp maybe could help?

>
>[jarod: manufacturing of changelog]
>CC: Jay Vosburgh <j.vosburgh@gmail.com>
>CC: Veaceslav Falico <vfalico@gmail.com>
>CC: Andy Gospodarek <gospo@cumulusnetworks.com>
>CC: netdev@vger.kernel.org
>Signed-off-by: Uwe Koziolek <uwe.koziolek@redknee.com>
>Signed-off-by: Jarod Wilson <jarod@redhat.com>
>---
> drivers/net/bonding/bond_main.c | 5 +++++
> 1 file changed, 5 insertions(+)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 0c627b4..60b9483 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2794,6 +2794,11 @@ static bool bond_ab_arp_probe(struct bonding *bond)
> 			return should_notify_rtnl;
> 	}
>
>+	if (bond_time_in_interval(bond, curr_arp_slave->last_link_up, 2)) {
>+		bond_arp_send_all(bond, curr_arp_slave);
>+		return should_notify_rtnl;
>+	}
>+
> 	bond_set_slave_inactive_flags(curr_arp_slave, BOND_SLAVE_NOTIFY_LATER);
>
> 	bond_for_each_slave_rcu(bond, slave, iter) {
>-- 
>1.8.3.1
>
