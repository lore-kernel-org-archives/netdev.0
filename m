From: Sargun Dhillon <sargun@sargun.me>
Subject: [PATCH net-next v4 0/3]
Date: Thu, 11 Aug 2016 20:14:34 -0700
Message-ID: <20160812031431.GA2063@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net, tj@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:37652 "EHLO
	mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404AbcHLDOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 23:14:37 -0400
Received: by mail-it0-f46.google.com with SMTP id f6so3053876ith.0
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 20:14:36 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset includes a helper and an example to determine whether the probe is
currently executing in the context of a specific cgroup based on a cgroup bpf
map / array. The helper checks the cgroupsv2 hierarchy based on the handle in
the map and if the current cgroup is equal to it, or a descendant of it. The
helper was tested with the example program, and it was verified that the correct
behaviour occurs in the interrupt context.

In an earlier version of this patchset I had added an "opensnoop"-like tool, and
I realized I was basically reimplementing a lot of the code that already exists
in the bcc repo. So, instead I decided to write a test that creates a new mount
namespace, mounts up the cgroupv2 hierarchy, and does some basic tests.  I used
the sync syscall as a canary for these tests because it's a simple, 0-arg
syscall. Once this patch is accepted, adding support to opensnoop will be easy.

I also added a task_under_cgroup_hierarchy function in cgroups.h, as this 
pattern is used in a couple places. Converting those can be done in a later 
patchset.

Thanks to Alexei, Tejun, and Daniel for providing review.

v1->v2: Clean up
v2->v3: Move around ifdefs out of *.c files, add an "integration" test
v3->v4: De-genercize arraymap fetching function;
	rename helper from in_cgroup to under_cgroup (makes much more sense)
	Split adding cgroups task_under_cgroup_hierarchy function

Sargun Dhillon (3):
  cgroup: Add task_under_cgroup_hierarchy cgroup inline function to
    headers
  bpf: Add bpf_current_task_under_cgroup helper
  samples/bpf: Add test_current_task_under_cgroup test

 include/linux/cgroup.h                            |  23 ++++
 include/uapi/linux/bpf.h                          |  11 ++
 kernel/bpf/arraymap.c                             |   2 +-
 kernel/bpf/verifier.c                             |   4 +-
 kernel/trace/bpf_trace.c                          |  30 +++++
 samples/bpf/Makefile                              |   5 +
 samples/bpf/bpf_helpers.h                         |   2 +
 samples/bpf/test_current_task_under_cgroup_kern.c |  43 +++++++
 samples/bpf/test_current_task_under_cgroup_user.c | 145 ++++++++++++++++++++++
 9 files changed, 263 insertions(+), 2 deletions(-)
 create mode 100644 samples/bpf/test_current_task_under_cgroup_kern.c
 create mode 100644 samples/bpf/test_current_task_under_cgroup_user.c

-- 
2.7.4
