From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFT 3/3] iptables: lock free counters
Date: Mon, 09 Feb 2009 16:52:59 +0100
Message-ID: <4990515B.3070409@trash.net>
References: <20090204001202.724266235@vyatta.com> <20090204001755.808036408@vyatta.com> <4989071E.5000803@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57928 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754633AbZBIPxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 10:53:03 -0500
In-Reply-To: <4989071E.5000803@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Stephen Hemminger a =E9crit :
>> @@ -939,14 +973,30 @@ static struct xt_counters * alloc_counte
>>  	counters =3D vmalloc_node(countersize, numa_node_id());
>> =20
>>  	if (counters =3D=3D NULL)
>> -		return ERR_PTR(-ENOMEM);
>> +		goto nomem;
>> +
>> +	tmp =3D xt_alloc_table_info(private->size);
>> +	if (!tmp)
>> +		goto free_counters;
>> +
>=20
>> +	xt_zero_table_entries(tmp);
> This is not correct. We must copy rules and zero counters on the copi=
ed stuff.

Indeed.

>>  static int
>>  do_add_counters(struct net *net, void __user *user, unsigned int le=
n, int compat)
>> @@ -1393,13 +1422,14 @@ do_add_counters(struct net *net, void __
>>  		goto free;
>>  	}
>> =20
>> -	write_lock_bh(&t->lock);
>> +	mutex_lock(&t->lock);
>>  	private =3D t->private;
>>  	if (private->number !=3D num_counters) {
>>  		ret =3D -EINVAL;
>>  		goto unlock_up_free;
>>  	}
>> =20
>> +	preempt_disable();
>>  	i =3D 0;
>>  	/* Choose the copy that is on our node */

This isn't actually necessary, its merely an optimization. Since this
can take quite a while, it might be nicer not to disable preempt.
