From: "Carlos R. Mafra" <crmafra@gmail.com>
Subject: /proc/net/dev regression
Date: Sat, 10 Jan 2015 23:25:18 +0000
Message-ID: <20150110232518.GA3212@linux-g29b.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I use a dockapp called 'wmnet' [1] to monitor the speed of
my internet connection and after the kernel v3.18 it does no
longer work properly (it still doesn't work in v3.19-rc3)

I bisected the problem and the culprit is this commit:

commit 6e094bd805a9b6ad2f5421125db8f604a166616c
Author: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
Date:   Fri Sep 5 00:18:48 2014 +0200

    bcma: move code for core registration into separate function
   =20
    This cleans code a bit and will us to register cores in other place=
s as
    well. The only difference with this patch is using "core_index" for
    setting device name.
   =20
   =20
The problem is caused by the different name that my wireless connection
receives after this patch:

wlp3s0b1 (after the patch)
wlp3s0   (before the patch)

because it affects the display of information in the file /proc/net/dev=
=2E

Before the patch the fields are all aligned:

[mafra@linux-g29b:wmnet]$ cat net_dev_good.txt
Inter-|   Receive                                                |  Tra=
nsmit
 face |bytes    packets errs drop fifo frame compressed multicast|bytes=
    packets errs drop fifo colls carrier compressed
    lo:   35916     332    0    0    0     0          0         0    35=
916     332    0    0    0     0       0          0
wlp3s0: 6406428    5794    0    0    0     0          0         0   426=
813    3778    0    0    0     0       0          0

but after the patch the fields are misaligned:

[mafra@linux-g29b:wmnet]$ cat net_dev_bad.txt
Inter-|   Receive                                                |  Tra=
nsmit
 face |bytes    packets errs drop fifo frame compressed multicast|bytes=
    packets errs drop fifo colls carrier compressed
    lo:     600       8    0    0    0     0          0         0      =
600       8    0    0    0     0       0          0
wlp3s0b1: 9266848    7298    0    0    0     0          0         0   3=
72229    4030    0    0    0     0       0          0

And for some reason this change confuses 'wmnet'. Reading the source co=
de
of 'wmnet' I found that it reads the packets as follows,

	totalpackets_in =3D strtoul(&buffer[15], NULL, 10);

I am not sure if 'wmnet' could do this better (any suggestions?),
but the fact is that it was working before and now it is not.

Any help is greatly appreciated.

[1] wmnet can be found in http://repo.or.cz/w/dockapps.git
