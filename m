From: James Lingard <jchl@arastra.com>
Subject: unregister_netdevice of tap interface blocks for up to 30 secs when
 ipv6 module loaded
Date: Wed, 9 May 2007 00:19:11 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0705090007510.4299@obsidian.arastra.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="0-1983418836-1178695141=:4299"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.mindcentric.com ([216.98.159.230]:42553 "EHLO
	zimbra1.mindcentric.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754082AbXEIHsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 03:48:01 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by zimbra1.mindcentric.com (Postfix) with ESMTP id 02593CBD4245
	for <netdev@vger.kernel.org>; Wed,  9 May 2007 00:22:04 -0700 (PDT)
Received: from zimbra1.mindcentric.com ([127.0.0.1])
	by localhost (zimbra1.mindcentric.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Kj4XpU2fTSPG for <netdev@vger.kernel.org>;
	Wed,  9 May 2007 00:22:02 -0700 (PDT)
Received: from [172.16.26.3] (unknown [71.141.148.153])
	by zimbra1.mindcentric.com (Postfix) with ESMTP id E1698CBD4242
	for <netdev@vger.kernel.org>; Wed,  9 May 2007 00:22:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0-1983418836-1178695141=:4299
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed

If the ipv6 module is loaded, then destroying a tap interface that has 
recently been disabled will cause close to block (in unregister_netdevice) 
until precisely 30 seconds have elapsed since the interface was disabled. 
This behavior does not occur if the ipv6 module is not loaded, nor if the 
tap interface is still enabled when calling close, nor if the tap 
interface has never been enabled.

If close is called less than 20 seconds after the interface has been 
disabled (so that it blocks for >10 seconds), then the following message 
is output:

   Message from syslogd@bs18 at Tue May  8 19:01:04 2007 ...
   bs18 kernel: unregister_netdevice: waiting for tap0 to become free. Usage count = 3

The attached Python script reliably reproduces this problem.  The 
timestamps in the output show the 30 second delay between running 'ip link 
set tap0 down' and the subsequent call to close returning.

I have tested on two machines, both running Fedora Core 6, one with kernel 
2.6.19 and one with kernel 2.6.20, and both machines exhibit the same 
symptoms.

   $ cat /proc/version
   Linux version 2.6.19-1.2895.fc6 (brewbuilder@hs20-bc2-2.build.redhat.com) (gcc version 4.1.1 20070105 (Red Hat 4.1.1-51)) #1 SMP Wed Jan 10 19:28:18 EST 2007
   Linux version 2.6.20-1.2933.fc6 (brewbuilder@hs20-bc2-4.build.redhat.com) (gcc version 4.1.1 20070105 (Red Hat 4.1.1-51)) #1 SMP Mon Mar 19 11:38:26 EDT 2007

I have also found the same symptoms to occur on a qemu virtual machine 
(running a custom 2.6.20 kernel) with minimal user-space code running 
(just syslogd, klogd, udevd, login and bash), which suggests that this 
isn't related to any badly-behaving user-space code.

Please cc any responses to me, as I'm not on the mailing list.  Thanks.

James.
--0-1983418836-1178695141=:4299
Content-Type: TEXT/PLAIN; charset=US-ASCII; name=taptest.py
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.64.0705090019010.4299@obsidian.arastra.com>
Content-Description: 
Content-Disposition: attachment; filename=taptest.py

IyEvdXNyL2Jpbi9weXRob24NCmltcG9ydCBvcywgdGltZSwgc3RydWN0LCBm
Y250bA0KDQojIFRoZSBmb2xsb3dpbmcgYXJlIGZyb20gbGludXgvaWZfdHVu
LmgNClRVTlNFVElGRiA9IDB4NDAwNDU0Y2EgICAgICMgaW9jdGwgdG8gY29u
ZmlndXJlIGEgVFVOL1RBUCBpbnRlcmZhY2UNCklGRl9UQVAgPSAweDAwMDIg
ICAgICAgICAgICMgRXRoZXJuZXQtbGV2ZWwgdHVubmVsIGludGVyZmFjZQ0K
SUZGX05PX1BJID0gMHgxMDAwICAgICAgICAgIyBQcm90b2NvbCBpbmZvcm1h
dGlvbiBoZWFkZXIgZm9yIHRhcCBpbnRlcmZhY2VzDQoNCmludGYgPSAndGFw
MCcNCg0KIyBDcmVhdGUgYSB0YXAgaW50ZXJmYWNlLg0KdGFwRmQgPSBvcy5v
cGVuKCAnL2Rldi9uZXQvdHVuJywgb3MuT19SRFdSICkNCmlvY3RsRGF0YSA9
IHN0cnVjdC5wYWNrKCAnMTZzIEggMTR4JywgaW50ZiwgSUZGX1RBUCB8IElG
Rl9OT19QSSApDQpmY250bC5pb2N0bCggdGFwRmQsIFRVTlNFVElGRiwgaW9j
dGxEYXRhICkNCg0KIyBFbmFibGUgdGhlbiBkaXNhYmxlIHRoZSB0YXAgaW50
ZXJmYWNlLg0Kb3Muc3lzdGVtKCAnaXAgbGluayBzZXQgJXMgdXAnICUgaW50
ZiApDQpwcmludCAnRW5hYmxlZCB0YXAgaW50ZXJmYWNlIGF0JywgdGltZS5j
dGltZSggdGltZS50aW1lKCkgKQ0KdGltZS5zbGVlcCggMSApICAjIEEgZGVs
YXkgaGVyZSBzZWVtcyB0byBiZSBuZWNlc3NhcnkgdG8gdHJpZ2dlciB0aGUg
YnVnLg0Kb3Muc3lzdGVtKCAnaXAgbGluayBzZXQgJXMgZG93bicgJSBpbnRm
ICkNCnByaW50ICdEaXNhYmxlZCB0YXAgaW50ZXJmYWNlIGF0JywgdGltZS5j
dGltZSggdGltZS50aW1lKCkgKQ0KdGltZS5zbGVlcCggMTcgKSAjIEEgZGVs
YXkgaGVyZSBpcyBub3QgbmVjZXNzYXJ5LCBidXQgaWxsdXN0cmF0ZXMgdGhh
dCB0aGUgMzAgc2Vjb25kDQogICAgICAgICAgICAgICAgICMgaW50ZXJ2YWwg
c3RhcnRzIHdoZW4gdGhlIGludGVyZmFjZSBpcyBkaXNhYmxlZCwgbm90IHdo
ZW4gY2xvc2UgaXMNCiAgICAgICAgICAgICAgICAgIyBjYWxsZWQuDQoNCiMg
RGVzdHJveSB0aGUgdGFwIGludGVyZmFjZS4NCnByaW50ICdBYm91dCB0byBj
bG9zZSB0YXAgRkQgYXQnLCB0aW1lLmN0aW1lKCB0aW1lLnRpbWUoKSApDQpv
cy5jbG9zZSggdGFwRmQgKQ0KcHJpbnQgJ0Nsb3NlZCB0YXAgRkQgYXQnLCB0
aW1lLmN0aW1lKCB0aW1lLnRpbWUoKSApDQo=

--0-1983418836-1178695141=:4299--
