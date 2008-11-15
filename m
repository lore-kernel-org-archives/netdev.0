From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [stable] [BUG] net: fix /proc/net/snmp as memory corruptor
Date: Sat, 15 Nov 2008 09:37:27 +0100
Message-ID: <491E8A47.1090007@cosmosbay.com>
References: <491D07E0.9010903@cosmosbay.com> <20081115051015.GB26468@kroah.com> <491E5D4D.1080800@cosmosbay.com> <20081115060237.GA3910@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010709040606020202000607"
Cc: stable@kernel.org, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:58622 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753408AbYKOIhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2008 03:37:40 -0500
In-Reply-To: <20081115060237.GA3910@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010709040606020202000607
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Greg KH a =E9crit :
> On Sat, Nov 15, 2008 at 06:25:33AM +0100, Eric Dumazet wrote:
>> Greg KH a =E9crit :
>>> On Fri, Nov 14, 2008 at 06:08:48AM +0100, Eric Dumazet wrote:
>>>> Hello Greg
>>>>
>>>> A patch was submited about /proc/net/snmp being a memory corruptor a=
nd=20
>>>> not SMP safe
>>>>
>>>> (commit b971e7ac834e9f4bda96d5a96ae9abccd01c1dd8)
>>>>
>>>> These bugs are present on 2.6.26 & 2.6.27.
>>> I looking at this, it doesn't seem to apply at all to the .27 tree.  =
If
>>> David doesn't object, care to backport it there and send it to
>>> stable@kernel.org?
>> Strange... I just tried to apply patch on top of a fresh linux-2.6.27.=
6=20
>> tree and got no error
>>
>> # patch -p1 < /tmp/icmp_snmp.patch
>> patching file net/ipv4/proc.c
>> #
>=20
> I've attached the patch I tried to apply below.  It fails with:
> 	$ patch -p1 --dry-run < ../net-fix-proc-net-snmp-as-memory-corruptor.p=
atch=20
> 	patching file net/ipv4/proc.c
> 	Hunk #1 FAILED at 237.
> 	1 out of 1 hunk FAILED -- saving rejects to file net/ipv4/proc.c.rej
>=20
>=20
> Any thoughts?
>=20
> thanks,
>=20
> greg k-h
>=20

Yes, you lost all the '\' character in "\n" sequences...=20
Also one missing ":" at the end of one line

I dont know how you did it :)

Here is the (manually) corrected file=20

--------------010709040606020202000607
Content-Type: text/plain;
 name="p.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="p.patch"

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 10 Nov 2008 21:43:08 -0800
Subject: net: fix /proc/net/snmp as memory corruptor

From: Eric Dumazet <dada1@cosmosbay.com>

commit b971e7ac834e9f4bda96d5a96ae9abccd01c1dd8 upstream.

icmpmsg_put() can happily corrupt kernel memory, using a static
table and forgetting to reset an array index in a loop.

Remove the static array since its not safe without proper locking.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

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

--------------010709040606020202000607--
