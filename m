From: Jerome Borsboom <j.borsboom@erasmusmc.nl>
Subject: [PATCH] parse ip:port strings correctly in in4_pton
Date: Mon, 16 Apr 2007 10:21:59 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0704161001280.1519@knorkaan.xs4all.nl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from knorkaan.xs4all.nl ([82.93.149.176]:45967 "EHLO
	knorkaan.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbXDPJIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 05:08:25 -0400
Received: from knorkaan.xs4all.nl (localhost [127.0.0.1])
	by knorkaan.xs4all.nl (8.14.1/8.14.1) with ESMTP id l3G8LxTr001526
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 16 Apr 2007 10:21:59 +0200
Received: from localhost (jborsboom@localhost)
	by knorkaan.xs4all.nl (8.14.1/8.14.1/Submit) with ESMTP id l3G8Lxag001523
	for <netdev@vger.kernel.org>; Mon, 16 Apr 2007 10:21:59 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

in4_pton converts a textual representation of an ip4 address into an 
integer representation. However, when the textual representation is of in 
the form ip:port, c.f. 192.168.1.1:5060, and 'delim' is set to -1, the 
function bails out when parsing the colon.

It makes sense to allow the colon as a delimiting character without 
explicitly having to set it through the 'delim' variable as there can be 
no ambiguity in the point where the ip address is completely parsed. 
Furthermore, this function is indeed called from nf_conntrack_sip.c in 
this way to parse textual ip:port combinations which fails as stated 
above.

Signed-off-by: Jerome Borsboom <j.borsboom@erasmusmc.nl>

--- linux-2.6.20/net/core/utils.c	2007-02-04 19:44:54.000000000 +0100
+++ linux-2.6.20/net/core/utils.c	2007-04-15 21:08:55.000000000 +0200
@@ -137,16 +137,16 @@
  	while(1) {
  		int c;
  		c = xdigit2bin(srclen > 0 ? *s : '\0', delim);
-		if (!(c & (IN6PTON_DIGIT | IN6PTON_DOT | IN6PTON_DELIM))) {
+		if (!(c & (IN6PTON_DIGIT | IN6PTON_DOT | IN6PTON_DELIM | IN6PTON_COLON_MASK))) {
  			goto out;
  		}
-		if (c & (IN6PTON_DOT | IN6PTON_DELIM)) {
+		if (c & (IN6PTON_DOT | IN6PTON_DELIM | IN6PTON_COLON_MASK)) {
  			if (w == 0)
  				goto out;
  			*d++ = w & 0xff;
  			w = 0;
  			i++;
-			if (c & IN6PTON_DELIM) {
+			if (c & (IN6PTON_DELIM | IN6PTON_COLON_MASK)) {
  				if (i != 4)
  					goto out;
  				break;
