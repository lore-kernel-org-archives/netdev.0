From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch] bonding: comparing a u8 with -1 is always false
Date: Fri, 4 Nov 2011 20:35:20 +0000
Message-ID: <1320438920.2753.16.camel@bwh-desktop>
References: <20111104182138.GB5796@elgon.mountain>  <10444.1320436921@death>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	Weiping Pan <wpan@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	<kernel-janitors@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:56748 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597Ab1KDUfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 16:35:25 -0400
In-Reply-To: <10444.1320436921@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-11-04 at 13:02 -0700, Jay Vosburgh wrote:
> Dan Carpenter <dan.carpenter@oracle.com> wrote:
> >slave->duplex is a u8 type so the in bond_info_show_slave() when we
> >check "if (slave->duplex == -1)", it's always false.
> >
> >Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> >
> >diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> >index b2b9109..b0c5772 100644
> >--- a/drivers/net/bonding/bond_main.c
> >+++ b/drivers/net/bonding/bond_main.c
> >@@ -560,8 +560,8 @@ static int bond_update_speed_duplex(struct slave *slave)
> > 	u32 slave_speed;
> > 	int res;
> >
> >-	slave->speed = -1;
> >-	slave->duplex = -1;
> >+	slave->speed = SPEED_UNKNOWN;
> >+	slave->duplex = DUPLEX_UNKNOWN;
> >
> > 	res = __ethtool_get_settings(slave_dev, &ecmd);
> > 	if (res < 0)
> >diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
> >index 2acf0b0..ad284ba 100644
> >--- a/drivers/net/bonding/bond_procfs.c
> >+++ b/drivers/net/bonding/bond_procfs.c
> >@@ -158,12 +158,12 @@ static void bond_info_show_slave(struct seq_file *seq,
> > 	seq_printf(seq, "\nSlave Interface: %s\n", slave->dev->name);
> > 	seq_printf(seq, "MII Status: %s\n",
> > 		   (slave->link == BOND_LINK_UP) ?  "up" : "down");
> >-	if (slave->speed == -1)
> >+	if (slave->speed == SPEED_UNKNOWN)
> > 		seq_printf(seq, "Speed: %s\n", "Unknown");
> > 	else
> > 		seq_printf(seq, "Speed: %d Mbps\n", slave->speed);
> 
> 	Since you #define SPEED_UNKNOWN to -1 (below), how does this
> actually change anything?  Did you mean 0xffff (because struct
> ethtool_cmd's speed is a u16)?

The speed in ethtool_cmd is 32 bits divided between two fields.

> 	Running on a moderately recent net-next (without the very recent
> change to bond_update_speed_duplex), I see that bonding indeed doesn't
> get the speed or duplex correct after a cable pull:
> 
> Slave Interface: eth2
> MII Status: down
> Speed: 100 Mbps
> Duplex: full
> 
> 	so perhaps a rational (unsigned-friendly) SPEED_UNKNOWN and
> DUPLEX_UNKNOWN are needed, but I'm not sure how this #define actually
> would change any behavior in the bonding case.

Agree that they should be defined somewhere.  The ethtool utility
recognises speed values of 0, (u16)(-1) and (u32)(-1) as 'unknown'.
Personally I think 0 makes more sense than (u32)(-1) but it doesn't
matter much.

> >-	if (slave->duplex == -1)
> >+	if (slave->duplex == DUPLEX_UNKNOWN)
> > 		seq_printf(seq, "Duplex: %s\n", "Unknown");
> > 	else
> > 		seq_printf(seq, "Duplex: %s\n", slave->duplex ? "full" : "half");
> 
> 	This one might "work," but it seems to depend on the fact that
> the integral conversion of -1 to an 8 bit unsigned type will be 255
> (0xff).  I believe that's true (according to the ISO C copy I have
> handy), but I'm not sure that kind of implicit assumption should be
> built into the code.  At least not without some explanation.
[...]

It's true and does not need explanation.  Quite why anyone expected a
negative value to survive conversion to u8 and back to int, now that
deserves explanation...

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
