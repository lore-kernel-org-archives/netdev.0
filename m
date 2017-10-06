From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 1/3] bpf: Change bpf_obj_name_cpy() to better ensure map's name is init by 0
Date: Thu, 5 Oct 2017 21:52:11 -0700
Message-ID: <20171006045213.752372-2-kafai@fb.com>
References: <20171006045213.752372-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:42880 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750768AbdJFExG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 00:53:06 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v964mhP8027407
        for <netdev@vger.kernel.org>; Thu, 5 Oct 2017 21:53:05 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2ddyqvgst9-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 21:53:05 -0700
In-Reply-To: <20171006045213.752372-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During get_info_by_fd, the prog/map name is memcpy-ed.  It depends
on the prog->aux->name and map->name to be zero initialized.

bpf_prog_aux is easy to guarantee that aux->name is zero init.

The name in bpf_map may be harder to be guaranteed in the future when
new map type is added.

Hence, this patch makes bpf_obj_name_cpy() to always zero init
the prog/map name.

Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/syscall.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 0048cb24ba7b..d124e702e040 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -322,6 +322,8 @@ static int bpf_obj_name_cpy(char *dst, const char *src)
 {
 	const char *end = src + BPF_OBJ_NAME_LEN;
 
+	memset(dst, 0, BPF_OBJ_NAME_LEN);
+
 	/* Copy all isalnum() and '_' char */
 	while (src < end && *src) {
 		if (!isalnum(*src) && *src != '_')
@@ -333,9 +335,6 @@ static int bpf_obj_name_cpy(char *dst, const char *src)
 	if (src == end)
 		return -EINVAL;
 
-	/* '\0' terminates dst */
-	*dst = 0;
-
 	return 0;
 }
 
-- 
2.9.5
