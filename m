From: fpavlic@de.ibm.com
Subject: [PATCH 5/9] s390: qeth driver fixes [2/6]
Date: Wed, 6 Sep 2006 17:05:47 +0200
Message-ID: <200609061705.47767.fpavlic@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev Mailinglist <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:21530 "EHLO
	mtagate4.de.ibm.com") by vger.kernel.org with ESMTP
	id S1751298AbWIFPEv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 11:04:51 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.7/8.13.7) with ESMTP id k86F4odg076952
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 15:04:50 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k86F9F5A2695210
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 17:09:15 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k86F4neX029976
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 17:04:50 +0200
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 5/9] s390: qeth driver fixes [2/6]

From: Frank Pavlic <fpavlic@de.ibm.com>
 - fixed error handling in create_device_attributes
 - fixed some minor bugs in IPv4 
   and IPv6 address checking

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---

 drivers/s390/net/qeth.h     |   25 ++++++++++++++++---------
 drivers/s390/net/qeth_sys.c |   22 ++++++++++++++++------
 2 files changed, 32 insertions(+), 15 deletions(-)

8d7b1277f7334cf8c5390d72563dcd22f69f3eb4
diff --git a/drivers/s390/net/qeth.h b/drivers/s390/net/qeth.h
index 619f4a0..e8bd8c5 100644
--- a/drivers/s390/net/qeth.h
+++ b/drivers/s390/net/qeth.h
@@ -1096,10 +1096,11 @@ qeth_string_to_ipaddr4(const char *buf, 
 {
  int count = 0, rc = 0;
  int in[4];
+ char c;
 
- rc = sscanf(buf, "%d.%d.%d.%d%n",
-      &in[0], &in[1], &in[2], &in[3], &count);
- if (rc != 4  || count<=0)
+ rc = sscanf(buf, "%u.%u.%u.%u%c",
+      &in[0], &in[1], &in[2], &in[3], &c);
+ if (rc != 4 && (rc != 5 || c != '\n'))
   return -EINVAL;
  for (count = 0; count < 4; count++) {
   if (in[count] > 255)
@@ -1123,24 +1124,28 @@ qeth_ipaddr6_to_string(const __u8 *addr,
 static inline int
 qeth_string_to_ipaddr6(const char *buf, __u8 *addr)
 {
- char *end, *start;
+ const char *end, *end_tmp, *start;
  __u16 *in;
         char num[5];
         int num2, cnt, out, found, save_cnt;
         unsigned short in_tmp[8] = {0, };
 
  cnt = out = found = save_cnt = num2 = 0;
-        end = start = (char *) buf;
+        end = start = buf;
  in = (__u16 *) addr;
  memset(in, 0, 16);
-        while (end) {
-                end = strchr(end,':');
+        while (*end) {
+                end = strchr(start,':');
                 if (end == NULL) {
-                        end = (char *)buf + (strlen(buf));
-                        out = 1;
+                        end = buf + strlen(buf);
+   if ((end_tmp = strchr(start, '\n')) != NULL)
+    end = end_tmp;
+   out = 1;
                 }
                 if ((end - start)) {
                         memset(num, 0, 5);
+   if ((end - start) > 4)
+    return -EINVAL;
                         memcpy(num, start, end - start);
    if (!qeth_isxdigit(num))
     return -EINVAL;
@@ -1158,6 +1163,8 @@ qeth_string_to_ipaddr6(const char *buf, 
   }
   start = ++end;
         }
+ if (cnt + save_cnt > 8)
+  return -EINVAL;
         cnt = 7;
  while (save_cnt)
                 in[cnt--] = in_tmp[--save_cnt];
diff --git a/drivers/s390/net/qeth_sys.c b/drivers/s390/net/qeth_sys.c
index 001497b..c1f3187 100644
--- a/drivers/s390/net/qeth_sys.c
+++ b/drivers/s390/net/qeth_sys.c
@@ -1110,12 +1110,12 @@ qeth_parse_ipatoe(const char* buf, enum 
 {
  const char *start, *end;
  char *tmp;
- char buffer[49] = {0, };
+ char buffer[40] = {0, };
 
  start = buf;
  /* get address string */
  end = strchr(start, '/');
- if (!end || (end-start >= 49)){
+ if (!end || (end - start >= 40)){
   PRINT_WARN("Invalid format for ipato_addx/delx. "
       "Use <ip addr>/<mask bits>\n");
   return -EINVAL;
@@ -1127,7 +1127,12 @@ qeth_parse_ipatoe(const char* buf, enum 
  }
  start = end + 1;
  *mask_bits = simple_strtoul(start, &tmp, 10);
-
+ if (!strlen(start) ||
+     (tmp == start) ||
+     (*mask_bits > ((proto == QETH_PROT_IPV4) ? 32 : 128))) {
+  PRINT_WARN("Invalid mask bits for ipato_addx/delx !\n");
+  return -EINVAL;
+ }
  return 0;
 }
 
@@ -1698,11 +1703,16 @@ qeth_create_device_attributes(struct dev
   sysfs_remove_group(&dev->kobj, &qeth_device_attr_group);
   sysfs_remove_group(&dev->kobj, &qeth_device_ipato_group);
   sysfs_remove_group(&dev->kobj, &qeth_device_vipa_group);
+  return ret;
  }
- if ((ret = sysfs_create_group(&dev->kobj, &qeth_device_blkt_group)))
+ if ((ret = sysfs_create_group(&dev->kobj, &qeth_device_blkt_group))){
+  sysfs_remove_group(&dev->kobj, &qeth_device_attr_group);
+  sysfs_remove_group(&dev->kobj, &qeth_device_ipato_group);
+  sysfs_remove_group(&dev->kobj, &qeth_device_vipa_group);
+  sysfs_remove_group(&dev->kobj, &qeth_device_rxip_group);
   return ret;
-
- return ret;
+ }
+ return 0;
 }
 
 void
-- 
1.2.4

