From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next v3] lib/rhashtable: allow user to set the minimum
 shifts of shrinking
Date: Mon, 1 Sep 2014 17:28:37 +0800
Message-ID: <54043C45.7090005@windriver.com>
References: <1409381306-7036-1-git-send-email-ying.xue@windriver.com> <20140901090302.GB27933@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:60805 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbaIAJ3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 05:29:16 -0400
In-Reply-To: <20140901090302.GB27933@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2014 05:03 PM, Thomas Graf wrote:
> On 08/30/14 at 02:48pm, Ying Xue wrote:
>> Although rhashtable library allows user to specify a quiet big size
>> for user's created hash table, the table may be shrunk to a
>> very small size - HASH_MIN_SIZE(4) after object is removed from
>> the table at the first time. Subsequently, even if the total amount
>> of objects saved in the table is quite lower than user's initial
>> setting in a long time, the hash table size is still dynamically
>> adjusted by rhashtable_shrink() or rhashtable_expand() each time
>> object is inserted or removed from the table. However, as
>> synchronize_rcu() has to be called when table is shrunk or
>> expanded by the two functions, we should permit user to set the
>> minimum table size through configuring the minimum number of shifts
>> according to user specific requirement, avoiding these expensive
>> actions of shrinking or expanding because of calling synchronize_rcu=
().
>>
>> Signed-off-by: Ying Xue <ying.xue@windriver.com>
>=20
> I see the following warning when compiling:
>=20
> In file included from lib/rhashtable.c:17:0:
> lib/rhashtable.c: In function =E2=80=98rhashtable_init=E2=80=99:
> include/linux/kernel.h:715:17: warning: comparison of distinct pointe=
r types lacks a cast [enabled by default]
>   (void) (&_max1 =3D=3D &_max2);  \
>                  ^
> lib/rhashtable.c:570:22: note: in expansion of macro =E2=80=98max=E2=80=
=99
>   params->min_shift =3D max(params->min_shift, ilog2(HASH_MIN_SIZE));
>=20
>=20

Thanks for your check.

After I made below change, the compiling warning disappears.

+       params->min_shift =3D max(params->min_shift,
+                               (size_t)ilog2(HASH_MIN_SIZE));
+

But when I check the patch format with scripts/checkpatch.pl, below
warning occurs:

=2E/scripts/checkpatch.pl
0001-lib-rhashtable-allow-user-to-set-the-minimum-shifts-.patch
WARNING: max() should probably be max_t(size_t, params->min_shift,
ilog2(HASH_MIN_SIZE))
#77: FILE: lib/rhashtable.c:570:
+	params->min_shift =3D max(params->min_shift,
 				(size_t)ilog2(HASH_MIN_SIZE));

total: 0 errors, 1 warnings, 46 lines checked

0001-lib-rhashtable-allow-user-to-set-the-minimum-shifts-.patch has
style problems, please review.

Do you think it's worth replacing max() macro with max_t() regarding
above suggestion?

By the way, if the replacement should do, all max() macro in the
lib/rhashtable.c should be replaced as well.

Thanks,
Ying
