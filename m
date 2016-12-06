From: Brad Campbell <lists2009@fnarfbargle.com>
Subject: Re: commit : ppp: add rtnetlink device creation support - breaks
 netcf on my machine.
Date: Tue, 6 Dec 2016 15:47:20 +0800
Message-ID: <5d537b7e-97e9-709c-7b3e-61280cc264f8@fnarfbargle.com>
References: <32208f70-4165-e79b-89ee-543eefaf40ef@fnarfbargle.com>
 <20161205175320.mbtswpmdjumfgh7y@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns3.fnarfbargle.com ([43.245.164.105]:49075 "EHLO
        ns3.fnarfbargle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751180AbcLFHsV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 02:48:21 -0500
In-Reply-To: <20161205175320.mbtswpmdjumfgh7y@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/12/16 01:53, Guillaume Nault wrote:
>>
> Probably not a mistake on your side. I've started looking at netcf'
> source code, but haven't found anything that could explain your issue.
> It'd really help if you could provide steps to reproduce the bug.

Further to my message this morning, I started with a clean linux.git 
4.9.0-rc7-00198-g0cb65c8 and did two runs. One untouched and one with 
the identified patch reverted. I logged both of these with NLCB=debug, 
then split out the ppp section and diffed them.

It appears the only difference of note is the new ATTR 18. I did a diff 
of the entire dump for both and nothing else popped out.


brad@test:~$ diff -u ppp-ok ppp-fail
--- ppp-ok	2016-12-06 13:32:04.358393578 +0800
+++ ppp-fail	2016-12-06 13:32:18.577864406 +0800
@@ -1,10 +1,10 @@
  --------------------------   BEGIN NETLINK MESSAGE 
---------------------------
    [HEADER] 16 octets
-    .nlmsg_len = 628
+    .nlmsg_len = 644
      .nlmsg_type = 16 <route/link::new>
      .nlmsg_flags = 2 <MULTI>
-    .nlmsg_seq = 1481001940
-    .nlmsg_pid = 7462
+    .nlmsg_seq = 1481002252
+    .nlmsg_pid = 7376
    [PAYLOAD] 16 octets
      00 00 00 02 0a 00 00 00 d1 10 01 00 00 00 00 00       ................
    [ATTR 03] 5 octets
@@ -71,6 +71,8 @@
      00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
..................
      00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
..................
      00 00 00 00 00 00                                     ......
+  [ATTR 18] 12 octets
+    08 00 01 00 70 70 70 00 04 00 02 00                   ....ppp.....
    [ATTR 26] 132 octets
      84 00 02 00 80 00 01 00 01 00 00 00 00 00 00 00 00 00 
..................
      00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 
..................
@@ -81,3 +83,4 @@
      00 00 00 00 10 27 00 00 e8 03 00 00 00 00 00 00 00 00 
.....'............
      00 00 00 00 00 00                                     ......
  ---------------------------  END NETLINK MESSAGE 
---------------------------

Running with NLDBG=4 seems to generate this :
DBG<2>: While picking up for 0x26d2e00 <route/link>, recvmsgs() returned 
-34:  (errno = Numerical result out of range)DBG<1>: Clearing cache 
0x26d2e00 <route/link>...

(skip forward 4 hours)

Ok, so I've spent the afternoon compiling and installing software.

I'm afraid I gave you a bum steer. The issue only manifests itself on 
libnl1. I had both installed and netcf was compiling against 1 and not 3.

I spent the afternoon compiling and installing various combinations of 
libnl and netcf and can only reproduce the issue if netcf is compiled 
against libnl <= 1.1.4. It won't compile against 2, 3, or 3.1 and it 
works against 3.2. That explains why it manifests itself on my clean 
Debian 7 machines.

I can work around it locally by recompiling all my stuff against libnl3 
if you don't feel inclined to chase it down, but it is certainly 
reproducible on nl1. I compiled up 1.1.4 and compiled netcf-0.2.8 
against that and the problem shows.

Regards,
Brad
