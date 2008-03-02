From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [PATCH (resend)][EBTABLES]: Fix alignment checks in
	ebt_among.ko module.
Date: Sun, 02 Mar 2008 16:12:53 +0100
Message-ID: <1204470773.2919.9.camel@localhost.localdomain>
References: <47C7C23C.2050100@openvz.org>  <47C7FF31.1060108@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-8cX1W5m8JXg4/FCX8M1V"
Cc: Pavel Emelyanov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47C7FF31.1060108@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-8cX1W5m8JXg4/FCX8M1V
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Op vr, 29-02-2008 te 13:48 +0100, schreef Patrick McHardy:
> Pavel Emelyanov wrote:
> > I've sent this patch some days ago to Bart, but with no answer...

Sorry about that.

> > 
> > When trying to do
> > 
> > 	# ebtables -A FORWARD --among-src 0:12:34:56:78:9a=192.168.0.10 -j ACCEPT
> > 
> > on x86_64 box the ebt_among->check() callback warns me that
> > 
> > 	ebtables: among: wrong size: 1060 against expected 1056, rounded to 1056
> > 
> > So the suggested fix is to move the alignment in the kernel. After
> > the fix the rule is added and appears in the ebtables -L output.
> 
> 
> It seems the kernel is correct and userspace is doing it
> wrong, so I think userspace should be fixed instead.
> The problem with your patch is that is causes misalignment
> for following structures that contain u64 members.

Pavel, please try the attached userspace patch to see if it fixes the
problem (and let me know the result).

cheers,
Bart


--=-8cX1W5m8JXg4/FCX8M1V
Content-Disposition: attachment; filename=among64.diff
Content-Type: text/x-patch; name=among64.diff; charset=utf-8
Content-Transfer-Encoding: 7bit

--- ebtables-v2.0.8-2/extensions/ebt_among.c.old	2008-03-02 16:08:13.000000000 +0100
+++ ebtables-v2.0.8-2/extensions/ebt_among.c	2008-03-02 16:06:55.000000000 +0100
@@ -68,6 +68,7 @@ static void print_help()
 " 00:00:00:fa:eb:fe=153.19.120.250,00:00:00:fa:eb:fe=192.168.0.1\n"
 	);
 }
+static int old_size;
 
 static void init(struct ebt_entry_match *match)
 {
@@ -75,6 +76,7 @@ static void init(struct ebt_entry_match 
 	    (struct ebt_among_info *) match->data;
 
 	memset(amonginfo, 0, sizeof(struct ebt_among_info));
+	old_size = sizeof(struct ebt_among_info);
 }
 
 static struct ebt_mac_wormhash *new_wormhash(int n)
@@ -308,7 +310,7 @@ static int parse(int c, char **argv, int
 	    (struct ebt_among_info *) (*match)->data;
 	struct ebt_mac_wormhash *wh;
 	struct ebt_entry_match *h;
-	int new_size, old_size;
+	int new_size;
 	long flen;
 	int fd;
 
@@ -354,21 +356,23 @@ static int parse(int c, char **argv, int
 		if (ebt_errormsg[0] != '\0')
 			break;
 
-		old_size = sizeof(struct ebt_entry_match) + (**match).match_size;
-		h = malloc((new_size = old_size + ebt_mac_wormhash_size(wh)));
+		new_size = old_size+ebt_mac_wormhash_size(wh);
+		h = malloc(sizeof(struct ebt_entry_match)+EBT_ALIGN(new_size));
 		if (!h)
 			ebt_print_memory();
-		memcpy(h, *match, old_size);
-		memcpy((char *) h + old_size, wh, ebt_mac_wormhash_size(wh));
-		h->match_size = new_size - sizeof(struct ebt_entry_match);
+		memcpy(h, *match, old_size+sizeof(struct ebt_entry_match));
+		memcpy((char *)h+old_size+sizeof(struct ebt_entry_match), wh,
+		       ebt_mac_wormhash_size(wh));
+		h->match_size = EBT_ALIGN(new_size);
 		info = (struct ebt_among_info *) h->data;
 		if (c == AMONG_DST) {
 			info->wh_dst_ofs =
-			    old_size - sizeof(struct ebt_entry_match);
+			    old_size;
 		} else {
 			info->wh_src_ofs =
-			    old_size - sizeof(struct ebt_entry_match);
+			    old_size;
 		}
+		old_size = new_size;
 		free(*match);
 		*match = h;
 		free(wh);

--=-8cX1W5m8JXg4/FCX8M1V--

