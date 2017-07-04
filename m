From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next V2] bpf: fix return in load_bpf_file
Date: Tue, 4 Jul 2017 15:57:50 -0700
Message-ID: <20170704225750.125603-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:48208 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752248AbdGDW5x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 18:57:53 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v64MtHiN026567
        for <netdev@vger.kernel.org>; Tue, 4 Jul 2017 15:57:52 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2bg7e1vprq-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 04 Jul 2017 15:57:52 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:0037:0000) with ESMTP       id
 34eae874610c11e7b0f61f53bdcd5fbc-79b3b8f0 for <netdev@vger.kernel.org>;        Tue,
 04 Jul 2017 15:57:51 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function load_bpf_file ignores the return value of
load_and_attach(), so even if load_and_attach() returns an error,
load_bpf_file() will return 0.

Now, load_bpf_file() can call load_and_attach() multiple times and some
can succeed and some could fail. I think the correct behavor is to
return error on the first failed load_and_attach().

v2: Added missing SOB

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
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
