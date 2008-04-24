From: Tom Quetchenbach <virtualphtn@gmail.com>
Subject: [PATCH net-2.6] tcp_probe buffer overflow and incorrect return value
Date: Thu, 24 Apr 2008 14:37:58 -0700
Message-ID: <4810FDB6.2060805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outgoing-mail.its.caltech.edu ([131.215.239.19]:61639 "EHLO
	outgoing-mail.its.caltech.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753317AbYDXVpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 17:45:34 -0400
Received: from fire-dog.its.caltech.edu (fire-dog [192.168.1.4])
	by wood-ox-postvirus (Postfix) with ESMTP id BFF9613EF1
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 14:37:02 -0700 (PDT)
Received: from [131.215.45.205] (DHCP-45-205.cs.caltech.edu [131.215.45.205])
	(Authenticated sender: quetchen)
	by fire-ox.its.caltech.edu (Postfix) with ESMTP id 7EE5B13F92
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 14:37:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_probe has a bounds-checking bug that causes many programs (less, python) to
crash reading /proc/net/tcp_probe. When it outputs a log line to the reader, it
only checks if that line alone will fit in the reader's buffer, rather than that
line and all the previous lines it has already written.

tcpprobe_read also returns the wrong value if copy_to_user fails--it just passes
on the return value of copy_to_user (number of bytes not copied), which makes a
failure look like a success.

This patch fixes the buffer overflow and sets the return value to -EFAULT if
copy_to_user fails.

Patch is against latest net-2.6; tested briefly and seems to fix the crashes in
less and python.

Signed-off-by: Tom Quetchenbach <virtualphtn@gmail.com>


diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index 1c50959..5ff0ce6 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -190,19 +190,18 @@ static ssize_t tcpprobe_read(struct file
 
 		width = tcpprobe_sprint(tbuf, sizeof(tbuf));
 
-		if (width < len)
+		if (cnt + width < len)
 			tcp_probe.tail = (tcp_probe.tail + 1) % bufsize;
 
 		spin_unlock_bh(&tcp_probe.lock);
 
 		/* if record greater than space available
 		   return partial buffer (so far) */
-		if (width >= len)
+		if (cnt + width >= len)
 			break;
 
-		error = copy_to_user(buf + cnt, tbuf, width);
-		if (error)
-			break;
+		if (copy_to_user(buf + cnt, tbuf, width))
+			return -EFAULT;
 		cnt += width;
 	}
 
