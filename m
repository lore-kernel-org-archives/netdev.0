From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: lnstat (rtstat replacement)
Date: Sun, 3 Oct 2004 23:07:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16736.27124.307123.345676@robur.slu.se>
References: <20041002162120.GT27499@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@oss.sgi.com>, David Miller <davem@davemloft.net>,
        Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20041002162120.GT27499@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Harald Welte writes:

 > I've finished my work on 'lnstat'.  The current development version is
 > available from
 > 	http://svn.gnumonks.org/cgi-bin/viewcvs.cgi/trunk/lnstat/

 I will get a useful tool...

 > Robert: I hope you're fine with the new lnstat tool replacing rtstat.


 I just tried "compatibility mode". Something like patch below makes it closer 
 to old rtstat. Did the last two fields get switched?

 Cheers.
							--ro



--- lnstat.c.orig	2004-10-03 21:01:50.518607296 +0200
+++ lnstat.c	2004-10-03 22:38:25.846513976 +0200
@@ -54,7 +54,7 @@
 		gettimeofday(&lf->last_read, NULL);
 
 		for (j = 0; j < lf->num_fields; j++)
-			lf->fields[j].values[i] += strtoul(ptr, &ptr, 16);
+			lf->fields[j].values[i] = strtoul(ptr, &ptr, 16);
 	}
 	return num_lines;
 }
@@ -79,6 +79,7 @@
 	struct lnstat_file *lf;
 	char buf[FGETS_BUF_SIZE];
 	struct timeval tv;
+	time_t told;
 
 	gettimeofday(&tv, NULL);
 
@@ -92,15 +93,22 @@
 				/* skip first line */
 				fgets(buf, sizeof(buf)-1, lf->fp);
 			}
+			told = lf->last_read.tv_sec;
 			scan_lines(lf, 1);
 
 			for (i = 0, lfi = &lf->fields[i]; 
 			     i < lf->num_fields; i++, lfi = &lf->fields[i]) {
 				if (i == 0)
 					lfi->result = lfi->values[1];
-				else
+				else {
+
 					lfi->result = (lfi->values[1]-lfi->values[0])
-				    			/ lf->interval.tv_sec;
+
+					  / ( lf->last_read.tv_sec -told);
+					
+					/* Save current to next diff */
+					lfi->values[0] = lfi->values[1];
+				}
 			}
 
 			rewind(lf->fp);
 
