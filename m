From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net 2/2] bpf, trace: check event type in bpf_perf_event_read
Date: Wed, 15 Jun 2016 18:25:39 -0700
Message-ID: <1466040339-3756110-3-git-send-email-ast@fb.com>
References: <1466040339-3756110-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Sasha Goldshtein <goldshtn@gmail.com>,
	<netdev@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:12139 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753224AbcFPBZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 21:25:42 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u5G1NjRG017866
	for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 18:25:41 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 23geabpqnf-2
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 18:25:41 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 3c5f9688336111e692860002c9dfb610-74ca2e0 for <netdev@vger.kernel.org>;	Wed,
 15 Jun 2016 18:25:39 -0700
In-Reply-To: <1466040339-3756110-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

similar to bpf_perf_event_output() the bpf_perf_event_read() helper
needs to check the type of the perf_event before reading the counter.

Fixes: a43eec304259 ("bpf: introduce bpf_perf_event_output() helper")
Reported-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
the fix is minor. No need for stable backport.
---
 kernel/trace/bpf_trace.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index e7af6cb9d5cf..26f603da7e26 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -209,6 +209,10 @@ static u64 bpf_perf_event_read(u64 r1, u64 index, u64 r3, u64 r4, u64 r5)
 	    event->pmu->count)
 		return -EINVAL;
 
+	if (unlikely(event->attr.type != PERF_TYPE_HARDWARE &&
+		     event->attr.type != PERF_TYPE_RAW))
+		return -EINVAL;
+
 	/*
 	 * we don't know if the function is run successfully by the
 	 * return value. It can be judged in other places, such as
-- 
2.8.0
