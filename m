From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 86081] New: Can't free the return value of sock_kmalloc()
 when the value is NULL
Date: Sun, 12 Oct 2014 17:07:56 +0200
Message-ID: <20141012170756.19d1d12e@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:50676 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115AbaJLPIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Oct 2014 11:08:11 -0400
Received: by mail-wg0-f52.google.com with SMTP id a1so6958069wgh.11
        for <netdev@vger.kernel.org>; Sun, 12 Oct 2014 08:08:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 12 Oct 2014 01:26:47 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 86081] New: Can't free the return value of sock_kmalloc() when the value is NULL


https://bugzilla.kernel.org/show_bug.cgi?id=86081

            Bug ID: 86081
           Summary: Can't free the return value of sock_kmalloc() when the
                    value is NULL
           Product: Networking
           Version: 2.5
    Kernel Version: 3.14
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: rucsoftsec@gmail.com
        Regression: No

in function rds_cmsg_rdma_args() at net/rds/rdma.c:L546, the variable
"iovstack" is an array and the pointer variable *iovs is equal to iovstack (at
Line 554). As the the return value of sock_kmalloc() (called at line 578),when
"iovs" is NULL, function sock_kfree_s() will be called(at line 697) and
function sock_kfree_s() will free "iovs".  
The related code snippets in function rds_cmsg_rdma_args() are as followings.
rds_cmsg_rdma_args() at net/rds/rdma.c:L546
546 int rds_cmsg_rdma_args(struct rds_sock *rs, struct rds_message *rm,
547                           struct cmsghdr *cmsg)
548 {
549         struct rds_rdma_args *args;
550         struct rm_rdma_op *op = &rm->rdma;
551         int nr_pages;
552         unsigned int nr_bytes;
553         struct page **pages = NULL;
554         struct rds_iovec iovstack[UIO_FASTIOV], *iovs = iovstack;
            ...
576         iov_size = args->nr_local * sizeof(struct rds_iovec);
577         if (args->nr_local > UIO_FASTIOV) {
578                 iovs = sock_kmalloc(rds_rs_to_sk(rs), iov_size,
GFP_KERNEL);
579                 if (!iovs) {
580                         ret = -ENOMEM;
581                         goto out;
582                 }
583         }
            ...
695 out:
696         if (iovs != iovstack)
697                 sock_kfree_s(rds_rs_to_sk(rs), iovs, iov_size);
698         kfree(pages);
699         if (ret)
700                 rds_rdma_free_op(op);
701         else
702                 rds_stats_inc(s_send_rdma);
703 
704         return ret;
705 }

Thak you!

RUC_Soft_Sec, supported by China.X.Orion

-- 
You are receiving this mail because:
You are the assignee for the bug.
