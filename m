From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net-next 0/4] bpf: add two helpers to read perf event enabled/running time
Date: Fri, 1 Sep 2017 09:53:53 -0700
Message-ID: <20170901165357.465121-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:60444 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752284AbdIAQx7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 12:53:59 -0400
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v81GrcV7014146
        for <netdev@vger.kernel.org>; Fri, 1 Sep 2017 09:53:58 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2cq7xp945j-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 09:53:58 -0700
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
The helper bpf_perf_read_counter_time reads counter/time_enabled/time_running
for perf event array map. The helper bpf_perf_prog_read_time read
time_enabled/time_running for bpf prog with type BPF_PROG_TYPE_PERF_EVENT.

Yonghong Song (4):
  bpf: add helper bpf_perf_read_counter_time for perf event array map
  bpf: add a test case for helper bpf_perf_read_counter_time
  bpf: add helper bpf_perf_prog_read_time
  bpf: add a test case for helper bpf_perf_prog_read_time

 include/linux/perf_event.h                |  3 ++
 include/uapi/linux/bpf.h                  | 29 +++++++++++-
 kernel/bpf/verifier.c                     |  4 +-
 kernel/events/core.c                      |  3 +-
 kernel/trace/bpf_trace.c                  | 73 +++++++++++++++++++++++++++++--
 samples/bpf/trace_event_kern.c            |  5 +++
 samples/bpf/tracex6_kern.c                | 26 +++++++++++
 samples/bpf/tracex6_user.c                | 13 +++++-
 tools/testing/selftests/bpf/bpf_helpers.h |  7 +++
 9 files changed, 155 insertions(+), 8 deletions(-)

-- 
2.9.5
