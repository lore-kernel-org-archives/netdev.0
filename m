From: William Tu <u9012063@gmail.com>
Subject: [PATCH] bpf: fix size of copy_to_user in percpu map.
Date: Thu, 28 Jul 2016 17:42:21 -0700
Message-ID: <1469752941-7140-1-git-send-email-u9012063@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35589 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbcG2Am3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 20:42:29 -0400
Received: by mail-pf0-f196.google.com with SMTP id h186so4463239pfg.2
        for <netdev@vger.kernel.org>; Thu, 28 Jul 2016 17:42:29 -0700 (PDT)
Received: from vm-dev.localdomain ([208.91.1.34])
        by smtp.gmail.com with ESMTPSA id zk7sm19699482pac.41.2016.07.28.17.42.28
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 17:42:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The total size of value copy_to_user() writes to userspace should
be the (current number of cpu) * (value size), instead of
num_possible_cpus() * (value size).  Found by samples/bpf/test_maps.c,
which always copies 512 byte to userspace, crashing the userspace
program stack.

Signed-off-by: William Tu <u9012063@gmail.com>
---
 kernel/bpf/syscall.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 228f962..47f738e 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -324,7 +324,8 @@ static int map_lookup_elem(union bpf_attr *attr)
 		goto free_value;
 
 	err = -EFAULT;
-	if (copy_to_user(uvalue, value, value_size) != 0)
+	if (copy_to_user(uvalue, value,
+		map->value_size * num_online_cpus()) != 0)
 		goto free_value;
 
 	err = 0;
-- 
2.5.0
