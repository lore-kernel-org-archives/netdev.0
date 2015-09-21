From: subashab@codeaurora.org
Subject: KASan warning with ping call stack
Date: Mon, 21 Sep 2015 21:03:44 -0000
Message-ID: <84e7ce381324f5490a163f1cd62d4e42.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:34129 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752926AbbIUVDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 17:03:46 -0400
Received: from www.codeaurora.org (unknown [198.145.29.65])
	by smtp.codeaurora.org (Postfix) with ESMTP id 828B81403E9
	for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 21:03:44 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are seeing a Kernel address sanitizer (KASan) out of bounds warning
during a stability test. The call stack is as follows -

<3>BUG: KASan: out of bounds on stack in
csum_partial_copy_fromiovecend+0xac/0x36c at addr ffffffc019537d38
<3>Read of size 8 by task Thread-208/7505
<0>page:ffffffbac23d4260 count:0 mapcount:0 mapping:          (null)
index:0x0
<0>flags: 0x0()
<1>page dumped because: kasan: bad access detected
<0>Call trace:
<6>[<ffffffc000089ec4>] dump_backtrace+0x0/0x1c4
<6>[<ffffffc00008a098>] show_stack+0x10/0x1c
<6>[<ffffffc0011b4448>] dump_stack+0x74/0xc8
<6>[<ffffffc00020ee08>] kasan_report_error+0x2b0/0x408
<6>[<ffffffc00020f03c>] kasan_report+0x34/0x40
<6>[<ffffffc00020dfd0>] __asan_load8+0x84/0x90
<6>[<ffffffc000ee47f8>] csum_partial_copy_fromiovecend+0xa8/0x36c
<6>[<ffffffc000ff7a10>] ping_getfrag+0x54/0xf0
<6>[<ffffffc000f9d13c>] __ip_append_data.isra.2+0x88c/0xe5c
<6>[<ffffffc000f9d7dc>] ip_append_data.part.3+0xd0/0xf4
<6>[<ffffffc000f9e804>] ip_append_data+0x18/0x30
<6>[<ffffffc000ff8a18>] ping_v4_sendmsg+0x5d4/0x724
<6>[<ffffffc000fe63a4>] inet_sendmsg+0xe0/0x12c
<6>[<ffffffc000ecfda8>] sock_aio_write+0x1ac/0x1ec
<6>[<ffffffc000218670>] do_sync_write+0xf4/0x14c
<6>[<ffffffc00021954c>] vfs_write+0x128/0x210
<6>[<ffffffc000219f94>] SyS_write+0xa8/0x114
<3>Memory state around the buggy address:
<3>ffffffc019537c00: f1 f1 f1 f1 00 00 00 00 00 00 00 00 00 00 00 00
<3>ffffffc019537c80: 00 00 00 f4 f3 f3 f3 f3 00 00 00 00 00 00 00 00
<3>ffffffc019537d00: f1 f1 f1 f1 00 00 f4 f4 f2 f2 f2 f2 00 00 00 00
<3>                   ^
<3>ffffffc019537d80: 00 00 00 00 00 00 00 f4 f3 f3 f3 f3 00 00 00 00
<3>ffffffc019537e00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 f1 f1

One possible suspect for this was the check for offset and possible
invalid access of an iov, but I am not sure about it.

int csum_partial_copy_fromiovecend(unsigned char *kdata, struct iovec *iov,
                             int offset, unsigned int len, __wsum *csump)
{
      __wsum csum = *csump;
      int partial_cnt = 0, err = 0;

      /* Skip over the finished iovecs */
      while (offset >= iov->iov_len) {  //Problem might occur here
             offset -= iov->iov_len;
             iov++;
     }

The test case for this is unknown as the issue was reported in a stability
run. The hardware is an ARM64 based system with 3.18 kernel.

Any tips to debug this is highly appreciated.

--
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux
Foundation Collaborative Project
