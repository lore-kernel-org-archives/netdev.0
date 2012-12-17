From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH lksctp-tools] sctp_send: fix msg_control data corruption
Date: Mon, 17 Dec 2012 17:32:04 +0100
Message-ID: <1355761924-18948-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Daniel Borkmann <dborkman@redhat.com>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62770 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753961Ab2LQQci (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2012 11:32:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The byte array outcmsg is allocated on the stack within the if-block
that test for a valif sctp_sndrcvinfo structure. There, it is assigned
to outmsg.msg_control, which is later on after leaving the if-block
passed to sendmsg. With this minimal example, the following is
happening:

int main(void)
{
	int fd;
	struct sctp_sndrcvinfo sndinfo;

	fd = socket(AF_INET, SOCK_SEQPACKET, IPPROTO_SCTP);
	assert(fd > 0);

	sctp_send(fd, "bla", strlen("bla") + 1, &sndinfo, 0);

	return 0;
}

strace ./a.out before this patch:

  sendmsg(3, {msg_name(0)=NULL, msg_iov(1)=[{"bla\0", 4}],
          msg_controllen=48, {cmsg_len=3364590592, cmsg_level=0x4003e8
          /* SOL_??? */, cmsg_type=, ...}, msg_flags=0}, 0)

  --> cmsg_len corrupted

strace ./a.out after this patch:

  sendmsg(3, {msg_name(0)=NULL, msg_iov(1)=[{"bla\0", 4}],
          msg_controllen=48, {cmsg_len=48, cmsg_level=0x84 /* SOL_??? */,
                              cmsg_type=, ...}, msg_flags=0}, 0)

This is basically the case since 2005, introduced in the commit 91239acf
("Add sctp_send() API support and testcases"). However, probably this
changed due to a different compiler behaviour / optimization (?), since
it was not visible / affected by older Linux versions.

Cc: Vlad Yasevich <vyasevich@gmail.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 src/lib/sendmsg.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/src/lib/sendmsg.c b/src/lib/sendmsg.c
index 1de592d..9046174 100644
--- a/src/lib/sendmsg.c
+++ b/src/lib/sendmsg.c
@@ -76,6 +76,7 @@ sctp_send(int s, const void *msg, size_t len,
 {
 	struct msghdr outmsg;
 	struct iovec iov;
+	char outcmsg[CMSG_SPACE(sizeof(struct sctp_sndrcvinfo))];
 
 	outmsg.msg_name = NULL;
 	outmsg.msg_namelen = 0;
@@ -86,7 +87,6 @@ sctp_send(int s, const void *msg, size_t len,
 	outmsg.msg_controllen = 0;
 
 	if (sinfo) {	
-		char outcmsg[CMSG_SPACE(sizeof(struct sctp_sndrcvinfo))];
 		struct cmsghdr *cmsg;
 
 		outmsg.msg_control = outcmsg;
-- 
1.7.11.7
