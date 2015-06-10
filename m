From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 99671] New: glibc deadlock in __check_pf() presumed due to
 missing netlink response
Date: Tue, 9 Jun 2015 17:04:34 -0700
Message-ID: <20150609170434.1eeec625@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:35155 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932557AbbFJAEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 20:04:32 -0400
Received: by qkhq76 with SMTP id q76so17267700qkh.2
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 17:04:31 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id n4sm3393638qha.19.2015.06.09.17.04.30
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 17:04:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 8 Jun 2015 21:20:23 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 99671] New: glibc deadlock in __check_pf() presumed due to missing netlink response


https://bugzilla.kernel.org/show_bug.cgi?id=99671

            Bug ID: 99671
           Summary: glibc deadlock in __check_pf() presumed due to missing
                    netlink response
           Product: Networking
           Version: 2.5
    Kernel Version: 4.0
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: dwmw2@infradead.org
        Regression: No

I keep seeing multithreaded processes deadlocked on glibc's __check_pf
function, with the culprit stuck like this:

#0  0x0000003841302edd in recvmsg () at ../sysdeps/unix/syscall-template.S:81
#1  0x000000384131f8ee in __check_pf (pid=-52599, fd=20) at
../sysdeps/unix/sysv/linux/check_pf.c:166
#2  0x000000384131f8ee in __check_pf (seen_ipv4=seen_ipv4@entry=0x7f5b137fdc32,
seen_ipv6=seen_ipv6@entry=0x7f5b137fdc33, in6ai=in6ai@entry=0x7f5b137fdc40,
in6ailen=in6ailen@entry=0x7f5b137fdc48) at
../sysdeps/unix/sysv/linux/check_pf.c:324

I don't understand why the glibc code is waiting; even if netlink responses are
dropped, it should get ENOBUFS and bail out.

This started happening to me, sporadically, when I updated my Fedora 22 beta
installation to the 4.0 kernel. It seemed to go away when I reverted to 3.19,
and came back again when I went back to 4.0. Filed in Red Hat bugzilla as
https://bugzilla.redhat.com/show_bug.cgi?id=1209433 and reported upstream at 
https://www.marc.info/?l=linux-netdev&m=142849461211078&w=3 and
https://www.marc.info/?l=linux-netdev&m=142954024310299&w=3

Others seem to have seen it on earlier kernels though:
https://github.com/nahi/httpclient/issues/232

-- 
You are receiving this mail because:
You are the assignee for the bug.
