From: =?UTF-8?B?QXVyw6lsaWVuIENoYXJib24=?=
	<aurelien.charbon@ext.bull.net>
Subject: Re: [PATCH 1/1] NFS: change the ip_map cache code to handle IPv6
 addresses
Date: Thu, 09 Aug 2007 17:08:49 +0200
Message-ID: <46BB2E01.2010406@ext.bull.net>
References: <46BAC0B9.1020207@ext.bull.net> <46BB05B6.5080301@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mailing list NFSv4 <nfsv4@linux-nfs.org>,
	netdev ML <netdev@vger.kernel.org>, Neil Brown <neilb@suse.de>
To: chuck.lever@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:32817 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936423AbXHIPHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 11:07:38 -0400
In-Reply-To: <46BB05B6.5080301@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for these comments.

Chuck Lever wrote:

> Some naive questions:
>
> 1.  If IPv6 support is not configured into the kernel, how does an=20
> IPv6-only cache work?

Yes it should work.
The INET6 structures are only used as containers for both type of addre=
ss.
I have tested by unabling IPv6 options in the .config file.

>
> 2.  I seem to recall (only quite vaguely) that at some point the=20
> server might need to use one of the stored addresses to, say, open a=20
> socket to the client?  In that case, on a system with NICs configured=
=20
> only with IPv4, is the cached IPv6 address properly converted back to=
=20
> IPv4 somehow?

Yes. we can do that by testing the format of the address, as we know=20
that an IPv4 address is mapped like that:
[00000000] [00000000] [0000FFFF] <32 bits of IPv4 addr>

> Can the cache code tell the difference between a cached IPv6 address=20
> that was converted from IPv4 and one that was added to the cache as=20
> IPv6?  Sorry I can't remember more clearly.

Yes. If the address starts with ::FFFF, we can infer that is a mapped=20
IPv4 address.

>
> 3.  Would it be better to make the m_addr field a struct sockaddr,=20
> store a whole address (with address family), and switch on the=20
> sa_family field?

That is possible but we're able to retrieve the family of the address b=
y=20
testing its format (IPv4 mapped or not).
But I don't know if it is a better solution.

>
>
>> diff -u -r -N linux-2.6.23-rc1/fs/nfsd/export.c=20
>> linux-2.6.23-rc1-IPv6-ip_map/fs/nfsd/export.c
>> --- linux-2.6.23-rc1/fs/nfsd/export.c    2007-08-08=20
>> 17:52:58.000000000 +0200
>> +++ linux-2.6.23-rc1-IPv6-ip_map/fs/nfsd/export.c    2007-08-08=20
>> 17:49:09.000000000 +0200
>> @@ -1558,6 +1558,7 @@
>>  {
>>      struct auth_domain    *dom;
>>      int            i, err;
>> +    struct in6_addr addr6;
>> =20
>>      /* First, consistency check. */
>>      err =3D -EINVAL;
>> @@ -1576,9 +1577,14 @@
>>          goto out_unlock;
>> =20
>>      /* Insert client into hashtable. */
>> -    for (i =3D 0; i < ncp->cl_naddr; i++)
>> -        auth_unix_add_addr(ncp->cl_addrlist[i], dom);
>> -
>> +    for (i =3D 0; i < ncp->cl_naddr; i++) {
>> +        /* Mapping address */
>> +            addr6.s6_addr32[0] =3D 0;
>> +            addr6.s6_addr32[1] =3D 0;
>> +            addr6.s6_addr32[2] =3D htonl(0xffff);
>> +            addr6.s6_addr32[3] =3D (uint32_t)ncp->cl_addrlist[i].s_=
addr;
>> +        auth_unix_add_addr(addr6, dom);
>> +    }
>>      auth_unix_forget_old(dom);
>>      auth_domain_put(dom);
>
>
> This converts IPv4 addresses to canonical IPv6 as it stores them. =20
> What happens if a full-blown IPv6 address is encountered?  Likewise,=20
> in nfsctl.c?

I have done this kind of convertion only for compilation an testing wit=
h=20
only IPv4... For the moment.

>
>> @@ -112,12 +112,16 @@
>>      return (hash ^ (hash>>8)) & 0xff;
>>  }
>>  #endif
>> +static inline int hash_ip6(struct in6_addr ip)
>> +{
>> +        return (hash_ip(ip.s6_addr32[0]) ^ hash_ip(ip.s6_addr32[1])=
=20
>> ^ hash_ip(ip.s6_addr32[2]) ^ hash_ip(ip.s6_addr32[3])) ;
>> +}
>
>
> How have you tested the effectiveness of the new hash function?

I have not tested that point but I can easily imagine there are better=20
solutions.
Perhaps we can keep the same function for an IPv4 address (only taking=20
the 32 bits of IPv4 addr), and then design one for IPv6 addresses.

Do you have any suggestion on that ?

>> -    seq_printf(m, "%s %d.%d.%d.%d %s\n",
>> +    seq_printf(m, "%s %04x.%04x.%04x.%04x.%04x.%04x.%04x.%04x %s\n"=
,
>>             im->m_class,
>> -           ntohl(addr.s_addr) >> 24 & 0xff,
>> -           ntohl(addr.s_addr) >> 16 & 0xff,
>> -           ntohl(addr.s_addr) >>  8 & 0xff,
>> -           ntohl(addr.s_addr) >>  0 & 0xff,
>> +           ntohl(addr.s6_addr32[3]) >> 16 & 0xffff,
>> +           ntohl(addr.s6_addr32[3]) & 0xffff,
>> +           ntohl(addr.s6_addr32[2]) >> 16 & 0xffff,
>> +           ntohl(addr.s6_addr32[2]) & 0xffff,
>> +           ntohl(addr.s6_addr32[1]) >> 16 & 0xffff,
>> +           ntohl(addr.s6_addr32[1]) & 0xffff,
>> +           ntohl(addr.s6_addr32[0]) >> 16 & 0xffff,
>> +           ntohl(addr.s6_addr32[0]) & 0xffff,
>>             dom
>>             );
>>      return 0;
>
>
> And I think here NIP6_FMT should be used, but you're not using colons=
=20
> between the hex digits.  Was that intentional
> ?

No that's a mistake. Colons have to be used here.

Aur=C3=A9lien

--=20

********************************
       Aurelien Charbon
       Linux NFSv4 team
           Bull SAS
     Echirolles - France
http://nfsv4.bullopensource.org/
********************************

