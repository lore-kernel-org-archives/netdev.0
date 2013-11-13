From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net RESEND] bonding: add ip checks when store ip target
Date: Wed, 13 Nov 2013 22:35:47 +0800
Message-ID: <52838E43.9080505@gmail.com>
References: <5282E196.8030401@huawei.com> <20131113100000.GH19702@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:39629 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755546Ab3KMOrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 09:47:04 -0500
Received: by mail-pa0-f45.google.com with SMTP id kp14so524884pab.18
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 06:47:03 -0800 (PST)
In-Reply-To: <20131113100000.GH19702@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/11/13 18:00, Veaceslav Falico =E5=86=99=E9=81=93:
> On Wed, Nov 13, 2013 at 10:19:02AM +0800, Ding Tianhong wrote:
>> I met a Bug when I add ip target with the wrong ip address:
>>
>> echo +500.500.500.500 > /sys/class/net/bond0/bonding/arp_ip_target
>>
>> the wrong ip address will transfor to 245.245.245.244 and add
>> to the ip target success, it is uncorrect, so I add checks to avoid
>> adding wrong address.
>>
>> The in4_pton() will set wrong ip address to 0.0.0.0, it will return =
by
>> the next check and will not add to ip target.
>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>> drivers/net/bonding/bond_sysfs.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/bonding/bond_sysfs.c=20
>> b/drivers/net/bonding/bond_sysfs.c
>> index ec9b646..e0c97fb 100644
>> --- a/drivers/net/bonding/bond_sysfs.c
>> +++ b/drivers/net/bonding/bond_sysfs.c
>> @@ -653,7 +653,7 @@ static ssize_t bonding_store_arp_targets(struct=20
>> device *d,
>> int ind, i, j, ret =3D -EINVAL;
>>
>> targets =3D bond->params.arp_targets;
>> - newtarget =3D in_aton(buf + 1);
>> + in4_pton(buf + 1, strlen(buf) - 1, (u8 *)&newtarget, -1, NULL);
>
> No need for strlen(buf)-1, if you specify -1 it will compute it by=20
> itself.
>
> Also, you might simplify the code a bit in the function. Otherwise -=20
> looks
> good, thank you.
>
> Untested patch:
>
> diff --git a/drivers/net/bonding/bond_sysfs.c=20
> b/drivers/net/bonding/bond_sysfs.c
> index c29b836..e3fff6e 100644
> --- a/drivers/net/bonding/bond_sysfs.c
> +++ b/drivers/net/bonding/bond_sysfs.c
> @@ -661,16 +661,16 @@ static ssize_t bonding_store_arp_targets(struct=
=20
> device *d,
> unsigned long *targets_rx;
> int ind, i, j, ret =3D -EINVAL;
>
> + if (!in4_pton(buf + 1, -1, (u8 *)&newtarget, -1, NULL)) {
> + pr_err("%s: invalid ARP target specified, use +<addr> or -<addr>\n"=
,
> + bond->dev->name);
> + goto out;
> + }
> +
> targets =3D bond->params.arp_targets;
> - newtarget =3D in_aton(buf + 1);
> +
> /* look for adds */
> if (buf[0] =3D=3D '+') {
> - if ((newtarget =3D=3D 0) || (newtarget =3D=3D htonl(INADDR_BROADCAS=
T))) {
> - pr_err("%s: invalid ARP target %pI4 specified for addition\n",
> - bond->dev->name, &newtarget);
> - goto out;
> - }
> -
> if (bond_get_targets_ip(targets, newtarget) !=3D -1) { /* dup */
> pr_err("%s: ARP target %pI4 is already present\n",
> bond->dev->name, &newtarget);
> @@ -693,12 +693,6 @@ static ssize_t bonding_store_arp_targets(struct=20
> device *d,
> targets[ind] =3D newtarget;
> write_unlock_bh(&bond->lock);
> } else if (buf[0] =3D=3D '-') {
> - if ((newtarget =3D=3D 0) || (newtarget =3D=3D htonl(INADDR_BROADCAS=
T))) {
> - pr_err("%s: invalid ARP target %pI4 specified for removal\n",
> - bond->dev->name, &newtarget);
> - goto out;
> - }
> -
> ind =3D bond_get_targets_ip(targets, newtarget);
> if (ind =3D=3D -1) {
> pr_err("%s: unable to remove nonexistent ARP target %pI4.\n",
> --=20
Although there is no substantial changes, but more simple more=20
beautiful, I'll take it,
resend it later, thanks for your opinion.

Regards
Ding


> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html
>
