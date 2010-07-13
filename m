From: Ben Greear <greearb@candelatech.com>
Subject: Re: iproute, batch-cmds, and mac-vlans.
Date: Mon, 12 Jul 2010 22:32:53 -0700
Message-ID: <4C3BFA85.8070500@candelatech.com>
References: <4C3BF050.7040206@candelatech.com> <20100712221958.2a87b0e3@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38693 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825Ab0GMFcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 01:32:54 -0400
In-Reply-To: <20100712221958.2a87b0e3@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/2010 10:19 PM, Stephen Hemminger wrote:
> On Mon, 12 Jul 2010 21:49:20 -0700
> Ben Greear<greearb@candelatech.com>  wrote:
>
>> After too much time debugging, I finally realized that the ip
>> tool was truncating my command because the mac-vlan device name
>> had a '#' in it.
>>
>> ]# cat /tmp/foo.txt
>> ru add to 10.99.21.1 iif eth0#0 lookup local pref 11
>>
>>
>> # IP tool has some hacked up debugging code
>> ]# ip -batch /tmp/foo.txt
>>    argc: 4
>>    arg -:to:-
>>    arg -:iif:-
>> WARNING:  Using TABLE_MAIN in iprule_modify, table_ok: 0  cmd: 32
>>
>>
>> So, it acts on eth0 instead of eth0#0, and silently ignores the 'lookup local pref 11'.
>>
>> I understand that it is trying to parse # as comments, but would you
>> all be interested in a patch that allowed ignoring '#' except
>> when it is the first non-whitespace character on a line, and maybe
>> when preceded by whitespace?  This would of course have the possibility
>> of breaking someone's script somewhere, so it could be enabled with
>> a new command line arg, perhaps.
>
> Putting # in device name just sounds like a bad idea.

It's been the standard naming for mac-vlans since we started supporting them.

In case you change your mind, this patch seems to work..though I can't figure out
how to trigger the second bit of code in the while loop, so it may not be right.

I'll move my iproute2 tree to github in case someone else wants to give
it a try.

diff --git a/lib/utils.c b/lib/utils.c
index a60d884..ad8e1ac 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -25,7 +25,7 @@
  #include <linux/pkt_sched.h>
  #include <time.h>
  #include <sys/time.h>
-
+#include <ctype.h>

  #include "utils.h"

@@ -708,8 +708,23 @@ ssize_t getcmdline(char **linep, size_t *lenp, FILE *in)
         ++cmdlineno;

         cp = strchr(*linep, '#');
-       if (cp)
-               *cp = '\0';
+
+       /* We don't want to treat the # in the middle of a word as
+        * a comment..makes batch commands dealing with mac-vlans: eth0#1
+        * silently do the wrong thing.  So, tighten up the # syntax a bit.
+        *
+        * # at start of line comments rest of line
+        * # preceded by a whitespace character comments rest of line.
+        */
+       while (cp) {
+               if (cp &&
+                   ((cp == *linep) /* starts line */
+                    || ((cp > *linep) && isspace(*(cp - 1))))) { /* follows space */
+                       *cp = '\0';
+                       break;
+               }
+               cp = strchr(cp+1, '#');
+       }

         while ((cp = strstr(*linep, "\\\n")) != NULL) {
                 char *line1 = NULL;
@@ -725,9 +740,16 @@ ssize_t getcmdline(char **linep, size_t *lenp, FILE *in)
                 *cp = 0;

                 cp = strchr(line1, '#');
-               if (cp)
-                       *cp = '\0';
-
+               while (cp) {
+                       if (cp &&
+                           ((cp == line1) /* starts line */
+                            || ((cp > line1) && isspace(*(cp - 1))))) { /* follows space */
+                               *cp = '\0';
+                               break;
+                       }
+                       cp = strchr(cp+1, '#');
+               }
+
                 *lenp = strlen(*linep) + strlen(line1) + 1;
                 *linep = realloc(*linep, *lenp);
                 if (!*linep) {

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
