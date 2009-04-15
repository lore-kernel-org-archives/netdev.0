From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 12954] New: SAMEIP --nodst functionality gone
 missing
Date: Wed, 15 Apr 2009 14:35:58 +0200
Message-ID: <49E5D4AE.3040203@trash.net>
References: <bug-12954-10286@http.bugzilla.kernel.org/> <20090407143509.05ab3b28.akpm@linux-foundation.org> <Pine.LNX.4.62.0904080941370.10428@wlug.westbo.se> <49DCC3A0.7050001@trash.net> <49E5CAB5.3060605@trash.net> <alpine.LSU.2.00.0904151410350.11308@fbirervta.pbzchgretzou.qr> <49E5CF6D.2070709@trash.net> <alpine.LSU.2.00.0904151421070.11961@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030700030103020702000204"
Cc: Martin Josefsson <gandalf@mjufs.se>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	berni@birkenwald.de, netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58651 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759582AbZDOMgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 08:36:00 -0400
In-Reply-To: <alpine.LSU.2.00.0904151421070.11961@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030700030103020702000204
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Jan Engelhardt wrote:
> On Wednesday 2009-04-15 14:13, Patrick McHardy wrote:
>> Jan Engelhardt wrote:
>>> On Wednesday 2009-04-15 13:53, Patrick McHardy wrote:
>>>   
>>>> How about this patch? If the IP_NAT_RANGE_PERSISTENT flag is set
>>>> on a NAT range, we ignore the destination address in the selection.
>>> But where do you set IP_NAT_RANGE_PERSISTENT? (It seems like a dead 
>>> feature right now.)
>> In userspace of course :)
> 
> Ah I hear the crisp sound of an upcoming iptables 1.4.4.

In a while :)

This is the corresponding userspace patch:


--------------030700030103020702000204
Content-Type: text/x-patch;
 name="nat.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nat.diff"

diff --git a/extensions/libipt_DNAT.c b/extensions/libipt_DNAT.c
index b5f8028..dc79b44 100644
--- a/extensions/libipt_DNAT.c
+++ b/extensions/libipt_DNAT.c
@@ -27,12 +27,13 @@ static void DNAT_help(void)
 "DNAT target options:\n"
 " --to-destination <ipaddr>[-<ipaddr>][:port-port]\n"
 "				Address to map destination to.\n"
-"[--random]\n");
+"[--random] [--persistent]\n");
 }
 
 static const struct option DNAT_opts[] = {
 	{ "to-destination", 1, NULL, '1' },
 	{ "random", 0, NULL, '2' },
+	{ "persistent", 0, NULL, '3' },
 	{ .name = NULL }
 };
 
@@ -178,6 +179,11 @@ static int DNAT_parse(int c, char **argv, int invert, unsigned int *flags,
 		} else
 			*flags |= IPT_DNAT_OPT_RANDOM;
 		return 1;
+
+	case '3':
+		info->mr.range[0].flags |= IP_NAT_RANGE_PERSISTENT;
+		return 1;
+
 	default:
 		return 0;
 	}
@@ -222,6 +228,8 @@ static void DNAT_print(const void *ip, const struct xt_entry_target *target,
 		printf(" ");
 		if (info->mr.range[i].flags & IP_NAT_RANGE_PROTO_RANDOM)
 			printf("random ");
+		if (info->mr.range[i].flags & IP_NAT_RANGE_PERSISTENT)
+			printf("persistent ");
 	}
 }
 
@@ -236,6 +244,8 @@ static void DNAT_save(const void *ip, const struct xt_entry_target *target)
 		printf(" ");
 		if (info->mr.range[i].flags & IP_NAT_RANGE_PROTO_RANDOM)
 			printf("--random ");
+		if (info->mr.range[i].flags & IP_NAT_RANGE_PERSISTENT)
+			printf("--persistent ");
 	}
 }
 
diff --git a/extensions/libipt_SNAT.c b/extensions/libipt_SNAT.c
index 944fe67..762d8d0 100644
--- a/extensions/libipt_SNAT.c
+++ b/extensions/libipt_SNAT.c
@@ -27,12 +27,13 @@ static void SNAT_help(void)
 "SNAT target options:\n"
 " --to-source <ipaddr>[-<ipaddr>][:port-port]\n"
 "				Address to map source to.\n"
-"[--random]\n");
+"[--random] [ --persistent]\n");
 }
 
 static const struct option SNAT_opts[] = {
 	{ "to-source", 1, NULL, '1' },
 	{ "random", 0, NULL, '2' },
+	{ "perstistent", 0, NULL, '3' },
 	{ .name = NULL }
 };
 
@@ -179,6 +180,10 @@ static int SNAT_parse(int c, char **argv, int invert, unsigned int *flags,
 			*flags |= IPT_SNAT_OPT_RANDOM;
 		return 1;
 
+	case '3':
+		info->mr.range[0].flags |= IP_NAT_RANGE_PERSISTENT;
+		return 1;
+
 	default:
 		return 0;
 	}
@@ -223,6 +228,8 @@ static void SNAT_print(const void *ip, const struct xt_entry_target *target,
 		printf(" ");
 		if (info->mr.range[i].flags & IP_NAT_RANGE_PROTO_RANDOM)
 			printf("random ");
+		if (info->mr.range[i].flags & IP_NAT_RANGE_PERSISTENT)
+			printf("persistent ");
 	}
 }
 
@@ -237,6 +244,8 @@ static void SNAT_save(const void *ip, const struct xt_entry_target *target)
 		printf(" ");
 		if (info->mr.range[i].flags & IP_NAT_RANGE_PROTO_RANDOM)
 			printf("--random ");
+		if (info->mr.range[i].flags & IP_NAT_RANGE_PERSISTENT)
+			printf("--persistent ");
 	}
 }
 
diff --git a/include/net/netfilter/nf_nat.h b/include/net/netfilter/nf_nat.h
index 094473e..c3e2060 100644
--- a/include/net/netfilter/nf_nat.h
+++ b/include/net/netfilter/nf_nat.h
@@ -18,6 +18,7 @@ enum nf_nat_manip_type
 #define IP_NAT_RANGE_MAP_IPS 1
 #define IP_NAT_RANGE_PROTO_SPECIFIED 2
 #define IP_NAT_RANGE_PROTO_RANDOM 4
+#define IP_NAT_RANGE_PERSISTENT 8
 
 /* NAT sequence number modifications */
 struct nf_nat_seq {

--------------030700030103020702000204--
