From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next] bpf: fix return in load_bpf_file
Date: Tue, 4 Jul 2017 14:51:29 -0700
Message-ID: <20170704215129.4047623-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:56830 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752169AbdGDVvf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 17:51:35 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v64LlbNd018507
        for <netdev@vger.kernel.org>; Tue, 4 Jul 2017 14:51:34 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2bg9ex32ah-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 04 Jul 2017 14:51:34 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (10.212.232.63) with ESMTP id
 f002e030610211e7a9e60002c992ebde-3bb338f0 for <netdev@vger.kernel.org>;        Tue,
 04 Jul 2017 14:51:30 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function load_bpf_file ignores the return value of
load_and_attach(), so even if load_and_attach() returns an error,
load_bpf_file() will return 0.

Now, load_bpf_file() can call load_and_attach() multiple times and some
can succeed and some could fail. I think the correct behavor is to
return error on the first failed load_and_attach().
---
 samples/bpf/bpf_load.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index a4be7cf..899f403 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -567,8 +567,12 @@ static int do_load_bpf_file(const char *path, fixup_map_cb fixup_map)
 		    memcmp(shname, "perf_event", 10) == 0 ||
 		    memcmp(shname, "socket", 6) == 0 ||
 		    memcmp(shname, "cgroup/", 7) == 0 ||
-		    memcmp(shname, "sockops", 7) == 0)
-			load_and_attach(shname, data->d_buf, data->d_size);
+		    memcmp(shname, "sockops", 7) == 0) {
+			ret = load_and_attach(shname, data->d_buf,
+					      data->d_size);
+			if (ret != 0)
+				goto done;
+		}
 	}
 
 	ret = 0;
-- 
2.9.3
