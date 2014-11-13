From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 88161] New: High traffic causes a lot of softirqs
Date: Thu, 13 Nov 2014 16:21:24 -0500
Message-ID: <20141113162124.5170b82d@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:36341 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753906AbaKMVVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 16:21:47 -0500
Received: by mail-qg0-f46.google.com with SMTP id i50so10994046qgf.19
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2014 13:21:46 -0800 (PST)
Received: from uryu.home.lan ([172.56.34.127])
        by mx.google.com with ESMTPSA id v4sm25112335qay.3.2014.11.13.13.21.46
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 13:21:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 13 Nov 2014 06:18:28 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 88161] New: High traffic causes a lot of softirqs


https://bugzilla.kernel.org/show_bug.cgi?id=88161

            Bug ID: 88161
           Summary: High traffic causes a lot of softirqs
           Product: Networking
           Version: 2.5
    Kernel Version: 3.17.2
          Hardware: Intel
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: mike@zcentric.com
        Regression: No

I'm using packaged rpms by centos and elrepo with the same results and I can
replicate this on any server in our cluster. 

I have tried installing 

kernel-3.10.56-11.el6.centos.alt.x86_64

Also currently running

[root@web125-east.domain.com /var/www/html]# uname -a
Linux web125-east.domain.com 3.17.2-1.el6.elrepo.x86_64 #1 SMP Fri Oct 31
10:37:44 EDT 2014 x86_64 x86_64 x86_64 GNU/Linux

from the centosplus repo to solve a problem where 2.6 was locking up process
tree on high cpu and it fixed it but it introduced another issue where we have
a lot of softirq requests when under a lot of traffic load. 

Here is a powertop from a 2.6 series server

Summary: 42492.1 wakeups/second, 0.0 GPU ops/seconds, 0.0 VFS ops/sec and
2422.0% CPU use

                Usage Events/s Category Description
            22613 ms/s 23637.4    Process php-fpm: pool www
            716.9 ms/s 15783.2    Process nginx: worker process
             21.3 ms/s 1096.1    Process /usr/bin/java -Xms200m -Xmx2000m
-Xss256k -XX:MaxDirectMemorySize=516m -XX:+UseParNewGC -XX:+UseConcMarkSweepGC
-Dage
              5.8 ms/s 674.4 Process /usr/sbin/gmond
            130.0 ms/s 494.5 Process /usr/bin/redis-server 127.0.0.1:6379
             73.2 ms/s 487.4 Process python /usr/bin/statsd-relay.py
              3.8 ms/s 82.7 Process java -Xmx6g -server -Dfile.encoding=utf-8
-XX:OnOutOfMemoryError=kill -9 %p -XX:+HeapDumpOnOutOfMemoryError -XX:HeapD
            212.4 ms/s 0.00 Interrupt [3] net_rx(softirq)


Here it is from 3.10


                Usage Events/s Category Description
             10.2 ms/s 1033.6    Timer hrtimer_wakeup
              3.3 ms/s 932.7 Process /usr/bin/java -Xms200m -Xmx2000m -Xss256k
            591.1 ms/s 624.3 Process php-fpm: pool www
             41.5 ms/s 724.0 Interrupt [3] net_rx(softirq)

Load pretty much just keeps crawling up to the 500's

There also is a lot of CPU usage from

  116 root 20 0 0 0 0 R 75.0 0.0 0:04.57 kworker/u66:0

Which from my understanding handles a lot of the acpi calls that softirq is
doing. 

I've tried many other 3.x kernels above 3.10 with the same results.. so I'm
wondering if this is a known issue

-- 
You are receiving this mail because:
You are the assignee for the bug.
