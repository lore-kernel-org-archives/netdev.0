From: Patrick McHardy <kaber@trash.net>
Subject: Re: tc filter add ... fw ... action drop
Date: Wed, 18 Jul 2007 11:49:55 +0200
Message-ID: <469DE243.20903@trash.net>
References: <20070718032841.GA14874@toroid.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020709090607070106030902"
Cc: netdev@vger.kernel.org, shemminger@osdl.org
To: Abhijit Menon-Sen <ams@toroid.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33784 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760650AbXGRJuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 05:50:21 -0400
In-Reply-To: <20070718032841.GA14874@toroid.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020709090607070106030902
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Abhijit Menon-Sen wrote:
> Hi.
> 
> Is it a bug that:
> 
>   # tc filter add dev eth0 parent 1: protocol ip prio 0 handle 0xfffffff
>     fw police rate 1 burst 1 mpu 0 mtu 1 action drop
>                                          ^^^^^^^^^^^
> creates a filter that looks like:
> 
>   # tc filter ls dev eth0
>   filter parent 1: protocol ip pref 49152 fw 
>   filter parent 1: protocol ip pref 49152 fw handle 0xfffffff police 0x1
>   rate 0bit burst 0b mtu 1b action reclassify
>                             ^^^^^^^^^^^^^^^^^
>   ref -543190236 bind 4
> 
> (which reclassifies and thus lets 0xfffffff-marked packets through).
> 
> I'm pretty sure this used to work under 2.4.x (though I no longer have a
> 2.4 box to test with), but it hasn't worked on any of the 2.6.x kernels
> I've tried (with both iproute2-ss060323 and 070710).


Good catch. It seems this is merely a parsing error, iproute doesn't
have an "action" parameter and aborts parsing, so it uses the default
value of "RECLASSIFY". It never had this parameter, so this patch
removes it from the help text and makes it return an error.


BTW, Stephen, whats the status of all the patches I sent you?

--------------020709090607070106030902
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/tc/m_police.c b/tc/m_police.c
index 36a7719..62e37f9 100644
--- a/tc/m_police.c
+++ b/tc/m_police.c
@@ -37,7 +37,7 @@ static void usage(void)
 	fprintf(stderr, "Usage: ... police rate BPS burst BYTES[/BYTES] [ mtu BYTES[/BYTES] ]\n");
 	fprintf(stderr, "                [ peakrate BPS ] [ avrate BPS ]\n");
 	fprintf(stderr, "                [ ACTIONTERM ]\n");
-	fprintf(stderr, "Old Syntax ACTIONTERM := action <EXCEEDACT>[/NOTEXCEEDACT] \n");
+	fprintf(stderr, "Old Syntax ACTIONTERM := <EXCEEDACT>[/NOTEXCEEDACT] \n");
 	fprintf(stderr, "New Syntax ACTIONTERM := conform-exceed <EXCEEDACT>[/NOTEXCEEDACT] \n");
 	fprintf(stderr, "Where: *EXCEEDACT := pipe | ok | reclassify | drop | continue \n");
 	fprintf(stderr, "Where:  pipe is only valid for new syntax \n");
@@ -236,7 +236,8 @@ int act_parse_police(struct action_util *a,int *argc_p, char ***argv_p, int tca_
 		} else if (strcmp(*argv, "help") == 0) {
 			usage();
 		} else {
-			break;
+			fprintf(stderr, "What is \"%s\"?\n", *argv);
+			return -1;
 		}
 		ok++;
 		argc--; argv++;

--------------020709090607070106030902--
