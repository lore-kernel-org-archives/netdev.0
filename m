From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net-next v4 0/4] bpf: add two helpers to read perf event enabled/running time
Date: Tue, 19 Sep 2017 00:04:09 -0700
Message-ID: <20170919070413.3838201-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:50288 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750925AbdISHER (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 03:04:17 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8J6tOfH020146
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 00:04:17 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2d2ud20u4q-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 00:04:17 -0700
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

Changelogs:
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

 include/linux/perf_event.h                |  7 +++-
 include/uapi/linux/bpf.h                  | 26 +++++++++++-
 kernel/bpf/arraymap.c                     |  2 +-
 kernel/bpf/verifier.c                     |  4 +-
 kernel/events/core.c                      | 16 ++++++--
 kernel/trace/bpf_trace.c                  | 67 +++++++++++++++++++++++++++++--
 samples/bpf/trace_event_kern.c            | 10 +++++
 samples/bpf/trace_event_user.c            | 13 +++---
 samples/bpf/tracex6_kern.c                | 26 ++++++++++++
 samples/bpf/tracex6_user.c                | 13 +++++-
 tools/include/uapi/linux/bpf.h            |  4 +-
 tools/testing/selftests/bpf/bpf_helpers.h |  6 +++
 12 files changed, 175 insertions(+), 19 deletions(-)

-- 
2.9.5
