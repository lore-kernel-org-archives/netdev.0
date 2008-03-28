From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH net-2.6.26 1/5][SOCK]: Enumerate struct proto-s to facilitate
 percpu inuse accounting.
Date: Fri, 28 Mar 2008 13:17:57 +0300
Message-ID: <47ECC5D5.4040208@openvz.org>
References: <47ECB362.5050104@openvz.org> <47ECBDDB.2040203@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:48014 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752696AbYC1KSA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 06:18:00 -0400
In-Reply-To: <47ECBDDB.2040203@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Pavel Emelyanov a =E9crit :
>> This add the inuse_idx to struct proto and generates one in proto_re=
gister.
>> The ++ in generator is protected with write-locked proto_list_lock.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>>
>> ---
>>  include/net/sock.h |    1 +
>>  net/core/sock.c    |   10 ++++++++++
>>  2 files changed, 11 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/net/sock.h b/include/net/sock.h
>> index 1c9d059..abc6341 100644
>> --- a/include/net/sock.h
>> +++ b/include/net/sock.h
>> @@ -562,6 +562,7 @@ struct proto {
>> =20
>>  	/* Keeping track of sockets in use */
>>  #ifdef CONFIG_PROC_FS
>> +	unsigned int		inuse_idx;
>>  	struct pcounter		inuse;
>>  #endif
>> =20
>> diff --git a/net/core/sock.c b/net/core/sock.c
>> index 3ee9506..a7faf30 100644
>> --- a/net/core/sock.c
>> +++ b/net/core/sock.c
>> @@ -1940,6 +1940,15 @@ EXPORT_SYMBOL(sk_common_release);
>>  static DEFINE_RWLOCK(proto_list_lock);
>>  static LIST_HEAD(proto_list);
>> =20
>> +static void assign_proto_idx(struct proto *prot)
>> +{
>> +#ifdef CONFIG_PROC_FS
>> +	static unsigned int idx =3D 0;
>> +
>>  =20
> I believe some protocols can be registered, then unregistered, then=20
> re-registered (module loads, unloads, ...)

Well yes :) I found this soon after I'd sent this set.
If you don't have other objections I'll send the v2 do Dave.

> So you probably want to use a bitmap instead of a counter that will=20
> eventually reach PROTO_INUSE_NR
>=20
> assign_proto_idx() should find a zero bit, and you should free this b=
it=20
> at proto_unregister() time
>=20
>> +	prot->inuse_idx =3D idx++;
>> +#endif
>> +}
>> +
>>  int proto_register(struct proto *prot, int alloc_slab)
>>  {
>>  	char *request_sock_slab_name =3D NULL;
>> @@ -2000,6 +2009,7 @@ int proto_register(struct proto *prot, int all=
oc_slab)
>> =20
>>  	write_lock(&proto_list_lock);
>>  	list_add(&prot->node, &proto_list);
>> +	assign_proto_idx(prot);
>>  	write_unlock(&proto_list_lock);
>>  	return 0;
>> =20
>>  =20
>=20
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

