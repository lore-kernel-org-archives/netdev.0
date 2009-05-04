From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH v2] Receive Packet Steering
Date: Mon, 04 May 2009 09:13:07 +0200
Message-ID: <49FE9583.8040009@cosmosbay.com>
References: <65634d660905032103h614225dbg9911e290f5537fbf@mail.gmail.com> <49FE7D63.6050102@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58052 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbZEDHQV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 03:16:21 -0400
In-Reply-To: <49FE7D63.6050102@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Tom Herbert a =E9crit :

>> +static ssize_t store_rps_cpus(struct device *dev,
>> +			      struct device_attribute *attr,
>> +			      const char *buf, size_t len)
>> +{
>> +	struct net_device *net =3D to_net_dev(dev);
>> +	cpumask_t mask;
>> +	int err, cpu;
>> +	int i =3D 0;
>> +
>> +	if (!capable(CAP_NET_ADMIN))
>> +		return -EPERM;
>> +
>> +	err =3D bitmap_parse(buf, len, cpumask_bits(&mask), nr_cpumask_bit=
s);
>> +	if (err)
>> +		return err;
>> +
>> +	rtnl_lock();
>> +	if (dev_isalive(net)) {
>> +		if (!net->rps_map) {
>> +			net->rps_map =3D kzalloc(sizeof(u16) *
>> +			    num_possible_cpus(), GFP_KERNEL);
>=20
> num_possible_cpus() is not the max index of a cpu, but the number of =
possible cpus.
> it can be for example 2, but cpu0 being index 0, and second cpu at in=
dex 511
>=20
> So I believe you want nr_cpu_ids here
>=20
> (num_possible_cpus() <=3D nr_cpu_ids), not necessarly equal.=20
>=20
>=20
>> +			if (!net->rps_map)
>> +				return -ENOMEM;
>> +		}
>> +		cpus_and(mask, mask, cpu_online_map);
>> +		for_each_cpu_mask(cpu, mask)
>> +			net->rps_map[i++] =3D  cpu;
>> +		net->rps_map_len =3D i;
>> +	}
>> +	rtnl_unlock();
>> +
>> +	return len;

I misread patch and my previous remark was wrong, as you put in rps_map
all possible cpu indexes, there is no hole in the array, so its size
is num_possible_cpus() indeed, sorry for the false alarm.

Now I wonder how this can handle cpu hotplug, I see nothing in your pat=
ch to transfert
packets ownership or  rps_map[] rebuilding in case a cpu is offlined...

