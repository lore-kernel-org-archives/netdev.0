From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 1/2] udp: introduce struct udp_table and multiple rwlocks
Date: Tue, 28 Oct 2008 22:48:34 +0100
Message-ID: <490788B2.1060301@cosmosbay.com>
References: <20081007160729.60c076c4@speedy>	<20081007.135548.56141000.davem@davemloft.net>	<48ECBBD8.9060602@cosmosbay.com> <20081008.114527.189056050.davem@davemloft.net> <4907780F.1080808@cosmosbay.com> <B7C6414D-7A69-48DA-8424-5D9F5FC50338@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Christian Bell <christian@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:39517 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751595AbYJ1Vss convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 17:48:48 -0400
In-Reply-To: <B7C6414D-7A69-48DA-8424-5D9F5FC50338@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christian Bell a =E9crit :
>=20
> On Oct 28, 2008, at 1:37 PM, Eric Dumazet wrote:
>=20
>> -extern struct hlist_head udp_hash[UDP_HTABLE_SIZE];
>> -extern rwlock_t udp_hash_lock;
>> +struct udp_hslot {
>> +    struct hlist_head    head;
>> +    rwlock_t        lock;
>> +};
>=20
> This structure should be aligned up to cacheline to reduce false shar=
ing=20
> of more than one hslot.


Yes, I though about that. But : a full cache line is a waste of memory,=
 and
choosing a power of two alignement is not easy because of 32bit/64bit a=
rches,
and fact that sozepf(wrlock_t) can be > 4 if DEBUG

>=20
>> +    } else {
>> +        hslot =3D &udptable->hash[udp_hashfn(net, snum)];
>> +        write_lock_bh(&hslot->lock);
>> +        if (udp_lib_lport_inuse(net, snum, hslot, sk, saddr_comp))
>> +            goto fail;
>=20
> The fail: label below should still unlock_bh when the above condition=
=20
> fails.
>=20
>>
>> +    }
>>     inet_sk(sk)->num =3D snum;
>>     sk->sk_hash =3D snum;
>>     if (sk_unhashed(sk)) {
>> -        sk_add_node(sk, &udptable[udp_hashfn(net, snum)]);
>> +        sk_add_node(sk, &hslot->head);
>>         sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
>>     }
>> +    write_unlock_bh(&hslot->lock);
>>     error =3D 0;
>> fail:
>> -    write_unlock_bh(&udp_hash_lock);
>>     return error;
>> }

Good spoting, the write_unlock_bh(&hslot->lock); must be moved after th=
e "fail:" label.

Thanks a lot


