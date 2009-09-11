From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: iproute2 tools for 2.6.31
Date: Fri, 11 Sep 2009 09:48:07 +0200
Message-ID: <4AAA00B7.9030904@gmail.com>
References: <20090910120416.6fd03d1f@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37786 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753925AbZIKHsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 03:48:06 -0400
In-Reply-To: <20090910120416.6fd03d1f@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> I am putting together release for 2.6.31 based tools.
> The only open issue is how to deal with the error handling in command=
s
> that do monitoring filtering.  Right now leaning towards the two sock=
et
> solution.
>=20
> So if you have anything else that you have been waiting for,
> please drop me a note.
>

One thing that is IMHO strange is the output of sk information=20
on 64 bits (x86_64 for example)

# ss -e dst 55.225.18.6
State      Recv-Q Send-Q                                Local Address:P=
ort                                    Peer Address:Port
ESTAB      0      0                                      55.225.18.96:9=
273                                     55.225.18.6:37405    timer:(kee=
palive,20min,0) ino:57807651 sk:36e40c80ffff8100

True sk pointer is ffff8100ffff8100, not 36e40c80ffff8100



ss/misc.c

                printf(" sk:%08x", r->id.idiag_cookie[0]);
                if (r->id.idiag_cookie[1] !=3D 0)
                        printf("%08x", r->id.idiag_cookie[1]);

while kernel does :
        r->id.idiag_cookie[0] =3D (u32)(unsigned long)sk;
        r->id.idiag_cookie[1] =3D (u32)(((unsigned long)sk >> 31) >> 1)=
;



What do you think of following patch ?

[PATCH] ss: correct display of sk pointer

On 64bit arches, sk pointer was 32/32 reversed.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/misc/ss.c b/misc/ss.c
index 651fe3b..2447186 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1393,9 +1393,10 @@ static int tcp_show_sock(struct nlmsghdr *nlh, s=
truct filter *f)
 		if (r->idiag_uid)
 			printf(" uid:%u", (unsigned)r->idiag_uid);
 		printf(" ino:%u", r->idiag_inode);
-		printf(" sk:%08x", r->id.idiag_cookie[0]);
+		printf(" sk:");
 		if (r->id.idiag_cookie[1] !=3D 0)
 			printf("%08x", r->id.idiag_cookie[1]);
+ 		printf("%08x", r->id.idiag_cookie[0]);
 	}
 	if (show_mem || show_tcpinfo) {
 		printf("\n\t");


