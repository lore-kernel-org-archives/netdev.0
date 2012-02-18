From: Arun Sharma <asharma@fb.com>
Subject: route add default fails with ESRCH?
Date: Fri, 17 Feb 2012 17:39:36 -0800
Message-ID: <4F3F0158.2020406@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:60661 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752264Ab2BRBjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 20:39:44 -0500
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.4/8.14.4) with SMTP id q1I1dhgK001537
	for <netdev@vger.kernel.org>; Fri, 17 Feb 2012 17:39:43 -0800
Received: from mail.thefacebook.com (corpout1.snc1.tfbnw.net [66.220.144.38])
	by mx0b-00082601.pphosted.com with ESMTP id 131xn709rf-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 17 Feb 2012 17:39:43 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've been trying to debug this strange problem with recent 3.2 kernels:

# boot to single user mode
# service network start
# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr <blah>
           inet addr:10.47.46.39  Bcast:10.47.46.255  Mask:255.255.255.0

<Link is up>
# strace route add default gw 10.47.46.1
ioctl(3, SIOCADDRT, 0x7fff1fd4db80)     = -1 ESRCH (No such process)

Couple of data points:

* This didn't happen with 2.6.3x kernels
* This doesn't happen on all machines. Only a small subset

I tried to debug using perf probe points:

# cmdline : /usr/bin/perf record -e 
probe:fib_get_table,probe:fib_new_table,probe:fib_table_insert route add 
default gw 10.47.46.1

            route  7800 [001]  4170.916261: fib_get_table: 
(ffffffff81406528 <- ffffffff814065a6) ret=ffff8802142605c0
            route  7800 [001]  4170.916265: fib_get_table: 
(ffffffff81406528 <- ffffffff814067d3) ret=ffff880212a36680
            route  7800 [001]  4170.916266: fib_new_table: 
(ffffffff814067b6 <- ffffffff81406f04) ret=ffff880212a36680
            route  7800 [001]  4170.916270: fib_get_table: 
(ffffffff81406528 <- ffffffff8140d7fa) ret=ffff8802142605c0
            route  7800 [001]  4170.916271: fib_get_table: 
(ffffffff81406528 <- ffffffff8140d7fa) ret=ffff880212a36680
            route  7800 [001]  4170.916272: fib_get_table: 
(ffffffff81406528 <- ffffffff8140d7fa) ret=0
            route  7800 [001]  4170.916273: fib_table_insert: 
(ffffffff8140a60f <- ffffffff81406f18) ret=fffffffd

Any ideas on why fib_table_insert() is failing with -ESRCH?

  -Arun
