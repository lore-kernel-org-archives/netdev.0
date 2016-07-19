From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [PATCH v10 01/12] bpf: add bpf_prog_add api for bulk prog refcnt
Date: Tue, 19 Jul 2016 12:16:46 -0700
Message-ID: <1468955817-10604-2-git-send-email-bblanco@plumgrid.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34432 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751507AbcGSTRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 15:17:24 -0400
Received: by mail-pa0-f52.google.com with SMTP id fi15so9754946pac.1
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 12:17:23 -0700 (PDT)
In-Reply-To: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A subsystem may need to store many copies of a bpf program, each
deserving its own reference. Rather than requiring the caller to loop
one by one (with possible mid-loop failure), add a bulk bpf_prog_add
api.

Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 include/linux/bpf.h  |  1 +
 kernel/bpf/syscall.c | 12 +++++++++---
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index c13e92b..75a5ae6 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -224,6 +224,7 @@ void bpf_register_map_type(struct bpf_map_type_list *tl);
 
 struct bpf_prog *bpf_prog_get(u32 ufd);
 struct bpf_prog *bpf_prog_get_type(u32 ufd, enum bpf_prog_type type);
+struct bpf_prog *bpf_prog_add(struct bpf_prog *prog, int i);
 struct bpf_prog *bpf_prog_inc(struct bpf_prog *prog);
 void bpf_prog_put(struct bpf_prog *prog);
 
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 96d938a..228f962 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -670,14 +670,20 @@ static struct bpf_prog *____bpf_prog_get(struct fd f)
 	return f.file->private_data;
 }
 
-struct bpf_prog *bpf_prog_inc(struct bpf_prog *prog)
+struct bpf_prog *bpf_prog_add(struct bpf_prog *prog, int i)
 {
-	if (atomic_inc_return(&prog->aux->refcnt) > BPF_MAX_REFCNT) {
-		atomic_dec(&prog->aux->refcnt);
+	if (atomic_add_return(i, &prog->aux->refcnt) > BPF_MAX_REFCNT) {
+		atomic_sub(i, &prog->aux->refcnt);
 		return ERR_PTR(-EBUSY);
 	}
 	return prog;
 }
+EXPORT_SYMBOL_GPL(bpf_prog_add);
+
+struct bpf_prog *bpf_prog_inc(struct bpf_prog *prog)
+{
+	return bpf_prog_add(prog, 1);
+}
 
 static struct bpf_prog *__bpf_prog_get(u32 ufd, enum bpf_prog_type *type)
 {
-- 
2.8.2
