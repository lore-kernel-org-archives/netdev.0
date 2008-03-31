From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fw: [Bug 10371] New: On big-endian machines getsockopt returns 0
 (via optval) for optlen==1 when returned value should 255
Date: Mon, 31 Mar 2008 08:45:22 -0700
Message-ID: <20080331084522.5c9a2732@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43363 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751130AbYCaPpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 11:45:32 -0400
Received: from extreme (97-115-66-114.ptld.qwest.net [97.115.66.114])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id m2VFjTK7012653
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 31 Mar 2008 08:45:31 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 31 Mar 2008 08:16:05 -0700 (PDT)
From: bugme-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 10371] New: On big-endian machines getsockopt returns 0 (via optval) for optlen==1 when returned value should 255


http://bugzilla.kernel.org/show_bug.cgi?id=10371

           Summary: On big-endian machines getsockopt returns 0 (via optval)
                    for optlen==1 when returned value should 255
           Product: Networking
           Version: 2.5
     KernelVersion: 2.6.24
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: M.Piechaczek@osmosys.tv


Latest working kernel version: 
Earliest failing kernel version: all 2.6
Distribution: 
Hardware Environment: 
Software Environment: 
Problem Description: 

On big-endian machines getsockopt fails for optlen==1 when returned value is
255.
Eg. after calling
  unsigned char ttl = 255;
  socklen_t     len = sizeof(ttl);
  setsockopt(socket, IPPROTO_IP, IP_MULTICAST_TTL, &ttl, &len);
the following call will fail:
  getsockopt(socket, IPPROTO_IP, IP_MULTICAST_TTL, &ttl, &len);
"ttl" returned will be 0.


It's because of bug in /net/ipv4/ip_sockglue.c:

 static int do_ip_getsockopt(struct sock *sk, int level, int optname,
                            char __user *optval, int __user *optlen) 
 ....
        if (len < sizeof(int) && len > 0 && val>=0 && val<255) {
                unsigned char ucval = (unsigned char)val;
                len = 1;
                if (put_user(len, optlen))
                        return -EFAULT;
                if (copy_to_user(optval,&ucval,1))
                        return -EFAULT;
        } else {
                len = min_t(unsigned int, sizeof(int), len);
                if (put_user(len, optlen))
                        return -EFAULT;
                if (copy_to_user(optval,&val,len))
                        return -EFAULT;
        }
        return 0;
} 

The comparision in if-statement should be:
        if (len < sizeof(int) && len > 0 && val>=0 && val<=255)

Otherwise on big-endian machines copy_to_user(optval,&val,len) routine copies
first (highest) byte which is 0 in that case.


This bug does not occur on low-endian machines since
copy_to_user(optval,&val,len) copies right (lowest) byte in that case.


-- 
Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.
