From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: fix /proc/net/snmp as memory corruptor
Date: Sat, 08 Nov 2008 06:53:31 +0100
Message-ID: <4915295B.4050102@cosmosbay.com>
References: <20081108002208.GB17721@alice> <20081108010237.GA7062@x200.localdomain> <20081108025256.GA16001@x200.localdomain> <20081108033618.GA27960@x200.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030102000201020101090005"
Cc: Eric Sesterhenn <snakebyte@gmx.de>, davem@davemloft.net,
	netdev@vger.kernel.org, alan@lxorguk.ukuu.org.uk
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:43157 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750948AbYKHFx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Nov 2008 00:53:56 -0500
In-Reply-To: <20081108033618.GA27960@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030102000201020101090005
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Alexey Dobriyan a =E9crit :
> On Sat, Nov 08, 2008 at 05:52:56AM +0300, Alexey Dobriyan wrote:
>> On Sat, Nov 08, 2008 at 04:02:37AM +0300, Alexey Dobriyan wrote:
>>> On Sat, Nov 08, 2008 at 01:22:08AM +0100, Eric Sesterhenn wrote:
>>>> running a bunch of network related stresstests (isic, isicng, ...)=20
>>>> and trying to read all files in /proc afterwards gave me two
>>>> oopses. I was able to reproduce them on another box with
>>>> a different config. I was able to reproduce this on 2.6.24 too,
>>>> so this is no regression. The icmpsic is version 0.06.=20
>>>> The minimal testcase to trigger this:
>>>>
>>>> ------------8<----------------
>>>> #!/bin/bash
>>>>
>>>> icmpsic -s 127.0.0.1 -d 127.0.0.1 -p 100000
>>>>
>>>> find /proc/net/ | xargs cat > /dev/null
>>>>
>>>> cat /proc/net/ip_mr_cache
>>>> cat /proc/net/ip_mr_vif
>>>> ------------8<----------------
>>>>
>>>>
>>>> root@computer-desktop:~/testing# cat /proc/338/net/ip_mr_cache
>>>>
>>>> [ 1572.702100] BUG: unable to handle kernel NULL pointer dereference=
at 000001c1
>>>> [ 1572.702588] IP: [<c05942c6>] ipmr_mfc_seq_show+0x26/0xf0
>>> Reproduced.
>> 	icmpsic -s 127.0.0.1 -d 127.0.0.1 -p 100000
>> 	cat /proc/net/snmp				# sic
>> 	cat /proc/net/ip_mr_cache
>>
>> mfc_cache_array is full of small integers
>>
>> 	[0] =3D 0x1a8
>> 	[1] =3D 0x1a9
>>
>> and so on.
>=20
> OK, this minimally fixes mfc_cache_array corruption.
>=20
> Someone was scared of 16 integers on stack. :^)

Good spot Alexey :)

This should be fixed as well, or multiple threads reading /proc/net/snmp
could get mixed results without proper locking.

ICMPMSG_MIB_MAX being 512, "int" can also be changed to "short",
so that "short out[PERLINE]" only use 32 bytes on stack.=20

Frankly, snmp_fold_field() results should be cached in a local array too,=

because this function can be expensive if machine has a lot of cpus.

Is 128 + 32 bytes on stack considered evil ?
Using a lock here sounds overkill, and dynamic allocation overkill too...=


[PATCH] net: fix /proc/net/snmp as memory corruptor

icmpmsg_put() can happily corrupt kernel memory, using a static
table and forgetting to reset an array index in a loop.

Remove the static array since its not safe without proper locking.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 net/ipv4/proc.c |   58 +++++++++++++++++++++++-----------------------
 1 files changed, 30 insertions(+), 28 deletions(-)


--------------030102000201020101090005
Content-Type: text/plain;
 name="icmp_snmp.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="icmp_snmp.patch"

diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 8f5a403..a631a1f 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -237,43 +237,45 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_SENTINEL
 };
 
+static void icmpmsg_put_line(struct seq_file *seq, unsigned long *vals,
+			     unsigned short *type, int count)
+{
+	int j;
+
+	if (count) {
+		seq_printf(seq, "\nIcmpMsg:");
+		for (j = 0; j < count; ++j)
+			seq_printf(seq, " %sType%u",
+				type[j] & 0x100 ? "Out" : "In",
+				type[j] & 0xff);
+		seq_printf(seq, "\nIcmpMsg:");
+		for (j = 0; j < count; ++j)
+			seq_printf(seq, " %lu", vals[j]);
+	}
+}
+
 static void icmpmsg_put(struct seq_file *seq)
 {
 #define PERLINE	16
 
-	int j, i, count;
-	static int out[PERLINE];
+	int i, count;
+	unsigned short type[PERLINE];
+	unsigned long vals[PERLINE], val;
 	struct net *net = seq->private;
 
 	count = 0;
 	for (i = 0; i < ICMPMSG_MIB_MAX; i++) {
-
-		if (snmp_fold_field((void **) net->mib.icmpmsg_statistics, i))
-			out[count++] = i;
-		if (count < PERLINE)
-			continue;
-
-		seq_printf(seq, "\nIcmpMsg:");
-		for (j = 0; j < PERLINE; ++j)
-			seq_printf(seq, " %sType%u", i & 0x100 ? "Out" : "In",
-					i & 0xff);
-		seq_printf(seq, "\nIcmpMsg: ");
-		for (j = 0; j < PERLINE; ++j)
-			seq_printf(seq, " %lu",
-				snmp_fold_field((void **) net->mib.icmpmsg_statistics,
-				out[j]));
-		seq_putc(seq, '\n');
-	}
-	if (count) {
-		seq_printf(seq, "\nIcmpMsg:");
-		for (j = 0; j < count; ++j)
-			seq_printf(seq, " %sType%u", out[j] & 0x100 ? "Out" :
-				"In", out[j] & 0xff);
-		seq_printf(seq, "\nIcmpMsg:");
-		for (j = 0; j < count; ++j)
-			seq_printf(seq, " %lu", snmp_fold_field((void **)
-				net->mib.icmpmsg_statistics, out[j]));
+		val = snmp_fold_field((void **) net->mib.icmpmsg_statistics, i);
+		if (val) {
+			type[count] = i;
+			vals[count++] = val;
+		}
+		if (count == PERLINE) {
+			icmpmsg_put_line(seq, vals, type, count);
+			count = 0;
+		}
 	}
+	icmpmsg_put_line(seq, vals, type, count);
 
 #undef PERLINE
 }

--------------030102000201020101090005--
