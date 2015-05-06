From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 97811] New: "ip netns create" hangs forever, spamming
 console with "unregister_netdevice: waiting for lo to become free"
Date: Wed, 6 May 2015 10:12:03 -0700
Message-ID: <20150506101203.3ec37196@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:34858 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590AbbEFRMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 13:12:00 -0400
Received: by pdbqd1 with SMTP id qd1so15388951pdb.2
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 10:11:59 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id ge4sm2391107pbc.52.2015.05.06.10.11.59
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 10:11:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 6 May 2015 17:09:25 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 97811] New: "ip netns create" hangs forever, spamming console with "unregister_netdevice: waiting for lo to become free"


https://bugzilla.kernel.org/show_bug.cgi?id=97811

            Bug ID: 97811
           Summary: "ip netns create" hangs forever, spamming console with
                    "unregister_netdevice: waiting for lo to become free"
           Product: Networking
           Version: 2.5
    Kernel Version: 4.0.1
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: zackw@panix.com
        Regression: No

Created attachment 176051
  --> https://bugzilla.kernel.org/attachment.cgi?id=176051&action=edit
.config

I have an application that makes heavy use of network namespaces, creating and
destroying them on the fly during operation.  With 100% reproducibility, the
first invocation of "ip netns create" after any "ip netns del" hangs forever in
D-state; only rebooting the machine clears the condition.  (This used to be an
intermittent fault, going back at least as far as 3.16, but 4.0 seems to have
upgraded it to an every-single-time fault.)

lockdep hung task detection reports:

May  5 22:48:07 laguz kernel: INFO: task ip:572431 blocked for more than 120
seconds.
May  5 22:48:07 laguz kernel:      Not tainted 4.0.1-linode55-lockdep #2
May  5 22:48:07 laguz kernel: "echo 0 >
/proc/sys/kernel/hung_task_timeout_secs" disables this message.
May  5 22:48:07 laguz kernel: ip              D ffff88000e28bda8     0 572431
572428 0x00000000
May  5 22:48:07 laguz kernel: ffff88000e28bda8 ffff880058b60000
ffff8801512c6540 ffff88000e28bda8
May  5 22:48:07 laguz kernel: ffff88000e28bfd8 ffff8800a07e6500
ffffffff81ecee88 ffff88000e28be28
May  5 22:48:07 laguz kernel: ffff8801512c6540 ffff88000e28bdc8
ffffffff81964ca9 0000000000000006
May  5 22:48:07 laguz kernel: Call Trace:
May  5 22:48:07 laguz kernel: [<ffffffff81964ca9>] schedule+0x74/0x83
May  5 22:48:07 laguz kernel: [<ffffffff81964cc6>]
schedule_preempt_disabled+0xe/0x10
May  5 22:48:07 laguz kernel: [<ffffffff81965b0f>]
mutex_lock_nested+0x200/0x462
May  5 22:48:07 laguz kernel: [<ffffffff8175a651>] ? copy_net_ns+0x79/0x103
May  5 22:48:07 laguz kernel: [<ffffffff8175a61c>] ? copy_net_ns+0x44/0x103
May  5 22:48:07 laguz kernel: [<ffffffff811139d5>] ?
lockdep_trace_alloc+0xca/0xdc
May  5 22:48:07 laguz kernel: [<ffffffff8175a651>] copy_net_ns+0x79/0x103
May  5 22:48:07 laguz kernel: [<ffffffff810f4b40>]
create_new_namespaces+0x103/0x17f
May  5 22:48:07 laguz kernel: [<ffffffff810f4d8b>]
unshare_nsproxy_namespaces+0x8b/0xb0
May  5 22:48:07 laguz kernel: [<ffffffff810da7f0>] SyS_unshare+0x120/0x2aa
May  5 22:48:07 laguz kernel: [<ffffffff8196a2c9>]
system_call_fastpath+0x12/0x17
May  5 22:48:07 laguz kernel: 1 lock held by ip/572431:
May  5 22:48:07 laguz kernel: #0:  (net_mutex){+.+.+.}, at:
[<ffffffff8175a651>] copy_net_ns+0x79/0x103

When the bug manifests, there is invariably also a kworker process stuck in
D-state, but I don't see anything related to that in this trace.  I've
restarted the machine so I can continue collecting data, but the condition will
recur in a few days, at which point I will provide any additional information
that you ask me for between now and then.

.config attached.  (This is Linode's latest stock 64-bit kernel + activation of
lockdep.)

-- 
You are receiving this mail because:
You are the assignee for the bug.
