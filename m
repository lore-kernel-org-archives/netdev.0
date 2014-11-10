From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: Face some error after applying commit 7dfa4b414d4(net/mlx4_en:
 Code cleanups in tx path)
Date: Mon, 10 Nov 2014 09:59:33 +0800
Message-ID: <20141110015933.GB6294@richard>
References: <20141108025758.GA13875@richard>
 <CANn89i+ekXHJSePzQ0rWx2KKqwYGTrok3-ZZ1RdEygVJcGDqRQ@mail.gmail.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>,
	Amir Vadai <amirv@mellanox.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:60155 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320AbaKJB7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2014 20:59:46 -0500
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 10 Nov 2014 11:59:39 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 41C4E357806F
	for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 12:59:36 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sAA1xP7v39911652
	for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 12:59:25 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sAA1xY1f010462
	for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 12:59:35 +1100
Content-Disposition: inline
In-Reply-To: <CANn89i+ekXHJSePzQ0rWx2KKqwYGTrok3-ZZ1RdEygVJcGDqRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 07, 2014 at 07:38:15PM -0800, Eric Dumazet wrote:
>On Fri, Nov 7, 2014 at 6:57 PM, Wei Yang <weiyang@linux.vnet.ibm.com> =
wrote:
>> Eric and Amir
>>
>> I am testing the VF on PowerNV platform with 3.18-rc2.
>> After applying this patch I face some errors.
>>
>> First is the compiling error.
>>
>>     drivers/net/ethernet/mellanox/mlx4//en_tx.c: In function =E2=80=98=
mlx4_en_xmit=E2=80=99:
>>     drivers/net/ethernet/mellanox/mlx4//en_tx.c:802:8: error: =E2=80=
=98shinfo=E2=80=99 undeclared (first use in this function)
>>             shinfo->tx_flags & SKBTX_HW_TSTAMP)) {
>>             ^
>>     include/linux/compiler.h:160:42: note: in definition of macro =E2=
=80=98unlikely=E2=80=99
>>      # define unlikely(x) __builtin_expect(!!(x), 0)
>>                                               ^
>>     drivers/net/ethernet/mellanox/mlx4//en_tx.c:802:8: note: each un=
declared identifier is reported only once for each function it appears =
in
>>             shinfo->tx_flags & SKBTX_HW_TSTAMP)) {
>>             ^
>>     include/linux/compiler.h:160:42: note: in definition of macro =E2=
=80=98unlikely=E2=80=99
>>      # define unlikely(x) __builtin_expect(!!(x), 0)
>>                                               ^
>>     make[1]: *** [drivers/net/ethernet/mellanox/mlx4//en_tx.o] Error=
 1
>>     make: *** [_module_drivers/net/ethernet/mellanox/mlx4/] Error 2
>>
>
>
>This compilation error seems strange.
>
>Are you sure your tree is pristine, not corrupted in any way ?

I believe I did the revert one by one with git revert.

>
>
>> I tried to fix this with following change:
>>
>>     [root@tian-lp1 3.18]# git diff
>>     diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/driver=
s/net/ethernet/m
>>     index eaf23eb..d2f06a7 100644
>>     --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>>     +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>>     @@ -799,8 +799,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb=
, struct net_dev
>>              * set flag for further reference
>>              */
>>             if (unlikely(ring->hwtstamp_tx_type =3D=3D HWTSTAMP_TX_O=
N &&
>>     -                    shinfo->tx_flags & SKBTX_HW_TSTAMP)) {
>>     -               shinfo->tx_flags |=3D SKBTX_IN_PROGRESS;
>>     +                    skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP=
)) {
>>     +               skb_shinfo(skb)->tx_flags |=3D SKBTX_IN_PROGRESS=
;
>>                     tx_info->ts_requested =3D 1;
>>             }
>>
>> But seems to face another error.
>>
>
>I suspect your tree is not the official tree, I do not see how you got
>this compilation error.


I checked the upstream git tree again, and find this commit:

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/=
?id=3D7dfa4b414d4eec8da56e44fb2b4aea3e549b092f


And I want to say the shinfo local variable is introduced in commit:

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/=
?id=3Db9d8839a44092cb4268ef2813c34d5dbf3363603

And in my log tree, also checked the upstream, this one is applyed afte=
r the
first one. And the compiling error will disappear untill I apply this o=
ne.

So this compiling issue can't reproduced at your side? You have reset -=
-hard
to the "Code cleanup" one, and can't see the error? That is strange.

--=20
Richard Yang
Help you, Help me
