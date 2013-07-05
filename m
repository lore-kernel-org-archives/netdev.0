From: wangyufen <wangyufen@huawei.com>
Subject: Re: [PATCH] bonding:fix speed unknown,lacp bonding failed
Date: Fri, 5 Jul 2013 18:08:44 +0800
Message-ID: <51D69B2C.4040102@huawei.com>
References: <1373005979-10196-1-git-send-email-wangyufen@huawei.com> <CAE3RKN=dy8t0W-pvq7yro643i-0AZziOw+7BQ5fc4z7JquC__Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, <lizefan@huawei.com>,
	<zhangdianfang@huawei.com>
To: Veaceslav Falico <darkmag@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:32376 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752391Ab3GEKZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jul 2013 06:25:58 -0400
In-Reply-To: <CAE3RKN=dy8t0W-pvq7yro643i-0AZziOw+7BQ5fc4z7JquC__Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/7/5 17:20, Veaceslav Falico wrote:
> On Fri, Jul 5, 2013 at 8:32 AM, Wangyufen <wangyufen@huawei.com> wrot=
e:
>> From: "Wang Yufen" <wangyufen@huawei.com>
>>
>> We bonded nic using LACP mode repeatedly, occasionally LACP bonding =
failed,
>> because a slave nic port speed was unknown. But when we used ethtool=
 to
>> check the slave NIC status, the nic status was normal,speed was 1000=
0Mb/s.
>=20
> Can you give a bit more details on how did you test? And which nic wa=
s it?
>=20
> I've tried to reproduce it with with while :; do echo +/- >
> /sys/.../bonding/slaves; done
> but failed.
>=20

that is my test script=EF=BC=9A
# !/bin/sh

function bond_enable()
{
        echo -vpa0 >/sys/class/net/bonding_masters
        sleep 2
        echo +vpa0 > /sys/class/net/bonding_masters
        echo 4 > /sys/class/net/vpa0/bonding/mode
        echo 1 > /sys/class/net/vpa0/bonding/xmit_hash_policy
        ifconfig vpa0 up
        sleep 1
        echo +eth0 > /sys/class/net/vpa0/bonding/slaves
        echo +eth5 > /sys/class/net/vpa0/bonding/slaves
        echo +eth7 > /sys/class/net/vpa0/bonding/slaves
        echo +eth9 > /sys/class/net/vpa0/bonding/slaves
        sleep 2
}

for((i=3D0;i<5000;i++))
do
        bond_enable

        j=3D0
        while [ $j -lt 10 ]
        do
                sleep 0.5
                ifconfig vpa0 192.168.13.8/24
                out=3D`ifconfig | grep "192.168.13.8"`
                if [ -n "$out" ];then
                        break
                fi
                ((j++))
        done
        out1=3D`ping 192.168.13.8 -c 4`
        out2=3D`cat /proc/net/bonding/vpa0 | grep "Number of ports: 4"`
        if [ -n "$out1" -a -n "$out2" ];then
                echo $i PASS >> dep002.log
        else
                echo "out1 is $out1, out2 is $out2" >>dep002.log
                echo $i FAIL >> dep002.log
                exit 0
        fi
done

>>
>> Bonding get the NIC speed from NIC drivers,just when enslave nic
>> and receive NETDEV_CHANGE event.We call bond_update_speed_duplex to
>> update speed and duplex when miimon inspect slave link is OK and sla=
ve
>> speed is unknown.
>>
>>
>> Signed-off-by: Wang Yufen <wangyufen@huawei.com>
>> ---
>>  drivers/net/bonding/bond_main.c | 5 ++++-
>>  1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/b=
ond_main.c
>> index f975696..d288a98 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -2301,8 +2301,11 @@ static int bond_miimon_inspect(struct bonding=
 *bond)
>>
>>                 switch (slave->link) {
>>                 case BOND_LINK_UP:
>> -                       if (link_state)
>> +                       if (link_state) {
>> +                               if (slave->speed =3D=3D SPEED_UNKNOW=
N)
>> +                                       bond_update_speed_duplex(sla=
ve);
>>                                 continue;
>> +                       }
>>
>>                         slave->link =3D BOND_LINK_FAIL;
>>                         slave->delay =3D bond->params.downdelay;
>> --
>> 1.8.0
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20
>=20
> --
> Best regards,
> Veaceslav Falico
>=20
>=20
