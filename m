From: David Laight <David.Laight@ACULAB.COM>
Subject: SCTP data chunk bundling when SCTP_NODELAY is set
Date: Tue, 17 Jun 2014 14:17:06 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725DD38@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:51485 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932316AbaFQOST convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 10:18:19 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 24495-04 for <netdev@vger.kernel.org>;
 Tue, 17 Jun 2014 15:18:11 +0100 (BST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If SCTP_NODELAY is set it is difficult to get SCTP to bundle
data chunks into ethernet packets.
This leads to very high packet rates which bundling could easily
reduce by a factor or 8 or 10.

Nagle can't really be enabled because it generates unwanted delays
when traffic is light (Nagle only really works for unidirectional bulk
data and command-response when the messages are smaller than the mtu).

Even if the sending application knows it has more data to send,
there isn't much it can do to get the chunks bundled.

AFAICT 'corking' the socket even stops full sized packets being
sent - so the application will deadlock if the socket write
buffer size is reached before the socket is 'uncorked'.
This also means that the application can't send back to back
full sized packets unless it uncorks the socket at exactly
the right places.

MSG_MORE isn't supported by SCTP, but I'm not sure it would help.
You really need a MSG_NO_MORE flag and to leave Nagle enabled.

About the only thing I can think of is to normally have Nagle
enabled, and then perform the following sequence to force the
buffered data chunks be sent:
1) disable Nagle
2) cork the socket
3) uncork the socket
4) enable Nagle
Four socket calls is a little excessive!

Any other ideas ?

	David
