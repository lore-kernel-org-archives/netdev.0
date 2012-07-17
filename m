From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH] cipso: don't follow a NULL pointer when setsockopt() is
 called
Date: Tue, 17 Jul 2012 17:07:47 -0400
Message-ID: <20120717210738.22790.23522.stgit@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63619 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755374Ab2GQVHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 17:07:49 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q6HL7md1017583
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 17:07:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As reported by Alan Cox, and verified by Lin Ming, when a user
attempts to add a CIPSO option to a socket using the CIPSO_V4_TAG_LOCAL
tag the kernel dies a terrible death when it attempts to follow a NULL
pointer (the skb argument to cipso_v4_validate() is NULL when called via
the setsockopt() syscall).

This patch fixes this by first checking to ensure that the skb is
non-NULL before using it to find the incoming network interface.  In
the unlikely case where the skb is NULL and the user attempts to add
a CIPSO option with the _TAG_LOCAL tag we return an error as this is
not something we want to allow.

A simple reproducer, kindly supplied by Lin Ming, although you must
have the CIPSO DOI #3 configure on the system first or you will be
caught early in cipso_v4_validate():

	#include <sys/types.h>
	#include <sys/socket.h>
	#include <linux/ip.h>
	#include <linux/in.h>
	#include <string.h>

	struct local_tag {
		char type;
		char length;
		char info[4];
	};

	struct cipso {
		char type;
		char length;
		char doi[4];
		struct local_tag local;
	};

	int main(int argc, char **argv)
	{
		int sockfd;
		struct cipso cipso = {
			.type = IPOPT_CIPSO,
			.length = sizeof(struct cipso),
			.local = {
				.type = 128,
				.length = sizeof(struct local_tag),
			},
		};

		memset(cipso.doi, 0, 4);
		cipso.doi[3] = 3;

		sockfd = socket(AF_INET, SOCK_DGRAM, 0);
		#define SOL_IP 0
		setsockopt(sockfd, SOL_IP, IP_OPTIONS,
			&cipso, sizeof(struct cipso));

		return 0;
	}

CC: Lin Ming <mlin@ss.pku.edu.cn>
Reported-by: Alan Cox <alan@lxorguk.ukuu.org.uk>
Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 net/ipv4/cipso_ipv4.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index c48adc5..667c1d4 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -1725,8 +1725,10 @@ int cipso_v4_validate(const struct sk_buff *skb, unsigned char **option)
 		case CIPSO_V4_TAG_LOCAL:
 			/* This is a non-standard tag that we only allow for
 			 * local connections, so if the incoming interface is
-			 * not the loopback device drop the packet. */
-			if (!(skb->dev->flags & IFF_LOOPBACK)) {
+			 * not the loopback device drop the packet. Further,
+			 * there is no legitimate reason for setting this from
+			 * userspace so reject it if skb is NULL. */
+			if (skb == NULL || !(skb->dev->flags & IFF_LOOPBACK)) {
 				err_offset = opt_iter;
 				goto validate_return_locked;
 			}
