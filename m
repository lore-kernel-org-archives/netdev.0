From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net] bonding: fix packets_per_slave showing
Date: Thu, 5 Dec 2013 12:08:43 +0100
Message-ID: <20131205110843.GD23210@redhat.com>
References: <1386239818-7408-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24052 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755792Ab3LELLQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Dec 2013 06:11:16 -0500
Content-Disposition: inline
In-Reply-To: <1386239818-7408-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 05, 2013 at 11:36:58AM +0100, Nikolay Aleksandrov wrote:
>There's an issue when showing the value of packets_per_slave due to
>using signed integer. The value may be < 0 and thus not put through
>reciprocal_value() before showing. This patch makes it use unsigned
>integer when showing it.

I was already checking my basic algebra knowledge here,
reciprocal_value(reciprocal_value(0..USHRT_MAX)) can become negative?!? :)

If anyone's also wondering...

packets_per_slave is reciprocal_value(0..USHRT_MAX), and thus can indeed be
negative, and then the code

	if (packets_per_slave > 1)
		packets_per_slave = reciprocal_value(packets_per_slave);

would fail to recognise that it's a reciprocal_divide() value, and not a
standard 0/1 option (in bond_rr_gen_slave_id() we verify it via a switch,
so we're safe there) - and thus output nonsense.

Acked-by: Veaceslav Falico <vfalico@redhat.com>

>
>CC: Andy Gospodarek <andy@greyhouse.net>
>CC: Jay Vosburgh <fubar@us.ibm.com>
>CC: Veaceslav Falico <vfalico@redhat.com>
>CC: David S. Miller <davem@davemloft.net>
>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>---
> drivers/net/bonding/bond_sysfs.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index abf5e10..0ae580b 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -1635,12 +1635,12 @@ static ssize_t bonding_show_packets_per_slave(struct device *d,
> 					      char *buf)
> {
> 	struct bonding *bond = to_bond(d);
>-	int packets_per_slave = bond->params.packets_per_slave;
>+	unsigned int packets_per_slave = bond->params.packets_per_slave;
>
> 	if (packets_per_slave > 1)
> 		packets_per_slave = reciprocal_value(packets_per_slave);
>
>-	return sprintf(buf, "%d\n", packets_per_slave);
>+	return sprintf(buf, "%u\n", packets_per_slave);
> }
>
> static ssize_t bonding_store_packets_per_slave(struct device *d,
>-- 
>1.8.1.4
>
