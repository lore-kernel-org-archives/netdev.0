From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Sun, 18 Apr 2010 13:34:36 +0200
Message-ID: <1271590476.16881.4925.camel@edumazet-laptop>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi>
	 <20100415.014857.168270765.davem@davemloft.net>
	 <1271332528.4567.150.camel@bigi>  <4BC741AE.3000108@hp.com>
	 <1271362581.23780.12.camel@bigi>
	 <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <1271424065.4606.31.camel@bigi>
	 <1271489739.16881.4586.camel@edumazet-laptop>
	 <1271525519.3929.3.camel@bigi>
	 <1271583573.16881.4798.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:53726 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328Ab0DRLes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Apr 2010 07:34:48 -0400
Received: by bwz25 with SMTP id 25so4482169bwz.28
        for <netdev@vger.kernel.org>; Sun, 18 Apr 2010 04:34:45 -0700 (PDT)
In-Reply-To: <1271583573.16881.4798.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 18 avril 2010 =C3=A0 11:39 +0200, Eric Dumazet a =C3=A9crit=
 :
> No, only one packet per IPI, since I setup my tg3 coalescing paramete=
r
> to the minimum value, I received one packet per interrupt.
>=20
> The specific app is :
>=20
> for f in `seq 1 8`; do while :; do :; done& done
>=20

An other interesting user land app would be to use a cpu _and_ memory
cruncher, because of caches misses we'll get.

$ cat nloop.c
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define SZ 4*1024*1024

int main(int argc, char *argv[])
{
	int nproc =3D 8;
	char *buffer;

	if (argc > 1)
		nproc =3D atoi(argv[1]);
	while (nproc > 1) {
		if (fork() =3D=3D 0)
			break;
		nproc--;
	}
	buffer =3D malloc(SZ);
	while (1)
		memset(buffer, 0x55, SZ);
}

$ ./nloop 8 &

echo 00 >/sys/class/net/eth3/queues/rx-0/rps_cpus
4861ms

echo 01 >/sys/class/net/eth3/queues/rx-0/rps_cpus
4981ms

echo 02 >/sys/class/net/eth3/queues/rx-0/rps_cpus
7191ms

echo 04 >/sys/class/net/eth3/queues/rx-0/rps_cpus
7128ms

echo 08 >/sys/class/net/eth3/queues/rx-0/rps_cpus
7107ms

echo 10 >/sys/class/net/eth3/queues/rx-0/rps_cpus
5505ms

echo 20 >/sys/class/net/eth3/queues/rx-0/rps_cpus
7125ms

echo 40 >/sys/class/net/eth3/queues/rx-0/rps_cpus
7022ms

echo 80 >/sys/class/net/eth3/queues/rx-0/rps_cpus
7157ms


Maximum overhead is 7191-4861 =3D 23.3 us per packet



