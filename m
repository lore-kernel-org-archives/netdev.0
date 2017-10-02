From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net-next v6 0/4] bpf: add two helpers to read perf event enabled/running time
Date: Mon, 2 Oct 2017 15:42:14 -0700
Message-ID: <20171002224218.3181418-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:57852 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751756AbdJBWnS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 18:43:18 -0400
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v92MgZns015085
        for <netdev@vger.kernel.org>; Mon, 2 Oct 2017 15:43:18 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2dbp63k41f-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 15:43:18 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hardware pmu counters are limited resources. When there are more
pmu based perf events opened than available counters, kernel will
multiplex these events so each event gets certain percentage
(but not 100%) of the pmu time. In case that multiplexing happens,
the number of samples or counter value will not reflect the
case compared to no multiplexing. This makes comparison between
different runs difficult.

Typically, the number of samples or counter value should be
normalized before comparing to other experiments. The typical
normalization is done like:
  normalized_num_samples = num_samples * time_enabled / time_running
  normalized_counter_value = counter_value * time_enabled / time_running
where time_enabled is the time enabled for event and time_running is
the time running for event since last normalization.

This patch set implements two helper functions.
The helper bpf_perf_event_read_value reads counter/time_enabled/time_running
for perf event array map. The helper bpf_perf_prog_read_value read
counter/time_enabled/time_running for bpf prog with type BPF_PROG_TYPE_PERF_EVENT.

[Dave, Peter,

 Previous communcation shows that this patch may potentially have
 merge conflict with upcoming tip changes in the next merge window.

 Could you advise how this patch should proceed?

 Thanks!
]

Changelogs:
v5->v6:
  . rebase on top of net-next
v4->v5:
  . fix some coding style issues
  . memset the input buffer in case of error for ARG_PTR_TO_UNINIT_MEM
    type of argument.
v3->v4:
  . fix a build failure
v2->v3:
  . counters should be read in order to read enabled/running time. This is to
    prevent that counters and enabled/running time may be read separately.
v1->v2:
  . reading enabled/running time should be together with reading counters
    which contains the logic to ensure the result is valid.

Yonghong Song (4):
  bpf: add helper bpf_perf_event_read_value for perf event array map
  bpf: add a test case for helper bpf_perf_event_read_value
  bpf: add helper bpf_perf_prog_read_value
  bpf: add a test case for helper bpf_perf_prog_read_value

 include/linux/perf_event.h                |  7 ++-
 include/uapi/linux/bpf.h                  | 28 +++++++++++-
 kernel/bpf/arraymap.c                     |  2 +-
 kernel/bpf/verifier.c                     |  4 +-
 kernel/events/core.c                      | 16 +++++--
 kernel/trace/bpf_trace.c                  | 74 ++++++++++++++++++++++++++++---
 samples/bpf/trace_event_kern.c            | 10 +++++
 samples/bpf/trace_event_user.c            | 13 +++---
 samples/bpf/tracex6_kern.c                | 26 +++++++++++
 samples/bpf/tracex6_user.c                | 13 +++++-
 tools/include/uapi/linux/bpf.h            |  4 +-
 tools/testing/selftests/bpf/bpf_helpers.h |  6 +++
 12 files changed, 182 insertions(+), 21 deletions(-)

-- 
2.9.5
