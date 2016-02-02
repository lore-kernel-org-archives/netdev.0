From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 0/6] bpf: introduce per-cpu maps
Date: Mon, 1 Feb 2016 22:39:52 -0800
Message-ID: <1454395198-1796236-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Martin KaFai Lau <kafai@fb.com>, Ming Lei <tom.leiming@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	<netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:1116 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752273AbcBBGkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 01:40:03 -0500
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u126b1uw006956
	for <netdev@vger.kernel.org>; Mon, 1 Feb 2016 22:40:02 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 20rsvbkkev-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 22:40:02 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 c7f11284c97711e59e3e24be0595f910-7cee26b0 for <netdev@vger.kernel.org>;	Mon,
 01 Feb 2016 22:39:59 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We've started to use bpf to trace every packet and atomic add
instruction (event JITed) started to show up in perf profile.
The solution is to do per-cpu counters.
For PERCPU_(HASH|ARRAY) map the existing bpf_map_lookup() helper
returns per-cpu area which bpf programs can use to store and
increment the counters. The BPF_MAP_LOOKUP_ELEM syscall command
returns areas from all cpus and user process aggregates the counters.
The usage example is in patch 6. The api turned out to be very
easy to use from bpf program and from user space.
Long term we were discussing to add 'bounded loop' instruction,
so bpf programs can do aggregation within the program which may
help some use cases. Right now user space aggregation of
per-cpu counters fits the best.

This patch set is new approach for per-cpu hash and array maps.
I've reused the map tests written by Martin and Ming, but
implementation and api is new. Old discussion here:
http://thread.gmane.org/gmane.linux.kernel/2123800/focus=2126435

Alexei Starovoitov (4):
  bpf: introduce BPF_MAP_TYPE_PERCPU_HASH map
  bpf: introduce BPF_MAP_TYPE_PERCPU_ARRAY map
  bpf: add lookup/update support for per-cpu hash and array maps
  samples/bpf: update tracex[23] examples to use per-cpu maps

Martin KaFai Lau (1):
  samples/bpf: unit test for BPF_MAP_TYPE_PERCPU_HASH

tom.leiming@gmail.com (1):
  samples/bpf: unit test for BPF_MAP_TYPE_PERCPU_ARRAY

 include/linux/bpf.h        |  24 ++++
 include/uapi/linux/bpf.h   |   2 +
 kernel/bpf/arraymap.c      | 166 ++++++++++++++++++++--
 kernel/bpf/hashtab.c       | 340 ++++++++++++++++++++++++++++++++++++++-------
 kernel/bpf/syscall.c       |  57 +++++---
 samples/bpf/test_maps.c    | 188 +++++++++++++++++++++++++
 samples/bpf/tracex2_kern.c |   2 +-
 samples/bpf/tracex2_user.c |   7 +-
 samples/bpf/tracex3_kern.c |   8 +-
 samples/bpf/tracex3_user.c |  21 ++-
 10 files changed, 727 insertions(+), 88 deletions(-)

-- 
2.4.6
