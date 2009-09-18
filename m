From: akpm@linux-foundation.org
Subject: [patch 5/6] isdn: eicon, use offsetof
Date: Fri, 18 Sep 2009 12:53:05 -0700
Message-ID: <200909181953.n8IJr5h3026316@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jirislaby@gmail.com, armin@melware.de
To: isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41377 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753975AbZIRUCF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2009 16:02:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jirislaby@gmail.com>

Use offsetof instead of explicit implementation.

* fixes bug with omitted & like:
  len = (byte)(((T30_INFO *) 0)->station_id + 20)

* avoids compiler warnings with wrong sizes (pointer-to-char cast):
  len = (byte)(&(((T30_INFO *) 0)->universal_6));

* cleans up the code

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
Cc: Karsten Keil <isdn@linux-pingi.de>
Acked-by: Armin Schindler <armin@melware.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/hardware/eicon/message.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff -puN drivers/isdn/hardware/eicon/message.c~isdn-eicon-use-offsetof drivers/isdn/hardware/eicon/message.c
--- a/drivers/isdn/hardware/eicon/message.c~isdn-eicon-use-offsetof
+++ a/drivers/isdn/hardware/eicon/message.c
@@ -2692,7 +2692,7 @@ static byte connect_b3_req(dword Id, wor
           if (!(fax_control_bits & T30_CONTROL_BIT_MORE_DOCUMENTS)
            || (fax_feature_bits & T30_FEATURE_BIT_MORE_DOCUMENTS))
           {
-            len = (byte)(&(((T30_INFO *) 0)->universal_6));
+            len = offsetof(T30_INFO, universal_6);
             fax_info_change = false;
             if (ncpi->length >= 4)
             {
@@ -2754,7 +2754,7 @@ static byte connect_b3_req(dword Id, wor
                     for (i = 0; i < w; i++)
                       ((T30_INFO   *)(plci->fax_connect_info_buffer))->station_id[i] = fax_parms[4].info[1+i];
                     ((T30_INFO   *)(plci->fax_connect_info_buffer))->head_line_len = 0;
-                    len = (byte)(((T30_INFO *) 0)->station_id + 20);
+                    len = offsetof(T30_INFO, station_id) + 20;
                     w = fax_parms[5].length;
                     if (w > 20)
                       w = 20;
@@ -2788,7 +2788,7 @@ static byte connect_b3_req(dword Id, wor
                 }
                 else
                 {
-                  len = (byte)(&(((T30_INFO *) 0)->universal_6));
+                  len = offsetof(T30_INFO, universal_6);
                 }
                 fax_info_change = true;
 
@@ -2892,7 +2892,7 @@ static byte connect_b3_res(dword Id, wor
     && (plci->nsf_control_bits & T30_NSF_CONTROL_BIT_ENABLE_NSF)
     && (plci->nsf_control_bits & T30_NSF_CONTROL_BIT_NEGOTIATE_RESP))
    {
-            len = ((byte)(((T30_INFO *) 0)->station_id + 20));
+            len = offsetof(T30_INFO, station_id) + 20;
             if (plci->fax_connect_info_length < len)
             {
               ((T30_INFO *)(plci->fax_connect_info_buffer))->station_id_len = 0;
@@ -3802,7 +3802,7 @@ static byte manufacturer_res(dword Id, w
       break;
     }
     ncpi = &m_parms[1];
-    len = ((byte)(((T30_INFO *) 0)->station_id + 20));
+    len = offsetof(T30_INFO, station_id) + 20;
     if (plci->fax_connect_info_length < len)
     {
       ((T30_INFO *)(plci->fax_connect_info_buffer))->station_id_len = 0;
@@ -6844,7 +6844,7 @@ static void nl_ind(PLCI *plci)
         if ((plci->requested_options_conn | plci->requested_options | a->requested_options_table[plci->appl->Id-1])
           & ((1L << PRIVATE_FAX_SUB_SEP_PWD) | (1L << PRIVATE_FAX_NONSTANDARD)))
         {
-          i = ((word)(((T30_INFO *) 0)->station_id + 20)) + ((T30_INFO   *)plci->NL.RBuffer->P)->head_line_len;
+          i = offsetof(T30_INFO, station_id) + 20 + ((T30_INFO   *)plci->NL.RBuffer->P)->head_line_len;
           while (i < plci->NL.RBuffer->length)
             plci->ncpi_buffer[++len] = plci->NL.RBuffer->P[i++];
         }
@@ -7236,7 +7236,7 @@ static void nl_ind(PLCI *plci)
     {
       plci->RData[1].P = plci->RData[0].P;
       plci->RData[1].PLength = plci->RData[0].PLength;
-      plci->RData[0].P = v120_header_buffer + (-((int) v120_header_buffer) & 3);
+      plci->RData[0].P = v120_header_buffer + (-((unsigned long)v120_header_buffer) & 3);
       if ((plci->NL.RBuffer->P[0] & V120_HEADER_EXTEND_BIT) || (plci->NL.RLength == 1))
         plci->RData[0].PLength = 1;
       else
@@ -8473,7 +8473,7 @@ static word add_b23(PLCI *plci, API_PARS
             fax_control_bits |= T30_CONTROL_BIT_ACCEPT_SEL_POLLING;
           }
             len = nlc[0];
-          pos = ((byte)(((T30_INFO *) 0)->station_id + 20));
+          pos = offsetof(T30_INFO, station_id) + 20;
    if (pos < plci->fax_connect_info_length)
    {
      for (i = 1 + plci->fax_connect_info_buffer[pos]; i != 0; i--)
@@ -8525,7 +8525,7 @@ static word add_b23(PLCI *plci, API_PARS
       }
 
       PUT_WORD(&(((T30_INFO *)&nlc[1])->control_bits_low), fax_control_bits);
-      len = ((byte)(((T30_INFO *) 0)->station_id + 20));
+      len = offsetof(T30_INFO, station_id) + 20;
       for (i = 0; i < len; i++)
         plci->fax_connect_info_buffer[i] = nlc[1+i];
       ((T30_INFO   *) plci->fax_connect_info_buffer)->head_line_len = 0;
_
