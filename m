From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Thu, 07 Feb 2008 10:40:19 +0100
Message-ID: <47AAD203.4030706@cosmosbay.com>
References: <20080206091353.GA12927@2ka.mipt.ru> <47a9fb13.01538c0a.3b80.ffff9328@mx.google.com> <20080207072415.GA13782@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090303070208040600000509"
Cc: Glenn Griffin <ggriffin.kernel@gmail.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp28.orange.fr ([80.12.242.99]:13877 "EHLO smtp28.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753130AbYBGJki (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2008 04:40:38 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2802.orange.fr (SMTP Server) with ESMTP id DE52D800181C
	for <netdev@vger.kernel.org>; Thu,  7 Feb 2008 10:40:35 +0100 (CET)
In-Reply-To: <20080207072415.GA13782@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090303070208040600000509
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Evgeniy Polyakov a =E9crit :
> On Wed, Feb 06, 2008 at 10:30:24AM -0800, Glenn Griffin (ggriffin.kerne=
l@gmail.com) wrote:
>  =20
>>>> +static u32 cookie_hash(struct in6_addr *saddr, struct in6_addr *dad=
dr,
>>>> +		       __be16 sport, __be16 dport, u32 count, int c)
>>>> +{
>>>> +	__u32 tmp[16 + 5 + SHA_WORKSPACE_WORDS];
>>>>        =20
>>> This huge buffer should not be allocated on stack.
>>>      =20
>> I can replace it will a kmalloc, but for my benefit what's the practic=
al
>> size we try and limit the stack to?  It seemed at first glance to me
>> that 404 bytes plus the arguments, etc. was not such a large buffer fo=
r
>> a non-recursive function.  Plus the alternative with a kmalloc require=
s
>>    =20
>
> Well, maybe for connection establishment path it is not, but it is
> absolutely the case in the sending and sometimes receiving pathes for 4=
k
> stacks. The main problem is that bugs which happen because of stack
> overflow are so much obscure, that it is virtually impossible to detect=

> where overflow happend. 'Debug stack overflow' somehow does not help to=

> detect it.
>
> Usually there is about 1-1.5 kb of free stack for each process, so this=

> change will cut one third of the free stack, getting into account that
> something can store ipv6 addresses on stack too, this can end up badly.=

>
>  =20
>> propogating the possible error status back up to tcp_ipv6.c in the eve=
nt
>> we are unable to allocate enough memory, so it can simply drop the
>> connection.  Not an impossible task by any means but it does
>> significantly complicate things and I would like to know it's worth th=
e
>> effort.  Also would it be worth it to provide a supplemental patch for=

>> the ipv4 implementation as it allocates the same buffer?
>>    =20
>
> One can reorganize syncookie support to work with request hash tables
> too, so that we could allocate per hash-bucket space and use it as a
> scratchpad for cookies.
>
>  =20
Or maybe use percpu storage for that...

I am not sure if cookie_hash() is always called with preemption disabled.=

(If not, we have to use get_cpu_var()/put_cpu_var())

[NET] IPV4: lower stack usage in cookie_hash() function

400 bytes allocated on stack might be a litle bit too much. Using a=20
per_cpu var is more friendly.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>



--------------090303070208040600000509
Content-Type: text/plain;
 name="cookie_scratch.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="cookie_scratch.patch"

diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index f470fe4..177da14 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -35,10 +35,12 @@ module_init(init_syncookies);
 #define COOKIEBITS 24	/* Upper bits store count */
 #define COOKIEMASK (((__u32)1 << COOKIEBITS) - 1)
 
+static DEFINE_PER_CPU(__u32, cookie_scratch)[16 + 5 + SHA_WORKSPACE_WORDS];
+
 static u32 cookie_hash(__be32 saddr, __be32 daddr, __be16 sport, __be16 dport,
 		       u32 count, int c)
 {
-	__u32 tmp[16 + 5 + SHA_WORKSPACE_WORDS];
+	__u32 *tmp = __get_cpu_var(cookie_scratch);
 
 	memcpy(tmp + 3, syncookie_secret[c], sizeof(syncookie_secret[c]));
 	tmp[0] = (__force u32)saddr;

--------------090303070208040600000509--


