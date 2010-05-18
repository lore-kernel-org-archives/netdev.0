From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next-2.6 2/2] bonding: allow user-controlled output
	slave selection
Date: Tue, 18 May 2010 08:57:05 -0400
Message-ID: <AANLkTilkujZ-XaPFNtlLp_9el6ABC7ICcxFIL13hDzWM@mail.gmail.com>
References: <20100511003245.GB7497@gospo.rdu.redhat.com>
	 <17897.1273608579@death.nxdomain.ibm.com>
	 <20100512002725.GA2460@localhost.localdomain>
	 <25238.1273693314@death.nxdomain.ibm.com>
	 <20100512221408.GI7497@gospo.rdu.redhat.com>
	 <20100513171504.GD21535@shamino.rdu.redhat.com>
	 <20100517184508.GD17419@hmsreliant.think-freely.org>
	 <17188.1274124341@death.nxdomain.ibm.com>
	 <12958.1274145714@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:64997 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753281Ab0ERM5L convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 08:57:11 -0400
Received: by wwi17 with SMTP id 17so459270wwi.19
        for <netdev@vger.kernel.org>; Tue, 18 May 2010 05:57:08 -0700 (PDT)
In-Reply-To: <12958.1274145714@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 17, 2010 at 9:21 PM, Jay Vosburgh <fubar@us.ibm.com> wrote:
> Jay Vosburgh <fubar@us.ibm.com> wrote:
> [...]
>> =A0 =A0 =A0 For your patch, I'm exploring the idea of not setting
>>IFF_SLAVE_INACTIVE on "inactive" slaves for an "all_slaves_active"
>>option (I think that's a more descriptive name than "keep_all") inste=
ad
>>of adding a new KEEP_ALL flag bit to priv_flags. =A0Did you consider =
this
>>methodology and exclude it for some reason?
>
> =A0 =A0 =A0 =A0Following up to myself, I coded up approximately what =
I was
> talking about. =A0This doesn't require the extra priv_flag, and the s=
ysfs
> _store is a little more complicated, but this appears to work (testin=
g
> with ping -f after clearing the switch's MAC table to induce traffic
> flooding). =A0I didn't change the option name from "keep_all" here, b=
ut as
> far as the functionality goes, this seems to do what I think you want=
 it
> to.
>

I can test it here to be sure, but overall this seems like a fine
approach.  The IFF_SLAVE_INACTIVE doesn't seem to be used for much
other than duplicate suppression at this point, so it seems like a
logical choice.

As for the original name 'keep_all,' I tried to use something that
user would find easy to understand.  Obviously not all users think
alike. :-)


> =A0 =A0 =A0 =A0-J
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 5e12462..c80d2ff 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -106,6 +106,7 @@ static int arp_interval =3D BOND_LINK_ARP_INTERV;
> =A0static char *arp_ip_target[BOND_MAX_ARP_TARGETS];
> =A0static char *arp_validate;
> =A0static char *fail_over_mac;
> +static int keep_all =A0 =A0=3D 0;
> =A0static struct bond_params bonding_defaults;
>
> =A0module_param(max_bonds, int, 0);
> @@ -155,6 +156,9 @@ module_param(arp_validate, charp, 0);
> =A0MODULE_PARM_DESC(arp_validate, "validate src/dst of ARP probes: no=
ne (default), active, backup or all");
> =A0module_param(fail_over_mac, charp, 0);
> =A0MODULE_PARM_DESC(fail_over_mac, "For active-backup, do not set all=
 slaves to the same MAC. =A0none (default), active or follow");
> +module_param(keep_all, int, 0);
> +MODULE_PARM_DESC(keep_all, "Keep all frames received on an interface=
"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"0 for never (de=
fault), 1 for always.");
>
> =A0/*----------------------------- Global variables -----------------=
-----------*/
>
> @@ -4756,6 +4760,13 @@ static int bond_check_params(struct bond_param=
s *params)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 if ((keep_all !=3D 0) && (keep_all !=3D 1)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_warning("Warning: keep_all module pa=
rameter (%d), "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"not of valid va=
lue (0/1), so it was set to "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"0\n", keep_all)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 keep_all =3D 0;
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0/* reset values for TLB/ALB */
> =A0 =A0 =A0 =A0if ((bond_mode =3D=3D BOND_MODE_TLB) ||
> =A0 =A0 =A0 =A0 =A0 =A0(bond_mode =3D=3D BOND_MODE_ALB)) {
> @@ -4926,6 +4937,7 @@ static int bond_check_params(struct bond_params=
 *params)
> =A0 =A0 =A0 =A0params->primary[0] =3D 0;
> =A0 =A0 =A0 =A0params->primary_reselect =3D primary_reselect_value;
> =A0 =A0 =A0 =A0params->fail_over_mac =3D fail_over_mac_value;
> + =A0 =A0 =A0 params->keep_all =3D keep_all;
>
> =A0 =A0 =A0 =A0if (primary) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0strncpy(params->primary, primary, IFNA=
MSIZ);
> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/b=
ond_sysfs.c
> index b8bec08..73b3c03 100644
> --- a/drivers/net/bonding/bond_sysfs.c
> +++ b/drivers/net/bonding/bond_sysfs.c
> @@ -339,7 +339,6 @@ out:
>
> =A0static DEVICE_ATTR(slaves, S_IRUGO | S_IWUSR, bonding_show_slaves,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bonding_store_slaves);
> -
> =A0/*
> =A0* Show and set the bonding mode. =A0The bond interface must be dow=
n to
> =A0* change the mode.
> @@ -1472,6 +1471,59 @@ static ssize_t bonding_show_ad_partner_mac(str=
uct device *d,
> =A0}
> =A0static DEVICE_ATTR(ad_partner_mac, S_IRUGO, bonding_show_ad_partne=
r_mac, NULL);
>
> +/*
> + * Show and set the keep_all flag.
> + */
> +static ssize_t bonding_show_keep(struct device *d,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stru=
ct device_attribute *attr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0char=
 *buf)
> +{
> + =A0 =A0 =A0 struct bonding *bond =3D to_bond(d);
> +
> + =A0 =A0 =A0 return sprintf(buf, "%d\n", bond->params.keep_all);
> +}
> +
> +static ssize_t bonding_store_keep(struct device *d,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 str=
uct device_attribute *attr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 con=
st char *buf, size_t count)
> +{
> + =A0 =A0 =A0 int i, new_value, ret =3D count;
> + =A0 =A0 =A0 struct bonding *bond =3D to_bond(d);
> + =A0 =A0 =A0 struct slave *slave;
> +
> + =A0 =A0 =A0 if (sscanf(buf, "%d", &new_value) !=3D 1) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("%s: no keep_all value specified=
=2E\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bond->dev->name);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (new_value =3D=3D bond->params.keep_all)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> + =A0 =A0 =A0 if ((new_value =3D=3D 0) || (new_value =3D=3D 1)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bond->params.keep_all =3D new_value;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_info("%s: Ignoring invalid keep_all =
value %d.\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bond->dev->name, new_va=
lue);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 bond_for_each_slave(bond, slave, i) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (slave->state =3D=3D BOND_STATE_BACK=
UP) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (new_value)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 slave->=
dev->priv_flags &=3D ~IFF_SLAVE_INACTIVE;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 slave->=
dev->priv_flags |=3D IFF_SLAVE_INACTIVE;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +out:
> + =A0 =A0 =A0 return count;
> +}
> +static DEVICE_ATTR(keep_all, S_IRUGO | S_IWUSR,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bonding_show_keep, bonding_store=
_keep);
> +
>
>
> =A0static struct attribute *per_bond_attrs[] =3D {
> @@ -1499,6 +1551,7 @@ static struct attribute *per_bond_attrs[] =3D {
> =A0 =A0 =A0 =A0&dev_attr_ad_actor_key.attr,
> =A0 =A0 =A0 =A0&dev_attr_ad_partner_key.attr,
> =A0 =A0 =A0 =A0&dev_attr_ad_partner_mac.attr,
> + =A0 =A0 =A0 &dev_attr_keep_all.attr,
> =A0 =A0 =A0 =A0NULL,
> =A0};
>
> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bond=
ing.h
> index 2aa3367..ef7969b 100644
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -131,6 +131,7 @@ struct bond_params {
> =A0 =A0 =A0 =A0char primary[IFNAMSIZ];
> =A0 =A0 =A0 =A0int primary_reselect;
> =A0 =A0 =A0 =A0__be32 arp_targets[BOND_MAX_ARP_TARGETS];
> + =A0 =A0 =A0 int keep_all;
> =A0};
>
> =A0struct bond_parm_tbl {
> @@ -291,7 +292,8 @@ static inline void bond_set_slave_inactive_flags(=
struct slave *slave)
> =A0 =A0 =A0 =A0struct bonding *bond =3D netdev_priv(slave->dev->maste=
r);
> =A0 =A0 =A0 =A0if (!bond_is_lb(bond))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slave->state =3D BOND_STATE_BACKUP;
> - =A0 =A0 =A0 slave->dev->priv_flags |=3D IFF_SLAVE_INACTIVE;
> + =A0 =A0 =A0 if (!bond->params.keep_all)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 slave->dev->priv_flags |=3D IFF_SLAVE_I=
NACTIVE;
> =A0 =A0 =A0 =A0if (slave_do_arp_validate(bond, slave))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slave->dev->priv_flags |=3D IFF_SLAVE_=
NEEDARP;
> =A0}
>
>
> ---
> =A0 =A0 =A0 =A0-Jay Vosburgh, IBM Linux Technology Center, fubar@us.i=
bm.com
>
