From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] NET: Fix /proc/net/arp for AX.25
Date: Sat, 11 Feb 2017 00:38:57 +0100
Message-ID: <20170210233857.GA13996@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Osterried <thomas@osterried.de>, linux-hams@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When sending ARP requests over AX.25 links the hwaddress in the neighbour
cache are not getting initialized.  For such an incomplete arp entry
ax2asc2 will generate an empty string resulting in /proc/net/arp output
like the following:

$ cat /proc/net/arp
IP address       HW type     Flags       HW address            Mask     Device
192.168.122.1    0x1         0x2         52:54:00:00:5d:5f     *        ens3
172.20.1.99      0x3         0x0              *        bpq0

The missing field will confuse the procfs parsing of arp(8) resulting in
incorrect output for the device such as the following:

$ arp
Address                  HWtype  HWaddress           Flags Mask            Iface
gateway                  ether   52:54:00:00:5d:5f   C                     ens3
172.20.1.99                      (incomplete)                              ens3

This changes the content of /proc/net/arp to:

$ cat /proc/net/arp
IP address       HW type     Flags       HW address            Mask     Device
172.20.1.99      0x3         0x0         *                     *        bpq0
192.168.122.1    0x1         0x2         52:54:00:00:5d:5f     *        ens3

To do so it change ax2asc to put the string "*" in buf for a NULL address
argument.  Finally the HW address field is left aligned in a 17 character
field (the length of an ethernet HW address in the usual hex notation) for
readability.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
---
 net/ipv4/arp.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 89a8cac4..51b27ae 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1263,7 +1263,7 @@ void __init arp_init(void)
 /*
  *	ax25 -> ASCII conversion
  */
-static char *ax2asc2(ax25_address *a, char *buf)
+static void ax2asc2(ax25_address *a, char *buf)
 {
 	char c, *s;
 	int n;
@@ -1285,10 +1285,10 @@ static char *ax2asc2(ax25_address *a, char *buf)
 	*s++ = n + '0';
 	*s++ = '\0';
 
-	if (*buf == '\0' || *buf == '-')
-		return "*";
-
-	return buf;
+	if (*buf == '\0' || *buf == '-') {
+		buf[0] = '*';
+		buf[1] = '\0';
+	}
 }
 #endif /* CONFIG_AX25 */
 
@@ -1322,7 +1322,7 @@ static void arp_format_neigh_entry(struct seq_file *seq,
 	}
 #endif
 	sprintf(tbuf, "%pI4", n->primary_key);
-	seq_printf(seq, "%-16s 0x%-10x0x%-10x%s     *        %s\n",
+	seq_printf(seq, "%-16s 0x%-10x0x%-10x%-17s     *        %s\n",
 		   tbuf, hatype, arp_state_to_flags(n), hbuffer, dev->name);
 	read_unlock(&n->lock);
 }
